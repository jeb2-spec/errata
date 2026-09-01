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

The proof ships beside the data: `data/errata.db.ots`.

## Check it yourself

```bash
pip install opentimestamps-client
ots verify data/errata.db.ots
```

While a stamp is still waiting for Bitcoin aggregation (usually less than a
day), `ots info data/errata.db.ots` shows the pending commitments from the
calendar servers. After aggregation, `ots upgrade data/errata.db.ots`
completes the proof and `ots verify` names the Bitcoin block and date.

## The anchor log

| stamped (UTC) | file sha256 | internal digest | status |
| --- | --- | --- | --- |
| 2026-09-01 | `2fa4a7cf8b51b4acc1ba761f9a9c29935bdf7781edd68df7c1d513e98b940e1f` | `17486ea44776847b022e6c158ef31dafd431d1fd5d05e37c22dffc22cc15c7c9` | pending aggregation |

Two hashes, on purpose. The internal digest is what `tools/verify.py`
recomputes over the rows; the file sha256 is what OpenTimestamps binds to
Bitcoin, and it covers the whole file, internal digest included.

## What this still cannot do

An anchor proves when a file existed. It does not prove any sentence in
the file is true. Integrity is not accuracy, here as everywhere in this
repository.
