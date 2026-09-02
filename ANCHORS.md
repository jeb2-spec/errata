# Anchors

The verifier in this repository proves the record has not changed since we
built it. It cannot prove we did not rebuild it and quietly re-seal. We
build the file, we hash it, we publish it, so a seal we make ourselves
proves internal consistency and nothing more.

An anchor closes that gap: the record's fingerprint, witnessed somewhere
outside our reach.

## How this record is anchored

Each published build of `data/errata.db` is stamped with
[OpenTimestamps](https://opentimestamps.org). The stamp submits the file's
fingerprint to several independent calendar servers, which aggregate it
into the Bitcoin blockchain. Once that happens, the claim "this exact file
existed by this date" is held by a ledger that nobody, including us, can
rewrite. Rewriting our history would require rewriting Bitcoin's.

The current build's proof ships beside the data as `data/errata.db.ots`.
Every rebuild changes the file, so a rebuild moves the previous stamp to
`data/anchors/<built>-<sha8>.ots`, named for the build it proves, and the
table below says where each build's proof is. A stamp is never deleted: the
prior state survives, which is the only thing that tells patching from
falsification.

## Check it yourself

```bash
pip install opentimestamps-client
ots verify data/errata.db.ots                       # the current build, once stamped
ots verify data/anchors/2026-08-31-2fa4a7cf.ots     # the first build, against its own file
```

A stamp verifies against the file it was made for. To check an archived
stamp, check out the commit that carried that build, or compare the stamp's
file hash with the table below.

While a stamp is still waiting for Bitcoin aggregation (usually less than a
day), `ots info` shows pending commitments from the calendar servers rather
than a block. After aggregation, `ots upgrade` completes the proof and the
stamp names the blocks itself.

**A note on how strong this is, and is not.** Once a stamp is confirmed, the
record's fingerprint sits in Bitcoin and we cannot reach it. That makes a
later rewrite **detectable**. It does not make one impossible: we could still
alter the file, and anyone who checked the stamp would simply find that it no
longer matches. The anchor buys detection by a stranger, not immutability,
and the difference matters enough to say plainly. If you see this project
described as having made its history unchangeable, that description is
generous beyond what we claim.

## The anchor log

| built | file sha256 | internal digest | proof | status |
| --- | --- | --- | --- | --- |
| 2026-08-31 | `2fa4a7cf8b51b4acc1ba761f9a9c29935bdf7781edd68df7c1d513e98b940e1f` | `17486ea44776847b022e6c158ef31dafd431d1fd5d05e37c22dffc22cc15c7c9` | `data/anchors/2026-08-31-2fa4a7cf.ots` | **confirmed in Bitcoin.** Aggregated 2026-09-02 into blocks **965029**, **965045** and **965063**, one per calendar |
| 2026-09-01 | `c7cc43849ea00b1fe0958fe43b360d4da4406bfdbae87156218c93f86997be78` | `69671f41fb6006a14e5df6643f42cfcc7b576e9fe0ad489b01cade265fc70b1d` | `data/anchors/2026-09-01-c7cc4384.ots` | debt paid 2026-09-02. Stamped against the committed file recovered from commit `31d5cb4`, never a rebuild. Awaiting aggregation |
| 2026-09-02 | `11b9c59d8b3d6c667eb3921f2544c4bee700d0a4e444306d3fc12d6f6619ccc7` | `96720d76cc36cc0f365db18ca06f2751913f71ec7c3c9e6b0e6b0653738e2609` | `data/errata.db.ots` | stamped 2026-09-02. Awaiting aggregation |

Two hashes, on purpose. The internal digest is what `tools/verify.py`
recomputes over the rows; the file sha256 is what OpenTimestamps binds to
Bitcoin, and it covers the whole file, internal digest included.

## What this still cannot do

An anchor proves when a file existed. It does not prove any sentence in
the file is true. Integrity is not accuracy, here as everywhere in this
repository.
