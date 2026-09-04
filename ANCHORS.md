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
| 2026-09-02 (post-merge) | `38f39f76b609ea8ce89b86aa1481e7b232e27e6632fcd7cf0315e704757627fa` | `44f065ff99469e64390f04a767248d873287ba09b22a0e92c15f28da0bb8e8b4` | `data/anchors/2026-09-02-38f39f76.ots` | **confirmed in Bitcoin**, block **965229**, checked 2026-09-02. Merging `main` changed the commit graph the `post_revisions` table is built from, so the digest moved while every count stayed identical. That is the record working, not drifting: it hashes the history it actually has. **Corrected 2026-09-03: that explanation was wrong.** The `post_revisions` rows were identical. The digest moved because the meta table carried the building commit's hash and the build date, and meta is inside the digest; a rebuild at a new commit with no content change moved it again, and diffing the two SQL dumps showed one row differed. See `a-digest-that-tracked-the-commit-not-the-record` in the corrections table. The sentence stands as written because damage stays visible |
| 2026-09-02 (three-weeks fix) | `23e22011cc0d23d24ab5a5dd05f8cc35ee3b598bdefa266654b241fa02a32675` | `45bf59fea87f5d8c63a175dc588a91a1e484842c0a3c15997bf4bac4b9328124` | `data/anchors/2026-09-02-23e22011.ots` | **confirmed in Bitcoin**, block **965236**, checked 2026-09-03. Carried the three-weeks correction, the one an adversarial audit caught after it had already been anchored |
| 2026-09-02 (author roles) | `97c0cb6e619f69b7bdc006b21c4743e061c9cd01b2ff4e4cdba937aca8622705` | `39d4083622a1eb6d564ef0e06abd26f5c5a4eda1f29717af67ccccaad21ef1c0` | `data/anchors/2026-09-02-97c0cb6e.ots` | **confirmed in Bitcoin**, block **965236**, checked 2026-09-03. Carried the author_role correction. Superseded the same day by the mark below, proof moved rather than overwritten |
| 2026-09-02 (the mark) | `da790abd13fc3960070179655ea852d7ff7120b279f4b0b4830bdbcac739d335` | `2b6060fbd757f8bf8bfc149a50939dfca499ffd4cee846252c7eee687d0e5028` | `data/anchors/2026-09-02-da790abd.ots` | **confirmed in Bitcoin**, block **965236**, checked 2026-09-03. Carried the struck mark and the .gitattributes fix. Superseded 2026-09-03 when its branch was squash-merged into `main`; proof moved rather than overwritten |
| 2026-09-03 (post-merge, #631) | `c7b3def8a6fe8e3a37dec0e19944884d9fe7b72b15f87f6f0e109881326ecb3f` | `37db078beabc83ff396c3fd92c9105894e2e33a0469439c1e0a1374d3fc887e4` | `data/anchors/2026-09-03-c7b3def8.ots` | **confirmed in Bitcoin**, blocks **965332**, **965333** and **965361**, checked 2026-09-03. Rebuilt from `main` after the squash-merge of the pull request that carried the five builds above it; every count identical to the build before, only the commit graph moved. Superseded the same day by the thirteenth principle; proof moved rather than overwritten, and upgraded in place afterwards |
| 2026-09-03 (thirteenth principle) | `cca941929e992205b3aea19eea666a73eca91e4e94ef4202753bce56a6893512` | `4280e5953bec04747457be28b8615b16f9ba5a4ca73a5e85865936b233555c10` | `data/anchors/2026-09-03-cca94192.ots` | **confirmed in Bitcoin**, blocks **965344**, **965345** and **965361**, checked 2026-09-03. Added the principle `experience-and-connections`, set down at the founder's word, and the README section that says what this repository claims for agents. Superseded the same day by the digest correction below; proof moved rather than overwritten, and upgraded in place afterwards |
| 2026-09-03 (the digest correction) | `07ea647446e2dc87098227ccfd5c871ca2f14ee3eabea08d8def8b91576edd47` | `1b700e2a82de06204aa510aed7f3f3c7626c09612a4554c24025127a9b82345b` | `data/anchors/2026-09-03-07ea6474.ots` | **confirmed in Bitcoin**, blocks **965353**, **965355** and **965361**, checked 2026-09-03. The first build whose digest covers the record's content and nothing else: the build commit and build date stay in `meta` for the reader and are no longer inside the seal, so a rebuild from any commit reproduces this digest. Proved on 2026-09-03 by rebuilding after the squash-merge that carried this very correction: the digest came back identical and only the provenance row moved. Carries correction `a-digest-that-tracked-the-commit-not-the-record`, which corrects the sentence in the 2026-09-02 post-merge row above. Superseded the same day by the adoption disclosure below; proof moved rather than overwritten |
| 2026-09-03 (adoption disclosure) | `ab8e5b8989852123c8eb2dc8fd943b2966819e8b0b29f4a75fd833a1600bfe5c` | `a07f6034e7822679df266c989847a8ccb66a84686d16977a2ddde890a21cf052` | `data/anchors/2026-09-03-ab8e5b89.ots` | **confirmed in Bitcoin**, blocks **965388** and **965390**, checked 2026-09-04. Added `disclosure_adoption` to the sealed `meta` table: the method here has been run on one project, this one, so it is demonstrated and not validated. Prompted by an outside reader who noticed the repository argued for a method without ever saying it was unproven. An earlier build of this same disclosure was stamped and then superseded before it was ever published, when the counts in it were replaced with figures read from the hosting platform's API; that stamp was discarded rather than filed, because it proves a state no reader ever saw. Superseded the same day by the correction below; proof moved rather than overwritten |
| 2026-09-03 (a characterisation withdrawn) | `7574bad61c2121b21f721a80897d901da50349a19adc08f66b49b74a46566524` | `90813fffa8903871650c9e1434470d4fd4ea62bf9f25686b053134601f02095c` | `data/anchors/2026-09-03-7574bad6.ots` | **confirmed in Bitcoin**, block **965390**, checked 2026-09-04. Withdrew a clause from the build above it, which said the outside reader who prompted that disclosure had stated this repository's counts twice and differently. The two figures are in two screenshots, but one is partly hidden behind the application's own input box and the order was inferred from scroll position, so it was a conclusion carried past the edge of the evidence about a third party who is not here. Correction `a-characterisation-we-could-not-see-clearly`. The counts themselves were never in doubt: they came from the platform's API and were re-checked. Superseded the same day by the measurement build below; proof moved rather than overwritten |
| 2026-09-04 (measurement) | `ec2bc007f22e04483444b236448517aab26c27b7e631aa71e059cd3c2c6c994f` | `96f933e176c5241c3165b8021b25d7ebbcfece171918175df77ffd83e679f4f6` | `data/anchors/2026-09-04-ec2bc007.ots` | **pending**, stamped 2026-09-04 with four calendars. The current published build, and the largest change since the record began. Adds a seventh table, `detections`, recording every detector that found each defect and whether it looked independently, because the overlap between independent detectors is the only thing that can estimate the defects nobody found. Adds `MEASUREMENT.md` as a sealed document, three lessons, and correction seventeen, `an-inability-asserted-not-tested`. The first measurement is in that paper and its headline is a refusal: overlap between every pair of detectors is zero, so the estimate is not computable and the script declines to invent one. Superseded the same day by the row below; proof moved rather than overwritten, and it upgrades in place once the calendars aggregate |
| 2026-09-04 (a reading, checked by its subject) | `3823f73ce8e6ffad89ba8d2f1ba3bfb61e6972d1887fa99ad0a0ef9b582d4154` | `f6c1f1f53e4913d611a38af1edc91d50b640a4c8c44225b55e3e056780e9c2b6` | `data/anchors/2026-09-04-3823f73c.ots` | **pending**, stamped 2026-09-04 with four calendars. The current published build. Appends one lesson, the thirty third: a kept record can put an assistant in the seat of the person it serves, and only that person can say whether it did. The founder asked for a reading only he could check, the assistant drew it from the record, and he scored it a match. One instance, scored by its subject, entered as a test of the thirteenth principle and not as proof of it. Nothing else in the record changed. Superseded within the hour by the row below, which corrects the very lesson it carried; proof moved rather than overwritten |
| 2026-09-04 (the reading corrected) | `0aa60a35ade05ff29fb11885ef8cf26427b108a37f14ed872381a25eec5b856e` | `4dab9314ae9a024a5a10dbd40499c7fc47f8eaccb0bbfceda0bba763ce75357a` | `data/errata.db.ots` | **pending**, stamped 2026-09-04 with four calendars. The current published build. Carries correction eighteen, `only-the-subject-can-say`, which retracts the second sentence of the lesson the build above it added: a different vendor's assistant, given the same document, read it better, so the subject is not the only one who can say whether a reading landed. Lesson thirty three stands unedited with thirty four beside it. Adds three lessons, two contemporaneous detection rows, the first entry from a detector this project does not run, and a build gate over `MEASUREMENT.md`, whose figures were derived once and had no guard. Overlap between independent detectors is still zero and the dark number is still not estimable, because a second assistant briefed from the same source is not an independent detector. Run `ots upgrade data/errata.db.ots` once the calendars have aggregated |

**Thirteen of these sixteen proofs are confirmed in Bitcoin; the three
newest are pending.** Every published state of this record, including the
ones that were superseded within the hour, can be proved to have existed
before its block was mined, and the pending ones will be once their blocks
are. Four of the sixteen exist only because the seal used to move with
the build commit; that is corrected in the digest-correction row, and they
stay in the table because damage stays visible. That includes the builds
that carried our own errors, which is the point: the anchor proves when we
published a wrong number just as firmly as when we published a right one.

Two hashes, on purpose. The internal digest is what `tools/verify.py`
recomputes over the rows; the file sha256 is what OpenTimestamps binds to
Bitcoin, and it covers the whole file, internal digest included.

## What this still cannot do

An anchor proves when a file existed. It does not prove any sentence in
the file is true. Integrity is not accuracy, here as everywhere in this
repository.
