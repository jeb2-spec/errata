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

## The finding, from twenty two defects

Twenty two corrections. Sixty-three point six percent of them reached a reader
before anyone caught them. Then this:

| detector | independent finds | triggered finds |
| --- | ---: | ---: |
| the founder | 6 | 0 |
| a second model, reviewing adversarially | 5 | 0 |
| the assistant auditing itself | 6 | 5 |
| an outside reader | 2 | 0 |
| the person being written about | 1 | 0 |
| a different vendor's assistant | 0 | 1 |

*Triggered* means the detector only looked because somebody else voiced doubt.
Five of the assistant's self-audits were triggered: twice the founder said "be
certain" without naming a defect, twice the assistant only checked a control
after a review agent reported it broken, and once a reading produced elsewhere
was relayed here and the comparison exposed a published sentence as false.
Confirming somebody else's finding is not detecting it, and this record counts
none of them as detection. The bottom row is the first entry from a detector
this project does not run. It arrived carrying the same briefing as the
assistant it caught, which is why its independent column is zero.

**The founder is the single largest independent detector of the assistant's
errors, in a project whose thesis is that it catches its own.**

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

It is easy to read that as a data problem. It is not. It is the result.

Zero overlap means **every defect in this record got exactly one look.** There
is no second, independent pass over the same material. The detectors are not
redundant, they are disjoint: each one happened to be pointed at different work
at a different moment.

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
concretely: the assistant's five independent self-catches are all mechanical
defects, a wrong count, a stale digest, a rebuild that disagreed with itself.
The judgement failures, a claim about a person that the evidence would not
carry, a limitation asserted without being tested, a control reported as
working after only its happy path was run, were caught by somebody else every
time.

The sharpest instance is the last one. On 2026-09-04 this project shipped a
hook that blocks a value the session never observed, tested it, watched it
deny a fabricated hash, and reported it as verified. A review agent then read
the shipped code rather than its description and found that the denial message
named the offending value, which put that value into the transcript the hook
trusts, so the identical retry passed. **The control defeated itself on the
second attempt and the author had only ever run the first.** Both the defect
and the fix are in the corrections table.

Machines are good at catching machine errors of arithmetic and consistency.
On their own overconfidence, in this record, they have caught nothing. Every
independent self-catch here is mechanical: a wrong count, a stale digest, a
rebuild that disagreed with itself, a publish that shipped fewer rows than the
one before it. Not one is a judgement failure. Those were reported first by the
founder, by a review agent, or by a different vendor's assistant reading the
same document and finding in hours what neither this assistant nor its
principal had seen. That last one is requirement four below arriving by
accident rather than as practice, and it was not even the clean orthogonal
test, because that reader shared this assistant's briefing. The cheap version
was available the whole time and nobody had run it.

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
Nobody confirms a hit with the assay that generated it. The same should be
true of a machine reviewing its own claims. Self-audit belongs in the pipeline,
and it belongs there as the cheap first pass whose job is to be beaten.

---

## Honest limits of this document

- **n = 22.** Small enough that the attribution table is suggestive, not
  established. Do not read the detector ranking as stable.
- **Most detection rows are reconstructed.** Nineteen of the twenty eight
  detection rows were read back from prose written after the fact; nine were
  recorded at the time. Reconstruction
  names whoever noticed first and systematically loses second finders, which
  is precisely the overlap the estimate needs. So the true overlap is not
  necessarily zero, it is *unrecorded*, and the correct reading is "this
  project cannot currently tell you." Rows from 2026-09-04 forward are
  contemporaneous, and that is the fix, arriving too late to help this table.
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
