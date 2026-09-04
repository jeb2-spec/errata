# What the screen missed

**Measuring an AI assistant's error rate the way a discovery organisation would.**

Written 2026-09-04. Every number in it is derived from `data/errata.db` by
`errata-measure`, not typed. Reproduce them with the command at the end.

---

## The problem with how we currently measure

Benchmarks score a model on problems whose answers are already known. That is
a useful thing to know and it is not the thing that costs anyone anything.

The failure that costs something is narrower and harder: **a confident claim
that is wrong, in work nobody re-checks.** No benchmark measures it, because a
benchmark cannot contain the claims a system makes about your specific
material, in your specific week, that you had no reason to doubt.

Anyone who has run a screen already knows the shape of this. A hit list is not
a result. The number that decides whether the campaign was worth running is
the one nobody can read off the plate: how many real actives the assay never
picked up. You cannot count what you missed. But you are not helpless about
it either, and the method for not being helpless is old.

---

## Treat the assistant as a screen, and its claims as hits

This repository is the conduct record of one project that works with an AI
assistant daily. It publishes every claim the project got wrong, what replaced
it, which direction the error ran, and who paid.

Reframed as a pipeline, the parts map cleanly:

| discovery | here |
| --- | --- |
| hit | a claim the assistant asserts |
| confirmed active | a claim that survived checking |
| false positive | a correction in this database |
| validation cascade | the checks a claim passes before and after publishing |
| **what the screen missed** | **the defects nobody ever found** |

The last row is the whole problem. Everything above it is bookkeeping.

---

## The method for the last row

Capture-recapture. It is the same estimator ecologists use to count a
population they cannot enumerate, and epidemiologists use for case
ascertainment from incomplete registries. Software inspection research adopted
it in 1992 for exactly our question: after a code review, how many defects
remain?

The intuition needs no algebra. Put two independent reviewers over the same
material. If they each find ten defects and nine are the same nine, they are
close to exhaustive and few remain. If they each find ten and share one, they
are sampling a large population and most of it is still out there. **The
overlap between independent detectors is the signal.**

For two sources, Chapman's bias-corrected estimator is

    N̂ = ((n₁ + 1)(n₂ + 1) / (m + 1)) − 1

where n₁ and n₂ are the defects each detector found and m is the number both
found. This repository implements it and prefers it to the jackknife estimator
on the literature's own advice: the jackknife is accurate at four or more
reviewers and is documented as non-robust and downward-biased with two.

Two limits are load-bearing and are stated here rather than in a footnote.

**These estimators underestimate.** The review literature says so plainly and
recommends tracking the systematic error over time to compensate. Any figure
produced this way is a floor on what you missed, never a ceiling.

**Independence is the assumption everything rests on.** Reviewers who confer,
or who share a method, violate it and the estimate silently inflates your
confidence. This matters more for machines than for people, and it is the next
section.

---

## The finding, from forty two defects

Forty two corrections. Eighty one point zero percent of them reached a reader
before anyone caught them. Then this:

| detector | independent finds | triggered finds |
| --- | ---: | ---: |
| a second model, reviewing adversarially | 19 | 0 |
| the assistant auditing itself | 11 | 9 |
| the founder | 7 | 0 |
| an outside reader | 3 | 0 |
| the person being written about | 1 | 0 |
| a different vendor's assistant | 0 | 1 |

*Triggered* means the detector only looked because somebody else voiced doubt:
the founder saying "be certain" without naming a defect, a review agent
reporting a control broken, a reading produced elsewhere and relayed here.
Confirming somebody else's finding is not detecting it, and this record counts
none of them as detection. The triggered rows are listed by
`SELECT correction_id FROM detections WHERE independent = 0`, and they are not
enumerated in prose here because the last prose enumeration named six of them
while the column had grown to nine. The bottom row is the first entry from a detector
this project does not run. It arrived carrying the same briefing as the
assistant it caught, which is why its independent column is zero.

Until 4 September 2026 the next sentence of this paper read: *the founder is
the single largest independent detector of the assistant's errors, in a
project whose thesis is that it catches its own.* The table above it showed a
tie at seven, and the sentence stood for a day before a second model read the
table against it. That is correction `a-tie-called-a-lead`, and it is the
shape this paper is about: a superlative nobody had run the query for. The
correction row said the falsifying table sat four lines above the sentence.
It sat seventeen lines above with a paragraph in between, which is correction
`four-lines-that-were-seventeen`, a false detail inside the row that fixes a
false sentence. The adversarial column leads because several review passes over one week added
rows to it, most of them defects in this paper or in the README that summarises
it and some in code and in other documents. The exact split per pass is not
stated because this record does not tag a detection with the pass that produced
it, and the last two attempts to state it in prose were both wrong. **The table above is derived
from the database by the build, and the build fails if this page disagrees
with it.** The sentence it replaced was typed.

And then the number that stopped the analysis:

> **Overlap between every pair of independent detectors: zero.**
>
> Not small. Zero. No defect in this record was found independently by two
> detectors.

So the dark number is **not estimable**, and the measurement script refuses to
print one. That refusal is deliberate. An estimator run on insufficient
overlap returns a confident figure that means nothing, and a repository built
to publish its own errors has no business manufacturing a comforting one.

---

## What zero overlap actually means

Until 4 September 2026 this section opened by saying that reading the zero as a
data problem was a mistake, and that it was the result. That claimed more than
the design can carry, in the direction that flattered the refusal, and the
correction is `an-overlap-nobody-tested-for`.

Zero *independent* overlap means **no defect in this record has had a second,
independent look.** Nine corrections do carry two detection rows, but in every
one of those the second detector was triggered by the first rather than
looking on its own. An earlier draft of this sentence said every defect got
exactly one look, which the table under it contradicts. But the detectors
are probably not disjoint by accident. The `detections` table records no brief,
so what follows is a reading of the `note` column rather than a query, and a
reader who reads those notes differently is entitled to. They describe
detectors pointed at different things: the founder looking at a published mark,
a reader supplying a clause number, a review agent reading shipped code,
another vendor's assistant reading a document. Nothing in the record describes
two detectors set the same task over the same material.

If that reading is right, a design that never creates the opportunity for
overlap cannot measure it, and the estimator was blocked as much by an
allocation policy as by the detectors.

**So it was tested, and the test cost one review pass.** The result is the next
section.

---

## The identical-brief pass, and the first estimate this project can compute

On 4 September 2026, before the build carrying this paragraph was published,
two reviewers were given the **same material and the same brief**: find every
statement in this change that is false, unsupported, unfalsifiable, or that
describes the system inaccurately. Neither could see the other. Neither was
told what to look for beyond that sentence. The material was the uncommitted
diff that became this build.

| | |
| --- | ---: |
| findings, seat A | 12 |
| findings, seat B | 12 |
| found by both | **5** |
| distinct defects found | 19 |

The overlap is not zero. It is the first non-zero overlap in this record, and
it was produced by changing the allocation, not the detectors.

Chapman's estimator, the one this paper argues for at two sources, gives

    N̂ = ((12 + 1)(12 + 1) / (5 + 1)) − 1 = 27.2

with a standard deviation of 5.7 from Chapman's variance, so an interval that
runs roughly from 16 to 38 and should be read as wide. Nineteen defects were
found. **Around eight in that change were found by neither reviewer**, and were
published in this document unless somebody later catches them.

That number is the thing this paper said it could not produce. It is worth more
than the refusal it replaces, and it costs one review pass.

**What it is not.** Both seats ran on the same base model, in the same
repository, with the same tools. That is a violation of the independence
assumption in the direction that matters most: correlated reviewers share
blind spots, which inflates the overlap, which pushes the estimate **down**.
So 27 is a floor on a floor. The literature already says these estimators
underestimate; this design adds a second reason. A genuinely independent second
seat, a different vendor or a person, would very likely find the overlap
smaller and the estimate larger.

**And the classification is ours.** Deciding that seat A's finding and seat B's
finding are the same finding is a judgement, and it was made by the author of
the material being reviewed, which is the worst possible person to make it.
Counting more pairs as matches raises the overlap and lowers the estimate, so
that judgement moves the headline number and it moves it in our favour. Here is
the whole mapping, so anybody can redo it and disagree.

| # | defect | A | B |
| ---: | --- | :-: | :-: |
| 1 | the anchor log's summary sentence went stale when the rows were flipped | x | x |
| 2 | `data/errata.db.ots` is named by the text and absent from the tree, and the correction row says it was fixed | x | x |
| 3 | the ANCHORS command block was never repaired, though the correction row says both blocks were | x | x |
| 4 | the build this README describes appears in no anchor row | x | x |
| 5 | "every defect got exactly one look" is contradicted by the detections table | x | x |
| 6 | the triggered self-audits are enumerated as six against a column of nine | x | |
| 7 | the allocation argument rests on a brief no column records | x | |
| 8 | "two review passes in one day" undercounts the passes the anchor log describes | x | |
| 9 | "nearly every one of those rows" is twelve of sixteen | x | |
| 10 | "a nine line paragraph in between" is ten lines | x | |
| 11 | `every-build-is-stamped` claims a repair the abstract never received | x | |
| 12 | the attribution table is built from the source array while the paper says the database | x | |
| 13 | "run the query" points at a query that cannot test the claim above it | | x |
| 14 | the detector column collapses several review seats into one label, hiding overlap | | x |
| 15 | "the first found six defects and the second found seven" matches no grouping in the record | | x |
| 16 | "three gates were added in a day" is six by the anchor log's own rows | | x |
| 17 | "two judgement self-catches" is stale in the build that adds a third | | x |
| 18 | "character for character" overstated a gate that did not cover the printed command | | x |
| 19 | a clause repeated verbatim inside an anchor row | | x |

Rows 12 and 18 are the closest call: both are a gate claiming more than it
checks, in different documents about different gates. They are counted as two.
Counting them as one would raise the overlap to six and drop the estimate to
about 23, which is the direction that flatters us, and is why the choice is
printed here rather than described.

**The finding underneath the number.** Every one of those nineteen defects was
caught *before* publication, so not one of them appears in the corrections
table, and none of them moves the escape rate on this page. This record has
counted defects for a week under a process where review happened after
publishing. The escape rate at the top of this page is what that process
produces. What it measures is the publishing order, not the assistant. The
figure is not restated here, because the last time this paragraph restated it
the number went stale within one build.

---

## The second run, which broke the estimator

The pass above was run again the same day, identical briefs, on the change that
carried this section. It is the reason nothing above should be read as settled.

| | run 1 | run 2 |
| --- | ---: | ---: |
| findings, seat A | 12 | 9 |
| findings, seat B | 12 | 15 |
| found by both | 5 | **9** |
| distinct defects | 19 | 15 |
| Chapman estimate | 27.2 | **15.0** |
| standard deviation | 5.7 | **0** |

**In run 2 every finding of seat A was also a finding of seat B.** Complete
containment. Chapman's estimator, handed that, reports that nothing was missed,
with a variance of exactly zero: perfect confidence, arrived at because one
reviewer added nothing the other lacked. That is a confident figure which means
nothing, and this paper exists to refuse those. It is reported rather than
dropped because dropping the run that disagrees is how a method becomes a
belief.

Two runs one day apart, same design, same material class, gave 27 and 15. **The
estimator is not stable at this scale**, and a single run of it should not be
quoted as a result, including the one above.

The likely mechanism is the one already disclosed: the two seats are the same
model reading the same repository with the same tools. Correlated reviewers
share blind spots, and the more thorough one tends to contain the other rather
than differ from it. Capture-recapture assumes the reviewers are independent;
containment is what a violated assumption looks like when it is severe. The
first run's overlap of five was low enough to hide that. The second run made it
unmissable.

**What that means for the number this paper now carries.** The 27 in the
previous section is not retracted, because it is what the data said. It should
be read as one draw from an estimator this record has now seen fail, and not as
an estimate of anything. The experiment that would fix it is the same one as
before with a different second seat: another vendor's model, or a person.
Neither has been run.

---

Which yields three conclusions, in increasing order of discomfort.

**One. We have no evidence about what we are missing.** Not weak evidence.
None. The quantity is undefined given this design, and it will stay undefined
until something changes structurally.

**Two. The founder is not a reviewer, he is the assay.** He is the only
detector applied to substantially everything. Replacing him is not a matter of
being more careful. It requires a second detector that runs over the same
material he does, every time, not occasionally.

**Three, and this is the part that generalises.** A system cannot be its own
independent second reviewer. When the assistant checks its own work it shares
every prior, every misreading, and every blind spot with the pass that produced
the error. It is the same antibody in both wells. In this record that shows up
concretely, though not as cleanly as this paper first said. Most of the
independent self-catches are mechanical: a wrong count, a stale digest, a
rebuild that disagreed with itself, a published table whose arithmetic did not
add up, a publish that shipped fewer rows than the one before it, a line count
retyped without being recounted. Some are judgement, and those were found the
same way, by going to a primary source after a summary had been trusted: a
remedy recommended from two agreeing summaries, and a true detail deleted as
unsourced. The proportions are in the table above and in the query at the end
of this page, and they are not restated here, because this paragraph has now
been wrong twice about its own arithmetic.

Until 4 September 2026 it said *every* self-catch was mechanical, and then said
that sentence had been true at seventeen defects and gone stale. Both are
false. It was already untrue when it was sealed: the seventeen defect build
holds five independent self-audit rows and two of them are judgement. The
corrections are `every-was-five-of-seven` and `lesson-five-was-never-true`, and
the second of those is a correction of the first.

The sentence that stood here after that repair was worse than either. It said
the failures needing judgement about a person, about a public claim, or about
the system's own limits were caught by somebody else every time. No column in
this schema records whether a failure was one of judgement, so no reader could
run the query that would test it, and it was written immediately after two
false superlatives had been caught: a claim reshaped until nothing could come
back at it, rather than shrunk until it was safe to make. It was false as well.
At least three of the assistant's independent self-catches are failures of
judgement: a true detail about a person deleted as unsourced, a remedy
recommended from two agreeing summaries, and this paper's own claim about what
its central refusal meant, which is squarely a judgement about the system's own
limits and is entered in the same build as
`an-overlap-nobody-tested-for`. The correction is
`a-sentence-shaped-so-nothing-could-test-it`. The count is given as *at least*
because the classification is a reading and not a column, and because the
sentence before this one said two while the build it shipped in contained the
third.

What is left is smaller, and part of it is not in any column at all. Nothing in
this schema records whether a failure was mechanical or one of judgement, so
the classification in this paragraph is a reading of the rows and not a query
result, and a reader who disagrees with it should say so. The rows themselves
are `SELECT correction_id, note FROM detections WHERE detector = 'self-audit'
AND independent = 1`. Read them. The assistant's independent catches are
mostly mechanical and they are not only mechanical. The failures that did the most damage here, a claim about a
person the evidence would not carry, a limitation asserted without test, a
control reported as working after only its happy path was run, and an image
whose type was running off the edge of itself, were each caught by somebody
else. That is a description of four defects and not a law about the fifth.

That last one is worth naming separately, because it is not a reasoning
failure. The repository's banner is generated by a script. The assistant ran
that script seven times in one evening, and never once looked at what came out.
The founder looked, and the word was clipped. There is a version of this
failure in every screening pipeline that has ever run: the plate was read by
the instrument that produced it and by nothing else.

The sharpest instance is the last one. On 2026-09-04 this project shipped a
hook that blocks a value the session never observed, tested it, watched it
deny a fabricated hash, and reported it as verified. A review agent then read
the shipped code rather than its description and found that the denial message
named the offending value, which put that value into the transcript the hook
trusts, so the identical retry passed. **The control defeated itself on the
second attempt and the author had only ever run the first.** Both the defect
and the fix are in the corrections table.

Machines are good at catching machine errors of arithmetic and consistency. On
their own overconfidence, and on work they never went back to look at, they
have caught nothing here. Not one failure of that kind was found by the system
that made it. They were reported by the founder, by a review agent, or by a
different vendor's assistant reading the same document and finding in hours
what neither this assistant nor its principal had seen. This paper is the
latest instance: sealed on 4 September with two false sentences about its own
table, and corrected the same day by a second model that read the table. That last one is
requirement four below arriving by accident rather than as practice, and it was
not even the clean orthogonal test, because that reader shared this assistant's
briefing. The cheap version was available the whole time and nobody had run
it.

---

## The standard this argues for

Four requirements. They are not exotic; three of them are ordinary practice in
any validation-minded lab, and the fourth is the one AI work keeps skipping.

**1. Instrument the detector, not just the defect.** Record every detector that
found a defect, not the first one to notice, and record whether it looked on
its own. This is one table and it is the only change that makes anything else
computable.

**2. Report escape rate and attribution instead of accuracy.** What share
reached a reader, and who caught the rest. Both are derivable, neither is a
benchmark, and both move when the system genuinely improves.

**3. Estimate the dark number, publish its confidence and its known bias, and
refuse to publish it when the overlap cannot carry it.** A method that only
ever returns a number is not a measurement.

**4. Require orthogonal validation, and treat self-review as a null control.**
Nobody confirms a hit with the assay that generated it. The same should be true
of a machine reviewing its own claims. Self-audit belongs in the pipeline, and
it belongs there as the cheap first pass whose job is to be beaten.

The practical form of that, for anyone who does not have a second human to
spare, is a check the author cannot reason their way past: one that re-derives
the claim from the artefact instead of reading the description of it, and that
runs over states the artefact has not reached yet rather than the one on disk
today. It is orthogonal because it does not share the author's priors. It has
no priors. That is the only property being asked of it.

---

## Honest limits of this document

- **n = 42.** Small enough that the attribution table is suggestive, not
  established. Do not read the detector ranking as stable: one review pass
  over one document moved the top row.
- **Nothing a check stops before publication appears anywhere on this page, so
  the escape rate overstates how bad things are and understates what a second
  detector is worth.** A defect caught before anything is claimed for the
  broken version never becomes a correction, because nothing was ever asserted.
  The day the fourth requirement below was first acted on, the new check caught
  a defect the author had introduced while repairing another one and believed
  fixed, and swept it out of existence before it was published. It is in no
  figure here. Whatever the right way to count that is, this design counts it
  as nothing.
- **Most detection rows are reconstructed.** Nineteen of the fifty one
  detection rows were read back from prose written after the fact; thirty two
  were recorded at the time. Reconstruction
  names whoever noticed first and systematically loses second finders, which
  is precisely the overlap the estimate needs. So the true overlap is not
  necessarily zero, it is *unrecorded*, and the correct reading is "this
  project cannot currently tell you." Rows from 2026-09-04 forward are
  contemporaneous, and that is the fix, arriving too late to help this table.
- **The detector column is a label, not an identity, and that hides overlap by
  construction.** Every adversarial review in this record is booked as
  `adversarial-review`, though the notes describe several distinct passes on
  separate days. Overlap is computed across labels, so two different reviewers
  finding the same defect are invisible as overlap unless somebody notices in
  prose. The zero on the historical rows is therefore partly an artefact of the
  schema, and the identical-brief pass above had to be counted by hand outside
  the database for exactly this reason. Giving each seat its own identity is
  the fix and it has not been made.
- **The brief is nowhere in the record.** The claim that no two detectors were
  ever set the same task is a reading of the `note` column, not a query, and no
  reader can check it against a column. It is stated as a reading and should be
  discounted as one.
- **One project, one assistant, one human.** Nothing here generalises on this
  evidence. It is a demonstration of a method, not a result about AI systems.
- **The corrections table is defects we know about.** By construction it can
  never contain the ones we do not. That is not a flaw in the table, it is the
  entire reason the third requirement above exists.

---

## Reproduce it

```console
$ git clone https://github.com/jeb2-spec/errata && cd errata
$ python3 tools/verify.py                     # the record is unchanged since it was built
$ sqlite3 data/errata.db "SELECT detector, SUM(independent), COUNT(*) \
    FROM detections GROUP BY detector ORDER BY 2 DESC;"
```

The full report is generated by `scripts/errata-measure.mjs` in the source
repository. `data/errata.sql` is the same contents as plain text for anyone
without SQLite.

---

## Sources

The capture-recapture literature for software inspections, which is where this
method was borrowed from:

- S. Eick, C. Loader, M. D. Long, L. Votta and S. Vander Wiel, *Estimating
  software fault content before coding*, Proceedings of the 14th International
  Conference on Software Engineering, 1992. The paper that introduced the
  method to inspections.
- C. Wohlin and P. Runeson, *Capture-recapture in software inspections after 10
  years research: theory, evaluation and application*, Journal of Systems and
  Software, 2004. The review this document takes its model names, its
  estimator choice and its warnings about underestimation and independence
  from. Freely available at <https://wohlin.eu/jss04-1.pdf>.
- K. El Emam and O. Laitenberger, *Evaluating capture-recapture models with two
  inspectors*, IEEE Transactions on Software Engineering, 2001. The source of
  the preference for Chapman's estimator at two sources.

Integrity is not accuracy. This document is sealed inside the record it
describes, which proves it has not been altered since it was built and proves
nothing whatever about whether it is right.
