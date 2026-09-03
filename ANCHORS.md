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
| 2026-09-01 | `c7cc43849ea00b1fe0958fe43b360d4da4406bfdbae87156218c93f86997be78` | `69671f41fb6006a14e5df6643f42cfcc7b576e9fe0ad489b01cade265fc70b1d` | `data/anchors/2026-09-01-c7cc4384.ots` | **confirmed in Bitcoin**, block **965223**, checked 2026-09-02. The debt paid on 2026-09-02 against the committed file recovered from commit `31d5cb4`, never a rebuild |
| 2026-09-02 | `11b9c59d8b3d6c667eb3921f2544c4bee700d0a4e444306d3fc12d6f6619ccc7` | `96720d76cc36cc0f365db18ca06f2751913f71ec7c3c9e6b0e6b0653738e2609` | `data/anchors/2026-09-02-11b9c59d.ots` | **confirmed in Bitcoin**, block **965223**, checked 2026-09-02. Transaction `ec5dc8a01696486d05338772a10c33c6cea832d53397097b85a2ef155c3668d0` reached its confirmations. Superseded same day by a rebuild; its proof was moved out of `data/` rather than overwritten, because a proof that no longer matches the file beside it is worse than no proof |
| 2026-09-02 (rebuild) | `b16dbca285d5590bab3e6d876635061e2c81f3dcf5fbfabbce536709f96ec7da` | `971b8fe4eccbbad6a165b395b93e2702c70e77e7248050091f1a456e4dabeeef` | `data/anchors/2026-09-02-b16dbca2.ots` | **confirmed in Bitcoin**, block **965229**, checked 2026-09-02. Superseded the same day by the merge below, proof moved rather than overwritten |
| 2026-09-02 (post-merge) | `38f39f76b609ea8ce89b86aa1481e7b232e27e6632fcd7cf0315e704757627fa` | `44f065ff99469e64390f04a767248d873287ba09b22a0e92c15f28da0bb8e8b4` | `data/anchors/2026-09-02-38f39f76.ots` | **confirmed in Bitcoin**, block **965229**, checked 2026-09-02. Merging `main` changed the commit graph the `post_revisions` table is built from, so the digest moved while every count stayed identical. That is the record working, not drifting: it hashes the history it actually has |
| 2026-09-02 (three-weeks fix) | `23e22011cc0d23d24ab5a5dd05f8cc35ee3b598bdefa266654b241fa02a32675` | `45bf59fea87f5d8c63a175dc588a91a1e484842c0a3c15997bf4bac4b9328124` | `data/anchors/2026-09-02-23e22011.ots` | **confirmed in Bitcoin**, block **965236**, checked 2026-09-03. Carried the three-weeks correction, the one an adversarial audit caught after it had already been anchored |
| 2026-09-02 (author roles) | `97c0cb6e619f69b7bdc006b21c4743e061c9cd01b2ff4e4cdba937aca8622705` | `39d4083622a1eb6d564ef0e06abd26f5c5a4eda1f29717af67ccccaad21ef1c0` | `data/anchors/2026-09-02-97c0cb6e.ots` | **confirmed in Bitcoin**, block **965236**, checked 2026-09-03. Carried the author_role correction. Superseded the same day by the mark below, proof moved rather than overwritten |
| 2026-09-02 (the mark) | `da790abd13fc3960070179655ea852d7ff7120b279f4b0b4830bdbcac739d335` | `2b6060fbd757f8bf8bfc149a50939dfca499ffd4cee846252c7eee687d0e5028` | `data/anchors/2026-09-02-da790abd.ots` | **confirmed in Bitcoin**, block **965236**, checked 2026-09-03. Carried the struck mark and the .gitattributes fix. Superseded 2026-09-03 when its branch was squash-merged into `main`; proof moved rather than overwritten |
| 2026-09-03 (post-merge, #631) | `c7b3def8a6fe8e3a37dec0e19944884d9fe7b72b15f87f6f0e109881326ecb3f` | `37db078beabc83ff396c3fd92c9105894e2e33a0469439c1e0a1374d3fc887e4` | `data/anchors/2026-09-03-c7b3def8.ots` | **pending**, stamped 2026-09-03 with four calendars. Rebuilt from `main` after the squash-merge of the pull request that carried the five builds above it; every count identical to the build before, only the commit graph moved. Superseded the same day by the thirteenth principle; proof moved rather than overwritten, and it upgrades in place once the calendars aggregate |
| 2026-09-03 (thirteenth principle) | `cca941929e992205b3aea19eea666a73eca91e4e94ef4202753bce56a6893512` | `4280e5953bec04747457be28b8615b16f9ba5a4ca73a5e85865936b233555c10` | `data/errata.db.ots` | **pending**, stamped 2026-09-03 with four calendars. The current published build. Adds the principle `experience-and-connections`, set down at the founder's word, and the README section that says what this repository claims for agents. Run `ots upgrade data/errata.db.ots` once the calendars have aggregated |

**Eight of these ten proofs are confirmed in Bitcoin; the ninth and tenth
are pending.** Every published state of this record, including the ones
that were superseded within the hour, can be proved to have existed before
its block was mined, and the two pending ones will be once their blocks are. That includes the builds
that carried our own errors, which is the point: the anchor proves when we
published a wrong number just as firmly as when we published a right one.

Two hashes, on purpose. The internal digest is what `tools/verify.py`
recomputes over the rows; the file sha256 is what OpenTimestamps binds to
Bitcoin, and it covers the whole file, internal digest included.

## What this still cannot do

An anchor proves when a file existed. It does not prove any sentence in
the file is true. Integrity is not accuracy, here as everywhere in this
repository.
