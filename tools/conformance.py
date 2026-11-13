#!/usr/bin/env python3
"""
conformance.py - print this record's shape, whether its author likes it or not.

No dependencies. Python 3 standard library only. Needs no network.

    python3 tools/conformance.py

SPEC.md section 6 specifies a conformance readout and then says: "No such
tool exists yet. What follows specifies what one must print... Until a tool
does, section 6 is a requirement and not a description." This is that tool.
It prints the seven items section 6 lists, in that order.

Conformance here is mechanical. It is checked by printing, not by judging.
There is no certificate, no score, and no pass mark, because a body that
approves other people's records is a reputation system, which is the thing
this format exists to avoid. What the tool does is make a record's shape
legible so a reader can decide. A record where every detector is the author
shows exactly that. One that has never had an entry cost its authors
anything shows that too.

The shape never decides the exit code. A record can be fully conformant and
still be a bad record, and this script has no opinion about that. What can
fail is the machinery: the digest not recomputing, the tamper test not
rejecting a changed file, a proof that cannot be read or that does not
attest the build the log says it does. Those print FAIL and exit non-zero.
Everything else is printed for a reader to weigh, and weighing it is not
this tool's job.
"""

import os
import re
import sqlite3
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TOOLS = ROOT / "tools"
DB = ROOT / "data" / "errata.db"
ANCHORS = ROOT / "ANCHORS.md"

CONTENT_TABLES = ["principles", "corrections", "detections", "lessons", "post_revisions", "documents"]

# A defect's stage is the earliest stage at which anybody caught it, so a
# defect found after publication and again in review later still counts as
# having reached a reader. Same ordering the measurement paper uses.
STAGE_ORDER = {"pre-publication": 0, "conversation": 1, "post-publication": 2}


def rule(title):
    print()
    print(title)
    print("-" * len(title))


def run_tool(name, *args):
    """Run one of this repository's own tools and report its verdict."""
    path = TOOLS / name
    if not path.exists():
        return None, f"{name} is not in this repository"
    proc = subprocess.run(
        [sys.executable, str(path), *args], capture_output=True, text=True
    )
    return proc.returncode == 0, (proc.stdout + proc.stderr).strip()


def check_lines(text):
    """The PASS/FAIL lines a tool printed, which are its actual verdicts."""
    return [l.strip() for l in text.splitlines() if l.strip().startswith(("PASS", "FAIL"))]


# ── 1, 2, 3. the machinery ────────────────────────────────────────────────
# Delegated to the tools that already make these claims rather than
# reimplemented here. A second implementation of the digest inside this
# repository would be a second definition of it, and the record has been
# bitten before by the same number being kept in more than one place.

def machinery():
    rule("1. Does the digest recompute?")
    ok, out = run_tool("verify.py")
    if ok is None:
        print(f"  SKIP  {out}")
    else:
        for line in out.splitlines():
            if line.strip().startswith(("stored", "computed", "OK", "FAIL")):
                print("  " + line.strip())
        print(f"  {'PASS' if ok else 'FAIL'}")

    rule("2 and 3. Does it fail on a changed byte, and does the published text reproduce it?")
    print("  tamper-test.py alters one character in a throwaway copy and requires")
    print("  the verifier to reject it, requires the shipped file to pass, and")
    print("  rebuilds the digest from data/errata.sql with a parser that shares no")
    print("  code with the builder. The third check is the one that is not circular.")
    ok, out = run_tool("tamper-test.py")
    if ok is None:
        print(f"  SKIP  {out}")
    else:
        for line in check_lines(out):
            print("  " + line)
        print(f"  {'PASS' if ok else 'FAIL'}  all three checks" if ok else "  FAIL")
    return ok


# ── 4. entries, and how many reached a reader ─────────────────────────────

def entries(conn):
    rule("4. Entries, and the share that reached a reader before anyone caught them")

    counts = {t: conn.execute(f"SELECT COUNT(*) FROM {t}").fetchone()[0] for t in CONTENT_TABLES}
    for table, n in counts.items():
        print(f"  {table:<16} {n}")

    stages = {}
    for cid, stage in conn.execute("SELECT correction_id, stage FROM detections"):
        if cid not in stages or STAGE_ORDER.get(stage, 9) < STAGE_ORDER.get(stages[cid], 9):
            stages[cid] = stage

    total = len(stages)
    escaped = sum(1 for s in stages.values() if s == "post-publication")
    print()
    if not total:
        print("  no detections recorded, so no escape rate can be computed")
        return
    print(f"  defects with a recorded detection   {total}")
    print(f"  first caught after publication      {escaped}   ({escaped / total:.1%})")
    for stage in sorted(STAGE_ORDER, key=STAGE_ORDER.get):
        n = sum(1 for s in stages.values() if s == stage)
        if n:
            print(f"    {stage:<20} {n}")

    # The number every reader should discount, said here rather than left to
    # be inferred. A defect stopped before publication never becomes a row,
    # so this rate measures where review sits in the pipeline at least as
    # much as it measures how often the work is wrong.
    orphans = counts["corrections"] - total
    if orphans:
        print(f"  corrections with no detection row   {orphans}")
    print()
    print("  Read this as an escape rate for defects that became entries. Anything")
    print("  a check stopped before publication is in no table here, so moving")
    print("  review earlier lowers this number without changing how often the")
    print("  work is actually wrong.")


# ── 5. detectors, and what each found on its own ──────────────────────────

def detectors(conn):
    rule("5. Detectors, and how many entries each found independently")
    rows = list(conn.execute("""
        SELECT detector,
               SUM(independent) AS independent,
               SUM(CASE WHEN independent = 0 THEN 1 ELSE 0 END) AS triggered,
               COUNT(*) AS total
        FROM detections GROUP BY detector
        ORDER BY independent DESC, detector
    """))
    if not rows:
        print("  no detections recorded")
        return
    print(f"  {'detector':<22}{'independent':>12}{'triggered':>11}{'total':>7}")
    for detector, independent, triggered, total in rows:
        print(f"  {detector:<22}{independent:>12}{triggered:>11}{total:>7}")
    print()
    print("  Independent means the detector looked without being told what to look")
    print("  for. Triggered means it only looked because somebody else voiced")
    print("  doubt, which is not an independent find and is not counted as one.")

    # SPEC 3.6 wants one row per detector INSTANCE. This record keys
    # detections by (correction, detector) where detector is a role label, so
    # two different reviewers of the same role collapse into one row. That
    # destroys exactly the overlap signal an estimate of the unfound needs,
    # and a readout that printed the table without saying so would be
    # flattering the record it is supposed to describe.
    pairs = {}
    for detector, in conn.execute("SELECT DISTINCT detector FROM detections"):
        pairs[detector] = {
            cid for cid, in conn.execute(
                "SELECT correction_id FROM detections WHERE detector = ? AND independent = 1", (detector,)
            )
        }
    names = sorted(pairs)
    best = 0
    for i, a in enumerate(names):
        for b in names[i + 1:]:
            best = max(best, len(pairs[a] & pairs[b]))
    print()
    print(f"  Best overlap between any two independent detectors: {best}")
    if best == 0:
        print("  With no overlap, the number of defects nobody found is not estimable")
        print("  from these rows, and this tool will not print a figure for it.")
    print("  Note the construction: detector is a role label under a primary key of")
    print("  (correction, detector), so two different reviewers of the same role")
    print("  cannot both be stored. Part of any overlap reported here, or missing")
    print("  from it, is that schema and not the world.")


# ── 6. every build, and its anchor ────────────────────────────────────────

def anchors():
    rule("6. Anchor status of every build, including any that are owed")

    if not ANCHORS.exists():
        print("  SKIP  ANCHORS.md is not in this repository")
        return None

    # Rows of the published log: | built | file sha256 | internal digest | proof | status |
    rows = []
    for line in ANCHORS.read_text(encoding="utf-8").splitlines():
        if not line.startswith("| 2026"):
            continue
        cells = [c.strip() for c in line.strip().strip("|").split(" | ")]
        if len(cells) < 5:
            continue
        built, file_sha, _digest, proof, status = cells[:5]
        rows.append({
            "built": built,
            "sha": file_sha.strip("`"),
            "proof": proof.strip("`"),
            "status": status,
        })

    if not rows:
        print("  no build rows found in ANCHORS.md")
        return None

    try:
        reader = _load_anchor_info()
    except Exception as exc:
        print(f"  SKIP  tools/anchor-info.py could not be loaded: {exc}")
        return None

    confirmed = pending = owed = missing = unreadable = 0
    mismatched = []
    for row in rows:
        # Derive the owed state from whether a proof exists, never from the
        # status prose. The first version of this line tested for the word
        # "owed" in that prose and matched "showed" and "followed", which is
        # the same shape as every hand-kept claim this record has had to
        # correct: a check that matches more than it means.
        named = row["proof"] if row["proof"].endswith(".ots") else ""
        path = ROOT / named if named else None
        if path is None:
            owed += 1
            print(f"  {row['built']:<44} OWED       the log names no proof for this build")
            continue
        if not path.exists():
            # Not the same thing as an owed anchor. A build may ship unstamped
            # and say so, and SPEC section 5 allows exactly that. A row that
            # names a proof file which is not in the repository is the log
            # being wrong, and this record has already had to correct one:
            # a-stamp-the-text-pointed-at, where published lines sent readers
            # to a proof that did not exist.
            missing += 1
            print(f"  {row['built']:<44} MISSING    the log points at {named}, which is not here")
            continue
        try:
            digest, found, trailing = reader.read_proof(path)
        except Exception as exc:
            unreadable += 1
            print(f"  {row['built']:<44} UNREADABLE  {exc}")
            continue
        blocks = [(k, v) for k, v, _ in found if k in ("bitcoin", "litecoin", "ethereum")]
        state = "confirmed" if blocks else "pending"
        confirmed += bool(blocks)
        pending += not blocks
        note = ", ".join(f"{k} {v}" for k, v in blocks) if blocks else "awaiting aggregation"
        flag = ""
        if digest.hex() != row["sha"]:
            # The proof does not attest the file the log says this build is.
            mismatched.append(row["built"])
            flag = "  SHA DOES NOT MATCH THE LOG"
        if trailing:
            flag += f"  ({trailing} unread bytes)"
        print(f"  {row['built']:<44} {state:<9}  {note}{flag}")

    print()
    tail = "".join(
        f", {n} {label}" for n, label in
        ((missing, "pointing at a proof that is not here"), (unreadable, "unreadable")) if n
    )
    print(f"  {len(rows)} builds: {confirmed} confirmed, {pending} pending, {owed} owed{tail}")
    if owed:
        print("  An owed anchor is disclosed, not broken. A build made where the")
        print("  calendars cannot be reached ships unstamped and says so, rather")
        print("  than shipping a proof of a different file.")

    # The published log states this same split in a sentence. Two independent
    # routes to one number is the check worth running; reciting either alone
    # is not.
    claim = re.search(
        r"\*\*([A-Za-z\- ]+?) of these ([A-Za-z\- ]+?) builds are confirmed in Bitcoin, ([A-Za-z\- ]+?) are pending\.\*\*",
        ANCHORS.read_text(encoding="utf-8"),
    )
    if claim:
        print(f"  ANCHORS.md says: {claim.group(1)} of {claim.group(2)} confirmed, {claim.group(3)} pending")
        print("  Compare that sentence with the counts above. They are derived by")
        print("  different routes and are supposed to agree.")
    if mismatched:
        print(f"  FAIL  {len(mismatched)} proof(s) do not attest the sha the log records: {', '.join(mismatched)}")
    if missing:
        print(f"  FAIL  {missing} row(s) name a proof file this repository does not ship")
    print()
    print("  An anchor buys detection by a stranger, not immutability. The file can")
    print("  still be altered; anyone who checks will find the proof no longer")
    print("  matches. Run tools/anchor-info.py for the block heights and merkle")
    print("  roots to compare against any explorer you like.")
    return not (mismatched or unreadable or missing)


def _load_anchor_info():
    """Load anchor-info.py, whose filename is not importable as a module name."""
    import importlib.util
    spec = importlib.util.spec_from_file_location("anchor_info", TOOLS / "anchor-info.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


# ── 7. what the record says it does not prove ─────────────────────────────

def disclaimers(conn):
    rule("7. What the record says it does not prove")
    keys = [k for k, in conn.execute("SELECT key FROM meta ORDER BY key")
            if k.startswith("disclosure_") or k == "integrity_note"]
    if not keys:
        print("  the record states no limits on itself, which is itself the finding")
        return
    for key in keys:
        value = conn.execute("SELECT value FROM meta WHERE key = ?", (key,)).fetchone()[0]
        print(f"  {key}")
        for line in _wrap(value, 74):
            print(f"    {line}")
        print()
    print("  Every one of these is inside the digest. A seal that did not cover a")
    print("  record's own disclosures would be decoration, because the disclosure")
    print("  could be edited and the file would still verify.")


def _wrap(text, width):
    words, line, out = text.split(), "", []
    for word in words:
        if len(line) + len(word) + 1 > width:
            out.append(line)
            line = word
        else:
            line = f"{line} {word}".strip()
    if line:
        out.append(line)
    return out


def main():
    if not DB.exists():
        print(f"FAIL  no database at {DB}")
        return 1

    print()
    print("errata conformance readout")
    print("==========================")
    print(f"record: {os.path.relpath(DB, ROOT)}")
    print()
    print("This prints what SPEC.md section 6 requires a conformance tool to print.")
    print("It is a readout, not a grade. Nothing here is a certificate and nothing")
    print("compels anybody to run it.")

    conn = sqlite3.connect(f"file:{DB}?mode=ro", uri=True)
    sound = machinery()
    entries(conn)
    detectors(conn)
    anchors_sound = anchors()
    disclaimers(conn)

    rule("What this readout does not establish")
    print("  It does not show that any statement in the record is true. Integrity")
    print("  is not accuracy.")
    print()
    print("  It does not show the record is complete. The corrections table holds")
    print("  the defects its authors know about, and by construction it can never")
    print("  hold the ones they do not. The record claims completeness of an ENTRY,")
    print("  meaning a passage cut from a page is reproduced here rather than")
    print("  summarised. It does not claim completeness of the SET.")
    print()
    print("  Part of this record is derived from version-control history, so it")
    print("  cannot be forgotten. That derivation enumerates the files it knows")
    print("  about; anything outside that enumeration is invisible to it. And the")
    print("  history it derives from is not public, so a reader cannot re-derive")
    print("  the revision table and check it. For a reader, that half currently")
    print("  rests on the author's word exactly as much as the entered half does.")
    print()

    # The shape items never touch this. There is no pass mark for shape, and a
    # record that shows every detector is its author is being described, not
    # graded. What decides the exit code is the machinery: the digest, the
    # tamper test, and whether every proof reads and attests the build the log
    # says it does.
    #
    # An earlier version of this function returned 0 unconditionally while
    # printing FAIL above it, so a scripted reader saw success on a record
    # whose seal did not recompute. That is a check that could not go red,
    # which is the failure this repository exists to make visible. It was
    # caught by running the tool against a deliberately altered copy rather
    # than by re-reading it.
    broken = [name for name, good in
              (("the seal or the tamper test", sound), ("the anchor log", anchors_sound))
              if good is False]
    if broken:
        print(f"FAIL  machinery: {' and '.join(broken)}.")
        print("      The shape above is still printed, because a reader should see")
        print("      what the record claims even when a check on it fails.")
        return 1
    # A check that could not run is not a check that passed. Saying "sound"
    # over an item nobody inspected is the same overclaim as a green light
    # wired to nothing, so the summary names its own coverage.
    skipped = [name for name, good in
               (("the seal or the tamper test", sound), ("the anchor log", anchors_sound))
               if good is None]
    if skipped:
        print(f"OK    machinery sound, except that {' and '.join(skipped)} could not be")
        print("      checked here. Not inspected is not the same as passed.")
    else:
        print("OK    machinery sound. The shape above is a description, not a grade.")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except BrokenPipeError:
        sys.stderr.close()
        sys.exit(0)
