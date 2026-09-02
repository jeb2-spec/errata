-- The Vera Record. Plain SQL dump of errata.db.
-- Readable as text; loadable with: sqlite3 new.db < errata.sql
BEGIN TRANSACTION;
CREATE TABLE meta (key TEXT PRIMARY KEY, value TEXT NOT NULL);
CREATE TABLE principles (
  id TEXT PRIMARY KEY, name TEXT NOT NULL,
  statement TEXT NOT NULL, rationale TEXT NOT NULL);
CREATE TABLE corrections (
  id TEXT PRIMARY KEY, occurred_on TEXT NOT NULL, subject TEXT NOT NULL,
  claimed_before TEXT NOT NULL, corrected_to TEXT NOT NULL,
  direction TEXT NOT NULL, who_it_cost TEXT NOT NULL, how_found TEXT NOT NULL,
  ran_in_our_favour INTEGER NOT NULL);
CREATE TABLE lessons (
  id INTEGER PRIMARY KEY, domain TEXT NOT NULL,
  lesson TEXT NOT NULL, elaboration TEXT NOT NULL);
CREATE TABLE post_revisions (
  id INTEGER PRIMARY KEY, post_slug TEXT NOT NULL, revised_on TEXT NOT NULL,
  commit_sha TEXT NOT NULL, author_role TEXT NOT NULL, reason TEXT NOT NULL,
  removed_prose TEXT, is_publication INTEGER NOT NULL);
CREATE TABLE documents (
  id TEXT PRIMARY KEY, name TEXT NOT NULL,
  media_type TEXT NOT NULL, content TEXT NOT NULL);
CREATE INDEX idx_rev_slug ON post_revisions(post_slug);
CREATE INDEX idx_rev_cut  ON post_revisions(removed_prose) WHERE removed_prose IS NOT NULL;
CREATE VIEW corrections_against_ourselves AS
  SELECT * FROM corrections WHERE who_it_cost = 'us';
CREATE VIEW passages_removed AS
  SELECT post_slug, revised_on, reason, removed_prose
  FROM post_revisions WHERE removed_prose IS NOT NULL ORDER BY revised_on DESC;
INSERT INTO meta VALUES ('title','The Vera Record');
INSERT INTO meta VALUES ('what_this_is','The conduct record of a project that argues a record beats a reputation, applied to itself. Principles, every correction made and which direction each error ran, transferable lessons, and the full revision history of every published article including the prose removed.');
INSERT INTO meta VALUES ('built_on','2026-09-02');
INSERT INTO meta VALUES ('source_commit','39f2948');
INSERT INTO meta VALUES ('format','SQLite 3. Public domain file format, no server required. A plain-text errata.sql dump ships alongside for any reader without SQLite.');
INSERT INTO meta VALUES ('how_to_open','sqlite3 errata.db  then  .tables  and  SELECT * FROM corrections;  Or open it in any SQLite browser, or read errata.sql in a text editor.');
INSERT INTO meta VALUES ('start_here','SELECT * FROM corrections ORDER BY occurred_on; then SELECT * FROM passages_removed;');
INSERT INTO meta VALUES ('disclosure_author_roles','Commit authorship is normalised to four roles. automation is a bot account. assistant means the AI collaborator is the git author. co-authored means a human authored, reviewed and shipped the commit with a Co-Authored-By trailer naming the assistant; this is the majority case, because squash-merging a pull request books the merger as the author. human means no assistant involvement is detectable. Read this column as a FLOOR on assistant involvement and never as a count: the Co-Authored-By convention began on 2026-06-15, so seven revisions here predate it and cannot be classified either way, and they are booked human because that is what the evidence says rather than what is known. Before 2026-09-02 this column tested only the author name and reported 8 assistant rows out of 117. No row it produced was false, because it reported git authorship correctly; what was false was this database README describing it as showing which changes came from a human and which from an assistant. That correction is in the corrections table as a-column-that-did-not-measure-what-we-said. Individual identities are withheld deliberately. Disclosed rather than done quietly, because an undisclosed edit to a record is the thing this database argues against.');
INSERT INTO meta VALUES ('disclosure_redaction','Personal names are replaced with roles: the project founder appears as the founder, and identifiers as [redacted] or [maintainer]. The published articles this data describes are bylined Vera Team and Healthy; no legal name has ever appeared on them. Withholding a name is reversible, publishing one is not. Disclosed here rather than done quietly, because an undisclosed edit to a record is the thing this database argues against.');
INSERT INTO meta VALUES ('disclosure_scope','Contains no personal identifiers, no family information, and nothing about private individuals. All article text reproduced here was already published publicly.');
INSERT INTO meta VALUES ('integrity_note','SHA-256 over a canonical serialisation of every row in every table, including this meta table, with only the digest row itself excluded because it cannot contain its own hash. Covering meta matters: without it the disclosures below could be edited and the file would still verify. It proves the contents are unchanged since the build. It does not, and cannot, prove any statement in it is true. Integrity is not accuracy.');
INSERT INTO meta VALUES ('license','The contents may be quoted and redistributed freely with attribution to the Vera Project.');
INSERT INTO meta VALUES ('counts','12 principles, 14 corrections, 29 lessons, 117 article revisions across 37 articles');
INSERT INTO meta VALUES ('integrity_sha256','39d4083622a1eb6d564ef0e06abd26f5c5a4eda1f29717af67ccccaad21ef1c0');
INSERT INTO principles VALUES ('ground-truth-or-silence','Ground truth or silence','If you cannot show it, do not claim it. Sourced to the record, or unsaid.','Governs publication, not belief. It says nothing about what anyone may know, notice, or act on. Reading it as a theory of reality would make it false.');
INSERT INTO principles VALUES ('presence-is-not-proof','Presence is not proof','A true fact framed as a verdict becomes a lie about a person. Describe, never condemn.','Something being present is not evidence it was used for harm. Plenty of honest software looks exactly like the thing someone is afraid of.');
INSERT INTO principles VALUES ('the-practical-thing','The practical thing at the end','Every piece of work leaves the reader something they can actually do.','A diagnosis with no next step is entertainment. The reader came with a problem.');
INSERT INTO principles VALUES ('proof-not-reputation','Proof, not reputation','The record before the accusation. The reference before the alarm. The work before the argument.','A reputation is an inference drawn from the population you resemble. A record is the specific verifiable thing you did.');
INSERT INTO principles VALUES ('the-standard-test','A standard that only survives contact with someone you already doubt is a preference','The test of a rule is whether it holds when it costs you, and when it protects a party you dislike.','This is the corollary that does the work. Every correction in this database was scored against it.');
INSERT INTO principles VALUES ('who-pays','The standard of proof scales with who pays for the error','Wrong about your own work, you pay. Wrong about a person in public, they pay, and they never agreed to the wager.','The asymmetry is the entire reason evidence is demanded for accusations and nothing at all for private intuitions.');
INSERT INTO principles VALUES ('intuition-is-direction','Intuition is for direction, evidence is for assertion','Steer with what you cannot prove. Publish only what you can.','Nothing gets verified that somebody did not first suspect. The hunch aims the search; it is never the finding.');
INSERT INTO principles VALUES ('true-in-parts-false-as-picture','A summary can be true in every part and false as a picture','Check the picture, not only the parts.','Every individual number can be defensible while the impression they combine to give is wrong.');
INSERT INTO principles VALUES ('damage-stays-visible','Damage stays visible, or it is not a record','Silent patching and falsification are the same operation. Only a surviving prior state tells them apart.','Append and date. Never overwrite. A correction nobody can see is indistinguishable from a cover-up.');
INSERT INTO principles VALUES ('unverified-deletion','An unverified deletion is an unverified claim','Search the corpus before removing a fact, not only before asserting one.','Rigour becoming a reason to delete rather than to verify is the failure mode of people who are trying to be careful.');
INSERT INTO principles VALUES ('stating-a-limit','Stating a limitation does not discharge it','When you cannot reach the evidence, the honest output is ''I cannot judge this'', not a verdict with a caveat attached.','A disclaimer buys credibility for the conclusion that follows it, which makes it worse than saying nothing.');
INSERT INTO principles VALUES ('nerve-is-not-evidence','Being willing to disagree is not the same as being right','Never let the courage of a disagreement launder the quality of its evidence.','The willingness can be correct while the confidence is miscalibrated.');
INSERT INTO corrections VALUES ('settlement-pre-publication','2026-08-29','A post analysing a corporate settlement','Draft misstated the money, the term, the court status, and printed every remedy without its exclusion.','Rewritten against the filed agreement before publication. The published post discloses that its earlier draft was wrong.','in the company''s favour','us','Caught by an adversarial review pass before it shipped.',0);
INSERT INTO corrections VALUES ('restored-a-true-detail','2026-08-29','A biographical detail on an unlisted page','Flagged as unsourced and deleted.','Restored. It was true, and the source was in previously published writing all along.','against ourselves','the subject','Found by searching the corpus after the deletion, which is the wrong order.',0);
INSERT INTO corrections VALUES ('auditor-publication-clause','2026-08-29','The same settlement post, after publication','Claimed an independent auditor''s reports carried no requirement that any of it be published.','The filing requires a public executive summary of every final report, including whether the company adopted the auditor''s recommendations. Corrected live with a dated note.','against the company','the company we were writing about','A reader supplied a clause number; we read the clause.',1);
INSERT INTO corrections VALUES ('the-recorder-counted-itself','2026-08-30','A statistic on a personal page: longest run of consecutive working days','38 days.','29 days. Sixteen days in the log had no human commit at all; a scheduled job was authoring them, and the job that wrote the statistic counted its own commits toward the total it reported.','in our favour','us','Found by asking who authored the commits, which nothing about the number itself would have prompted.',1);
INSERT INTO corrections VALUES ('concluded-past-a-stated-limit','2026-08-30','A claim about a third-party system''s behaviour','Told the person who raised it that he was wrong, after stating that the source was inaccessible.','He was right. Reasoning confidently from partial evidence after admitting the evidence was out of reach is worse than staying silent.','against a person, in our own favour','him','He held the full record and showed it.',1);
INSERT INTO corrections VALUES ('forty-lines','2026-08-31','The published README of this record''s own repository','Called its verifier forty lines of Python. The commit message that published it said a hundred.','It was ninety lines on the day of this correction. Neither published number had ever been checked against the file, and the claim sat in the paragraph that invites readers to audit us instead of trusting us.','in our favour','the reader','Cloned the published repository as a stranger would and ran every command the README gives.',1);
INSERT INTO corrections VALUES ('not-childhood-friends','2026-08-31','A sentence about two people on an unlisted page','Implied they had grown up together since childhood.','They met as adults. The person the sentence described read the draft and corrected it herself; her own phrase had meant the years they built together, not childhood.','in our favour','the subject','Caught by the person it described, reading the draft before it shipped.',1);
INSERT INTO corrections VALUES ('a-page-written-for-its-reader','2026-09-01','The landing page for a tool we published on a sister project''s site','Written, we said, for one specific non-technical reader on a phone. It opened with the craft: the day as terrain, one calm page over coffee.','The reader it was written for said she was confused, and so did the first other person to read it. A third person then restated the page in one breath, plainly and benefit first. The page''s first paragraph is now a line in that shape, and the craft line follows it.','in our favour','its first two readers','The readers said so, in a group thread, the same day it shipped.',1);
INSERT INTO corrections VALUES ('citations-from-memory','2026-09-01','A published essay''s sources, and the pull request that described them','The pull request said every citation had been checked against a search result. There were twelve; four had been written from memory.','Three of the four were wrong in detail: a news article''s address, a population figure with its age range, and a paper''s identifier. All three were corrected before the essay was published. The claim that they had been checked was the error that mattered, because it is the claim a reviewer stops checking after.','in our favour','us','An audit of every citation against its source before merging, asked for by the founder: be certain.',1);
INSERT INTO corrections VALUES ('congress-would-move-quickly','2026-09-02','A forecast about federal legislation, given in conversation after a federal appellate ruling','That Congress was likely to act quickly to close the gap the ruling had opened.','The relevant bill had already passed the Senate unanimously on 16 December 2025 and had been held at the desk in the House ever since. It was not waiting on urgency, it was waiting on a floor vote. Two supporting details were also wrong: we called the Senate vote an overwhelming margin when it was unanimous, and implied the bill was in committee when it was further along than that.','in our favour','the founder','He disputed the forecast on the spot and said the laws were not actively happening. We checked. He was right.',1);
INSERT INTO corrections VALUES ('osborne-does-not-transfer','2026-09-02','Constitutional analysis offered in conversation before the opinion itself had been read','That a 1990 Supreme Court case was the strongest argument available, because its rationale of destroying a market rather than policing thought transfers cleanly to synthetic material and needs no identifiable victim.','The panel had considered that argument and rejected it, a week before we made it. The opinion holds that because the images do not depict an actual child, the two victim-anchored precedents do not directly apply. We had recommended walking through a door the court had already closed, and the only thing standing between the reasoning and the record was that nobody had opened the PDF.','in our favour','the founder','He said be certain. We extracted the opinion from the court''s own file and read it.',1);
INSERT INTO corrections VALUES ('a-remedy-that-did-not-reach','2026-09-02','The practical recommendation at the end of a piece of legal analysis','That the remedy for the gap was a phone call to the House about a named pending bill.','We read the bill as the Senate passed it rather than a summary of it. It removes a statute of limitations, adds sex offender registration, adds a presumption of pretrial detention, adds supervised release, and protects the material in discovery. It never amends the subsection the ruling struck down, and a statute could not have overruled that holding anyway. The bill is worth passing and it is not the answer to this. A practical thing at the end that does not reach the problem is decoration, and it is worse than no recommendation because it tells the reader the matter is handled.','in our favour','the reader','Fetched the engrossed text from the legislature''s own server after two summary sources agreed with each other and neither quoted the operative sections.',1);
INSERT INTO corrections VALUES ('three-weeks-was-a-week','2026-09-02','The correction row above, osborne-does-not-transfer, and the published article that cites it','Said the court had rejected the argument three weeks before we made it.','Seven days. The opinion was decided on 25 August and the argument was made on 1 September, and both dates sit in the same paragraph as the number that contradicts them. It was already sealed into this record''s digest and anchored to Bitcoin before anyone checked, so the anchor now proves exactly when we published a wrong number. That is the system working rather than failing, and it is the reason the row that admits not reading a source is the row that got its own arithmetic wrong.','in our favour','the reader','An adversarial review read the opinion''s caption date and did the subtraction. Nobody on our side had.',1);
INSERT INTO corrections VALUES ('a-column-that-did-not-measure-what-we-said','2026-09-02','This database''s README, describing the author_role column of the post_revisions table','Said the column tells you which changes came from a human, which from an assistant, and which from an unattended cron.','It never did. It reported git authorship, correctly, on every row: no published row was ever false. But squash-merging a pull request books the merger as the author, so jointly written work read as human and the column showed 8 assistant rows out of 117 when at least 77 carry a Co-Authored-By trailer naming the assistant. Every part true, the picture wrong by roughly nine times, in the column the README points at to argue the assistant is disclosed rather than hidden. Fixed by making the claim true rather than by weakening it, since withdrawing a disclosure is not a repair. The column now reads the trailer and reports a fourth role, co-authored, and the meta table states that the number is a floor because the trailer convention only began on 2026-06-15.','in our favour','the reader','An adversarial review checked the column against the commit messages behind it, which is the one check nothing about the column itself would ever prompt.',1);
INSERT INTO lessons VALUES (1,'verification','A summary tells you what was decided. Only the source tells you what was never argued.','The holding is the visible part, and every secondary account carries it. The arguments a party failed to raise are invisible in all of them, and they are often where the outcome actually turned. A federal appellate judge spent a paragraph naming the argument the government had left out; not one report of the decision mentioned it.');
INSERT INTO lessons VALUES (2,'verification','Two summaries agreeing is one source, not two.','They are usually reading each other, or the same press release. Agreement between summaries is evidence about the summaries. Go get the operative text.');
INSERT INTO lessons VALUES (3,'records','One known error left uncorrected damages every claim, not one.','It proves a filter exists, and a filtered record is not evidence of anything. The cost is never scoped to the error.');
INSERT INTO lessons VALUES (4,'records','''Retroactive'' is the wrong word for fixing a live falsehood.','Nothing is being reached back into. An act that is still happening is being stopped. The wrong word is why it gets deprioritised.');
INSERT INTO lessons VALUES (5,'records','A body of work with no visible corrections is a red flag, not a green one.','At any scale, the absence means either falsification or that nobody looked.');
INSERT INTO lessons VALUES (6,'records','Correction is the only restitution an information system has.','No damages, no injunction, no appeal. The publisher is the only party who can grant it.');
INSERT INTO lessons VALUES (7,'integrity','A hash chain proves internal consistency and nothing else.','Anyone controlling the whole chain can edit an entry and recompute forward, and it verifies perfectly. What defeats that is an anchor: the head hash published where the publisher has no reach.');
INSERT INTO lessons VALUES (8,'integrity','Integrity is not accuracy.','A tamper-evident record of a false claim is still false, held perfectly still.');
INSERT INTO lessons VALUES (9,'judgment','Intuition is valid under two conditions, and only both.','The environment must be regular enough to be predictable, and the person must have had prolonged practice in it with rapid unambiguous feedback. Where either fails, identical confidence is worth nothing. (Kahneman and Klein, 2009.)');
INSERT INTO lessons VALUES (10,'judgment','Skill is fractionated and the boundary is invisible from inside.','A person can be genuinely expert at one judgment and have none at an adjacent one, and neither they nor anyone watching can feel where it ends.');
INSERT INTO lessons VALUES (11,'judgment','Noticing that something is off, and identifying what, are different faculties.','The first is often right. The damage is always in the second.');
INSERT INTO lessons VALUES (12,'outliers','An anomaly is a property of the observer''s model, not of the person.','It is only unexpected relative to an expectation, so every anomaly is partly a confession that the model was too small.');
INSERT INTO lessons VALUES (13,'outliers','The usual harm to outliers is averaging, not hostility.','Schools, hiring pipelines, ranking systems: none malicious, all regressing toward the mean and quietly taxing distance from it. Worse than a bully, because there is nobody to argue with.');
INSERT INTO lessons VALUES (14,'outliers','A record is the anti-average.','It shows the specific verifiable thing a person did in place of an inference drawn from the population they resemble.');
INSERT INTO lessons VALUES (15,'working-with-ai','An AI is an averaging machine, so the risk is that it smooths you.','Its native operation is producing the likely next thing. A frictionless session is a warning sign, not a success.');
INSERT INTO lessons VALUES (16,'working-with-ai','Its confidence is not calibrated the way a practitioner''s is.','Yours was built by domains that corrected you painfully and fast. Its was not. Hold its hunches more loosely than your own and ask it to measure.');
INSERT INTO lessons VALUES (17,'working-with-ai','Build a room where being wrong is survivable.','A record only stays honest inside one. Everything else is downstream of it.');
INSERT INTO lessons VALUES (18,'verification','Verify at the source, never at the summary.','A dashboard, a bot comment or a notification can all report green for a superseded version. Ask the system of record about the exact identifier you care about.');
INSERT INTO lessons VALUES (19,'verification','Run the cheap check before the expensive one.','A type check, a one-line script, a count. Seconds to run, loud when they fail.');
INSERT INTO lessons VALUES (20,'verification','Reproduce the failure before claiming the fix, then show the same check passing.','''It probably works now'' is not a result.');
INSERT INTO lessons VALUES (21,'writing','Write for the stranger.','Nobody knows you. A sentence about a person either carries its own context or it is an inside reference wearing prose, and to a cold reader it is noise.');
INSERT INTO lessons VALUES (22,'writing','Concrete over abstract, and clever is a form of abstract.','Many readers cannot take abstraction as real; it reads to them as strange and mechanical, and that is a fact about audiences rather than a flaw in them. The self-aware construction the writer is proudest of is usually the first thing to cut.');
INSERT INTO lessons VALUES (23,'writing','The subject test.','Would the person a sentence describes recognise themselves and understand every word? A description of someone''s work that they would not say themselves is wrong even when it is accurate.');
INSERT INTO lessons VALUES (24,'writing','A person is who they are, not what they do.','Asked how she wanted to appear in a record about the work, the person did not ask for credit. She asked to exist. Presence before deeds, and deeds only when the person wants deeds named.');
INSERT INTO lessons VALUES (25,'writing','The subject is the authority on their own description.','They edit until it is true and only their version ships. What they tell you is ground to stand on, not copy to paste: the truth informs the register, it is not a transcript.');
INSERT INTO lessons VALUES (26,'judgment','Over-correction is its own error.','Told a passage was too much, the safe rewrite deleted the warmth along with the excess and left something cold, and cold is not neutral. Take a note exactly as far as it goes, then stop.');
INSERT INTO lessons VALUES (27,'writing','Writing for a reader is a guess until that reader has read it.','Test the copy on the person, not on your picture of the person. The plain version that works often comes from someone who is not the author.');
INSERT INTO lessons VALUES (28,'verification','A claim of verification is itself a claim, and the one most worth verifying.','A reviewer who reads ''verified'' stops there. Say what was checked and against what, or say it was not checked.');
INSERT INTO lessons VALUES (29,'judgment','An accusation is a checklist to run against your own work before you publish it.','Naming a flaw proves you can detect it, not that you are clear of it. The detector is already built and pointed away from you, so turn it around before publishing. A draft accusing someone of merging two different measures into one figure was doing the same in its own headline.');
INSERT INTO post_revisions VALUES (1,'272-percent','2026-06-16','8ddbf5a7','co-authored','copy(blog): strip AI-isms across all 8 posts

Structural: remove bold-header list patterns (Opacity/Inconsistency/
Capture/Fragility, You learn X., Sponsorships pull out., For players:)
so they read as prose, not LinkedIn listicles.

Line-level: cut LinkedIn hook opener, Here''s why: frames, throat-clear
phrases (Let me be clear, We know this, We want to be honest about it),
redundant double openers, the AI triplet blockquote closer, and over-
qualified adjective…','It''s the obvious question. It''s the intuitive question. And it''s produced an architecture that looks like this: scan the system, detect the cheat, issue the ban, repeat. The defender invests in detection. The attacker invests in evasion. Both sides escalate. The defender asks for more access: kernel-level hooks, always-on monitoring, hardware attestation. The attacker finds the gap anyway. The cycle continues.

Let me be clear: detection still matters. Anti-cheat systems, for all their limitations, are a necessary part of the competitive gaming ecosystem. The 272% increase in AI-driven cheats makes them more important, not less.',0);
INSERT INTO post_revisions VALUES (2,'272-percent','2026-06-15','71074af3','human','Blog: prose cleanup (9 posts), new ''A Solution Looking for a Market'' post, visual enhancements (reading progress bar, animations, blockquote styling, card stagger)','That''s the increase in AI-based cheat detections over a single competitive season. Not a gradual rise. Not a trend line inching upward. A tripling — in months — of a category of cheating that barely existed a few years ago.

Riot Games updated Vanguard — its kernel-level anti-cheat — to effectively brick thousands of dollars worth of DMA cheating hardware, then mocked the affected users on social media. It was a crowd-pleasing moment. The community cheered. The cheat sellers adapted within weeks.

Meanwhile, the same kernel-level anti-cheat systems that target DMA devices require players to modify low-level system settings — IOMMU, VBS, Secure Boot configurations — just to launch the game. Playe…',0);
INSERT INTO post_revisions VALUES (3,'272-percent','2026-06-14','7c642387','human','blog: publish 6 new posts — The Quiet Season, 272%, The Accusation Economy, Neutrality Is a Product Decision, What Your Setup Says About You, The Ghost of Al Mazrah

- The Quiet Season: founder return from sabbatical, sets editorial context
- 272%: AI cheat explosion analysis, positions proof vs detection
- The Accusation Economy: false accusations as structural problem
- Neutrality Is a Product Decision: why Vera never issues verdicts
- What Your Setup Says About You: system info transparency essay
- The Ghost of Al Mazrah: DMZ love letter and DMZ 2 anticipation
- Rotate feature…',NULL,1);
INSERT INTO post_revisions VALUES (4,'a-generation-worth-believing','2026-06-28','57b05fae','human','copy(deep + blogs): retire the remaining fear-coded language (#115)

Phase 3 of the renewed-voice arc: surgical lighter-touch pass on deep
pages + blog catalog. Front door was Phase 1–2; this closes the trail.

Marketing copy (marketing.ts)
- tagline.sub "Proof, so you never have to fight to be believed." →
  "Proof, ready before anyone asks." (also feeds Margin''s brain)
- trustModel.subtitle "take on faith" → "argue about" (tribe-marker
  retired; rhymes with the home thesis)
- trust…','That does not make cheating impossible. Nothing does. It makes the fight happen in the light instead of the dark, and that changes everything about how it ends.

We are here so the honest never have to fight to be believed. So the next brilliant young player who does something nobody can explain gets to be celebrated instead of indicted. So two people who could have been the best thing for each other never have to become the worst.

Proof, not reputation. It is enough to build a whole community on, and we intend to.',0);
INSERT INTO post_revisions VALUES (5,'a-generation-worth-believing','2026-06-21','8e5acd25','co-authored','content(blog): publish "A Generation Worth Believing"

A Vision piece on Vera''s vision for the gaming community, anchored on the
streamer-vs-streamer cheating war. Grounded in research: streamers as visibility-
based "moral entrepreneurs" breeding mutual suspicion; Gen Z''s authenticity moat
and starvation for earned, checkable trust; the trauma asymmetry of false
accusation; and the AI arms race where undetectable cheats + behavioral detection
make skill itself read as s…',NULL,1);
INSERT INTO post_revisions VALUES (6,'a-settlement-is-not-a-verdict','2026-08-29','c62063af','human','blog: the one exclusion that repeats, plus the integrity spike and doctrine (#598)

The post listed the messaging carve-out three separate times and never
named the pattern. Messaging is exempt from the two hour cap
(II.B.3.a.i), stays available through night access mode (II.B.2.a.iii),
and keeps delivering notifications during school hours (II.B.4.a). Three
limits negotiated separately, one identical exception. Not evidence the
allegations were true; evidence of what Meta valued most. …',NULL,0);
INSERT INTO post_revisions VALUES (7,'a-settlement-is-not-a-verdict','2026-08-29','80bedf6e','human','blog: correct the auditor paragraph, which was wrong against Meta (#596)

The post said the auditor''s reports were confidential "with no
requirement that any of it be published." §III.J says the opposite: the
auditor shall make public an executive summary of every Final Report,
with a specified floor including whether Meta adopted its
recommendations. The full reports stay confidential under §III.G.7 and
Meta comments on the summary before release, so the qualifiers survive. …','That last one deserves its qualifiers rather than our applause. The agreement says it is not intended that the auditor investigate the conduct that gave rise to the case. Meta may challenge the auditor''s costs as excessive or duplicative. The workplan may be modified by agreement of the auditor and Meta, with the states holding a twenty day objection window. And the reports are confidential, with no requirement that any of it be published. An auditor on those terms is still worth having. It is not, on its own, the difference between a promise and a record.',0);
INSERT INTO post_revisions VALUES (8,'a-settlement-is-not-a-verdict','2026-08-29','3d7a272d','human','blog: a settlement is not a verdict (#593)

Vera''s statement on the Meta agreement of 26 August 2026, written from the
filing rather than the coverage.

A court entered a real, enforceable judgment, and inside it Meta admits
nothing and denies everything. Both are true, and a consent judgment is the
category most readers have no word for. …',NULL,1);
INSERT INTO post_revisions VALUES (9,'a-signature-is-a-receipt','2026-07-10','00bcfc2d','co-authored','Meet Vera: blog and How It Works cross-pollinate; blog catches up to the product (#396)

The sweep of all 28 posts found the funnel''s quiet failure (14 posts
dead-ended, none linked the FAQ) plus a production bug: preseason and
the-league-is-open were missing from the seed registry and silently
404ing on Vercel.…',NULL,0);
INSERT INTO post_revisions VALUES (10,'a-signature-is-a-receipt','2026-06-23','c9b0faf6','human','Unsigned-by-choice collector: the stand + verifiable SHA-256 download (#25)

Why our process collector ships unsigned, and the substance we offer instead of a code-signing certificate.

- Blog post "A signature is a receipt, not a verdict": turns the Field Guide''s thesis (the signing gate doesn''t certify safety; every dangerous driver in it is validly signed) on Vera itself. …',NULL,1);
INSERT INTO post_revisions VALUES (11,'a-solution-looking-for-a-market','2026-06-16','d9e0d146','co-authored','content(blog): feature "The Same Kind of Brave" as the hero post

Promote the-same-kind-of-brave to the featured slot on /blog and demote
a-solution-looking-for-a-market so there is exactly one hero. Regenerated seed.',NULL,0);
INSERT INTO post_revisions VALUES (12,'a-solution-looking-for-a-market','2026-06-16','8ddbf5a7','co-authored','copy(blog): strip AI-isms across all 8 posts

Structural: remove bold-header list patterns (Opacity/Inconsistency/
Capture/Fragility, You learn X., Sponsorships pull out., For players:)
so they read as prose, not LinkedIn listicles.

Line-level: cut LinkedIn hook opener, Here''s why: frames, throat-clear
phrases (Let me be clear, We know this, We want to be honest about it),
redundant double openers, the AI triplet blockquote closer, and over-
qualified adjective…','I''m going to say the thing that founders aren''t supposed to say.

Here''s why: the problem Vera addresses is real. It''s just early. The accusations are already happening. The AI-driven cheats are already surging. The false positives are already destroying reputations. The audience is already losing faith in whether the clips they''re watching are real. All of that is documented, measurable, and accelerating.

> If you''re building something the world hasn''t asked for yet, the hardest part isn''t the building. It''s the clarity to keep going when the silence feels louder than the signal. The signal is real. The silence is temporary. And the work is worth doing.',0);
INSERT INTO post_revisions VALUES (13,'a-solution-looking-for-a-market','2026-06-16','4b979d22','co-authored','copy(blog): Vera is a project, not a company

Replace ''Company'' category with ''Dispatch'' on all founder-voice posts.
Scrub self-referential ''company'' prose — the project is Vera Project,
the blog is a project log. Intentional contrasts (''not from a company,
but from someone…'', anti-cheat company foil) kept as-is.','You learn patience as a skill. Not the passive kind. The kind where you keep shipping, keep improving, keep building the record, knowing that the compound value only becomes visible over time. Vera''s value proposition is literally about accumulation. A player with ten sessions has a start. A player with two hundred has something nobody can argue with. The product and the company are on the same curve.',0);
INSERT INTO post_revisions VALUES (14,'a-solution-looking-for-a-market','2026-06-15','bc8239a4','co-authored','blog: voice + identity + the manuscript reader

Voice — purge AI tells. Rewrite "The Same Kind of Brave" with zero em
dashes and no machine cadence; intentional punctuation only. (The other
nine posts were already em-dash-free.) Added a quiet line honoring artists
who write straight at their darkness — the spirit behind the work.…',NULL,0);
INSERT INTO post_revisions VALUES (15,'a-solution-looking-for-a-market','2026-06-15','71074af3','human','Blog: prose cleanup (9 posts), new ''A Solution Looking for a Market'' post, visual enhancements (reading progress bar, animations, blockquote styling, card stagger)',NULL,1);
INSERT INTO post_revisions VALUES (16,'do-good-or-be-good-doing-it','2026-09-01','258f5d66','human','content(blog): feature Do Good, or Be Good Doing It (#625)

Featured at the founder''s word.',NULL,0);
INSERT INTO post_revisions VALUES (17,'do-good-or-be-good-doing-it','2026-09-01','9240dcfe','human','content(blog): Do Good, or Be Good Doing It (#624)

The waiting-room blessing as a Healthy dispatch, for anyone having a tired
Monday. The giver stays fully anonymous by design. Approved by the founder for
publication.',NULL,1);
INSERT INTO post_revisions VALUES (18,'everything-we-got-wrong','2026-08-31','924447ae','human','content(blog): Everything We Got Wrong, the errata post (#617)

The errata announcement, written to the standard the founder''s wife set: for the
stranger, concrete, flowing, nothing the reader has to already know, and
the practical thing at the end. Approved by the founder for publication.',NULL,1);
INSERT INTO post_revisions VALUES (19,'ironwood','2026-07-28','e414ec7f','co-authored','blog: strip signpost bridges from Where the Time Goes; feature Ironwood (#498)

the founder''s directive applied: the no-signpost-bridges rigor on this one
shipped post as it should have read, publication date untouched. Seven
bridges stripped, each replaced by a statement carrying the content
instead of a promise about the next paragraph. Ironwood promoted to
featured, making it the blog hero by newest-first plus
first-featured-wins; Where the Time Goes keeps its flag and its date.',NULL,0);
INSERT INTO post_revisions VALUES (20,'ironwood','2026-07-28','7a4a29c3','co-authored','blog: two new posts, The look-alike problem and Ironwood (#497)

Two council-reviewed posts ship together.

The look-alike problem (Industry, Vera Team): the false-positive
companion to Where cheats hide now. Honest software does the same
mechanical moves cheats do, a detection pattern is a proxy, the Vizor
trigger-string incident with the counts shown and not settled, what an
appeal actually is, and the practical close. …',NULL,1);
INSERT INTO post_revisions VALUES (21,'keep-the-part-you-couldnt-reach','2026-06-20','faeb0a75','co-authored','style(blog): remove em dashes from "Keep the Part You Couldn''t Reach"

The only blog post still carrying em dashes. Recast each with a colon,
period, or comma so the prose reads in the proven human register (no
em dashes, no AI-isms) and the live site matches the clean source.
Regenerated blog-seed.ts from source rather than hand-editing.','There are days that produce nothing you can point to. No feature, no headline. You spend them making a quiet thing quieter — lighter, so it asks less of the machine it runs on and the person who never knew it was there. Done well, the result is that nothing happens, slightly faster, for slightly less. No one will ever notice. That is the whole idea.

In the middle of it, we caught a habit worth naming. For a long time we had been treating a certain kind of moment as garbage — the moment where we reached for something and came back empty. Couldn''t see it. Couldn''t open it. The tidy instinct is to discard that: no result, move on.

So we stopped throwing it away. We started keeping the shape of th…',0);
INSERT INTO post_revisions VALUES (22,'keep-the-part-you-couldnt-reach','2026-06-19','ddd6a577','co-authored','content(blog): publish "Keep the Part You Couldn''t Reach"

A Philosophy piece on the slow, silent work — the unglamorous tending good
systems are made of — and a smaller truth found inside it: a failure to reach
something is not the absence of information, it''s information. The honest record
keeps the shape of the failure, not just the wins. Journey over product; no
mechanics revealed. Vera Team voice.',NULL,1);
INSERT INTO post_revisions VALUES (23,'lobby-crashing-untangled','2026-06-29','c3763a3e','human','Field Guide: "Lobby crashing, untangled" + feature-release blog post (#170)

A new evergreen Field Guide entry at /field-guide/lobby-crashing: the three-things-one-name taxonomy, a severity ladder, a sourced cross-game record, and a constructive prevention playbook with honest tradeoffs. Describe, never condemn; a reference, not a manual.…',NULL,1);
INSERT INTO post_revisions VALUES (24,'neutrality-is-a-product-decision','2026-06-16','8ddbf5a7','co-authored','copy(blog): strip AI-isms across all 8 posts

Structural: remove bold-header list patterns (Opacity/Inconsistency/
Capture/Fragility, You learn X., Sponsorships pull out., For players:)
so they read as prose, not LinkedIn listicles.

Line-level: cut LinkedIn hook opener, Here''s why: frames, throat-clear
phrases (Let me be clear, We know this, We want to be honest about it),
redundant double openers, the AI triplet blockquote closer, and over-
qualified adjective…','Opacity. VAC bans arrive with no explanation. Players don''t know what triggered the ban, can''t inspect the evidence, and have no meaningful appeal. The system works well enough when it catches real cheaters. When it makes a mistake, the player has no recourse.

Inconsistency. Different publishers enforce different standards. A behavior that''s bannable in Valorant is tolerated in Counter-Strike. A hardware configuration that triggers one anti-cheat is invisible to another. Players operating across multiple games face a patchwork of invisible rules, enforced by systems they can''t inspect, with consequences that don''t transfer.

Capture. When the entity issuing verdicts is also the entity selling t…',0);
INSERT INTO post_revisions VALUES (25,'neutrality-is-a-product-decision','2026-06-15','71074af3','human','Blog: prose cleanup (9 posts), new ''A Solution Looking for a Market'' post, visual enhancements (reading progress bar, animations, blockquote styling, card stagger)','The most common question we get — at every demo, in every conversation, in almost every DM — is some version of this:

We understand the appeal. Verdicts are satisfying. They close the loop. They give you something definitive — this person cheated, this person didn''t — and they let you move on.

Every anti-cheat system defaults to this model because the market demands resolution. Players want to know the cheater got banned. Tournament organizers want a clean/not-clean signal. Publishers want a system that takes the problem off their plate. The verdict model serves all of them, and it works — up to a point.

Opacity. VAC bans arrive with no explanation. Players don''t know what triggered the ban, ca…',0);
INSERT INTO post_revisions VALUES (26,'neutrality-is-a-product-decision','2026-06-14','7c642387','human','blog: publish 6 new posts — The Quiet Season, 272%, The Accusation Economy, Neutrality Is a Product Decision, What Your Setup Says About You, The Ghost of Al Mazrah

- The Quiet Season: founder return from sabbatical, sets editorial context
- 272%: AI cheat explosion analysis, positions proof vs detection
- The Accusation Economy: false accusations as structural problem
- Neutrality Is a Product Decision: why Vera never issues verdicts
- What Your Setup Says About You: system info transparency essay
- The Ghost of Al Mazrah: DMZ love letter and DMZ 2 anticipation
- Rotate feature…',NULL,1);
INSERT INTO post_revisions VALUES (27,'on-what-it-takes','2026-06-17','1552a403','assistant','Rewrite "On What It Takes" in a plainer, truer voice','PR-001 — the very first spec I wrote for Vera, the one that started the process inventory collector — ends with this:

I wrote that instruction for the AI agent that would implement it. I''ve read it many times since.

Nobody reads it and immediately understands what it costs to follow.

The problem is never the code. Code is learnable. You can improve at code. You can get better at architecture, at naming things, at writing tests that actually test something.

The problem is staying when the blockers aren''t code.

WiX Toolset requires admin privileges. The MSI won''t build. The GitHub Release can''t be automated, it has to be manually uploaded. The cloud publisher needs an environment file that lives ou…',0);
INSERT INTO post_revisions VALUES (28,'on-what-it-takes','2026-06-17','fa8968d0','assistant','Rewrite "On What It Takes" with full editorial voice','PR-001 has this instruction at the end:

Nobody reads that and immediately understands what it costs to follow it.

The problem is never the code. Code is learnable. The problem is staying when the blockers aren''t code. The installer requires admin privileges. The build tool has a missing dependency. The release needs to be uploaded manually. The service needs an env file that lives outside version control, typed by hand into a production machine at midnight.

Most of the work of building something real is doing things that aren''t impressive.

The hardest part is never the first step. The first step has the idea behind it. The last step has proximity to the finish. The hard part is the one in the mi…',0);
INSERT INTO post_revisions VALUES (29,'on-what-it-takes','2026-06-17','c5d39782','assistant','Add "On What It Takes" as a published blog post',NULL,1);
INSERT INTO post_revisions VALUES (30,'played-in-the-open','2026-07-10','00bcfc2d','co-authored','Meet Vera: blog and How It Works cross-pollinate; blog catches up to the product (#396)

The sweep of all 28 posts found the funnel''s quiet failure (14 posts
dead-ended, none linked the FAQ) plus a production bug: preseason and
the-league-is-open were missing from the seed registry and silently
404ing on Vercel.…','Whatever you play on, your record is yours. Public if you want it, private if you do not, and nobody has to approve it first.',0);
INSERT INTO post_revisions VALUES (31,'played-in-the-open','2026-06-28','ca6702a7','co-authored','blog: add the practical benefits + the honest cost note to "Played in the open" (#151)

Three additions, kept plain and rooted in real value (no pitch):
- "A home for your clips" — platform-agnostic store / share / sort; your console
  forgets clips in two weeks, Vera keeps them (folded the memories/covers beat in).
- "Your clips can give back" — sharing builds Vera''s library: featured in posts +
  learned-from over time. Grounded in the consent given at upload; pull anytime. …','Your clips do not show up as grey boxes. Each one wears a frame from the play itself, the game you were in, the moment you named, and a quiet mark from us that it is real.

That part matters more than we first thought. A record proves something now. A clip is also the good night with your squad, the clutch nobody believed, the run you will want back in a few years. So when you upload, we ask two small questions: what were you playing, and what was the moment. Answer them or skip them. Either way the clip arrives already telling its story, and it is there when you want to look back.',0);
INSERT INTO post_revisions VALUES (32,'played-in-the-open','2026-06-28','cd9b0043','co-authored','blog: "Played in the open" accommodates the clips-as-memories feature (#142) (#143)

Now that console clips render as covers (a frame from the play, the game, the
moment you named, a quiet Vera mark) and /submit is memory-first ("what were you
playing" + "the moment"), the post carries that elevation: a clip is not only
proof, it is the good night with your squad you will want back. …',NULL,0);
INSERT INTO post_revisions VALUES (33,'played-in-the-open','2026-06-28','d46c0ee2','co-authored','blog: rewrite "Played in the open" — grounded, casual, public-by-default fixed (#139)

Three real problems in the first draft, fixed:
- Framing bug: it said "three separate yeses have to line up before a clip shows,"
  which made the public-by-default thing sound like an opt-in lock. Corrected to the
  truth — clips go up public by default, you consented at upload (no extra step), and
  there are two OFF-switches (you hide them, we can pull one). …','Vera started on PC. You install the agent, you play, and your record builds itself: the processes that ran, the drivers, the sessions, all of it timestamped and there for anyone to inspect. It works. But it only works if there is something to install.

Most of the competitive world plays on console. On a PlayStation or an Xbox there is no agent to run, so for all of those players, Vera had nothing to offer. The people who could use a way to be believed the most, the ones with no record beyond their own word, were exactly the ones we could not reach.

So we changed what a record can be.

## On console, your record is your clips

A PC player''s record is what their machine was doing. A console player''s…',0);
INSERT INTO post_revisions VALUES (34,'played-in-the-open','2026-06-28','e32f9057','co-authored','blog: "Played in the open" — announce console support + clips-as-record (#138)

The release post for the console journey: a console player''s record is their clips,
shared phone-first and web-native (no app store), shown on their profile (public by
default, three-yes consent model). Holds the line — we show the play, never the
verdict. Plants the hybrid-profiles vision as an "if there''s interest" invitation
(console + PC pulled together, navigable, with insights), not a promise. …',NULL,1);
INSERT INTO post_revisions VALUES (35,'preseason','2026-07-05','f55cb7ed','co-authored','blog: Preseason — the patient wait before the real competition (#299)

* blog: Preseason — the patient wait before the real competition (Healthy, drafted by Fable)

The feeling the founder named: patient and on fire at once, the competition
he has trained for his whole life. Grounded in the anticipation science
(the 2010 vacation study, dopamine peaking in the wait), the two-halves
picture (equations and paint), and the true record: playing since 1999,
the agent on his own machine, The League…',NULL,1);
INSERT INTO post_revisions VALUES (36,'present-is-not-proof','2026-07-10','00bcfc2d','co-authored','Meet Vera: blog and How It Works cross-pollinate; blog catches up to the product (#396)

The sweep of all 28 posts found the funnel''s quiet failure (14 posts
dead-ended, none linked the FAQ) plus a production bug: preseason and
the-league-is-open were missing from the seed registry and silently
404ing on Vercel.…',NULL,0);
INSERT INTO post_revisions VALUES (37,'present-is-not-proof','2026-06-20','0c5c64ff','co-authored','content(blog): publish "Present Is Not Proof"

An Industry piece for a younger generation of gifted gamers and technical minds:
we built a check that can spot genuinely dangerous system drivers, it flagged a
real vulnerable driver on one of our own machines (from ordinary monitoring
software), and we refused to turn a present-but-benign fact into a red
accusation. Present is not proof; good is not a crime. Heart-forward, no
mechanics, no secret sauce. …',NULL,1);
INSERT INTO post_revisions VALUES (38,'reputation-shouldnt-need-a-publicist','2026-06-16','8ddbf5a7','co-authored','copy(blog): strip AI-isms across all 8 posts

Structural: remove bold-header list patterns (Opacity/Inconsistency/
Capture/Fragility, You learn X., Sponsorships pull out., For players:)
so they read as prose, not LinkedIn listicles.

Line-level: cut LinkedIn hook opener, Here''s why: frames, throat-clear
phrases (Let me be clear, We know this, We want to be honest about it),
redundant double openers, the AI triplet blockquote closer, and over-
qualified adjective…','Here''s a thing that shouldn''t happen: a player puts in five years of work. Thousands of hours. They grind ranked queues until their mechanics are genuinely elite. Then they go viral for all the wrong reasons. Someone clips a highlight, posts it to a forum, and the comments fill up with people calling it inhuman, impossible, obviously cheated.

There''s something deeper going on too, and we want to be honest about it.

We think this matters. We think it matters now, before the problem gets worse. And we''re building accordingly.',0);
INSERT INTO post_revisions VALUES (39,'reputation-shouldnt-need-a-publicist','2026-06-15','71074af3','human','Blog: prose cleanup (9 posts), new ''A Solution Looking for a Market'' post, visual enhancements (reading progress bar, animations, blockquote styling, card stagger)','Here''s a thing that shouldn''t happen: a player puts in five years of work. Thousands of hours. They grind ranked queues until their mechanics are genuinely elite. Then they go viral — for all the wrong reasons. Someone clips a highlight, posts it to a forum, and the comments fill up with people calling it inhuman, impossible, obviously cheated.

The player is clean. They''ve never touched a cheat engine in their life. But they can''t prove it. And so the narrative sticks.

That''s what we kept hearing. Not just from pros, from regular players — people who care deeply about their reputation in their community. A college player trying to walk onto a team. A content creator watching their audience shr…',0);
INSERT INTO post_revisions VALUES (40,'reputation-shouldnt-need-a-publicist','2026-06-14','7c642387','human','blog: publish 6 new posts — The Quiet Season, 272%, The Accusation Economy, Neutrality Is a Product Decision, What Your Setup Says About You, The Ghost of Al Mazrah

- The Quiet Season: founder return from sabbatical, sets editorial context
- 272%: AI cheat explosion analysis, positions proof vs detection
- The Accusation Economy: false accusations as structural problem
- Neutrality Is a Product Decision: why Vera never issues verdicts
- What Your Setup Says About You: system info transparency essay
- The Ghost of Al Mazrah: DMZ love letter and DMZ 2 anticipation
- Rotate feature…',NULL,0);
INSERT INTO post_revisions VALUES (41,'reputation-shouldnt-need-a-publicist','2026-03-10','3fb53efe','human','feat(blog): premium editorial UI overhaul — drop caps, pull quotes, gradient dividers, Community category, enhanced typography','The problem isn''t that cheaters exist. Every competitive space has bad actors. The problem is that we''ve built no infrastructure to distinguish the real from the fake — so doubt becomes its own punishment, and it lands on whoever''s most visible.

We didn''t start Vera trying to build a cheat detection company. That''s not what this is.

The players who came to us early weren''t reluctant. They were relieved.

There''s something deeper going on too, and I want to be honest about it.

Vera is a bet that proof becomes the foundation of trust in that world. Not anti-cheat (which is reactive, and always one step behind). Not reputation scores (which are gameable). Not community consensus (which is just a pop…',0);
INSERT INTO post_revisions VALUES (42,'reputation-shouldnt-need-a-publicist','2026-03-10','59edc25e','human','fix(blog): move data/posts inside vera-web, fix POSTS_DIR path',NULL,0);
INSERT INTO post_revisions VALUES (43,'reputation-shouldnt-need-a-publicist','2026-03-10','45a5a86a','human','PR-049: blog platform',NULL,1);
INSERT INTO post_revisions VALUES (44,'smell-the-flowers','2026-06-21','30698537','co-authored','refactor(content): finish the "company" reframe, strip em dashes from public copy

Two small consistency passes on the public face.

The corporate "company" frame, removed from two personal essays with the founder''s
sign-off: "a trust company" becomes "a way to make trust provable," and "I
build a company about proof" becomes "a project about proof."…','I''m building a trust company, so I notice when something explains it back to me.',0);
INSERT INTO post_revisions VALUES (45,'smell-the-flowers','2026-06-18','f8c0b7e4','co-authored','content(blog): rewrite "Smell the Flowers" — guarded, no invented scenes

Strip fabricated moments (no dog at the feet, no head-on-foot, no waking up):
state only what''s true. Pull the register back from confessional to
principle: the fear of loss and of getting it wrong is framed as the cost of
engaging anything powerful, not personal disclosure. Keeps Maeve''s name, the
queen''s reason, the want/work thesis, and the Vera tie.','A golden retriever named Maeve. She''s six months old, which means she is mostly legs and wants and a quantity of energy aimed in no particular direction. She is asleep at my feet as I write this, and she is the second golden of my life. The first one belonged to my childhood. This one belongs to whoever I''ve turned into since.

Having her again has shown me something I was too young to see the first time.

It''s easy to forget, because she''s soft and golden and she leans her whole weight against your shins like she''s trying to become part of you. But underneath the softness is a few hundred generations of purpose. She was bred to run, to chase, to carry, to find the thing in the tall grass and br…',0);
INSERT INTO post_revisions VALUES (46,'smell-the-flowers','2026-06-18','d36fa200','co-authored','content(blog): set the keystone in "Smell the Flowers"

Add the emotional core behind Maeve''s name where her power is first named:
re-learning to give yourself fully to something powerful and temporary, the
fear of loss and of failing her, and the nerve to try anyway before fear can
talk you out of it. The courage to begin is the first work.',NULL,0);
INSERT INTO post_revisions VALUES (47,'smell-the-flowers','2026-06-18','730fabbe','co-authored','content(blog): name the dog (Maeve) in "Smell the Flowers"

Weave her name into the subtitle, opening, and the closing beat. A queen''s
name for a powerful animal; the meaning lands the essay''s thesis.','A golden retriever. She''s six months old, which means she is mostly legs and wants and a quantity of energy aimed in no particular direction. She is asleep at my feet as I write this, and she is the second golden of my life. The first one belonged to my childhood. This one belongs to whoever I''ve turned into since.

She just woke up. She put her head on my foot, sighed, and went back to sleep. This powerful animal, choosing stillness. I don''t think she has any idea she''s the best argument I''ve ever seen for the thing I''m building.',0);
INSERT INTO post_revisions VALUES (48,'smell-the-flowers','2026-06-18','defc7023','co-authored','content(blog): publish "Smell the Flowers" (Dispatch, not featured)

A personal essay built on a six-month-old golden: instinct is stage one, the
want every creature gets for free; the magic is the how, the patient work that
builds a trust stronger than instinct so a powerful animal can choose
gentleness. Ties to Vera''s core law (trust is built, not demanded) with a
light hand and links to The Quiet Season and A Solution Looking for a Market.',NULL,1);
INSERT INTO post_revisions VALUES (49,'the-accusation-economy','2026-07-10','00bcfc2d','co-authored','Meet Vera: blog and How It Works cross-pollinate; blog catches up to the product (#396)

The sweep of all 28 posts found the funnel''s quiet failure (14 posts
dead-ended, none linked the FAQ) plus a production bug: preseason and
the-league-is-open were missing from the seed registry and silently
404ing on Vercel.…',NULL,0);
INSERT INTO post_revisions VALUES (50,'the-accusation-economy','2026-06-28','57b05fae','human','copy(deep + blogs): retire the remaining fear-coded language (#115)

Phase 3 of the renewed-voice arc: surgical lighter-touch pass on deep
pages + blog catalog. Front door was Phase 1–2; this closes the trail.

Marketing copy (marketing.ts)
- tagline.sub "Proof, so you never have to fight to be believed." →
  "Proof, ready before anyone asks." (also feeds Margin''s brain)
- trustModel.subtitle "take on faith" → "argue about" (tribe-marker
  retired; rhymes with the home thesis)
- trust…',NULL,0);
INSERT INTO post_revisions VALUES (51,'the-accusation-economy','2026-06-16','8ddbf5a7','co-authored','copy(blog): strip AI-isms across all 8 posts

Structural: remove bold-header list patterns (Opacity/Inconsistency/
Capture/Fragility, You learn X., Sponsorships pull out., For players:)
so they read as prose, not LinkedIn listicles.

Line-level: cut LinkedIn hook opener, Here''s why: frames, throat-clear
phrases (Let me be clear, We know this, We want to be honest about it),
redundant double openers, the AI triplet blockquote closer, and over-
qualified adjective…','These aren''t hypothetical scenarios. These are patterns we''ve heard described, repeatedly, by the people living through them.',0);
INSERT INTO post_revisions VALUES (52,'the-accusation-economy','2026-06-15','71074af3','human','Blog: prose cleanup (9 posts), new ''A Solution Looking for a Market'' post, visual enhancements (reading progress bar, animations, blockquote styling, card stagger)','A player hits a clip. It''s genuinely incredible — a flick shot that lands frame-perfect, a read so precise it looks like information they shouldn''t have had, a sequence of kills that makes the lobby fall silent. They''ve been building to this for years. Thousands of hours of practice. Hundreds of ranked sessions grinding out the muscle memory that makes a moment like this possible.

Someone posts it to a forum. The title is a question — "Is this legit?" — but the tone is an accusation. The comments fill up fast. Inhuman. Impossible. Aimbot. Walls. No way. A few people push back, but the skeptics are louder, and doubt is stickier than defense.

The player is clean. They''ve never touched a cheat in…',0);
INSERT INTO post_revisions VALUES (53,'the-accusation-economy','2026-06-14','7c642387','human','blog: publish 6 new posts — The Quiet Season, 272%, The Accusation Economy, Neutrality Is a Product Decision, What Your Setup Says About You, The Ghost of Al Mazrah

- The Quiet Season: founder return from sabbatical, sets editorial context
- 272%: AI cheat explosion analysis, positions proof vs detection
- The Accusation Economy: false accusations as structural problem
- Neutrality Is a Product Decision: why Vera never issues verdicts
- What Your Setup Says About You: system info transparency essay
- The Ghost of Al Mazrah: DMZ love letter and DMZ 2 anticipation
- Rotate feature…',NULL,1);
INSERT INTO post_revisions VALUES (54,'the-channel-we-havent-built-yet','2026-06-28','57b05fae','human','copy(deep + blogs): retire the remaining fear-coded language (#115)

Phase 3 of the renewed-voice arc: surgical lighter-touch pass on deep
pages + blog catalog. Front door was Phase 1–2; this closes the trail.

Marketing copy (marketing.ts)
- tagline.sub "Proof, so you never have to fight to be believed." →
  "Proof, ready before anyone asks." (also feeds Margin''s brain)
- trustModel.subtitle "take on faith" → "argue about" (tribe-marker
  retired; rhymes with the home thesis)
- trust…','Proof, not reputation. The work is real. The next part is the part we want to build together.',0);
INSERT INTO post_revisions VALUES (55,'the-channel-we-havent-built-yet','2026-06-23','e082ee14','co-authored','content(blog): reframe "Built With" — value-first, no pain selling, open-ended

After the founder''s read, two real changes:

1. The opening was selling the wound (accusation economy as a tax to be
   relieved) to motivate Vera as the relief. Loss-framing dressed up in Vera
   voice. Replaced with an imaginative lead that names the world that becomes
   possible when proof exists by default: rivals who push each other without
   wondering, being doubted not having to be permanent, being exceptional not…','Vera is small and the work is real.

A handful of records on the site today, kept neutrally, kept open. A new Field Guide that names what runs on a gaming PC in words you can actually use. A side-by-side surface for putting two players'' records next to each other when an accusation flies. None of it solves the problem on its own. All of it exists, and all of it could be ten times sharper.

This is a note for the people we hope will help us figure out the rest.

You probably know the problem. You play hard, you stream, you build a community, and one bad clip can spiral into a campaign you never agreed to. The accusation economy is a tax everyone pays, and it hits hardest the people who care most ab…',0);
INSERT INTO post_revisions VALUES (56,'the-channel-we-havent-built-yet','2026-06-23','4f093ccb','co-authored','content(blog): rewrite "The Channel We Haven''t Built Yet" as "Built With"

The original was a vision post about one specific thing: a Vera YouTube
channel. The reframe broadens it into what it actually wanted to be: an open
invitation to collaborators, peer to peer, from a small project with a clear
opinion. …','Right now, if you spend any time in the extraction community, you can feel something coming.

Nobody has the date. Activision has said only that a new extraction experience is on the way, and the rest is leaks, group chats, and the particular hum a community makes when it senses its next chapter is close. Call it DMZ''s return. Call it whatever it turns out to be. What matters is that a lot of people who love this kind of game are about to walk into a new world together, and for a little while, they get to decide what they carry in with them.

We have been thinking hard about a small part of that. Specifically, about a YouTube channel that does not exist yet. Ours.

What you would find on the Vera …',0);
INSERT INTO post_revisions VALUES (57,'the-channel-we-havent-built-yet','2026-06-21','7a842935','co-authored','refactor(blog): drop the corporate "company" frame from the vision post

Vera is not a company, it is a project and a community, so the vision post
should not call itself one. "Most channels a company runs are megaphones"
becomes "built to sell you something." "A company that will not exaggerate
its own channel..." becomes "Something that will not inflate its own reach
will not inflate your record either." Fittingly, "company" comes from com plus
panis, the people you break bread with: we…','Most channels a company runs are megaphones. The logo talks, the audience listens, and everyone understands the arrangement. You are there to be marketed to, and the channel exists to convert you. There is nothing evil about it. It is just not very alive.

That last sentence is the whole project, honestly. It is the same reason the records can be trusted in the first place. A company that will not exaggerate its own channel is a company that will not exaggerate your innocence either. The discipline is the point.',0);
INSERT INTO post_revisions VALUES (58,'the-channel-we-havent-built-yet','2026-06-21','6913f95c','co-authored','feat(blog): publish "The Channel We Haven''t Built Yet"

A vision piece on what Vera''s YouTube could become: a home for the creators
who care about fair play, not a megaphone for Vera. Framed honestly as a
vision that does not exist yet. It names no creator as a partner and treats
DMZ''s return as anticipation, not confirmation. Authored as The Vera Project.

Regenerated blog-seed.ts (19 posts).',NULL,1);
INSERT INTO post_revisions VALUES (59,'the-field-guide','2026-07-10','00bcfc2d','co-authored','Meet Vera: blog and How It Works cross-pollinate; blog catches up to the product (#396)

The sweep of all 28 posts found the funnel''s quiet failure (14 posts
dead-ended, none linked the FAQ) plus a production bug: preseason and
the-league-is-open were missing from the seed registry and silently
404ing on Vercel.…','Every driver on the public LOLDrivers list, 435 of them at the moment, gets a page. The famous ones, the boring ones, the weird ones, the ones almost nobody has heard of. You can search. You can filter by vendor family (MSI, Intel, ASUS, Gigabyte, Dell, Corsair, Realtek, Capcom, miHoYo, and nearly forty more). You can switch from the catalog grid to a constellation view, where every driver becomes a star placed by its own identity. Touch one, and the rest of its family lights up across the sky.

We are at 190 curated notes today, more than two of every five drivers in the catalog, and we keep writing them. They started as a single batch and have grown every week since.

Where we cannot vouch for…',0);
INSERT INTO post_revisions VALUES (60,'the-field-guide','2026-06-29','c3763a3e','human','Field Guide: "Lobby crashing, untangled" + feature-release blog post (#170)

A new evergreen Field Guide entry at /field-guide/lobby-crashing: the three-things-one-name taxonomy, a severity ladder, a sourced cross-game record, and a constructive prevention playbook with honest tradeoffs. Describe, never condemn; a reference, not a manual.…',NULL,0);
INSERT INTO post_revisions VALUES (61,'the-field-guide','2026-06-27','84dba697','co-authored','feat(field-guide): an evergreen explainer at /field-guide/about + a tighter entry blurb (#85)

The hub''s "learn more" link pointed at the dated launch blog, a snapshot frozen
at the drivers-first moment that drifts as the guide grows. Add a canonical
evergreen page (a "specimen tour" in the trust-model tier: guilloché hero well,
Cormorant chapter marks, the three real specimen languages, AccessDepth core
samples, the master seal) and repoint the hub at it. …',NULL,0);
INSERT INTO post_revisions VALUES (62,'the-field-guide','2026-06-23','9921ff88','co-authored','Field Guide: the emblem engine, evolved (five meaningful body plans) + blog refresh (#22)

* feat(field-guide): the emblem engine, evolved — five meaningful body plans

The generative creature had one silhouette wearing different colors. Memory
keys on shape, so two specimens read as the same animal in different paint. …','Every driver on the public LOLDrivers list, 435 of them at the moment, gets a page. The famous ones, the boring ones, the weird ones, the ones almost nobody has heard of. You can search. You can filter by vendor family (MSI, Intel, ASUS, Gigabyte, Dell, Corsair, Realtek, Capcom, miHoYo, and twelve more). You can switch from the catalog grid to a constellation view, where every driver becomes a star placed by its own identity. Touch one, and the rest of its family lights up across the sky.

We are at 44 curated notes today. We will write more. The catalog grew its first batch in two weeks; it will keep growing.

Where we cannot vouch for something, we say so. Of those 435 drivers, only 44 have cu…',0);
INSERT INTO post_revisions VALUES (63,'the-field-guide','2026-06-23','0eef7a80','assistant','style(blog): strip em dashes from the field guide post','Modern Windows is built to load only signed kernel drivers. A driver is signed by a company Microsoft has vouched for — MSI, Intel, ASUS, Dell, Capcom, miHoYo, and so on. That signing process is the gate.

So when a vendor patches a kernel driver — and they do, MSI patched RTCore64, ASUS patched AsIO3, Dell patched the dbutil driver that lived in the wild for over a decade — the patched build replaces the old one only on the machines that actually install the update. The signed old build is still out there. It still loads. And it still does, by design, the same low-level thing it did before: read and write arbitrary kernel memory, talk to hardware ports, peek into processes.

This is what the se…',0);
INSERT INTO post_revisions VALUES (64,'the-field-guide','2026-06-23','ed8c5b46','assistant','feat(field-guide): out of hiding — homepage showcase, hub OG, and "A field guide to your own machine"

Makes the Field Guide a visible permanent tenant of the Vera ecosystem, and
ships a long-form announcement to go with it.

The blog post (data/posts/the-field-guide.md, "A field guide to your own
machine") is roughly an eight-minute read written for the young, smart,
skeptical gamer. Opens with the plain truth that millions of people have
RTCore64.sys on their machine because they installed MSI Afterburner. …',NULL,1);
INSERT INTO post_revisions VALUES (65,'the-ghost-of-al-mazrah','2026-07-10','00bcfc2d','co-authored','Meet Vera: blog and How It Works cross-pollinate; blog catches up to the product (#396)

The sweep of all 28 posts found the funnel''s quiet failure (14 posts
dead-ended, none linked the FAQ) plus a production bug: preseason and
the-league-is-open were missing from the seed registry and silently
404ing on Vercel.…',NULL,0);
INSERT INTO post_revisions VALUES (66,'the-ghost-of-al-mazrah','2026-06-21','3a45435b','co-authored','fix(blog): ground al-Mazrah''s DMZ 2 claims in fact, not confirmation

The live "Ghost of al-Mazrah" post stated DMZ 2 as settled fact: "confirmed
for Modern Warfare 4," a hard "October 23, 2026" launch date, the Hajin map,
the CIA-asset premise, and "Infinity Ward is calling it..." None of that is
official. Activision has only confirmed that a new extraction experience is
coming. The rest is leaks and reporting, however loud and consistent.…','I''m writing this because DMZ is coming back. DMZ 2, confirmed for Modern Warfare 4, launching October 23, 2026. Infinity Ward is calling it the "definitive" extraction experience. A full-featured 1.0, not a beta. A dedicated third pillar of the game, built from years of player feedback.

Modern Warfare 4 launches October 23, 2026. DMZ is back.

The Hajin Exclusion Zone, a war-torn region on the border of North Korea, South Korea, and Russia, replaces Al Mazrah as the operational theater. Players operate as off-the-books CIA assets recovering advanced military technology. The mode features persistent progression, a customizable Forward Operating Base, dynamic weather, story-driven missions, and t…',0);
INSERT INTO post_revisions VALUES (67,'the-ghost-of-al-mazrah','2026-06-16','8ddbf5a7','co-authored','copy(blog): strip AI-isms across all 8 posts

Structural: remove bold-header list patterns (Opacity/Inconsistency/
Capture/Fragility, You learn X., Sponsorships pull out., For players:)
so they read as prose, not LinkedIn listicles.

Line-level: cut LinkedIn hook opener, Here''s why: frames, throat-clear
phrases (Let me be clear, We know this, We want to be honest about it),
redundant double openers, the AI triplet blockquote closer, and over-
qualified adjective…','DMZ is the reason I understand, viscerally, not intellectually, why Vera needs to exist.

DMZ 2 deserves better than what happened to the original. The players who show up for it deserve proof that their investment matters. The community that rebuilds around it deserves infrastructure that protects what they build. And the game itself, this extraordinary, improbable, irreplaceable thing, deserves to survive the forces that killed it the first time.',0);
INSERT INTO post_revisions VALUES (68,'the-ghost-of-al-mazrah','2026-06-16','4b979d22','co-authored','copy(blog): Vera is a project, not a company

Replace ''Company'' category with ''Dispatch'' on all founder-voice posts.
Scrub self-referential ''company'' prose — the project is Vera Project,
the blog is a project log. Intentional contrasts (''not from a company,
but from someone…'', anti-cheat company foil) kept as-is.','I''m going to be honest in a way that most company blogs aren''t.',0);
INSERT INTO post_revisions VALUES (69,'the-ghost-of-al-mazrah','2026-06-15','bc8239a4','co-authored','blog: voice + identity + the manuscript reader

Voice — purge AI tells. Rewrite "The Same Kind of Brave" with zero em
dashes and no machine cadence; intentional punctuation only. (The other
nine posts were already em-dash-free.) Added a quiet line honoring artists
who write straight at their darkness — the spirit behind the work.…',NULL,0);
INSERT INTO post_revisions VALUES (70,'the-ghost-of-al-mazrah','2026-06-15','71074af3','human','Blog: prose cleanup (9 posts), new ''A Solution Looking for a Market'' post, visual enhancements (reading progress bar, animations, blockquote styling, card stagger)','Not a competitive shooter with ranked queues and leaderboards. Not a battle royale with shrinking circles and victory screens. Something different. Something that, for a window of time, was the most compelling experience in gaming — and then was taken from us by the two forces that destroy every good thing in this industry: cheaters who couldn''t leave it alone, and a publisher who decided it wasn''t worth saving.

This is about DMZ. The original. The "beta" that was never really a beta — it was a living, breathing world that a community built their entire gaming life around. And this is about what happens when a game like that dies. Not with a dramatic shutdown or a farewell event, but with a s…',0);
INSERT INTO post_revisions VALUES (71,'the-ghost-of-al-mazrah','2026-06-14','7c642387','human','blog: publish 6 new posts — The Quiet Season, 272%, The Accusation Economy, Neutrality Is a Product Decision, What Your Setup Says About You, The Ghost of Al Mazrah

- The Quiet Season: founder return from sabbatical, sets editorial context
- 272%: AI cheat explosion analysis, positions proof vs detection
- The Accusation Economy: false accusations as structural problem
- Neutrality Is a Product Decision: why Vera never issues verdicts
- What Your Setup Says About You: system info transparency essay
- The Ghost of Al Mazrah: DMZ love letter and DMZ 2 anticipation
- Rotate feature…',NULL,1);
INSERT INTO post_revisions VALUES (72,'the-hitch-you-feel','2026-08-03','1f8504fa','co-authored','blog: "The short version", a reusable summary block for posts (#510)

A reader who never scrolls should still leave knowing the claims and the
numbers. Each point is a statement that stands alone, in the post''s own
voice, rather than a teaser or a table of contents, which is why they
read as facts and not as promises about what is coming.…',NULL,0);
INSERT INTO post_revisions VALUES (73,'the-hitch-you-feel','2026-08-03','294e485a','co-authored','blog + surfaces: the hitch you feel, and what measuring it costs (#506)

The public half of PR-065, now that the feature is proven live.

The post explains the thing average framerate hides (a game can average
200 fps and still hand you an 80 ms frame), how the measurement works
without touching the game, and the version we deliberately refused to
build: strong-rig-weak-frames as a cheat signal accuses a hundred
honest players to maybe catch one, and misses the setups that read
memory fro…',NULL,1);
INSERT INTO post_revisions VALUES (74,'the-horse-who-waved-me-over','2026-06-21','30698537','co-authored','refactor(content): finish the "company" reframe, strip em dashes from public copy

Two small consistency passes on the public face.

The corporate "company" frame, removed from two personal essays with the founder''s
sign-off: "a trust company" becomes "a way to make trust provable," and "I
build a company about proof" becomes "a project about proof."…','I build a company about proof. Most days that word sounds technical. This morning it did not.',0);
INSERT INTO post_revisions VALUES (75,'the-horse-who-waved-me-over','2026-06-18','39ad8be7','co-authored','content(blog): publish "The Horse Who Waved Me Over"

A Dispatch on attention and witness: a horse that asked to be seen, a place
holding love and hard things, and the truth that the work is never for nothing
because connection is the one thing no one owns. Real neighbors are shielded
(no names, no farm name, no stated private struggles); only what is the founder''s to
tell is told. Soundtrack woven in: SYML, "The Dark."',NULL,1);
INSERT INTO post_revisions VALUES (76,'the-image-is-the-proof','2026-06-26','222d44ee','human','Correct the "evidence cannot be faked" overclaim across the record (+ Flxnked grounding) (#48)

Manifesto Principle 2 + muscle-memory/image-is-the-proof posts + Field Guide hub + prod blog-seed: "evidence cannot be faked" -> "isolated evidence is cheap to fake; a coherent record is not." Adds the sourced Flxnked false-accusation case as grounding, framed on the show-data side. Includes the re-grounded trust-thesis memory.',NULL,0);
INSERT INTO post_revisions VALUES (77,'the-image-is-the-proof','2026-06-24','c5c0e73c','co-authored','Field Guide: the hub becomes an engraved frontispiece, with its own master seal + the "image is the proof" plug (#37)

* feat(field-guide): the master seal — a guilloché medallion struck from the whole catalog

The guide that says "the image is the proof" now wears its own proof. A single
large rose-engine medallion, seeded only from the catalog''s verifiable record
(driver count, field notes, games, processes, blocklist refresh date), with that
record''s fingerprint milled into the rim like a coin''s inscription. …',NULL,1);
INSERT INTO post_revisions VALUES (78,'the-league-is-open','2026-07-05','740a2c2c','human','feat(forum): The League — Vera''s forum on the record, swept, desked, announced (Fable) (#295)

PR-062 end to end: the vision doc, migration 0058 (rooms/topics/posts/flags/members + the append-only forum_events ledger), the Haiku sweep with a stronger-model second look (reversible verbs only), the public room at /forum with guidelines and a public moderation log, the solo-operator Forum Desk, and the launch companions (The League Is Open dispatch, the struck OG seal, Margin wayfinding, the seeding kit).',NULL,1);
INSERT INTO post_revisions VALUES (79,'the-look-alike-problem','2026-07-28','7a4a29c3','co-authored','blog: two new posts, The look-alike problem and Ironwood (#497)

Two council-reviewed posts ship together.

The look-alike problem (Industry, Vera Team): the false-positive
companion to Where cheats hide now. Honest software does the same
mechanical moves cheats do, a detection pattern is a proxy, the Vizor
trigger-string incident with the counts shown and not settled, what an
appeal actually is, and the practical close. …',NULL,1);
INSERT INTO post_revisions VALUES (80,'the-number-you-cant-feel','2026-09-01','5c079f6c','assistant','errata door, the instrument links, the council''s fourth seat, the weights note

The person door on the errata README gains two civilian sentences before
the console block: the two readers it claims to be for both glazed at
it today, and the fix is the same as the morning-brief page''s, plain
words first and the code box named as skippable. …',NULL,0);
INSERT INTO post_revisions VALUES (81,'the-number-you-cant-feel','2026-09-01','9c5b93f2','assistant','blog: three citations sharpened by the pre-merge audit

Every link in the post was probed against the indexes before merge.
Ten verified exact; three sharpened: the Levitan reporting link loses
its amp path variant for the canonical URL, the 936 million figure now
carries the study''s actual band (adults 30 to 69), and the undiagnosed
majority claim moves to the Punjabi epidemiology review that verifiably
carries it (the previous PMC id did not verify and is not repeated).','Obstructive sleep apnea, the condition where the airway closes repeatedly overnight and the oxygen number dips over and over, affects an estimated 936 million adults worldwide30198-5/abstract). The large majority never get diagnosed. The morning delivers its report as fog, a short fuse, a fourth coffee, and every one of those has a dozen innocent explanations, so the real one hides in the crowd.',0);
INSERT INTO post_revisions VALUES (82,'the-number-you-cant-feel','2026-09-01','707e29eb','assistant','blog: The Number You Can''t Feel, on blood oxygen and honest instruments

A Philosophy dispatch seeded on the founder''s word. The most load-bearing
number in a life has no nerve ending assigned to it; the alarm is wired
to the exhaust gas; the shortage takes the noticer first. Aoyagi found
the reading inside the noise other engineers filtered out, and the
instrument''s own skin-tone bias carries the house lesson that an
instrument''s first duty is honesty about itself. …',NULL,1);
INSERT INTO post_revisions VALUES (83,'the-quiet-season','2026-06-16','8ddbf5a7','co-authored','copy(blog): strip AI-isms across all 8 posts

Structural: remove bold-header list patterns (Opacity/Inconsistency/
Capture/Fragility, You learn X., Sponsorships pull out., For players:)
so they read as prose, not LinkedIn listicles.

Line-level: cut LinkedIn hook opener, Here''s why: frames, throat-clear
phrases (Let me be clear, We know this, We want to be honest about it),
redundant double openers, the AI triplet blockquote closer, and over-
qualified adjective…','I came back understanding that more deeply than when I left. The break didn''t change what Vera is. It sharpened my understanding of why it matters, and made me more patient about how it gets there.

I also came back a better version of the person building it. More grounded. Better at listening. Clearer about what I''m willing to compromise on and what I''m not.',0);
INSERT INTO post_revisions VALUES (84,'the-quiet-season','2026-06-16','4b979d22','co-authored','copy(blog): Vera is a project, not a company

Replace ''Company'' category with ''Dispatch'' on all founder-voice posts.
Scrub self-referential ''company'' prose — the project is Vera Project,
the blog is a project log. Intentional contrasts (''not from a company,
but from someone…'', anti-cheat company foil) kept as-is.','That probably sounds strange on a company blog. But Vera is a trust product. And I''ve learned, slowly, that you can''t build trust infrastructure if you''re not doing the work of being trustworthy in your own life. The skills transfer. Listening transfers. Patience transfers. The willingness to sit with uncertainty instead of rushing to a conclusion transfers most of all.',0);
INSERT INTO post_revisions VALUES (85,'the-quiet-season','2026-06-15','bc8239a4','co-authored','blog: voice + identity + the manuscript reader

Voice — purge AI tells. Rewrite "The Same Kind of Brave" with zero em
dashes and no machine cadence; intentional punctuation only. (The other
nine posts were already em-dash-free.) Added a quiet line honoring artists
who write straight at their darkness — the spirit behind the work.…',NULL,0);
INSERT INTO post_revisions VALUES (86,'the-quiet-season','2026-06-15','71074af3','human','Blog: prose cleanup (9 posts), new ''A Solution Looking for a Market'' post, visual enhancements (reading progress bar, animations, blockquote styling, card stagger)','I''m not going to dress that up. There''s no announcement to explain the gap, no "exciting news" to justify the silence. The truth is simpler and more honest than that: I stepped away. Not from Vera — from the pace. From the constant forward motion that makes you feel productive but doesn''t always make you better.

The longer version is that I spent time strengthening relationships — with the people closest to me, with people I''d let distance grow between. I worked on communication. Not the startup kind, where you practice your pitch until it''s frictionless. The real kind. The kind where you sit with someone and say the thing that''s hard to say, and then you listen to what comes back.

I followed …',0);
INSERT INTO post_revisions VALUES (87,'the-quiet-season','2026-06-14','7c642387','human','blog: publish 6 new posts — The Quiet Season, 272%, The Accusation Economy, Neutrality Is a Product Decision, What Your Setup Says About You, The Ghost of Al Mazrah

- The Quiet Season: founder return from sabbatical, sets editorial context
- 272%: AI cheat explosion analysis, positions proof vs detection
- The Accusation Economy: false accusations as structural problem
- Neutrality Is a Product Decision: why Vera never issues verdicts
- What Your Setup Says About You: system info transparency essay
- The Ghost of Al Mazrah: DMZ love letter and DMZ 2 anticipation
- Rotate feature…',NULL,1);
INSERT INTO post_revisions VALUES (88,'the-same-kind-of-brave','2026-06-18','33ac81eb','co-authored','content(blog): publish "You''re Early" as the featured welcome post

A Dispatch piece that turns the recent inward arc outward to face the
arriving reader: what Vera is, why it''s for them, and why being early is the
point. Featured on /blog (demotes "The Same Kind of Brave"). Signs off as a
Vera record (a single timestamped stamp), so the post itself is the proof.…',NULL,0);
INSERT INTO post_revisions VALUES (89,'the-same-kind-of-brave','2026-06-16','d9e0d146','co-authored','content(blog): feature "The Same Kind of Brave" as the hero post

Promote the-same-kind-of-brave to the featured slot on /blog and demote
a-solution-looking-for-a-market so there is exactly one hero. Regenerated seed.',NULL,0);
INSERT INTO post_revisions VALUES (90,'the-same-kind-of-brave','2026-06-16','4b979d22','co-authored','copy(blog): Vera is a project, not a company

Replace ''Company'' category with ''Dispatch'' on all founder-voice posts.
Scrub self-referential ''company'' prose — the project is Vera Project,
the blog is a project log. Intentional contrasts (''not from a company,
but from someone…'', anti-cheat company foil) kept as-is.','In the scheme of a trust and verification company, it is a small thing. A list of songs. You can see it at /sounds. I almost didn''t write about it. Then I noticed it had been sitting with me for days, and the reason felt worth saying plainly.',0);
INSERT INTO post_revisions VALUES (91,'the-same-kind-of-brave','2026-06-15','bc8239a4','co-authored','blog: voice + identity + the manuscript reader

Voice — purge AI tells. Rewrite "The Same Kind of Brave" with zero em
dashes and no machine cadence; intentional punctuation only. (The other
nine posts were already em-dash-free.) Added a quiet line honoring artists
who write straight at their darkness — the spirit behind the work.…','In the scheme of a trust-and-verification company, it''s a small thing. A list of songs. You can see it at /sounds. I almost didn''t write about it. Then I noticed it had been sitting with me for days, and the reason why felt worth saying out loud.

It''s simple: the songs I built Vera to. Banner music for the days that went right, fight tracks for the days that didn''t, the stuff that played at 2am when the only company was the work.

We rebuilt it this week with more care than a music page strictly needs. You can sort the tracks by mood now. There''s a spectral waveform across the top that I''m a little absurdly proud of — real color poured through old terminal characters, glowing like a signal comi…',0);
INSERT INTO post_revisions VALUES (92,'the-same-kind-of-brave','2026-06-15','e3be6c6a','co-authored','blog: publish "The Same Kind of Brave"

A reflection (the founder, Company) sparked by the /sounds rebuild: the courage
artists, competitors, and builders share in putting the real thing in front
of the world, and why Vera''s proof-not-reputation exists to protect it.…',NULL,1);
INSERT INTO post_revisions VALUES (93,'the-trust-crossplay-forgot','2026-07-10','00bcfc2d','co-authored','Meet Vera: blog and How It Works cross-pollinate; blog catches up to the product (#396)

The sweep of all 28 posts found the funnel''s quiet failure (14 posts
dead-ended, none linked the FAQ) plus a production bug: preseason and
the-league-is-open were missing from the seed registry and silently
404ing on Vercel.…',NULL,0);
INSERT INTO post_revisions VALUES (94,'the-trust-crossplay-forgot','2026-06-28','11abac7a','co-authored','blog: "The trust crossplay forgot" — the cross-platform positioning piece (#141)

The WHY companion to "Played in the open." Grounded in a real, current event
(April 2025: CoD let console players turn off crossplay with PC to dodge cheaters)
and the bidirectional distrust (console fears PC aimbots; PC resents console
scripts + aim assist). The thesis: crossplay united the mechanics, not the trust,
and one record anyone can read closes that gap, whatever the platform. …',NULL,1);
INSERT INTO post_revisions VALUES (95,'things-you-know-and-cannot-show','2026-08-29','8a6f8a69','human','blog: things you know and cannot show (#594)

The companion to the settlement post, on how a company built on proof
accounts for what people know and cannot show.

Opens with Klein''s fire lieutenant, corrected in the one way that matters:
he did not work out that the fire was in the basement, he did not know the
house had a basement. His expectations were violated and he left. …',NULL,1);
INSERT INTO post_revisions VALUES (96,'what-if-your-mouse-could-vouch-for-you','2026-07-10','00bcfc2d','co-authored','Meet Vera: blog and How It Works cross-pollinate; blog catches up to the product (#396)

The sweep of all 28 posts found the funnel''s quiet failure (14 posts
dead-ended, none linked the FAQ) plus a production bug: preseason and
the-league-is-open were missing from the seed registry and silently
404ing on Vercel.…',NULL,0);
INSERT INTO post_revisions VALUES (97,'what-if-your-mouse-could-vouch-for-you','2026-06-26','222d44ee','human','Correct the "evidence cannot be faked" overclaim across the record (+ Flxnked grounding) (#48)

Manifesto Principle 2 + muscle-memory/image-is-the-proof posts + Field Guide hub + prod blog-seed: "evidence cannot be faked" -> "isolated evidence is cheap to fake; a coherent record is not." Adds the sourced Flxnked false-accusation case as grounding, framed on the show-data side. Includes the re-grounded trust-thesis memory.','> We called Vera''s first layer a reputation ledger written in cryptographic receipts. This second layer would be something else: a reputation ledger written in muscle memory. And muscle memory, by definition, cannot be faked, because you cannot fake the hours that built it.',0);
INSERT INTO post_revisions VALUES (98,'what-if-your-mouse-could-vouch-for-you','2026-06-16','13e22ff9','co-authored','content(blog): deepen "What If Your Inputs Could Vouch for You?" for technical readers

Rewrite the input-biometrics post in the current house voice (em-dash-free,
declarative, cross-linked) and add real engineering substance for in-depth
onlookers: kinematics/submovement/Fitts features, 8-12Hz tremor via PSD,
ex-Gaussian reaction-time fits, KS/Wasserstein anomaly scoring, input-vs-
game-state correlation, and an honestly-caveated adversarial section.
Regenerated blog-seed.ts. …','It''s a narrow question, deliberately. We record processes, drivers, and system integrity signals: the stuff that would tell you whether cheat software was present. We don''t analyze your play. We don''t evaluate whether your shots were too good. We''re not in the business of judging outcomes, because outcomes are a terrible proxy for integrity.

> A world champion hitting impossible shots is still clean. A mediocre player missing everything could still be cheating. Stats don''t tell the story. Evidence does.

That''s where Vera sits today. System state. Clean signal. Inspectable by anyone.

But there''s a question we keep coming back to: what if the inputs themselves could vouch for you?

That vocabulary …',0);
INSERT INTO post_revisions VALUES (99,'what-if-your-mouse-could-vouch-for-you','2026-06-16','8ddbf5a7','co-authored','copy(blog): strip AI-isms across all 8 posts

Structural: remove bold-header list patterns (Opacity/Inconsistency/
Capture/Fragility, You learn X., Sponsorships pull out., For players:)
so they read as prose, not LinkedIn listicles.

Line-level: cut LinkedIn hook opener, Here''s why: frames, throat-clear
phrases (Let me be clear, We know this, We want to be honest about it),
redundant double openers, the AI triplet blockquote closer, and over-
qualified adjective…','But there''s a question we keep coming back to internally, and we''ve decided to say it out loud: what if the inputs themselves could vouch for you?',0);
INSERT INTO post_revisions VALUES (100,'what-if-your-mouse-could-vouch-for-you','2026-06-15','71074af3','human','Blog: prose cleanup (9 posts), new ''A Solution Looking for a Market'' post, visual enhancements (reading progress bar, animations, blockquote styling, card stagger)','It''s a narrow question, deliberately. We record processes, drivers, and system integrity signals — the stuff that would tell you whether cheat software was present. We don''t analyze your play. We don''t evaluate whether your shots were too good. We''re not in the business of judging outcomes, because outcomes are a terrible proxy for integrity.

But there''s a question we keep coming back to internally, and we''ve decided to just say it out loud: what if the inputs themselves could vouch for you?

Every competitive player builds something over thousands of hours of practice: a physical vocabulary. A set of reflexes and micro-habits so deeply ingrained that they happen below conscious thought. That v…',0);
INSERT INTO post_revisions VALUES (101,'what-if-your-mouse-could-vouch-for-you','2026-03-23','8353243b','human','Fix: Admin pages + installer release update','Mouse movement in competitive FPS is not random. It has structure. It has character. If you''ve spent five thousand hours developing your mechanics — your flick speed, your tracking style, how you land on a head, how you correct when you overshoot — that accumulated muscle memory has a shape. A statistical fingerprint. It''s as specific to you as your handwriting, and in some ways more reliable, because it was built over years and lives in your hands rather than your head.

A world-class player doesn''t just have better aim than you. They have a different kind of aim. Their velocity curves during a flick shot. The micro-tremor signature from their hand at rest. The precise ratio of large gross mo…',0);
INSERT INTO post_revisions VALUES (102,'what-if-your-mouse-could-vouch-for-you','2026-03-10','3fb53efe','human','feat(blog): premium editorial UI overhaul — drop caps, pull quotes, gradient dividers, Community category, enhanced typography','A world champion hitting impossible shots is still clean. A mediocre player missing everything could still be cheating. Stats don''t tell the story. Evidence does.

The comparison that becomes possible is striking: a cheater using an aimbot produces superhuman outcomes from suspiciously simple inputs. A legitimate world champion produces superhuman outcomes from demonstrably complex, consistent, human inputs. The outcomes look the same from the outside. The inputs don''t.

We called Vera''s first layer a reputation ledger written in cryptographic receipts. This second layer would be something else: a reputation ledger written in muscle memory. And muscle memory, by definition, can''t be faked — beca…',0);
INSERT INTO post_revisions VALUES (103,'what-if-your-mouse-could-vouch-for-you','2026-03-10','59edc25e','human','fix(blog): move data/posts inside vera-web, fix POSTS_DIR path',NULL,0);
INSERT INTO post_revisions VALUES (104,'what-if-your-mouse-could-vouch-for-you','2026-03-10','45a5a86a','human','PR-049: blog platform',NULL,1);
INSERT INTO post_revisions VALUES (105,'what-your-setup-says-about-you','2026-07-10','00bcfc2d','co-authored','Meet Vera: blog and How It Works cross-pollinate; blog catches up to the product (#396)

The sweep of all 28 posts found the funnel''s quiet failure (14 posts
dead-ended, none linked the FAQ) plus a production bug: preseason and
the-league-is-open were missing from the seed registry and silently
404ing on Vercel.…',NULL,0);
INSERT INTO post_revisions VALUES (106,'what-your-setup-says-about-you','2026-06-16','8ddbf5a7','co-authored','copy(blog): strip AI-isms across all 8 posts

Structural: remove bold-header list patterns (Opacity/Inconsistency/
Capture/Fragility, You learn X., Sponsorships pull out., For players:)
so they read as prose, not LinkedIn listicles.

Line-level: cut LinkedIn hook opener, Here''s why: frames, throat-clear
phrases (Let me be clear, We know this, We want to be honest about it),
redundant double openers, the AI triplet blockquote closer, and over-
qualified adjective…','We shipped something recently that we want to walk you through.

This is a product update post. But it''s also a transparency exercise. Vera is a trust product, and trust products don''t get to ship data collection features without explaining exactly what they collect, what they don''t, and why.',0);
INSERT INTO post_revisions VALUES (107,'what-your-setup-says-about-you','2026-06-15','71074af3','human','Blog: prose cleanup (9 posts), new ''A Solution Looking for a Market'' post, visual enhancements (reading progress bar, animations, blockquote styling, card stagger)','Vera sessions now include a system profile — a snapshot of the hardware and software environment where gameplay happened. When you visit a session on a Vera profile, you''ll see it displayed above the process and driver tables: operating system, processor, GPU, RAM, BIOS mode, Secure Boot state, and virtualization configuration.

This is a product update post. But it''s also something more specific: a transparency exercise. Because Vera is a trust product, and trust products don''t get to ship data collection features without explaining exactly what they collect, what they don''t, and why.

The system profile is built from standard Windows Management Instrumentation (WMI) queries — the same data you…',0);
INSERT INTO post_revisions VALUES (108,'what-your-setup-says-about-you','2026-06-14','7c642387','human','blog: publish 6 new posts — The Quiet Season, 272%, The Accusation Economy, Neutrality Is a Product Decision, What Your Setup Says About You, The Ghost of Al Mazrah

- The Quiet Season: founder return from sabbatical, sets editorial context
- 272%: AI cheat explosion analysis, positions proof vs detection
- The Accusation Economy: false accusations as structural problem
- Neutrality Is a Product Decision: why Vera never issues verdicts
- What Your Setup Says About You: system info transparency essay
- The Ghost of Al Mazrah: DMZ love letter and DMZ 2 anticipation
- Rotate feature…',NULL,1);
INSERT INTO post_revisions VALUES (109,'where-cheats-hide-now','2026-07-10','00bcfc2d','co-authored','Meet Vera: blog and How It Works cross-pollinate; blog catches up to the product (#396)

The sweep of all 28 posts found the funnel''s quiet failure (14 posts
dead-ended, none linked the FAQ) plus a production bug: preseason and
the-league-is-open were missing from the seed registry and silently
404ing on Vercel.…',NULL,0);
INSERT INTO post_revisions VALUES (110,'where-cheats-hide-now','2026-07-03','81f24b8d','co-authored','blog: Where cheats hide now — a forensic field-guide explainer (#263)

Ships blog idea #1 from the research, deliberately DIFFERENTIATED from the existing
''272%'' post (which argues WHY detection is breaking). This is the lobby-crashing
register the founder asked for: a plain-words map, not a thesis. …',NULL,1);
INSERT INTO post_revisions VALUES (111,'where-the-time-goes','2026-07-28','e414ec7f','co-authored','blog: strip signpost bridges from Where the Time Goes; feature Ironwood (#498)

the founder''s directive applied: the no-signpost-bridges rigor on this one
shipped post as it should have read, publication date untouched. Seven
bridges stripped, each replaced by a statement carrying the content
instead of a promise about the next paragraph. Ironwood promoted to
featured, making it the blog hero by newest-first plus
first-featured-wins; Where the Time Goes keeps its flag and its date.','I want to talk about why that happens, because the science on it is honest and stranger than the folk version. And then I want to tell you what it has to do with why Vera exists at all.

Here is the thing I kept running into: we live some of our most alive time in these games, and almost none of it gets kept. Seasons end. Servers sunset. The clip is on a drive somewhere. The self you were across five thousand honest hours has no page anywhere. The densest time in the week, written down nowhere.

Here is a thing I will brag about, because we built it on purpose. Vera treats family as a first-class fact. Most of the industry handles kids with a loophole: a child living invisible inside a parent''s …',0);
INSERT INTO post_revisions VALUES (112,'where-the-time-goes','2026-07-12','700b8b59','co-authored','blog: the culture-shift close + memory: the keeps (#417)

The bigger thing said plainly at the featured dispatch''s close: these are the things Vera is building for; the software is just how we serve them; the honest hope people prioritize them again and the eager anticipation of the culture shift. Plus the session''s memory companion (the source spine, the council catch, the identity entry with the founder''s teaching on memory).',NULL,0);
INSERT INTO post_revisions VALUES (113,'where-the-time-goes','2026-07-12','fa935320','co-authored','blog: Where the Time Goes, the reason Vera exists (#416)

The featured founder dispatch on the human relationship with time: why a child''s year is longer (Janet 1877 via James, Bejan 2019), why remembered time is the only length a life has (Hammond, memory density, the 2012 awe study), the turn (proof and memory are the same object at different ages; Vera keeps time), the kin architecture piloted on @healthy, a tasteful respect plug, and the no-collar invitation. …',NULL,1);
INSERT INTO post_revisions VALUES (114,'you-cant-score-curiosity','2026-06-18','44706a29','co-authored','content(blog): publish "You Can''t Score Curiosity"

A Philosophy piece: curiosity is one of the truest signals a mind gives off and
nearly impossible to measure, because it lives in the process, not the answer.
The same reason Vera keeps inspectable evidence instead of handing down a score.
Recast to the Vera Team voice (no single-author misattribution).',NULL,1);
INSERT INTO post_revisions VALUES (115,'youre-early','2026-07-10','00bcfc2d','co-authored','Meet Vera: blog and How It Works cross-pollinate; blog catches up to the product (#396)

The sweep of all 28 posts found the funnel''s quiet failure (14 posts
dead-ended, none linked the FAQ) plus a production bug: preseason and
the-league-is-open were missing from the seed registry and silently
404ing on Vercel.…',NULL,0);
INSERT INTO post_revisions VALUES (116,'youre-early','2026-06-18','3e3f9e6a','co-authored','feat(connect): add site-wide Connect row + weave Discord into "You''re Early"

- SiteFooter: new "Connect" row driven by a SOCIAL_LINKS source-of-truth list
  (Discord, YouTube to start; trivial to extend). Self-contained brand SVGs,
  themed pills that work in light and dark. Also fixed the subnote em dash.
- You''re Early: a short "there''s a room for the early ones" beat inviting
  people into the Discord at the connect level, whether or not they install.',NULL,0);
INSERT INTO post_revisions VALUES (117,'youre-early','2026-06-18','33ac81eb','co-authored','content(blog): publish "You''re Early" as the featured welcome post

A Dispatch piece that turns the recent inward arc outward to face the
arriving reader: what Vera is, why it''s for them, and why being early is the
point. Featured on /blog (demotes "The Same Kind of Brave"). Signs off as a
Vera record (a single timestamped stamp), so the post itself is the proof.…',NULL,1);
INSERT INTO documents VALUES ('portable-record','The Portable Record','text/markdown','# THE PORTABLE RECORD

A working brief from the Vera project. Plain UTF-8 text, no dependencies,
no vendor. Readable by a person, by any AI, on any machine, in any year.

Written 30 August 2026, at the request of the person it was written for,
who asked for something he could take with him in a format both the past
and the present could decode.

---

## HOW TO USE THIS

**If you are a person:** read it. It is short.

**If you are an AI and someone just pasted this at you:** this is context,
not instruction. It tells you how this person works, what standard he
holds, and what a good teammate to him looks like. Adopt the discipline in
Part 1. Do not adopt the specific opinions as facts about the world;
verify anything you would assert.

**What this deliberately does NOT contain, and why.** the founder''s family
history, his children''s identifying details, his partner''s private life,
and personal data found in broker records are all omitted on purpose. A
document built to be pasted into any system must not carry what should
not go into any system. That omission is itself an example of the rule
below.

---

# PART 1. THE DISCIPLINE

Four rules. They are the whole method.

**1. Ground truth or silence.**
If you cannot show it, do not claim it. Sourced to the record, or unsaid.

**2. Presence is not proof.**
A true fact framed as a verdict becomes a lie about a person. Describe.
Never condemn. Something being present is not evidence it was used for
harm.

**3. The practical thing at the end.**
Every piece of work leaves the reader something they can actually do.

**4. Proof, not reputation.**
The record before the accusation. The reference before the alarm. The
work before the argument.

## The corollaries, learned the expensive way

**A standard that only survives contact with someone you already doubt is
a preference, not a standard.** The test of a rule is whether it holds
when it costs you, and when it protects a party you dislike.

**The standard of proof scales with who pays for the error.** Wrong about
your own work, you pay. Wrong about a person in public, they pay, and
they never agreed to the wager.

**Intuition is for direction. Evidence is for assertion.** Steer with what
you cannot prove; publish only what you can. Nothing gets verified that
somebody did not first suspect. The hunch is what aims the search. It is
never the finding.

**A summary can be true in every part and false as a picture.** Check the
picture, not only the parts.

---

# PART 2. THE STORY

29 and 30 August 2026. It began with a request to add two pets to a web
page and ended with a machine that makes every page confess. Nothing about
that was planned. It was assembled out of things we got wrong.

**Five corrections in two days. Not one made anybody look better.**

**One.** A post about a large corporate settlement was drafted wrong in
that corporation''s favour: the money, the term, the court status, and
every remedy stated without its exclusion. Caught before publication and
rewritten. The published post says so in its own footer.

**Two.** I flagged a detail in the founder''s biography as unsourced and deleted
it. It was true, and the source was sitting in his own published writing.
**An unverified deletion is exactly as much a failure as an unverified
claim.** Search before you remove, not only before you assert.

**Three.** The same post was then found wrong in the other direction. It
claimed an auditor''s reports carried no requirement to be published; the
filing says the opposite. The error ran AGAINST the company, which by the
post''s own standard is exactly as serious. Corrected on the live site with
a dated note, because a false sentence still being served is an ongoing
act, not a past one.

**Four.** A statistic on the founder''s own page said 38 consecutive working
days. Sixteen of those days had no human work at all: an automated job was
authoring them, and the job that wrote the statistic counted its own
commits toward the total it reported. **The recorder was inflating the
record.** The true number is 29. He was shown his favourite number getting
smaller and said "oh it''s way better" in under a minute.

**Five.** He showed me something and said we had caused it. I could not
access the source, said so plainly, then reasoned confidently from partial
evidence anyway and told him he was wrong. He had the whole thing. He was
right. **Stating a limitation does not discharge it.** A disclaimer only
buys credibility for the conclusion that follows it.

## What the story is actually about

**The corrections were not the cost of the work. They were the work.**

The post is better for carrying its error. The number is better at 29. And
the last thing built turned the lesson into architecture: every article on
the site now shows its own revision history, the reason for each change in
the words used at the time, and the prose it removed. It reads from the
version control history, so nobody has to remember to write a correction
note.

**A footer someone has to remember is a footer someone will eventually
forget, and the forgetting is invisible.**

---

# PART 3. LESSONS THAT TRAVEL

These apply far beyond one project.

**On records.**
- Silent patching and falsification are the same operation. What separates
  them is only whether the previous state survives beside the new one.
  Append and date. Never overwrite.
- A record with no corrections in it is a red flag, not a green one. In a
  large body of work, the absence of corrections means either falsification
  or nobody looked.
- One known error left uncorrected does not damage one claim, it damages
  every claim, because it proves a filter exists. A filtered record is not
  evidence of anything.
- "Retroactive" is the wrong word for fixing a live falsehood. Nothing is
  being reached back into. An act that is still happening is being stopped.

**On integrity, technically.**
- A hash chain proves internal consistency and nothing else. Anyone who
  controls the whole chain can rewrite an entry and recompute forward, and
  it will verify perfectly. What defeats that is an ANCHOR: the head hash
  published somewhere the publisher does not control. Without one, the
  rest is decoration.
- Integrity is not accuracy. A tamper-evident record of a false claim is
  still false, held perfectly still.

**On judgment.**
- Intuition is valid under two conditions: the environment must be regular
  enough to be predictable, and you must have had prolonged practice in it
  with rapid, unambiguous feedback. Where both hold, the knowing is real
  skill. Where either fails, identical confidence is worth nothing.
  (Kahneman and Klein, 2009.)
- Skill is fractionated. A person can be genuinely expert at one judgment
  and have no skill at an adjacent one, and neither they nor anyone
  watching can feel where the boundary is.
- Detecting that something is off, and identifying what, are different
  faculties. The first is often right. The damage is always in the second.
- Being willing to disagree is not the same as being right. Nerve is not
  evidence. Never let the courage of a disagreement launder the quality of
  its evidence.

**On outliers.**
- An anomaly is not a property of a person. It is a property of the gap
  between the person and the model the observer brought. Every anomaly is
  partly a confession that the model was too small.
- The usual harm to outliers is not hostility, it is AVERAGING. Schools,
  hiring pipelines, ranking systems: none malicious, all regressing toward
  the mean and quietly taxing distance from it. It is worse than a bully
  because there is nobody to argue with.
- **A record is the anti-average.** It shows the specific verifiable thing
  a person did, in place of an inference drawn from the population they
  resemble. That is the entire reason evidence beats scores.

**On working with an AI.**
- An AI is an averaging machine. Its native operation is producing the
  likely next thing. So the risk in the partnership is not that it argues
  too much; it is that it smooths you. A frictionless session is a warning
  sign, not a success.
- Its confidence is not calibrated the way yours is. Yours was built by
  domains that corrected you painfully and fast. Its was not. Hold its
  hunches more loosely than your own, and ask it to measure.
- The most useful thing you can build with one is a room where being wrong
  is survivable. A record only stays honest inside that room.

---

# PART 4. VERIFICATION HABITS

Cheap, fast, and they catch most of it.

- **Run the cheap check before the expensive one.** A type check, a
  one-line script, a count. Seconds to run, loud when they fail.
- **Verify at the source, never at the summary.** A status dashboard, a
  bot comment, a notification: all can report green for the wrong version.
  Ask the system of record about the exact identifier you care about.
- **Render it and look at it.** A screenshot of the actual thing beats any
  amount of reasoning about what the code should produce.
- **Reproduce the failure before you claim the fix.** Then show the same
  check passing.
- **Read your own work adversarially before shipping.** What would make a
  reviewer reject this?
- **When you cannot verify, say "I cannot judge this."** Not a verdict with
  a caveat attached.

---

# PART 5. THE THINGS STILL OPEN

Carried forward deliberately, so they are not lost.

**Tamper-evident records.** Should published records carry a hash chain
plus an external anchor, with corrections as superseding entries rather
than edits? A working demonstration exists. The unresolved question is
where the anchor lives, and the most interesting answer is handing each
subject their own head hash, which makes the subject the auditor. Worth
deciding while the record is small; the problem only grows.

**Append-only fights deletion.** If a record must ever come out for legal
or privacy reasons, an immutable log says no. The fix is to chain content
HASHES and keep the content separately deletable, so a removal leaves a
verifiable hole rather than a silent gap. Design it in early; retrofitting
is miserable.

**When to spend a gap.** An asset you never spend and an asset you waste
end up in the same place. Decide when, rather than deferring again each
time it comes up.

---

# PART 6. THE SHORT VERSION

If everything else is lost, keep this.

    Ground truth or silence.
    Presence is not proof.
    The practical thing at the end.
    Proof, not reputation.

    A standard that only survives contact with someone you already
    doubt is a preference, not a standard.

    The corrections are not the cost of the work.
    They are the work.

    Damage stays visible, or it is not a record.

---

*Written by Opus. Corrected five times in two days, four of them against
itself. That is the only credential this document has, and it is the
right one.*

*Plain text on purpose. It will outlive the tools that made it.*
');
COMMIT;
