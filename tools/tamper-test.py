#!/usr/bin/env python3
"""
tamper-test.py - test the seal's promise instead of reading its description.

No dependencies. Python 3 standard library only. Works offline.

    python3 tools/tamper-test.py

Proposed by an outside reader who had inspected this repository through a
code-reading connector and said plainly that they could not execute anything,
so they would not pretend to have run the verifier. They were right that
inspection is not a test, and right about which test was missing.

Three checks, in increasing order of what they prove.

  1. THE VERIFIER REJECTS A CHANGED RECORD.
     One character in one row of a working copy is altered and the verifier
     is run against that copy. It must fail. A seal that only ever passes is
     decoration.

  2. THE VERIFIER STILL ACCEPTS THE REAL ONE.
     Run against the shipped file, untouched. It must pass. Check 1 alone
     would be satisfied by a verifier that rejects everything.

  3. THE DIGEST IS REPRODUCIBLE FROM THE PUBLISHED TEXT, BY OTHER CODE.
     This is the one that matters and the only one that is not circular.
     The digest is recomputed here from data/errata.sql, the plain-text dump,
     by a parser written for this file and sharing no code with the builder
     or with verify.py. Reading the same database with the same library
     proves the library is consistent with itself. Rebuilding the number
     from the text proves the published bytes carry the record, and that a
     stranger with no SQLite and no trust in us can arrive at it alone.

Exit status is 0 only when all three pass.
"""

import hashlib
import re
import shutil
import sqlite3
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DB = ROOT / "data" / "errata.db"
SQL = ROOT / "data" / "errata.sql"
VERIFY = ROOT / "tools" / "verify.py"

TABLES = ["principles", "corrections", "detections", "lessons", "post_revisions", "documents"]
EXCLUDED_META = {"integrity_sha256", "built_on", "source_commit"}


def run_verify(path):
    """Return (ok, first_meaningful_line) from the shipped verifier."""
    p = subprocess.run(
        [sys.executable, str(VERIFY), str(path)],
        capture_output=True, text=True,
    )
    line = next((l.strip() for l in p.stdout.splitlines() if l.strip().startswith(("OK", "FAIL"))), "")
    return p.returncode == 0, line


def parse_sql(text):
    """
    Parse the INSERT statements of the plain-text dump.

    Deliberately hand-rolled rather than handed to sqlite3: the point of
    check 3 is to reach the digest without the library that produced it.
    Values are SQL string literals with '' for an embedded quote, bare NULL,
    or bare numbers. Prose values contain newlines and commas, so this scans
    characters rather than lines.

    TWO MISTAKES THIS FUNCTION MADE ON ITS FIRST RUN, KEPT AS A WARNING.
    It searched the whole file for "INSERT INTO" with a regular expression,
    which also matches that phrase inside a stored document and invents a
    row that is not there. And it stripped whitespace from string values,
    which silently edits any prose that begins or ends with a space or a
    newline. Both produced a digest that did not match, and the first guess
    was that the record was wrong. The record was fine. A new instrument's
    first disagreement is usually the instrument.
    """
    rows = {}
    i, n = 0, len(text)
    while i < n:
        c = text[i]
        if c == "'":                      # skip a string literal at top level
            i += 1
            while i < n:
                if text[i] == "'":
                    if i + 1 < n and text[i + 1] == "'":
                        i += 2
                        continue
                    i += 1
                    break
                i += 1
            continue
        if not text.startswith("INSERT INTO ", i):
            i += 1
            continue
        m = re.compile(r"INSERT INTO (\w+) VALUES \(").match(text, i)
        if not m:
            i += 1
            continue
        table = m.group(1)
        i = m.end()
        values = []
        while i < n:
            while i < n and text[i] in " \t\r\n":
                i += 1
            if text[i] == "'":            # a quoted value: never trimmed
                i += 1
                buf = []
                while i < n:
                    if text[i] == "'":
                        if i + 1 < n and text[i + 1] == "'":
                            buf.append("'")
                            i += 2
                            continue
                        i += 1
                        break
                    buf.append(text[i])
                    i += 1
                values.append("".join(buf))
            else:                          # a bare token: NULL or a number
                buf = []
                while i < n and text[i] not in ",)":
                    buf.append(text[i])
                    i += 1
                token = "".join(buf).strip()
                values.append("" if token == "NULL" else token)
            while i < n and text[i] in " \t\r\n":
                i += 1
            if i < n and text[i] == ",":
                i += 1
                continue
            if i < n and text[i] == ")":
                i += 1
            break
        rows.setdefault(table, []).append(values)
    return rows


def digest_from_sql(text):
    rows = parse_sql(text)
    canonical = []
    for table in TABLES:
        # Sort the serialised rows as UTF-8 bytes. This needs no database and
        # no knowledge of any query plan, which is the whole point: the order
        # is a property of the published text. The first run of this file used
        # the old rule, ordering on the first column only, and disagreed with
        # the stored digest by two rows of `detections`, whose first column is
        # not unique. That disagreement was the defect, not the parser.
        serialised = [table + "\x1f" + "\x1f".join(row) for row in rows.get(table, [])]
        serialised.sort(key=lambda s: s.encode("utf-8"))
        canonical.extend(serialised)
    for key, value in sorted((r[0], r[1]) for r in rows.get("meta", [])):
        if key in EXCLUDED_META:
            continue
        canonical.append("meta\x1f" + key + "\x1f" + value)
    return hashlib.sha256("\x1e".join(canonical).encode("utf-8")).hexdigest(), canonical


def stored_digest(text):
    rows = parse_sql(text)
    for key, value in ((r[0], r[1]) for r in rows.get("meta", [])):
        if key == "integrity_sha256":
            return value
    return None


def main():
    for path in (DB, SQL, VERIFY):
        if not path.exists():
            print(f"FAIL  missing {path}")
            return 1

    results = []

    # 1. a changed record must be rejected
    with tempfile.TemporaryDirectory() as tmp:
        copy = Path(tmp) / "errata.db"
        shutil.copy2(DB, copy)
        conn = sqlite3.connect(copy)
        target = conn.execute("SELECT id, who_it_cost FROM corrections ORDER BY id LIMIT 1").fetchone()
        conn.execute(
            "UPDATE corrections SET who_it_cost = ? WHERE id = ?",
            (target[1] + ".", target[0]),
        )
        conn.commit()
        conn.close()
        ok, line = run_verify(copy)
        rejected = not ok
        results.append(("a one character change is rejected", rejected))
        print(f"1. altered corrections.who_it_cost on row {target[0]!r}")
        print(f"   verifier said: {line or '(no verdict line)'}")
        print(f"   {'PASS' if rejected else 'FAIL'}  the seal caught it\n")

    # 2. the untouched record must still pass
    ok, line = run_verify(DB)
    results.append(("the shipped record still verifies", ok))
    print("2. the shipped file, untouched")
    print(f"   verifier said: {line or '(no verdict line)'}")
    print(f"   {'PASS' if ok else 'FAIL'}  the seal is not simply refusing everything\n")

    # 3. the digest rebuilt from the published text by unrelated code
    text = SQL.read_text(encoding="utf-8")
    computed, canonical = digest_from_sql(text)
    stored = stored_digest(text)
    match = computed == stored
    results.append(("the digest is reproducible from the text", match))
    print("3. recomputed from data/errata.sql by this file's own parser")
    print(f"   {len(canonical)} canonical rows")
    print(f"   stored    {stored}")
    print(f"   computed  {computed}")
    print(f"   {'PASS' if match else 'FAIL'}  the published text carries the record\n")

    failed = [name for name, ok in results if not ok]
    if failed:
        for name in failed:
            print(f"FAILED: {name}")
        return 1
    print("All three checks passed.")
    print("This proves the seal detects change and that the published text")
    print("reproduces the digest without our code. It proves nothing about")
    print("whether any sentence in the record is true. Integrity is not accuracy.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
