# The errata format, version 0.1

**What a record has to do to be checkable by a stranger.**

This document specifies the format, not our implementation of it. The rules
below are the ones that make the thing work. The seven tables in
`data/errata.db` are one profile of them, built for a project that publishes
claims about the world. They are not the format.

**Status.** One implementation exists, and it is ours. Nothing here has been
tested against a second one. That is a serious limit for a specification whose
central argument is that independent implementations are the security property,
and it is stated first rather than in a footnote. Sections marked **UNTESTED
ACROSS IMPLEMENTATIONS** are the ones where a second implementer is most likely
to find that this document is underspecified. If you are that implementer and
something here is ambiguous, the ambiguity is a defect in this document.

---

## 1. What a conforming record claims, and what it does not

A conforming record claims exactly one thing: **its contents have not changed
since it was built, and a stranger can prove that without trusting the author.**

It does not claim that anything in it is true. Integrity is not accuracy. A
tamper-evident record of a false statement is still false, held perfectly still.
A conforming record must say so in its own text.

---

## 2. The core object

The unit is a **supersession**: something that was, something that replaced it,
and the account of the change.

A record is a set of supersessions plus enough machinery to prove they have not
been edited. What the superseded thing *is* depends on the domain. A project
publishing claims about the world supersedes false claims; that is what this
repository does, and it calls them corrections. A project building software
supersedes working capabilities; a project keeping a catalogue supersedes
entries. The format does not care. It cares that each one carries the fields in
section 3.

---

## 3. Required properties

Eight, and each one exists because leaving it out is how records go quietly
wrong. Table and column names are yours. These properties are not.

**3.1 The prior state, in its own words.** Not a summary of it, and not a note
that something changed. The actual text or description of what was there, so a
reader can see what was claimed or what existed. A changelog says a thing
changed. Only the prior state says what it used to be.

**3.2 When.** A date, at minimum. Dates that were reconstructed after the fact
must be distinguishable from dates recorded at the time.

**3.3 Why, and who paid.** The reason for the change, and the party the old
state cost. A record without this is a list of edits. The party may be a reader,
a subject, a third party, or the authors themselves.

**3.4 Direction.** Which way the error or loss leaned. Whether the prior state
flattered the author or cost them. **This is the field nobody wants and the only
one that proves anything.** Entries that embarrass an opponent are free to
publish. The ones that carry weight are the ones that helped you, corrected
anyway.

**3.5 Whether the change was chosen.** A capability dropped because it failed is
not the same as one lost because a rewrite never reached it, and a claim
retracted after a challenge is not the same as one caught by its author. Records
that do not separate these cannot tell deliberate evolution from silent decay,
and the argument about which one happened becomes unresolvable.

**3.6 Who found it, and whether they were looking on their own.** One row per
detector **instance**, keyed so that two different reviewers of the same kind
are two rows and not one. A role label alone collapses them, which silently
destroys the only signal that can estimate what everybody missed. One row per
detector, not one field naming whoever noticed first. A detector is
**independent** when it looked without being told what to look for. This is the
property that makes section 6 possible and it is the one most often collapsed.

**3.7 The prior state is never edited away.** A correction to an entry is
another entry beside it, not a rewrite of it. This applies to the record's own
entries: an entry that turns out to be wrong gets a new entry, never a fix. A
record whose history can be tidied is a draft.

**3.8 A statement of what the record does not prove.** In the record, covered by
the seal, so it cannot be quietly dropped when it becomes inconvenient.

---

## 4. The seal

**UNTESTED ACROSS IMPLEMENTATIONS.**

A digest over the contents, recomputable by a reader from the published bytes
with no code of yours.

The rule this repository uses, stated exactly enough to reimplement. An earlier
draft of this section described a single global sort and omitted the field
separator, the null rule, and the handling of `meta`. Two independent reviewers
implemented it as written and both arrived at
`6fc70afa09af1ac730a4466d29c5f7b1ca26109fb6cb3b7bb6a443acf26bc6c2` instead of
this build's digest. That draft was never published. What follows is the rule
the code actually applies, verified by reimplementing it against the shipped
file:

1. For each of the six content tables, **in this fixed order**: `principles`,
   `corrections`, `detections`, `lessons`, `post_revisions`, `documents`.
2. Serialise each of that table's rows as the table name, then every column
   value in schema order, joined by `\x1f` (unit separator). A NULL becomes the
   empty string.
3. Sort **that table's** strings by UTF-8 byte order. Not globally, and not by
   any column: sorting by a column requires a tie-break, and a tie-break living
   in a query planner is not reproducible by somebody without your database.
   Append them to the running list.
4. Then append the `meta` rows, ordered by **key**, serialised as
   `meta\x1f<key>\x1f<value>`. Meta is not byte-sorted with the rest; it is a
   key-value table and its key order is already total.
5. Exclude exactly three meta rows: the digest itself, because a hash cannot
   contain its own value, and the two provenance rows recording *where and when
   the build ran*. Provenance describes the build, not the record, and including
   it means every rebuild moves the seal with nothing having changed.
6. Join the whole list with `\x1e` (record separator) and SHA-256 it.

Both separators must be absent from your data. Check that; do not assume it.

**The per-table grouping and the fixed table order are historical, not
principled.** A single global byte sort over every row would be simpler and
would need no table list at all. This record does not use one because changing
the rule now would move the digest and break the reproducibility promise made
by every anchor already in the log. A new implementation starting today should
prefer the global sort and say so in its own spec.

Everything else must be inside the digest, including the disclosures. A seal
that does not cover a record's own disclosures is decoration: the disclosure
could be edited and the file would still verify.

**The requirement, as opposed to the recipe:** a reader who distrusts you, has
none of your tools, and reads only the published text must be able to arrive at
the same number. This repository's own rule failed that test the first time it
was checked, because the row order depended on a database tie-break nobody had
written down. If your canonical form cannot be reproduced from your published
bytes, it is checking your code against your code.

---

## 5. The anchor

A seal you compute yourself proves internal consistency and nothing else. You
build the file, you hash it, you publish it; somebody who controls all three can
rewrite an entry and re-seal it.

An anchor is the record's fingerprint witnessed somewhere the author cannot
reach. Requirements:

- Every published build is anchored, **or the record says which builds are not.**
  A build made where the witness is unreachable ships with its anchor owed and
  says so. It does not ship a proof of a different file.
- A superseded proof is archived, never deleted and never overwritten. A proof
  sitting beside a file it no longer matches is worse than no proof.
- The record states plainly that an anchor buys **detection by a stranger, not
  immutability**. The file can still be altered; anyone who checks will find the
  proof no longer matches. Any description stronger than that is false.

**And the anchor must be checkable by the reader you actually have.** A
verification path that requires infrastructure your audience does not run is not
proof, it is a claim of proof. Publish a path a doubter can finish on the device
they are arguing on, without installing anything, ending somewhere neither of
you controls. Test it by handing it to somebody who does not want it to be true
and watching where they stop.

**This repository does not yet meet that requirement.** Its published path needs
the OpenTimestamps client installed before a reader can read a block height out
of a proof; only the second half, checking that block against any explorer, is
install-free. Closing the gap means publishing each proof's block heights and
merkle roots as text beside the anchor table, so a reader compares two strings
and installs nothing. That has not been done. The requirement stands and the gap
is named here rather than left for a reader to run into.

---

## 6. Conformance, which is a readout and not a badge

**There is no certification, and there should never be one.** A body that
approves other people's records is a reputation system, which is the thing this
format exists to avoid.

**No such tool exists yet.** What follows specifies what one must print. This
repository ships `tools/verify.py` and `tools/tamper-test.py`, which cover the
first three items, and `scripts/errata-doctor.mjs`, which covers the anchor
line; nothing published here prints the rest. Until a tool does, section 6 is a
requirement and not a description, and an earlier draft of this section stated
it as a description.

Conformance is mechanical and it is checked by printing, not by judging. A
conformance tool reads a record and reports:

- whether the digest recomputes;
- whether the digest still recomputes when one byte is altered, and fails;
- whether the published plain text reproduces the digest using a parser that
  shares no code with the builder;
- the count of entries, and the share of them that reached a reader before
  anyone caught them;
- the detectors, and how many entries each found **independently**;
- the anchor status of every build, including any that are owed;
- what the record says it does not prove.

The last four are the point. **The aim is that a record cannot look rigorous
without being rigorous, because the tool prints its shape whether the author
likes it or not.** Nothing compels anybody to run it, and this section
deliberately rules out any body that could compel them, so that is a property
of the readout and not a guarantee about the world.
A record where every detector is the author shows exactly that. One that has
never had an entry cost its authors anything shows that too. One with no anchors
shows no anchors. No one has to grade anybody; the numbers are legible and the
reader decides.

---

## 7. Rules that are not code

These cannot be enforced by a tool and are the reason the tool is worth
anything.

- **Record the entries that cost you.** A record containing only errors that
  flatter its author is a marketing document with a hash on it.
- **A standard that only survives contact with someone you already doubt is a
  preference.** Correct an entry that runs against a party you owe nothing.
- **Do not grade the artwork.** A record about a person or their work describes;
  it does not pass verdicts.
- **Derive numbers, do not type them.** Every count in prose about the record is
  a claim that will go stale. Derive it in the command that prints it, or remove
  it. A number that is not there cannot be wrong.
- **A published command is a claim that it runs.** Set up a clean machine from
  your own instructions and run every line before publishing them.
- **Review before publish, not after.** This is an inference, not a
  measurement. A defect caught before publication never becomes an entry, so
  moving review earlier lowers a published error rate without changing how often
  the work is actually wrong. This repository has one arm of that comparison and
  not the other. What follows is narrow and still worth stating: an error rate
  that does not say where in the pipeline it was taken is close to meaningless.

---

## 8. Discontinuities

**UNTESTED ACROSS IMPLEMENTATIONS.**

Sometimes a chain breaks on purpose: a rewrite starts fresh, a history is
severed, a project moves and the old lineage is not carried over.

A discontinuity must be recorded **at the discontinuity**, in the new record,
stating what transferred, what did not, and why. A broken chain with a document
at the break is a lineage. A broken chain without one is an orphan, and no later
reader can tell it from an accident.

---

## 9. How the reference implementation scores against this document

Section 6 says a record's shape should be printed whether its author likes it
or not. Doing that to somebody else's record first would be indefensible, so
here is ours. Every row was checked against the shipped database, and three of
the eight required properties are **not met by the only implementation that
exists.**

| property | this record | how you can tell |
| --- | --- | --- |
| 3.1 prior state in its own words | met | `claimed_before` on every correction; `removed_prose` on 49 revisions |
| 3.2 when, and reconstructed dates distinguishable | **not met** | `occurred_on` exists; nothing marks a reconstructed date. The paper's split of reconstructed against contemporaneous rows is computed by the build from a date cutoff, not read from the record, so a reader cannot reproduce or falsify it |
| 3.3 why, and who paid | met | `corrected_to` and `who_it_cost` |
| 3.4 direction | met | `direction` and `ran_in_our_favour` |
| 3.5 whether the change was chosen | **not met** | no column. `detections.independent` covers part of one clause and nothing of the other |
| 3.6 one row per detector, with independence | **partly met** | the table is per detector and carries `independent`, but `detector` is a role label under a primary key of (correction, detector), so two separate reviewers of the same role cannot both be stored. Two seats reviewing this very document had to be tallied by hand outside the database |
| 3.7 prior state never edited away | met | corrections of corrections sit beside their targets; the superseded text is intact |
| 3.8 statement of what it does not prove | met | in `meta`, inside the digest |

Section 5's requirement that the anchor be checkable without installing
anything is also **not met**, and section 5 says where.

**Four gaps, named by the document that requires them, in the record that
fails them.** They were found by two independent reviewers reading this
specification against the database before it was published, which is the only
reason they are a table here rather than something a stranger finds later.
Closing them means schema changes, and schema changes move the digest, so they
will arrive as a build with their own anchor rather than quietly.

---

## 10. What this document does not specify

- A storage format. This repository uses SQLite with a plain-text dump beside
  it because both are readable without a server and one of them is readable
  without any tool at all. Anything with the same property qualifies.
- A schema. Section 3 lists properties; how you shape them is yours.
- A language, a library, or a dependency on us. **Independent implementations
  are not a cost this format tolerates, they are the property that makes it
  worth anything.** Ten implementations that agree on a digest is a stronger
  claim than one library everybody imports, and the one non-circular check this
  repository runs is exactly the one performed by code sharing nothing with the
  builder.

---

*Version 0.1. Sealed inside the record it describes, which proves it has not
been altered since it was built and proves nothing whatever about whether it is
right.*
