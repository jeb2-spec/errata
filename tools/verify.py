#!/usr/bin/env python3
"""
verify.py - check this database against its own integrity digest.

No dependencies. Python 3 standard library only. Works offline.

    python3 tools/verify.py [path/to/errata.db]

It recomputes a SHA-256 over a canonical serialisation of every row in
every table, the meta table included, and compares it to the digest
stored inside. A match means nothing has changed since it was built,
disclosures and all.

It does NOT and CANNOT prove that any statement inside is true. Integrity
is not accuracy. That distinction is the point of the whole repository, so
this script refuses to blur it.
"""

import hashlib
import sqlite3
import sys
from pathlib import Path

TABLES = ["principles", "corrections", "lessons", "post_revisions", "documents"]

# An explicit path wins; otherwise verify the copy this repository ships.
# Silently verifying a different file than the one named on the command
# line is worse than erroring, and an earlier version of this script did
# exactly that by ignoring its arguments.
DB = (
    Path(sys.argv[1]).resolve()
    if len(sys.argv) > 1
    else Path(__file__).resolve().parent.parent / "data" / "errata.db"
)


def digest(conn):
    rows = []
    for table in TABLES:
        for row in conn.execute(f"SELECT * FROM {table} ORDER BY 1"):
            values = "\x1f".join("" if v is None else str(v) for v in row)
            rows.append(f"{table}\x1f{values}")

    # meta is covered too. Without it, the disclosures could be rewritten
    # and the file would still verify. Excluded: the digest row, because a
    # hash cannot contain itself, and the two provenance rows built_on and
    # source_commit, which describe the build and not the record.
    for key, value in conn.execute(
        "SELECT key, value FROM meta WHERE key NOT IN ('integrity_sha256', 'built_on', 'source_commit') ORDER BY key"
    ):
        rows.append(f"meta\x1f{key}\x1f{value}")

    return hashlib.sha256("\x1e".join(rows).encode("utf-8")).hexdigest()


def main():
    if not DB.exists():
        print(f"FAIL  database not found at {DB}")
        return 1

    conn = sqlite3.connect(f"file:{DB}?mode=ro", uri=True)
    stored = conn.execute(
        "SELECT value FROM meta WHERE key = 'integrity_sha256'"
    ).fetchone()

    if stored is None:
        print("FAIL  no integrity digest recorded in this database")
        return 1

    stored = stored[0]
    computed = digest(conn)

    print(f"  stored    {stored}")
    print(f"  computed  {computed}")
    print()

    if computed != stored:
        print("FAIL  contents do not match the recorded digest.")
        print("      Something changed after this database was built.")
        return 1

    counts = {t: conn.execute(f"SELECT COUNT(*) FROM {t}").fetchone()[0] for t in TABLES}
    print("OK    contents match the recorded digest.")
    print("      " + ", ".join(f"{n} {t}" for t, n in counts.items()))
    print()
    print("      This proves the contents are unchanged since the build.")
    print("      It does not prove any statement in them is true.")
    print("      Integrity is not accuracy.")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except BrokenPipeError:
        # Someone piped us into head or less. Not an error, and a tool meant
        # to be copied should not hand its new owner a traceback.
        sys.stderr.close()
        sys.exit(0)
