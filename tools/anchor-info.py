#!/usr/bin/env python3
"""
anchor-info.py - read this record's timestamp proofs without installing anything.

No dependencies. Python 3 standard library only. Works offline.

    python3 tools/anchor-info.py                     # every proof in this repo
    python3 tools/anchor-info.py data/errata.db.ots  # one proof

SPEC.md section 5 requires that an anchor be checkable by the reader you
actually have: "Publish a path a doubter can finish on the device they are
arguing on, without installing anything, ending somewhere neither of you
controls." Until this script existed the published path failed that test,
because reading a block height out of a proof needed the OpenTimestamps
client installed first. That gap was named in SPEC.md section 5 rather than
left for a reader to run into. This closes it.

An .ots proof is a chain of operations from the file's SHA-256 to a value
that a Bitcoin block committed to. This script walks that chain and prints
where it lands. Two lines matter per attestation: the block height, and the
merkle root in the byte order block explorers print. Look the block up
anywhere you like and compare the merkle root to the one below.

WHAT THIS PROVES, EXACTLY. It proves the proof file commits the file's hash
to that merkle root. It does not check Bitcoin, because a script in our
repository checking our claim against our copy of anything would be us
checking us. The last step is deliberately yours, and it ends somewhere
neither of us controls. Nothing here proves a statement in the record is
true. Integrity is not accuracy.
"""

import glob
import hashlib
import os
import sys
from pathlib import Path

MAGIC = b"\x00OpenTimestamps\x00\x00Proof\x00\xbf\x89\xe2\xe8\x84\xe8\x92\x94"

# Attestation tags, from the OpenTimestamps format. An unrecognised tag is
# reported as unknown rather than skipped: a proof that anchors somewhere we
# cannot name is information, and swallowing it would be the same failure as
# a gate that only inspects the case it was written for.
ATTESTATIONS = {
    bytes.fromhex("0588960d73d71901"): "bitcoin",
    bytes.fromhex("06869a0d73d71b45"): "litecoin",
    bytes.fromhex("30fe8087b5c7ead7"): "ethereum",
    bytes.fromhex("83dfe30d2ef90c8e"): "pending",
}

DIGEST_LEN = {0x02: 20, 0x03: 20, 0x08: 32, 0x67: 32}
ROOT = Path(__file__).resolve().parent.parent


class Reader:
    """Byte reader for the proof format. Varints are base 128, little end first."""

    def __init__(self, data):
        self.data, self.pos = data, 0

    def byte(self):
        value = self.data[self.pos]
        self.pos += 1
        return value

    def take(self, n):
        if self.pos + n > len(self.data):
            raise ValueError("proof ended mid-value")
        value = self.data[self.pos:self.pos + n]
        self.pos += n
        return value

    def varuint(self):
        value = shift = 0
        while True:
            b = self.byte()
            value |= (b & 0x7F) << shift
            if not b & 0x80:
                return value
            shift += 7

    def varbytes(self):
        return self.take(self.varuint())


def apply_op(reader, tag, msg):
    """Run one operation over the running message."""
    if tag == 0xF0:
        return msg + reader.varbytes()
    if tag == 0xF1:
        return reader.varbytes() + msg
    if tag == 0xF2:
        return msg[::-1]
    if tag == 0xF3:
        return msg.hex().encode()
    if tag == 0x08:
        return hashlib.sha256(msg).digest()
    if tag == 0x02:
        return hashlib.sha1(msg).digest()
    if tag == 0x03:
        # Some Python builds ship without ripemd160. Say which op could not
        # run rather than reporting a proof unreadable for no stated reason.
        try:
            h = hashlib.new("ripemd160")
        except ValueError:
            raise ValueError("this Python has no ripemd160, so one branch of this proof cannot be walked")
        h.update(msg)
        return h.digest()
    raise ValueError(f"unsupported operation 0x{tag:02x}")


def walk(reader, msg, out):
    """Collect every attestation in the proof tree below this message."""
    def step(tag):
        if tag == 0x00:
            kind = ATTESTATIONS.get(reader.take(8), None)
            payload = Reader(reader.varbytes())
            if kind == "pending":
                out.append((kind, payload.varbytes().decode("utf-8", "replace"), msg))
            elif kind is None:
                out.append(("unknown", None, msg))
            else:
                out.append((kind, payload.varuint(), msg))
        else:
            walk(reader, apply_op(reader, tag, msg), out)

    tag = reader.byte()
    while tag == 0xFF:
        step(reader.byte())
        tag = reader.byte()
    step(tag)


def read_proof(path):
    """Return (file digest, attestations, trailing byte count)."""
    reader = Reader(Path(path).read_bytes())
    if reader.take(len(MAGIC)) != MAGIC:
        raise ValueError("not an OpenTimestamps proof")
    reader.varuint()  # format version
    op = reader.byte()
    if op not in DIGEST_LEN:
        raise ValueError(f"unknown digest operation 0x{op:02x}")
    digest = reader.take(DIGEST_LEN[op])
    found = []
    walk(reader, digest, found)
    # Bytes left over mean this script and the file disagree about the format,
    # and a parser that quietly stops early would report a subset of the
    # attestations as though it were all of them.
    return digest, found, len(reader.data) - reader.pos


def sha256_of(path):
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def stamped_file_for(proof):
    """The file a proof is about, when this repository still ships it."""
    name = os.path.basename(proof)
    if name == "errata.db.ots":
        return ROOT / "data" / "errata.db"
    return None  # archived proofs name a build, not a file still on disk


def report(proof):
    print(f"{os.path.relpath(proof, ROOT)}")
    try:
        digest, found, trailing = read_proof(proof)
    except Exception as exc:
        print(f"  UNREADABLE  {exc}")
        return False

    print(f"  {'stamped file sha256':<21} {digest.hex()}")

    subject = stamped_file_for(proof)
    if subject and subject.exists():
        actual = sha256_of(subject)
        match = actual == digest.hex()
        print(f"  {'file on disk':<21} {actual}  {'match' if match else 'DOES NOT MATCH'}")
        if not match:
            # A proof beside a file it no longer matches is worse than no
            # proof, which is why the record archives rather than overwrites.
            print("  WARNING: this proof is not a proof of the file sitting beside it.")

    if trailing:
        print(f"  WARNING: {trailing} unread byte(s) after the proof; this reader may be out of date.")

    blocks = [(k, v, m) for k, v, m in found if k in ("bitcoin", "litecoin", "ethereum")]
    waiting = [v for k, v, _ in found if k == "pending"]

    for kind, height, msg in blocks:
        print(f"  {kind + ' block':<21} {height}")
        print(f"  {'merkle root':<21} {msg[::-1].hex()}")
        if kind == "bitcoin":
            print(f"  {'compare at':<21} https://blockstream.info/block-height/{height}")

    if waiting:
        print(f"  {'awaiting aggregation':<21} {len(waiting)} calendar(s): {', '.join(sorted(waiting))}")
    if not blocks:
        print("  no block attestation yet. This stamp is pending, not missing.")
    print()
    return True


def main():
    if len(sys.argv) > 1:
        proofs = sys.argv[1:]
    else:
        proofs = [str(ROOT / "data" / "errata.db.ots")] + sorted(
            glob.glob(str(ROOT / "data" / "anchors" / "*.ots"))
        )
        proofs = [p for p in proofs if os.path.exists(p)]

    if not proofs:
        print("no proof files found")
        return 1

    print()
    ok = all([report(p) for p in proofs])
    print("Each merkle root above is the value the proof commits to, in the byte")
    print("order explorers print. Look the block up anywhere and compare the two")
    print("strings. That last step is yours on purpose: it is the only part of")
    print("this path that does not run on our code or our data.")
    print()
    print("This shows where the record's fingerprint was witnessed.")
    print("It does not show that anything the record says is true.")
    return 0 if ok else 1


if __name__ == "__main__":
    try:
        sys.exit(main())
    except BrokenPipeError:
        sys.stderr.close()
        sys.exit(0)
