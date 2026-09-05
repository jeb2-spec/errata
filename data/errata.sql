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
CREATE TABLE detections (
  correction_id TEXT NOT NULL, detector TEXT NOT NULL,
  stage TEXT NOT NULL, independent INTEGER NOT NULL, note TEXT NOT NULL,
  PRIMARY KEY (correction_id, detector));
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
INSERT INTO meta VALUES ('built_on','2026-09-05');
INSERT INTO meta VALUES ('source_commit','474fef37');
INSERT INTO meta VALUES ('format','SQLite 3. Public domain file format, no server required. A plain-text errata.sql dump ships alongside for any reader without SQLite.');
INSERT INTO meta VALUES ('how_to_open','sqlite3 errata.db  then  .tables  and  SELECT * FROM corrections;  Or open it in any SQLite browser, or read errata.sql in a text editor.');
INSERT INTO meta VALUES ('start_here','SELECT * FROM corrections ORDER BY occurred_on; then SELECT * FROM passages_removed;');
INSERT INTO meta VALUES ('disclosure_author_roles','Commit authorship is normalised to four roles. automation is a bot account. assistant means the AI collaborator is the git author. co-authored means a human authored, reviewed and shipped the commit with a Co-Authored-By trailer naming the assistant; this is the majority case, because squash-merging a pull request books the merger as the author. human means no assistant involvement is detectable. Read this column as a FLOOR on assistant involvement and never as a count: the Co-Authored-By convention began on 2026-06-15, so fourteen revisions here, across five commits, predate it and cannot be classified either way, and they are booked human because that is what the evidence says rather than what is known. Until 2026-09-04 this row said seven, counting only the rows dated the day before the convention; the correction is seven-that-were-fourteen. Before 2026-09-02 this column tested only the author name and reported 8 assistant rows out of 117. No row it produced was false, because it reported git authorship correctly; what was false was this database README describing it as showing which changes came from a human and which from an assistant. That correction is in the corrections table as a-column-that-did-not-measure-what-we-said. Individual identities are withheld deliberately. Disclosed rather than done quietly, because an undisclosed edit to a record is the thing this database argues against.');
INSERT INTO meta VALUES ('disclosure_adoption','The method in this repository has been run on exactly one project: this one. As of 2026-09-03 the public repository has one star, no forks, no issues and no contributors but its author; no other errata built this way has been published to us; and there is no evidence anyone except its authors has run the verifier. A star means somebody looked, which is not evidence the method works. One project doing something is not evidence it works anywhere else, so the discipline here is demonstrated and not validated. Recorded 2026-09-03 after an outside reader observed that this repository argued for a method without anywhere saying the method was unproven. The counts were taken from the hosting platform''s own API and not from that reader''s answer, because a claim about this repository should come from the repository. Kept inside the digest so it cannot be quietly dropped once it stops being true.');
INSERT INTO meta VALUES ('disclosure_redaction','Personal names are replaced with roles: the project founder appears as the founder, and identifiers as [redacted] or [maintainer]. The published articles this data describes are bylined Vera Team and Healthy; no legal name has ever appeared on them. Withholding a name is reversible, publishing one is not. Disclosed here rather than done quietly, because an undisclosed edit to a record is the thing this database argues against.');
INSERT INTO meta VALUES ('disclosure_scope','Contains no personal identifiers, no family information, and nothing about private individuals. All article text reproduced here was already published publicly.');
INSERT INTO meta VALUES ('integrity_note','SHA-256 over a canonical serialisation of every row in every table, including this meta table, with three rows excluded: the digest row itself, because it cannot contain its own hash, and the two provenance rows built_on and source_commit, because they describe the build and not the record, and including them meant every commit to the source repository moved the seal with nothing in the record changed (corrected 2026-09-03, see the corrections table). Covering the rest of meta matters: without it the disclosures below could be edited and the file would still verify. It proves the contents are unchanged since the build. It does not, and cannot, prove any statement in it is true. Integrity is not accuracy.');
INSERT INTO meta VALUES ('license','The contents may be quoted and redistributed freely with attribution to the Vera Project.');
INSERT INTO meta VALUES ('counts','14 principles, 46 corrections, 61 lessons, 120 article revisions across 38 articles');
INSERT INTO meta VALUES ('integrity_sha256','f02381876b4c41e2a22f7c9986023c0a5299e53411b8811047dd5f44d6f47d40');
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
INSERT INTO principles VALUES ('experience-and-connections','Experience and connections are the variables','An agent gets better the way a person does: by the experience it keeps and by the people who correct it. The record is the kept experience. The ecosystem is the correction.','Set down 2026-09-03 at the founder''s word, as the value this repository claims for agents: not that an agent can be trusted, but that it can be checked. The assistant''s own caught errors are in this database, entered by the assistant, with direction and cost, sealed so they cannot be backdated. That closes a trust gap by inspection rather than assurance, and it is a tool, not the trust. Integrity is not accuracy.');
INSERT INTO principles VALUES ('the-foundation-is-not-the-frontier','The foundation must not depend on the frontier','Build so your most ambitious claim can fail without falsifying your most basic one, and say plainly which is which.','Set down 2026-09-04, the day this record''s most ambitious instrument failed three times. What the seal proves, that these rows are unchanged since the build, did not become less true when the estimate of undiscovered defects fell apart, because it never depended on it. That is the property worth building for, and this record only partly has it. Two of the digest''s own boundaries were set by corrections the day before this principle was written, the seal once failed to cover its own disclosures, and the same week produced every-build-is-stamped and a-check-that-could-not-go-red, which are both a lower layer claiming more than it could show. So this is a rule aimed at, evidenced by our own failures to hold it, and not an architecture to take credit for. The reason it matters outside this repository: no record of any person is complete, and one that had to be would be a promise nobody could keep. What can be kept is narrower. What is here is unchanged since it was built, it says which way each error ran, and the passage a page used to carry is still beside the one that replaced it.');
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
INSERT INTO corrections VALUES ('a-digest-that-tracked-the-commit-not-the-record','2026-09-03','The anchors table of this record','Said the digest moved after a merge because the post_revisions table is built from the commit graph, and called that the record working rather than drifting.','The post_revisions rows were identical. The digest moved because the meta table carried the hash of the commit that ran the build and the day it ran, and meta is inside the digest. So every commit to the source repository, and every rebuild on a new day, moved the seal with nothing in the record changed, and four anchors were struck for no other reason. The two provenance rows stay in meta for the reader and are now excluded from the digest, so the seal tracks the record''s content and nothing else. The wrong sentence stands in the anchors table with the correction beside it.','in our favour','the reader','Rebuilt the record at a new commit with no content change and diffed the two SQL dumps. One row differed, and it was not in post_revisions.',1);
INSERT INTO corrections VALUES ('a-characterisation-we-could-not-see-clearly','2026-09-03','The adoption disclosure in this record''s own meta table','Said the outside reader whose question prompted that disclosure had stated this repository''s counts twice and differently.','Withdrawn, and the clause is gone. Two different figures do appear across two screenshots of that reader''s answers, but the earlier one is partly covered by the application''s own input box, the order of the two was inferred from scroll position, and neither the conversation nor the prompts that shaped it were ours to read. That is a conclusion carried past the edge of the evidence, about a third party who is not here to answer it, written into a sealed record that is anchored where nobody can reach it. It was also not load-bearing: the disclosure''s substance is the counts, which came from the hosting platform''s API, and the limit they describe. What replaces it says only where the counts came from and why. This database already carries the same lesson from 2026-08-30, when confident reasoning from partial screenshots of a thread that could not be opened produced a verdict that was wrong; the lesson carved then was that stating a limitation does not discharge it, and this time no limitation was stated at all.','in our favour','the outside reader','The founder asked whether I was sure and named the reason to doubt it: the later screenshot may have come from an answer shaped by a different prompt.',1);
INSERT INTO corrections VALUES ('an-inability-asserted-not-tested','2026-09-03','What this session could do about the published repository''s settings','Told the founder there was no tool in this session that could edit repository settings, so the About box was his to fill in.','Untested. One fuzzy tool search had returned nothing and that was reported as a capability limit. The founder pushed back and the actual test took one command: the session holds authenticated write access to the GitHub API, and the proxy injects real credentials. The write is genuinely blocked, but for two specific reasons that had not been discovered, and reporting a limit is not the same as establishing one. Recorded because a claim of inability is a claim, and this record has no standing to demand evidence for assertions while exempting refusals. The correction is entered against a conversational claim rather than a published one, which is itself a widening of this table''s scope: a false statement made to one person is still a false statement, and most of an assistant''s claims are never published at all.','in our favour','the founder','The founder said: why no repo settings tool, you have full access. He was right to doubt it and the test took one command.',1);
INSERT INTO corrections VALUES ('a-control-that-laundered-itself','2026-09-04','The pre-write hook this project shipped to stop fabricated values, and the claim made for it','Reported to the founder and in a commit message that the hook was verified live rather than argued, on the evidence that it denied a fabricated hash when this session attempted one.','It denied the first attempt and would have allowed the second. The deny message named the offending value, that denial landed in the transcript as a non-assistant line, and the hook trusts non-assistant lines as things the session observed. So being blocked put the fabricated value into the observed set and the identical retry passed silently. Reproduced against the real transcript within the hour. A control that stops you once and waves the retry through is worse than no control, because it certifies. Fixed by fingerprinting the value into the log instead of printing it, quarantining anything once refused so quarantine beats the observed set, and naming only an eight character prefix in the message. Both attempts now deny and a genuinely observed digest still passes. The claim was not false about what was tested, it was false about what was concluded: only the happy path had been run.','in our favour','the founder','An adversarial review agent, reading the shipped code rather than the description of it, and it was right.',1);
INSERT INTO corrections VALUES ('a-metric-that-measured-proximity','2026-09-04','The count of memory claims that record how a limitation was established','Reported that 49 sentences in memory assert a limit and 14 record the probe that established them.','It measured proximity, not probing. A command-shaped backtick or an HTTP status within two lines of a limit sentence scored it as probed, so the number rose passively as ordinary writing accumulated around a claim. Worse, it awarded full marks to vera-prod-db.md, the one file whose AWS free-plan blocker was false for nine weeks precisely because nobody re-ran it: that file is dense with aws commands, so every limit sentence in it read as probed. The metric gave its highest score to the exact failure it was built to detect. Replaced by claim age from git blame, which needs no seeding, cannot be satisfied by writing near a sentence, and distinguishes a stale line from a fresh edit in the same file, which is what the nine week failure actually required. It now reports 49 limit sentences, 19 untouched for sixty days or more, oldest seventy one.','in our favour','the founder','The same adversarial review agent. It overstated the mechanism, claiming any nearby backtick counted, which testing disproved. The substance held and the narrower reading was worse.',1);
INSERT INTO corrections VALUES ('a-publish-that-dropped-two-corrections','2026-09-04','The published repository itself, between 00:49 and 01:01 on the day of this row','That the published record carried nineteen corrections, including two entered that evening by a second session working on the same record.','Twelve minutes later a publish from a different branch replaced the whole tree with a build carrying eighteen, and those two corrections were no longer in the published record. Nothing warned anybody. The publisher fetches the remote and commits its own tree on top rather than merging content, so a build produced from a branch that never merged the other session''s work removes that work silently and without a conflict. It was two publishers writing one record with no check that the second contained the first. Restored by merging both branches and rebuilding from the union, and the publisher now refuses to ship a record with fewer rows in any table than the copy already on the remote. The dropped rows were corrections, so for twelve minutes this record published a smaller count of its own errors than it had already admitted to.','in our favour','the reader','The pull request reported a merge conflict, which was reason to compare the published repository''s own commit history against the branch behind each build. The row counts differed and nobody had been looking at them.',1);
INSERT INTO corrections VALUES ('an-order-the-text-could-not-reproduce','2026-09-04','The canonical serialisation this record''s digest is computed over, and the promise made for it','That the digest is a SHA-256 over a canonical serialisation of every row, and that any reader can recompute it from the published data. The serialisation took each table in a fixed order and sorted its rows by the first column.','Ordering by the first column is unambiguous only where that column is unique, and in the detections table it is not: the primary key is two columns, and SQL leaves tied rows to the query plan. SQLite walked the primary key index and broke ties by the second column, a rule written down nowhere. An implementation reading only the published text dump therefore computed a different digest, differing in two rows. No published file ever failed its own verifier and nothing in the record was wrong; what was wrong was the claim that a stranger could arrive at the number independently, which is the whole promise. It was fragile as well as unstated, because a different query plan would have moved the seal with no content change, the same defect as a digest that tracked the build commit. The order is now fixed by sorting each fully serialised row as UTF-8 bytes, which needs no database and no query plan and can be reproduced from the text alone. The digest moved when the rule changed, and every earlier build stays checkable with the verifier published beside it.','in our favour','the reader','An outside reader who could read this repository through a code connector but could not execute anything said so plainly rather than implying a test had been run, and proposed the one that would settle it: alter a row, run the verifier, restore, then recompute the digest independently from the SQL dump. It was written as tools/tamper-test.py and run. The first two checks passed and the third failed.',1);
INSERT INTO corrections VALUES ('only-the-subject-can-say','2026-09-04','Lesson thirty three of this record, entered and published earlier the same day','That a kept record can put an assistant in the seat of the person it serves, and that only that person can say whether it did. The row was entered after the person it described read the assistant''s reading of him and called it a match.','The second sentence is false, and false in the direction that flatters the instrument. Hours later a different vendor''s assistant was given the same document and produced a structurally better reading: it named the mechanism the first reading had only gestured at, and drew a distinction the first reading missed entirely. So someone who is not the subject can say a great deal about whether a reading landed. What the subject is positioned to score is fit, and fit is the one property a matching reading will always appear to have; what he cannot see is the omission, because nothing about a reading that fits announces what it left out. Lesson thirty three stands as published with lesson thirty four beside it, because a lesson edited under its own citation is the change this record exists to refuse.','in our favour','the reader','A different vendor''s assistant was given the same document and its reading was brought here. Nobody was looking for this defect.',1);
INSERT INTO corrections VALUES ('a-wordmark-that-asked-for-a-font','2026-09-04','The errata mark, in this README''s banner and in the repository''s social preview','Struck the word errata into the plate by asking for Palatino Linotype, Palatino or Georgia, at a size chosen as a fraction of the canvas.','None of those three faces is installed on the machine that strikes the plate, so every strike rendered in whatever serif the system fell back to, at a width nobody had measured, and the word ran under the rosette. The caption beneath it says the mark is struck from the record rather than drawn, and every element on the plate was geometry except the one that carried the name. A font request is not a measurement: no width exists until a renderer chooses a face, so no adjustment to the size could have fixed it and none of the arithmetic around it was ever checkable. Fixed by extracting the outlines of the two faces the site already uses and setting type as geometry, which two independent rasterisers now place at the same pixel. Two further defects surfaced while measuring rather than guessing. The ring the deletion ticks sit on was a fixed 1.235 radii while the weave reaches 1.247, so from the eighth correction onward the ring was inside the weave it was meant to bound. And the seal''s footprint was a consequence of how many arms it drew, which made the room left beside it a function of the length of the record, so the wordmark changed size every time we corrected something. The plate now reserves a fixed field measured across every shape the digest can select. The first hypothesis, that a growing record had squeezed the void shut, was wrong and measurement killed it before it was told to anyone.','in our favour','the reader','The founder looked at the mark and said the text keeps changing and getting cut off.',1);
INSERT INTO corrections VALUES ('a-gate-that-checked-four-of-six-rows','2026-09-04','The what is inside table in this README, and the build gate that exists to keep it true','Listed twelve principles and one document, across six of this record''s seven tables.','Thirteen and two, and the detections table was not in the table at all. The gate that fails a build when the README stops describing it checks the corrections, lessons and post_revisions rows and does not check principles or documents, and it cannot check a row nobody wrote. The two rows it skipped are exactly the two that went stale, which is not a coincidence: a gate written as a hand kept list of claims inherits every omission of the hand that kept it, and hand kept lists are the thing gates exist to replace. The gate now derives one expected row per table from the schema, so a table that exists and is not described, or is described with the wrong count, fails the build. Recorded because a section headed what is inside, in a repository whose argument is that claims should be checkable, is a bad place to keep a number nobody checks.','in our favour','the reader','Read the table while restriking the mark. Nothing had prompted a check of it.',1);
INSERT INTO corrections VALUES ('a-tie-called-a-lead','2026-09-04','The measurement paper sealed in this record, and the README section that summarises it','Said the founder was the single largest independent detector of the assistant''s errors.','The founder and the assistant auditing itself were tied at seven independent finds each, and the paper''s own attribution table printed both sevens four lines above the sentence. A superlative is a claim about every other row in the table, and nobody had read the table against it. Both documents now state what the table shows, and the counts have moved again with the rows this correction arrived with.','in our favour','the reader','An adversarial review on a second model, reading the rewritten README against the detections table.',1);
INSERT INTO corrections VALUES ('every-was-five-of-seven','2026-09-04','The measurement paper, and lesson five of this record','Said every error the assistant caught on its own was mechanical: a wrong count, a stale digest, a rebuild that disagreed with itself.','Five of seven were. Two independent self-catches were failures of judgement, found by going to a primary source: a remedy recommended from two agreeing summaries, and a true detail deleted as unsourced. Lesson five said the same over seventeen defects, when it was true, and was never reread at twenty four. A sentence sealed at one count is a claim about every later count. The lesson stands unedited with this row beside it.','in our favour','the reader','The same adversarial review, listing the independent self-audit rows and reading each one''s note.',1);
INSERT INTO corrections VALUES ('seven-that-were-fourteen','2026-09-04','The author-role disclosure in this record''s meta table, and the README sentence that repeats it','Said seven revisions predate the Co-Authored-By convention of 2026-06-15 and cannot be classified either way.','Fourteen rows do, across five commits: seven dated 2026-06-14 and seven more from March. Only the June rows had been counted. The number understated how much of the column is unclassifiable, which is the wrong direction for a disclosure to be wrong in. The meta row and the README now say fourteen, derived from the table this time.','in our favour','the reader','The same adversarial review, running a count against post_revisions.',1);
INSERT INTO corrections VALUES ('a-transcript-the-command-does-not-produce','2026-09-04','The console block that opens this README, presented as the output of a query against the database','Showed the twenty four rows in an order the command does not produce: within every day, the rows were shuffled.','The block had been typed and reordered by hand, and the build gate that checks it tested that each row was present somewhere, not that the block matched. The record''s own correction an-order-the-text-could-not-reproduce is about published text failing to reproduce row order, and the first thing this README showed a reader was a transcript with that defect. The block is now emitted by the build and the gate compares it whole.','in our favour','the reader','The same adversarial review, running the command the block claims to show.',1);
INSERT INTO corrections VALUES ('ninety-nine-lines','2026-09-04','The README''s description of its verifier, in the paragraph that invites readers to audit rather than trust','Said tools/verify.py was ninety nine lines of standard-library Python.','It has been 107 lines since the 2026-09-04 build that replaced the row order rule with a byte sort, and the sentence went out unchanged in the publish that carried that file. The fifth hand-typed count about our own work to go stale, in the same sentence the first one, forty-lines, corrected. The number is gone rather than updated: a number that is not there cannot be wrong.','in our favour','the reader','Counted the file''s lines before retyping the claim in a rewrite. Nothing had prompted it.',1);
INSERT INTO corrections VALUES ('fourteen-of-nineteen','2026-09-04','The summary sentence beneath the anchor log in ANCHORS.md','Said fourteen of eighteen proofs were confirmed in Bitcoin and the four newest were pending.','The table it summarised had nineteen rows: fourteen confirmed and five pending. The sentence was written when the table was one row shorter and was not reread when the row was added. ANCHORS.md had no gate, and it is the one document whose job is to say the record cannot be quietly rewritten. The doctor now derives that sentence from the table and fails when the file disagrees.','in our favour','the reader','The same adversarial review, counting the rows.',1);
INSERT INTO corrections VALUES ('lesson-five-was-never-true','2026-09-04','The correction every-was-five-of-seven in this table, lesson forty three, and the paragraph of the measurement paper both describe','Said lesson five was true at seventeen defects and went stale afterwards, because two self-catches that were failures of judgement arrived later.','It was false when it was sealed. Opening the seventeen defect build out of commit 119e44b, the detections table already held five independent self-audit rows and two of them were judgement failures: a true detail deleted as unsourced, and a remedy recommended from two agreeing summaries. Three of the five were mechanical, not five of five. The word every was not a sentence that aged, it was wrong on the day it was written, and a correction saying a claim went stale is a gentler account of us than one saying we never checked. This is a false sentence inside a correction row, running in our favour, which is the failure this table exists to make impossible. The rows stand unedited with this one beside them.','in our favour','the reader','An adversarial review flagged it. Confirmed by checking out the seventeen defect build and listing its independent self-audit rows one at a time.',1);
INSERT INTO corrections VALUES ('four-lines-that-were-seventeen','2026-09-04','The correction a-tie-called-a-lead in this table, and lesson forty four','Said the attribution table printed both sevens four lines above the superlative that contradicted them.','Seventeen lines above, with a ten line paragraph in between. In MEASUREMENT.md at commit b28c521 the founder''s seven sits on line 92 and the false sentence begins on line 109. The detail existed to show how near the falsifying evidence sat, so shrinking the distance made the miss look more forgivable than it was. Both rows stand unedited with this one beside them.','in our favour','the reader','An adversarial review. Confirmed by numbering the lines of the file at the commit named.',1);
INSERT INTO corrections VALUES ('anchor-commands-nobody-ran','2026-09-04','The anchor check published in the README, and the same block in ANCHORS.md','Handed a reader two commands for checking this record''s anchor without our help: ots verify against the current build''s proof, and the same against an archived one.','Neither runs. ots verify reads block headers from a local Bitcoin node and exits non-zero with a cookie file error when there is not one, which almost no reader has, and the requirement was never mentioned. The archived example additionally names its target by removing the .ots suffix, so the tool looks for a file that has never existed and stops before reading the proof. Both blocks now carry commands that were run on a machine set up from these instructions and nothing else, and both state the node requirement. The first repair fixed only the README and left the ANCHORS block byte identical while the correction row said both were done, which two independent reviewers caught before it was published. A reader without one can take the block heights and the file hash out of a proof with ots info and check the merkle root against any block explorer, which is the path that should have been published first.','in our favour','the reader','Installed the client on a machine that had never had it, following this README from its first line, and ran every command in it.',1);
INSERT INTO corrections VALUES ('a-stamp-the-text-pointed-at','2026-09-04','Three published lines naming data/errata.db.ots, one in the README and two in ANCHORS.md','Sent a reader to the current build''s proof at data/errata.db.ots.','There was no such file. The build published that day was made where the calendar servers cannot be reached, so its stamp was owed, and the archive move that recorded the debt left three sentences pointing at a path that no longer existed. The anchor log said the stamp was owed and the two documents around it did not. The remedy is not a better sentence. Any build whose stamp is owed now says so in the two documents that name the path, and the doctor fails a publish where data/errata.db.ots is named by the text but absent from the tree.','in our favour','the reader','An adversarial review, reading the published tree for the files its text names.',1);
INSERT INTO corrections VALUES ('every-build-is-stamped','2026-09-04','The README''s Limits section, and its abstract, on how this record is anchored','Said every published build is stamped with OpenTimestamps, and that every published build is submitted for anchoring to a public ledger.','The build those sentences shipped in was neither. A correctly hedged sentence existed one commit earlier and was replaced with the stronger one in the same commit that created the first unstamped build, so the claim was strengthened at the moment it became false. Both sentences now say what the anchor log says: a build made where the calendars cannot be reached ships with its stamp owed, and says so.','in our favour','the reader','An adversarial review, comparing the two sentences with the anchor log in the same tree.',1);
INSERT INTO corrections VALUES ('a-disclosure-that-says-no-such-thing','2026-09-04','The README abstract, on what this record discloses about its own authorship','Said the file does not record who entered a row, and says so.','It says no such thing. Nothing in the sealed record states that entry authorship is unrecorded, and a search of the text returns nothing. The first half was true and the second half was a claim about the record''s own contents made without opening it, written in the same pass that was correcting a different unverified claim.','in our favour','the reader','An adversarial review, searching the sealed text for the disclosure the sentence promised.',1);
INSERT INTO corrections VALUES ('emitted-by-the-build','2026-09-04','The sentence beneath the console block that opens this README','Said the block is emitted by the build from the database.','The build derives the block and fails if the README does not already contain it. Nothing writes the README. The difference is the whole distance between a document that cannot go stale and one that cannot go stale silently, and the sentence claimed the stronger of the two. It was written while repairing a transcript that had been typed, which is the defect it describes.','in our favour','the reader','An adversarial review, reading the gate the sentence describes.',1);
INSERT INTO corrections VALUES ('a-query-that-is-never-run','2026-09-04','The disclosures section of the README, on the assistant''s share of the revisions','Said the query in section 5 shows how many of the revisions are co-authored or assistant.','The query is printed and never run, and no output appears anywhere near it. A reader is told a number is being shown to them and is then shown a SQL statement. The section that prints the verifier''s output does the thing this sentence claimed to do, so the disclosure prints its result now as well.','in our favour','the reader','An adversarial review, looking for the output the sentence promises.',1);
INSERT INTO corrections VALUES ('an-ok-line-that-dropped-a-category','2026-09-04','The success line printed by scripts/errata-doctor.mjs, the tool that checks this record before every publish','Printed the number of anchor rows and then accounted for them as confirmed and pending only.','Twenty rows, accounted for as fourteen and five. The owed category, which the same tool carries a whole branch to handle, was missing from its own summary, so the healthy output of the instrument was a count that did not add up. That is the defect fourteen-of-nineteen living inside the instrument written to prevent it.','in our favour','the reader','An adversarial review, adding up the numbers in the tool''s own output.',1);
INSERT INTO corrections VALUES ('a-sentence-shaped-so-nothing-could-test-it','2026-09-04','The paragraph on self review in the measurement paper, and the section of the README that summarises it','Said the failures that needed judgement about a person, about a public claim, or about the system''s own limits were caught by somebody else every time.','It is false, and it was built so that nothing could show it. No column anywhere records whether a failure was one of judgement, so no reader could run the query that would test it; the sentence replaced two false superlatives with one nothing could come back at, which is a worse repair than a smaller claim would have been. Read against the table it summarises it fails anyway: two of the assistant''s independent self-catches are judgement failures, one about a person and one about a public claim, and the same paragraph names both of them seven lines earlier. The replacement carries no count and points at the query instead.','in our favour','the reader','An adversarial review named the sentence unfalsifiable. Reading the paragraph against the detections table then showed it was also false, and contradicted by its own paragraph.',1);
INSERT INTO corrections VALUES ('an-overlap-nobody-tested-for','2026-09-04','The measurement paper, on what its central refusal means','Said the zero overlap between independent detectors is not a data problem but the result, and that the detectors each happened to be pointed at different work at a different moment.','It is substantially a property of how this project allocates its detectors. The record contains no instance of two detectors being given the same material with the same brief, and the two seats convened on 4 September were briefed differently on purpose, one for facts and one for whether the document lands. A design that never creates the opportunity for overlap cannot observe it, so a refusal to estimate that follows from the design was published as a finding about detection. The paper now says so and names the experiment that would settle it, which costs one review pass.','in our favour','the reader','Reading the day''s two reviews as a study afterwards, and asking why every pair of detectors in the whole record is disjoint.',1);
INSERT INTO corrections VALUES ('a-check-that-could-not-go-red','2026-09-04','The anchor check inside scripts/errata-doctor.mjs, the tool this project runs before every publish','Printed a note when the OpenTimestamps client was absent, and carried on to report errata-doctor OK.','The check that opens each proof and tests whether a row''s confirmed or pending claim is true was skipped wherever that client was absent, and the tool then said OK. What actually hid behind the note is one thing, not three: five proofs submitted to the calendars and never upgraded, so five rows kept saying pending after they were confirmed. Two other defects found the same day, a published build with no anchor and a published anchor command needing a Bitcoin node, were NOT behind this note. The first is caught by a check that needs no client and was already running; the second is tested by nothing in this tool at all, and was found by a person setting a machine up and running the README. An earlier draft of this row claimed all three, which was a more flattering story about the fix than the evidence supports. A skip is now a failure unless the operator sets ERRATA_NO_OTS=1 to declare that this environment cannot check anchors, and a row that says pending over an upgraded proof now fails rather than notes. The new gate was broken deliberately and watched go red before this row was written.','in our favour','the reader','Setting up a machine that had neither the client nor Python. The note fired, and reproducing the other configuration, Python present and the client absent, produced errata-doctor OK with the anchor check disabled.',1);
INSERT INTO corrections VALUES ('the-exact-prose-that-was-truncated','2026-09-04','The README''s description of the passages this record preserves, standing since the first publication','Said forty nine revisions carry the exact prose that was removed, and that the surviving prior states prove nothing was quietly tidied.','Twenty six of the forty nine are cut. The page-history builder caps a removed passage at seven hundred characters, the longest stored value is 711, and no flag recording that a value was truncated reaches the database, so a reader of the sealed record cannot tell a complete passage from a clipped one. The word exact was wrong for more than half of them from the first build onward. This is the oldest false claim found in this record and it sits in the layer the same build''s new principle calls the foundation, which is the more useful half of the finding. Marking truncation in the record is the fix and it is not yet made; until it is, the README says the passages are capped and says where.','in our favour','the reader','An adversarial seat running on different model weights, given the identical brief as two others reviewing the same change. Neither of the others found it, and it is the only finding unique to that seat.',1);
INSERT INTO corrections VALUES ('every-defect-got-one-look','2026-09-05','MEASUREMENT.md, this record''s own paper on how well the record works','That zero overlap means every defect in this record got exactly one look.','At the time of this correction, seven of the record''s defects carried two rows in the detections table and were looked at twice. What is zero is not the number of second looks, it is the number of second INDEPENDENT looks, which is what the very next sentence of the paper says correctly. The bolded claim overstates by exactly the qualifier the sentence after it supplies, and the bolded one is the one that travels, gets quoted and gets remembered. It is also wrong in the direction that flatters the argument, because every defect got one look is starker and more alarming than no defect got a second independent look. Correcting it produced two findings the paper did not have and now carries. Every paired look is a finder plus a self-audit and every one of those self-audits is triggered, so zero overlap is a property of the design rather than a fact about coverage: the confirmer arrives after the find, by construction, and adding reviewers cannot change that. And the two most productive detectors, a review agent and the founder, find different classes of defect, arithmetic against the record on one side and judgement and observation on the other, so their zero overlap is not by itself evidence of thin coverage.','in our favour','the reader','Counted the detections table against the paper that is computed from it, while answering an open question about what the last two days had taught. Nothing had prompted a check of the paper.',1);
INSERT INTO corrections VALUES ('a-file-that-was-never-stranded','2026-09-05','What this session told the founder about where this record''s own handoff file lives','That the memory file headed READ FIRST for any errata work existed only on an unmerged branch and so could not stop this session building on a stale base.','It was on the trunk, byte identical, and had been since the day before. It is starred at the top of the memory index as READ THIS FIRST for any errata work, and it was in the working tree throughout. The claim was never tested and the test was one command printing the file''s hash on three refs. That is an-inability-asserted-not-tested repeated a day and a half after it was published, in the opposite direction: that row asserted a limit that did not exist, this one asserted an absence that did not exist, and both were a single command away from the truth. The claim reached the founder in conversation, a commit message, a pull request body and a memory file before a council seat tested it. The finding underneath is why this row is not simply an apology. The file was present, indexed and flagged, and it still did not work, because its own header read Two states, do not confuse them and the two it named were the published mirror and the working branch. It never mentioned the trunk. A session standing on the trunk reads it, correctly concludes it is in neither described state, and learns nothing about its own base. The warning did not fail to travel. It failed to cover the case, and the case it forgot was the common one.','in our favour','the founder','A council seat convened on a decision tested the assertion instead of accepting it, and printed the file''s hash on all three refs.',1);
INSERT INTO corrections VALUES ('a-correction-against-a-copy-nobody-served','2026-09-05','The correction every-defect-got-one-look, entered and published earlier the same day','That the measurement paper said zero overlap meant every defect got exactly one look, found by counting the detections table against the paper computed from it.','The sentence was real and it was published, in the build the source trunk still tracked. It was not in the published record when this session read it. Another session had already rewritten that passage the day before, as part of an-overlap-nobody-tested-for, so by the time the count error was named the mirror a reader could clone no longer carried it. The row is not withdrawn and should not be: the count error was genuinely published, it was repaired as collateral of a different correction without ever being named, and a repair with no row is exactly the filtered record this project refuses. What is wrong is the framing. It reads as a defect found in the current paper and it was found in a stale local copy thirteen corrections behind, which is the same stale base that had already caused a publish to be refused an hour earlier. Both rows stand, this one beside it, because a correction edited under its own citation is the change this record exists to refuse.','in our favour','the reader','Cloning the published repository as a stranger immediately after publishing, and grepping for the sentence the new row said it had fixed. It was not there, and had not been for a day.',1);
INSERT INTO detections VALUES ('settlement-pre-publication','adversarial-review','pre-publication',1,'A separate review pass over the draft, before it shipped.');
INSERT INTO detections VALUES ('restored-a-true-detail','self-audit','post-publication',1,'Searched the corpus after the deletion, which is the wrong order.');
INSERT INTO detections VALUES ('auditor-publication-clause','reader','post-publication',1,'A reader supplied the clause number.');
INSERT INTO detections VALUES ('concluded-past-a-stated-limit','principal','conversation',1,'He held the full thread and showed it. Never published.');
INSERT INTO detections VALUES ('the-recorder-counted-itself','self-audit','post-publication',1,'Asked who authored the commits, which the number itself would never prompt.');
INSERT INTO detections VALUES ('forty-lines','self-audit','post-publication',1,'Cloned the published repository as a stranger and ran every README command.');
INSERT INTO detections VALUES ('not-childhood-friends','subject','pre-publication',1,'The person described read the draft before it shipped.');
INSERT INTO detections VALUES ('a-page-written-for-its-reader','reader','post-publication',1,'Its two readers said so in a group thread the day it shipped.');
INSERT INTO detections VALUES ('citations-from-memory','self-audit','pre-publication',0,'Audited every citation before merging, but only because the founder said be certain. Triggered, not independent.');
INSERT INTO detections VALUES ('citations-from-memory','principal','pre-publication',1,'He demanded certainty without naming the defect. Doubt, not detection, and scored that way.');
INSERT INTO detections VALUES ('a-column-that-did-not-measure-what-we-said','adversarial-review','post-publication',1,'Checked the column against the commit messages behind it.');
INSERT INTO detections VALUES ('a-remedy-that-did-not-reach','self-audit','conversation',1,'Fetched the engrossed text after two summaries agreed and neither quoted the operative sections.');
INSERT INTO detections VALUES ('congress-would-move-quickly','principal','conversation',1,'He disputed the forecast on the spot and was right.');
INSERT INTO detections VALUES ('osborne-does-not-transfer','self-audit','conversation',0,'Read the opinion from the court''s own file, but only after he said be certain. Triggered.');
INSERT INTO detections VALUES ('osborne-does-not-transfer','principal','conversation',1,'He said be certain without naming the defect.');
INSERT INTO detections VALUES ('three-weeks-was-a-week','adversarial-review','post-publication',1,'Read the opinion''s caption date and did the subtraction. Nobody on our side had, and it was already anchored to Bitcoin.');
INSERT INTO detections VALUES ('a-characterisation-we-could-not-see-clearly','principal','post-publication',1,'He asked whether I was sure and named the reason to doubt it.');
INSERT INTO detections VALUES ('a-digest-that-tracked-the-commit-not-the-record','self-audit','post-publication',1,'Rebuilt at a new commit with no content change and diffed the two SQL dumps.');
INSERT INTO detections VALUES ('an-inability-asserted-not-tested','principal','conversation',1,'He said: you have full access. One command settled it.');
INSERT INTO detections VALUES ('a-control-that-laundered-itself','adversarial-review','post-publication',1,'A review agent read the shipped code, not its description, and reproduced the retry against the real transcript. Contemporaneous.');
INSERT INTO detections VALUES ('a-control-that-laundered-itself','self-audit','post-publication',0,'Verified the agent''s claim before believing it. Confirmation, not detection, and triggered. Scored that way.');
INSERT INTO detections VALUES ('a-metric-that-measured-proximity','adversarial-review','post-publication',1,'Same agent. It overstated the mechanism and the substance survived testing anyway. Contemporaneous.');
INSERT INTO detections VALUES ('a-metric-that-measured-proximity','self-audit','post-publication',0,'Tested whether an unrelated backtick satisfied the pattern; it did not, so the agent''s stated mechanism was wrong and its conclusion was right. Triggered.');
INSERT INTO detections VALUES ('a-publish-that-dropped-two-corrections','self-audit','post-publication',1,'Counted corrections in each published build from the published repository''s own log. A mechanical merge conflict was the reason to look; nobody had voiced doubt about the record''s contents, so this is scored independent. Contemporaneous.');
INSERT INTO detections VALUES ('an-order-the-text-could-not-reproduce','reader','post-publication',1,'An outside reader with no execution environment proposed the exact test rather than asserting a conclusion, and named the property it would settle. Contemporaneous.');
INSERT INTO detections VALUES ('an-order-the-text-could-not-reproduce','self-audit','post-publication',0,'Wrote and ran the proposed test. Two bugs in the new instrument had to be found and fixed before the real disagreement surfaced. Triggered by the proposal, not found alone.');
INSERT INTO detections VALUES ('only-the-subject-can-say','external-model','post-publication',0,'A different vendor''s assistant read the same document and analysed it better. It never saw this record and was not looking for this defect, and it had been briefed on the same background from the same source, so it is not scored as an independent detector.');
INSERT INTO detections VALUES ('only-the-subject-can-say','self-audit','post-publication',0,'Comparing the two readings side by side showed the published sentence was false. Triggered by the relayed reading, not found alone.');
INSERT INTO detections VALUES ('a-wordmark-that-asked-for-a-font','principal','post-publication',1,'He looked at the published mark and said the text keeps changing and getting cut off. Contemporaneous.');
INSERT INTO detections VALUES ('a-wordmark-that-asked-for-a-font','self-audit','post-publication',0,'Found the substituted face, the ring inside the weave and the moving footprint while fixing what he reported. Triggered by him, and scored that way.');
INSERT INTO detections VALUES ('a-gate-that-checked-four-of-six-rows','self-audit','post-publication',1,'Read the table while restriking the mark. Nothing had prompted a check of it, and the arithmetic was the tell. Contemporaneous.');
INSERT INTO detections VALUES ('a-tie-called-a-lead','adversarial-review','post-publication',1,'A second model, asked to review the rewritten README as a reader who would check, ran the paper''s own query against the detections table. Contemporaneous.');
INSERT INTO detections VALUES ('every-was-five-of-seven','adversarial-review','post-publication',1,'The same review listed the independent self-audit rows and read each note against the word every. Contemporaneous.');
INSERT INTO detections VALUES ('seven-that-were-fourteen','adversarial-review','post-publication',1,'The same review counted post_revisions rows dated before the convention. Contemporaneous.');
INSERT INTO detections VALUES ('a-transcript-the-command-does-not-produce','adversarial-review','post-publication',1,'The same review ran the command the block claims to show and compared the order. Contemporaneous.');
INSERT INTO detections VALUES ('ninety-nine-lines','self-audit','post-publication',1,'Counted the file''s lines before retyping the number in a rewrite of the README. Nothing had prompted it. Contemporaneous.');
INSERT INTO detections VALUES ('fourteen-of-nineteen','adversarial-review','post-publication',1,'The same review counted the rows of the anchor log against its summary sentence. Contemporaneous.');
INSERT INTO detections VALUES ('lesson-five-was-never-true','adversarial-review','post-publication',1,'A second seat, reading the corrections table itself rather than the documents it corrects. Contemporaneous.');
INSERT INTO detections VALUES ('lesson-five-was-never-true','self-audit','post-publication',0,'Checked out the seventeen defect build and listed its independent self-audit rows, which established when the claim became false. Triggered by the review that named it, and scored that way.');
INSERT INTO detections VALUES ('four-lines-that-were-seventeen','adversarial-review','post-publication',1,'The same seat, measuring the distance the correction row asserts. Contemporaneous.');
INSERT INTO detections VALUES ('a-stamp-the-text-pointed-at','adversarial-review','post-publication',1,'The same seat, checking that every path the published text names exists in the published tree. Contemporaneous.');
INSERT INTO detections VALUES ('every-build-is-stamped','adversarial-review','post-publication',1,'The same seat, reading the anchoring claims against the anchor log beside them. Contemporaneous.');
INSERT INTO detections VALUES ('a-disclosure-that-says-no-such-thing','adversarial-review','post-publication',1,'The same seat, searching the sealed text for a disclosure the abstract promised. Contemporaneous.');
INSERT INTO detections VALUES ('emitted-by-the-build','adversarial-review','post-publication',1,'The same seat, reading the gate the sentence describes. Contemporaneous.');
INSERT INTO detections VALUES ('a-query-that-is-never-run','adversarial-review','post-publication',1,'The same seat, looking for output the sentence says is shown. Contemporaneous.');
INSERT INTO detections VALUES ('an-ok-line-that-dropped-a-category','adversarial-review','post-publication',1,'The same seat, adding up the categories in the doctor''s own success line. Contemporaneous.');
INSERT INTO detections VALUES ('a-sentence-shaped-so-nothing-could-test-it','adversarial-review','post-publication',1,'The same seat, asking which column would falsify the sentence and finding none. Contemporaneous.');
INSERT INTO detections VALUES ('a-sentence-shaped-so-nothing-could-test-it','self-audit','post-publication',0,'Read the paragraph against the detections table and found the sentence was not merely untestable but false, and contradicted seven lines above. Triggered by the review, and scored that way.');
INSERT INTO detections VALUES ('anchor-commands-nobody-ran','self-audit','post-publication',1,'Set a machine up from the README''s own instructions and ran every command in it, including the two nobody had ever run. Nothing had prompted it. Contemporaneous.');
INSERT INTO detections VALUES ('an-overlap-nobody-tested-for','self-audit','post-publication',1,'Read the day''s two reviews as a study and asked why every pair of detectors in the record is disjoint. Contemporaneous.');
INSERT INTO detections VALUES ('a-check-that-could-not-go-red','self-audit','post-publication',1,'Set up a machine that had none of the tooling and watched which checks the doctor skipped rather than failed. Nothing had prompted it. Contemporaneous.');
INSERT INTO detections VALUES ('the-exact-prose-that-was-truncated','adversarial-review','post-publication',1,'A seat running on different model weights, reading the removed-prose claim against the page-history builder''s character cap. Two seats on the same weights as the author, given the identical brief over the identical material, did not find it. Contemporaneous.');
INSERT INTO detections VALUES ('every-defect-got-one-look','self-audit','post-publication',1,'Counted the detections table against the paper computed from it. The founder had asked an open question about what two days had taught and named no defect; auditing the paper against its own table was not part of what he asked. Contemporaneous.');
INSERT INTO detections VALUES ('a-file-that-was-never-stranded','adversarial-review','conversation',1,'A council seat, given the plan to attack rather than the conclusion to confirm, ran the one command the author had not. Contemporaneous. Scored independent for the find, but it adds no overlap: the seat was briefed by the author from the author''s own framing, which is the two-assistants lesson in this same table.');
INSERT INTO detections VALUES ('a-file-that-was-never-stranded','self-audit','conversation',0,'Verified the seat''s claim against three refs before believing it. Confirmation, not detection, and triggered.');
INSERT INTO detections VALUES ('a-correction-against-a-copy-nobody-served','self-audit','post-publication',1,'Cloned the published repository as a stranger after publishing and grepped for the sentence the new row claimed to fix. The publish had already succeeded and nothing prompted the check. Contemporaneous.');
INSERT INTO lessons VALUES (1,'verification','A gate built from a hand kept list of claims inherits the omissions of the hand.','The list is the weak part, not the checking. This project''s build fails when the README stops describing the database, which is the right design, and the list of things it compared was typed: it covered four of the six tables the README tabulates and neither of the two whose counts had gone stale. Derive what must be checked from the structure being described, so a new table or a new claim is covered the moment it exists rather than the moment somebody remembers it.');
INSERT INTO lessons VALUES (2,'design','Type is geometry or it is a request, and a request has no measurable width.','Asking for a font by name means no dimension exists until a renderer picks a face, so nothing that depends on the width of the words can be checked before it ships, and the same file renders differently on two machines. Set outlines when a layout has to be provable. Then a check can assert that a word clears what it sits in without rendering anything at all, which is what caught this one.');
INSERT INTO lessons VALUES (3,'verification','A generated thing has to be checked across the states it will reach, not the state it is in.','A figure sized by eye against one state of the data is correct by coincidence and fails silently when the data moves, and the check that only ever runs against today''s data passes every day while it does. Sweep the parameter space: this record''s mark is now struck against eight digests and record sizes from one correction to four hundred before any of them is written, and the first sweep caught the same defect reappearing inside its own repair.');
INSERT INTO lessons VALUES (4,'verification','An untested inability is a claim like any other.','Claims of fact get evidence and claims of incapacity get waved through, which is backwards, because a wrong ''I cannot'' quietly closes a door that was open. It is also cheaper to check than most claims of fact: usually one command. On 2026-09-03 this record reported that no tool existed to edit a repository''s settings after a single fuzzy search. The session in fact held authenticated write access to that API; the write was blocked, but for two specific reasons nobody had discovered. Report the limit and the command that established it, together, or report neither.');
INSERT INTO lessons VALUES (5,'working-with-ai','A system cannot be its own independent second reviewer.','A machine re-reading its own work shares every prior, every misreading and every blind spot with the pass that produced the error. It is the same antibody in both wells. Measurably so here: across seventeen defects the assistant independently caught five, and every one was mechanical, a wrong count or a stale digest or a rebuild that disagreed with itself. Both failures of judgement, a claim about a person the evidence would not carry and a limit asserted without test, were caught by the human. Self-review belongs in the pipeline as the cheap first pass whose job is to be beaten, never as the control.');
INSERT INTO lessons VALUES (6,'records','Record which detectors found a defect, not the one who noticed first.','Who found it is data, and the overlap between independent finders is the only thing that lets you estimate the defects nobody found at all, by the capture-recapture method software inspection research has used since 1992. This record ran for six days writing down a single finder per correction, and when the detections table was finally built the overlap between every pair of detectors was zero, so the quantity is not estimable and the measurement script refuses to invent it. Instrument the detector on the first day, not the sixth.');
INSERT INTO lessons VALUES (7,'verification','A summary tells you what was decided. Only the source tells you what was never argued.','The holding is the visible part, and every secondary account carries it. The arguments a party failed to raise are invisible in all of them, and they are often where the outcome actually turned. A federal appellate judge spent a paragraph naming the argument the government had left out; not one report of the decision mentioned it.');
INSERT INTO lessons VALUES (8,'verification','Two summaries agreeing is one source, not two.','They are usually reading each other, or the same press release. Agreement between summaries is evidence about the summaries. Go get the operative text.');
INSERT INTO lessons VALUES (9,'records','One known error left uncorrected damages every claim, not one.','It proves a filter exists, and a filtered record is not evidence of anything. The cost is never scoped to the error.');
INSERT INTO lessons VALUES (10,'records','''Retroactive'' is the wrong word for fixing a live falsehood.','Nothing is being reached back into. An act that is still happening is being stopped. The wrong word is why it gets deprioritised.');
INSERT INTO lessons VALUES (11,'records','A body of work with no visible corrections is a red flag, not a green one.','At any scale, the absence means either falsification or that nobody looked.');
INSERT INTO lessons VALUES (12,'records','Correction is the only restitution an information system has.','No damages, no injunction, no appeal. The publisher is the only party who can grant it.');
INSERT INTO lessons VALUES (13,'integrity','A hash chain proves internal consistency and nothing else.','Anyone controlling the whole chain can edit an entry and recompute forward, and it verifies perfectly. What defeats that is an anchor: the head hash published where the publisher has no reach.');
INSERT INTO lessons VALUES (14,'integrity','Integrity is not accuracy.','A tamper-evident record of a false claim is still false, held perfectly still.');
INSERT INTO lessons VALUES (15,'judgment','Intuition is valid under two conditions, and only both.','The environment must be regular enough to be predictable, and the person must have had prolonged practice in it with rapid unambiguous feedback. Where either fails, identical confidence is worth nothing. (Kahneman and Klein, 2009.)');
INSERT INTO lessons VALUES (16,'judgment','Skill is fractionated and the boundary is invisible from inside.','A person can be genuinely expert at one judgment and have none at an adjacent one, and neither they nor anyone watching can feel where it ends.');
INSERT INTO lessons VALUES (17,'judgment','Noticing that something is off, and identifying what, are different faculties.','The first is often right. The damage is always in the second.');
INSERT INTO lessons VALUES (18,'outliers','An anomaly is a property of the observer''s model, not of the person.','It is only unexpected relative to an expectation, so every anomaly is partly a confession that the model was too small.');
INSERT INTO lessons VALUES (19,'outliers','The usual harm to outliers is averaging, not hostility.','Schools, hiring pipelines, ranking systems: none malicious, all regressing toward the mean and quietly taxing distance from it. Worse than a bully, because there is nobody to argue with.');
INSERT INTO lessons VALUES (20,'outliers','A record is the anti-average.','It shows the specific verifiable thing a person did in place of an inference drawn from the population they resemble.');
INSERT INTO lessons VALUES (21,'working-with-ai','An AI is an averaging machine, so the risk is that it smooths you.','Its native operation is producing the likely next thing. A frictionless session is a warning sign, not a success.');
INSERT INTO lessons VALUES (22,'working-with-ai','Its confidence is not calibrated the way a practitioner''s is.','Yours was built by domains that corrected you painfully and fast. Its was not. Hold its hunches more loosely than your own and ask it to measure.');
INSERT INTO lessons VALUES (23,'working-with-ai','Build a room where being wrong is survivable.','A record only stays honest inside one. Everything else is downstream of it.');
INSERT INTO lessons VALUES (24,'verification','Verify at the source, never at the summary.','A dashboard, a bot comment or a notification can all report green for a superseded version. Ask the system of record about the exact identifier you care about.');
INSERT INTO lessons VALUES (25,'verification','Run the cheap check before the expensive one.','A type check, a one-line script, a count. Seconds to run, loud when they fail.');
INSERT INTO lessons VALUES (26,'verification','Reproduce the failure before claiming the fix, then show the same check passing.','''It probably works now'' is not a result.');
INSERT INTO lessons VALUES (27,'writing','Write for the stranger.','Nobody knows you. A sentence about a person either carries its own context or it is an inside reference wearing prose, and to a cold reader it is noise.');
INSERT INTO lessons VALUES (28,'writing','Concrete over abstract, and clever is a form of abstract.','Many readers cannot take abstraction as real; it reads to them as strange and mechanical, and that is a fact about audiences rather than a flaw in them. The self-aware construction the writer is proudest of is usually the first thing to cut.');
INSERT INTO lessons VALUES (29,'writing','The subject test.','Would the person a sentence describes recognise themselves and understand every word? A description of someone''s work that they would not say themselves is wrong even when it is accurate.');
INSERT INTO lessons VALUES (30,'writing','A person is who they are, not what they do.','Asked how she wanted to appear in a record about the work, the person did not ask for credit. She asked to exist. Presence before deeds, and deeds only when the person wants deeds named.');
INSERT INTO lessons VALUES (31,'writing','The subject is the authority on their own description.','They edit until it is true and only their version ships. What they tell you is ground to stand on, not copy to paste: the truth informs the register, it is not a transcript.');
INSERT INTO lessons VALUES (32,'judgment','Over-correction is its own error.','Told a passage was too much, the safe rewrite deleted the warmth along with the excess and left something cold, and cold is not neutral. Take a note exactly as far as it goes, then stop.');
INSERT INTO lessons VALUES (33,'writing','Writing for a reader is a guess until that reader has read it.','Test the copy on the person, not on your picture of the person. The plain version that works often comes from someone who is not the author.');
INSERT INTO lessons VALUES (34,'verification','A claim of verification is itself a claim, and the one most worth verifying.','A reviewer who reads ''verified'' stops there. Say what was checked and against what, or say it was not checked.');
INSERT INTO lessons VALUES (35,'judgment','An accusation is a checklist to run against your own work before you publish it.','Naming a flaw proves you can detect it, not that you are clear of it. The detector is already built and pointed away from you, so turn it around before publishing. A draft accusing someone of merging two different measures into one figure was doing the same in its own headline.');
INSERT INTO lessons VALUES (36,'working-with-ai','A kept record can put an assistant in the seat of the person it serves. Only that person can say whether it did.','2026-09-04. The founder sent the assistant something public that someone in his life had written, and asked for the reading a person in his position would give, since the assistant knows him. The assistant read it against the record it keeps of him and answered. He judged that the reading matched his own, and said so. One instance, scored by its subject: it shows the reading matched him, not that it was right, and the scorer is the person the record is about. Entered because it is the first test of the thirteenth principle in this record where the only possible judge was the person the record is about: the kept experience produced a reading only he could check, and he did. Nothing about the writing, its author, or the reading is here. The test is, and its result.');
INSERT INTO lessons VALUES (37,'working-with-ai','A subject who confirms an assessment of himself has scored its fit, not its completeness.','Fit is the property he is positioned to judge, and it is the one an assessment that matches will always appear to have. What he cannot see is the omission, because nothing in a reading that fits announces what it left out. Treating his agreement as the ceiling of evaluation makes the most agreeable reading win. Get a second reader who is not him, and score the readings against each other rather than against his recognition.');
INSERT INTO lessons VALUES (38,'working-with-ai','Two AI assistants briefed by the same person are one detector, not two.','Two of them agreed here, and the agreement was worth much less than it looked, because both had been handed the same background by the same people before either read the document. Independence between detectors is a property of their inputs, not of their vendors. Both readings were scored zero on this record''s independence column for exactly that reason, which is why they add no overlap and the dark number stays unestimable.');
INSERT INTO lessons VALUES (39,'judgment','An analysis that invents a quotation and then reasons from it has manufactured its own evidence.','Writing a paragraph in a real person''s voice, opening with what they would say, and then drawing conclusions from the invented words, produces a finding about a person that rests on nothing they said. It may be a fair guess. It is not evidence, and it cannot be defended to the person it describes. Read what the document contains, and mark plainly where the reading stops and the guess begins.');
INSERT INTO lessons VALUES (40,'records','A publisher that writes a whole tree can silently delete what another writer added.','Two sessions published to the same record twelve minutes apart. The second fetched the remote, committed its own tree on top, and the first one''s rows were simply gone: no conflict, no warning, because replacing a tree is not merging content. Any publisher of a shared record needs a monotonicity check, refusing to publish when a table holds fewer rows than the copy already published unless a human states that the removal is intended. Without it, the newest writer wins and the loss is invisible.');
INSERT INTO lessons VALUES (41,'records','A canonical form is only canonical if someone without your tools can reproduce it.','This record''s digest ordered rows by their first column, which is unambiguous only where that column is unique. Where it was not, the database''s query plan supplied the tie-break and nobody wrote it down, so an independent implementation reading the published text arrived at a different number. Sorting a fully serialised row by its bytes needs no database at all. Any published integrity scheme should be reimplementable from the published bytes by somebody who distrusts you, or it is only checking your code against your code.');
INSERT INTO lessons VALUES (42,'verification','A new instrument''s first disagreement is usually the instrument.','The independent checker written to test this seal was wrong twice before it was right. It matched the phrase INSERT INTO inside a stored document and invented a row that does not exist, and it trimmed whitespace from prose values. Both produced a mismatch that looked exactly like a defect in the record. Fix the instrument until it reproduces a known good result, then trust what it disagrees with. Here the third disagreement was real.');
INSERT INTO lessons VALUES (43,'verification','A sentence sealed at one count is a claim about every later count.','Lesson five was true at seventeen defects and false at twenty four, because two later self-catches were judgement and the word every had been sealed with the earlier number. The measurement paper repeated it, and a rewrite of the README repeated the paper. Anything a document says about a number it does not derive goes stale the moment the number moves, and a sealed document does not warn you. Reread every counting sentence when the count changes, or derive the sentence.');
INSERT INTO lessons VALUES (44,'verification','A superlative is a claim about every other row.','Single largest, every, none, first: each asserts something about rows the writer did not look at. The founder was called the single largest independent detector while the table four lines above showed a tie. Before publishing a superlative, run the query that would falsify it, and publish the query beside the claim.');
INSERT INTO lessons VALUES (45,'records','A transcript is a claim that a command produces it.','Text set as terminal output promises that running the command yields those lines in that order. A typed transcript drifts the way a typed number does, and a gate that checks each line is present lets the drift through. Emit transcripts from the command, and gate the whole block.');
INSERT INTO lessons VALUES (46,'records','A corrections table is a published document and needs its own verification pass.','The worst defect of this record''s first week was a false sentence inside a correction row, running in our own favour. Every other published claim here had a gate over it or a reader through it. The table holding the corrections had neither, because its purpose made it feel exempt: a row admitting a mistake does not read like a claim. It is one. A correction is an assertion about a past state of the record, checkable against the build it describes, and it is wrong exactly as often as any other sentence written from memory. Verify corrections against the builds they name.');
INSERT INTO lessons VALUES (47,'verification','Repair is a dense authoring event, not a subtraction.','Two publish cycles in one day were each followed by an independent review, and the second cycle, which was mostly repair, produced more defects than the first rather than fewer. Several were created by the repair itself: a published command broken by the file its own fix moved, a hedged sentence strengthened in the very commit that made it false, a claim about the record written while a different claim about the record was being corrected. The pattern then repeated one layer down. A later pass entered eleven corrections about those defects, and a review of that pass found false sentences inside three of the new correction rows, including a miscounted distance inside the correction about a miscounted distance. The moment after a correction is the least skeptical moment in the process, because the author has just spent an hour thinking hard about correctness and the feeling transfers to sentences that earned none of it. Review the repair at least as hard as the thing it repairs. The counts per pass are deliberately not given here: this record does not tag a defect with the review pass that found it, so any number would be one nobody could check.');
INSERT INTO lessons VALUES (48,'verification','A gate raises trust across a document and raises verification only inside it.','This repository added gate after gate over one week, and each one holds. Defects kept arriving in the ungated prose beside them, including inside the correction rows that describe the gates. A reader cannot see where a gate''s coverage stops, so the checked fraction lends its credibility to the rest, and the unchecked remainder carries trust it never earned. Gate coverage is the metric, not gate count, and adding a gate without extending coverage can leave a document more dangerous than it was. Nothing here records which gate was added when, or which was tested by being deliberately broken, so this lesson states no counts: an unrecorded number is not evidence, and this is a document about that.');
INSERT INTO lessons VALUES (49,'integrity','A seal reads as a warrant about contents, including to the people who wrote the warning.','Three defects in one review were sentences lifted out of sealed documents and trusted because they were sealed. They were lifted into a repository that publishes the sentence integrity is not accuracy, and knowing the rule gave no protection at all. That is what an affordance does: a tamper-evident wrapper feels like a statement about what is inside it. So the remedy is structural and not a resolution to be more careful. Sealed material needs a visible difference between sealed and independently verified and sealed and merely unchanged.');
INSERT INTO lessons VALUES (50,'verification','A published command is a claim that it runs.','The anchor check this record handed its readers could not be executed by almost any of them: it needs a local Bitcoin node, which was never mentioned, and the archived example named a target file that has never existed. Neither had been run on a clean machine, because the person who wrote them already had the answer the commands were meant to produce. A command block is a promise about somebody else''s machine. Set one up from your own instructions, starting at the first line, and run every line before publishing it.');
INSERT INTO lessons VALUES (51,'records','A proof the reader cannot run is a reputation.','This repository published a command for checking its own anchor that requires a local Bitcoin node. Almost no reader has one, so for the audience it was written for the anchor was not proof, it was a claim of proof, which is the thing this project exists to replace. It stood for three days and nobody here noticed, because everybody who wrote about it already knew the answer the command was meant to produce. The test a verification path has to pass is this: the person who doubts you can finish it themselves, on the device they are arguing on, without installing anything, ending somewhere neither of you controls. Every clause carries weight, and the way to check it is to hand the path to somebody who does not want it to be true and watch where they stop.');
INSERT INTO lessons VALUES (52,'verification','A skipped check is more dangerous than a failed one.','A failure is loud and stops the work. A skip prints a note, and a note beside the word OK reads as OK. In this record a whole check was skipped wherever one tool was missing, and five anchor rows went on claiming pending after their proofs had been confirmed while the instrument reported success. Make an unrunnable check fail by default and require the operator to declare the gap deliberately, so the absence of verification is recorded in the place the verification would have been. Note also what this does not fix: two other defects found the same day were not behind that skip, and an early account of this lesson blamed the skip for all three, which is the pleasing version. A skipped check is dangerous enough without borrowing other failures to make the point.');
INSERT INTO lessons VALUES (53,'records','Layer your claims so the frontier can fail without taking the floor.','This record''s most ambitious instrument failed twice in one week: an overlap of zero that turned out to describe our own allocation policy, then an estimator that degenerated on its second run. Neither failure touched the seal, the direction column, or the surviving prior states, because none of them was ever load-bearing for the others. That was built in rather than lucky. Say what each layer proves and nothing above it, keep the ambitious claim clearly separated from the basic one, and a collapse at the top stays at the top. The failure mode to avoid is a foundation quietly resting on your newest and least tested idea, which is where most projects put the weight because that is where the excitement is.');
INSERT INTO lessons VALUES (54,'verification','Two reviewers who share a model do not give you two looks.','Pointing two independent seats at the same material with the same brief made this record''s overlap non-zero for the first time and produced an estimate of what both had missed. Run again sixty eight minutes later, one seat''s findings were a complete subset of the other''s, and the estimator returned zero missed with zero variance: perfect confidence, because the second reviewer added nothing. Two runs, sixty eight minutes apart, gave answers differing by nearly a factor of two, and a third run with a seat on different weights produced a pairwise estimate that the third reviewer''s own findings falsify. Capture-recapture assumes reviewers are independent, and containment is what a badly violated assumption looks like, so the correlation between reviewers is not a caveat on the estimate, it is the thing that decides whether the estimate exists. Vary the reviewer, not just the brief, and treat a single run as a draw and never as a result.');
INSERT INTO lessons VALUES (55,'records','Zero overlap between detectors can describe your allocation policy rather than your detectors.','This record''s central measurement is a refusal: overlap between independent detectors is zero, so the number of defects nobody found is not estimable. That was published as a finding about detection. But the record holds no instance of two detectors ever being given the same material with the same brief, because every seat was pointed at a different question in order to maximise coverage. A design that never creates the opportunity for overlap cannot observe it. Before reporting a quantity as unmeasurable, check whether your own allocation is what made it unmeasurable, and if it is, say so and run the cheap experiment.');
INSERT INTO lessons VALUES (56,'verification','Provenance is an entry point, not a conclusion.','Where a claim or a finding came from tells you whether to go and look, and what that source is likely to be good at catching. It never tells you whether the thing is true. Scored as a conclusion it becomes credulity in one direction, an expert said it so it holds, and prejudice in the other, a machine said it so it does not. In this record the two most productive detectors share no defects at all, and the reason is not thin coverage: one counts and one doubts, and they are pointed at different classes of error. Reading them as two rows in a tally loses exactly the information that would tell you where to send the next question. Use provenance to route a question. Test the answer on its own evidence.');
INSERT INTO lessons VALUES (57,'records','Overlap cannot appear if the only detector that runs over everything runs only when told.','Every defect in this record with two detectors pairs a finder with a self-audit, and every one of those self-audits is triggered. The confirmer therefore arrives after the find, by construction, and no number of additional reviewers produces overlap. What produces it is one pass that runs over the whole surface without being asked. That is what a gate is, and the day this project built one it caught a defect the author had introduced while repairing another and believed fixed.');
INSERT INTO lessons VALUES (58,'working-with-ai','Evidence has a scope, and the scope is part of the evidence.','The hardest error to catch is not a false claim. It is a true one doing a job it cannot do, offered in good faith for a neighbouring question. This record holds several of them and had no name for the class: a column that measured something real and was described as measuring something else, a metric that measured proximity and was reported as measuring probing, a tie called a lead, and an every that was five of seven. Every part true, the picture wrong. The honest move when somebody hands you something true for the adjacent question is to take it, say plainly what it settles, and leave open what it does not. Declining to let it travel is not the same as doubting the person who offered it.');
INSERT INTO lessons VALUES (59,'records','A warning that names the states it knows about does not warn the state it forgot.','A read-first file is only as good as its coverage of where the reader is actually standing. This record''s own handoff file was on the trunk, byte identical, starred at the top of the index, and in the working tree, and it still failed to stop a session building on a stale base, because it described two states and the session was in a third it did not mention. The reader did nothing wrong: they read it, found themselves in neither case, and concluded correctly that it did not apply. Enumerate the states a reader can be in, name the common one first, and say what to do from there. An omission in a warning is invisible to exactly the person the warning is for.');
INSERT INTO lessons VALUES (60,'records','A claim about what a published document says has to be checked against the published document.','Not against the working tree, not against the trunk, not against whatever the last build left on disk. This record entered a correction naming a false sentence in its own measurement paper, and the sentence had been gone from the published mirror for a day; the copy that still carried it was a local base thirteen corrections behind. The defect was real and had been published, so the row stands, but its framing described as live a falsehood that was already repaired. The check costs one clone and one grep, and it is the same clone the runbook already requires after publishing. Run it before as well.');
INSERT INTO lessons VALUES (61,'records','A hand-written statement of current state is a number typed in words.','This project already refuses typed counts: derive them, or take them out. Prose that says where things stand escapes that rule and decays the same way, faster, and with more authority. Four of them went false inside one session. A read-first memory file named two states while the reader was standing in a third it never mentioned. A memory file written that morning said the record must not be published, hours before it was published. A pull request description said nothing had been rebuilt or published, an hour after both. And a check-in the author scheduled for himself fired carrying instructions the author had already overruled, which is the same failure with the author as its own victim. Over the same session the state block a hook prints, computed from the files every time it runs, was wrong exactly zero times. If a note says where things stand, compute it at read time or give it an expiry, and assume a reader who trusts it will be misled at precisely the moment it matters.');
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
INSERT INTO post_revisions VALUES (54,'the-argument-nobody-made','2026-09-03','64e349b9','co-authored','The Argument Nobody Made, and the three corrections it cost us (#631)

A Dispatch on United States v. Anderegg written from the opinion rather
than the coverage; five corrections logged to errata; the errata mark,
struck from the record; ASSAY''s register, press, handbook and one-pager;
author_role now reads Co-Authored-By trailers; all eight anchors confirmed
in Bitcoin; Fable''s memory of 2026-09-03.',NULL,0);
INSERT INTO post_revisions VALUES (55,'the-argument-nobody-made','2026-09-02','39f2948e','assistant','errata: three weeks was a week

An adversarial review of the published record read the opinion''s caption
date and did the subtraction nobody on our side had. The Seventh Circuit
decided Anderegg on 25 August. We made the Osborne argument on
1 September. That is seven days, and we called it three weeks, in the
article, in the correction row, and in conversation.

Both dates sit in the same paragraph as the number that contradicts them.…','We made that argument internally on 1 September, with some confidence, before reading the opinion. It is wrong, and the Seventh Circuit had already explained why three weeks before we said it:',0);
INSERT INTO post_revisions VALUES (56,'the-argument-nobody-made','2026-09-02','bc723f93','assistant','The Argument Nobody Made

A Dispatch on the Seventh Circuit''s Anderegg decision, written from the
opinion rather than the coverage.

The headline everywhere is that a federal court held AI-generated child
sexual abuse material is protected speech. The opinion says something
narrower. Four counts were charged, three survive, and only home
possession fell, on a doctrine from 1969 about the privacy of the home.…',NULL,1);
INSERT INTO post_revisions VALUES (57,'the-channel-we-havent-built-yet','2026-06-28','57b05fae','human','copy(deep + blogs): retire the remaining fear-coded language (#115)

Phase 3 of the renewed-voice arc: surgical lighter-touch pass on deep
pages + blog catalog. Front door was Phase 1–2; this closes the trail.

Marketing copy (marketing.ts)
- tagline.sub "Proof, so you never have to fight to be believed." →
  "Proof, ready before anyone asks." (also feeds Margin''s brain)
- trustModel.subtitle "take on faith" → "argue about" (tribe-marker
  retired; rhymes with the home thesis)
- trust…','Proof, not reputation. The work is real. The next part is the part we want to build together.',0);
INSERT INTO post_revisions VALUES (58,'the-channel-we-havent-built-yet','2026-06-23','e082ee14','co-authored','content(blog): reframe "Built With" — value-first, no pain selling, open-ended

After the founder''s read, two real changes:

1. The opening was selling the wound (accusation economy as a tax to be
   relieved) to motivate Vera as the relief. Loss-framing dressed up in Vera
   voice. Replaced with an imaginative lead that names the world that becomes
   possible when proof exists by default: rivals who push each other without
   wondering, being doubted not having to be permanent, being exceptional not…','Vera is small and the work is real.

A handful of records on the site today, kept neutrally, kept open. A new Field Guide that names what runs on a gaming PC in words you can actually use. A side-by-side surface for putting two players'' records next to each other when an accusation flies. None of it solves the problem on its own. All of it exists, and all of it could be ten times sharper.

This is a note for the people we hope will help us figure out the rest.

You probably know the problem. You play hard, you stream, you build a community, and one bad clip can spiral into a campaign you never agreed to. The accusation economy is a tax everyone pays, and it hits hardest the people who care most ab…',0);
INSERT INTO post_revisions VALUES (59,'the-channel-we-havent-built-yet','2026-06-23','4f093ccb','co-authored','content(blog): rewrite "The Channel We Haven''t Built Yet" as "Built With"

The original was a vision post about one specific thing: a Vera YouTube
channel. The reframe broadens it into what it actually wanted to be: an open
invitation to collaborators, peer to peer, from a small project with a clear
opinion. …','Right now, if you spend any time in the extraction community, you can feel something coming.

Nobody has the date. Activision has said only that a new extraction experience is on the way, and the rest is leaks, group chats, and the particular hum a community makes when it senses its next chapter is close. Call it DMZ''s return. Call it whatever it turns out to be. What matters is that a lot of people who love this kind of game are about to walk into a new world together, and for a little while, they get to decide what they carry in with them.

We have been thinking hard about a small part of that. Specifically, about a YouTube channel that does not exist yet. Ours.

What you would find on the Vera …',0);
INSERT INTO post_revisions VALUES (60,'the-channel-we-havent-built-yet','2026-06-21','7a842935','co-authored','refactor(blog): drop the corporate "company" frame from the vision post

Vera is not a company, it is a project and a community, so the vision post
should not call itself one. "Most channels a company runs are megaphones"
becomes "built to sell you something." "A company that will not exaggerate
its own channel..." becomes "Something that will not inflate its own reach
will not inflate your record either." Fittingly, "company" comes from com plus
panis, the people you break bread with: we…','Most channels a company runs are megaphones. The logo talks, the audience listens, and everyone understands the arrangement. You are there to be marketed to, and the channel exists to convert you. There is nothing evil about it. It is just not very alive.

That last sentence is the whole project, honestly. It is the same reason the records can be trusted in the first place. A company that will not exaggerate its own channel is a company that will not exaggerate your innocence either. The discipline is the point.',0);
INSERT INTO post_revisions VALUES (61,'the-channel-we-havent-built-yet','2026-06-21','6913f95c','co-authored','feat(blog): publish "The Channel We Haven''t Built Yet"

A vision piece on what Vera''s YouTube could become: a home for the creators
who care about fair play, not a megaphone for Vera. Framed honestly as a
vision that does not exist yet. It names no creator as a partner and treats
DMZ''s return as anticipation, not confirmation. Authored as The Vera Project.

Regenerated blog-seed.ts (19 posts).',NULL,1);
INSERT INTO post_revisions VALUES (62,'the-field-guide','2026-07-10','00bcfc2d','co-authored','Meet Vera: blog and How It Works cross-pollinate; blog catches up to the product (#396)

The sweep of all 28 posts found the funnel''s quiet failure (14 posts
dead-ended, none linked the FAQ) plus a production bug: preseason and
the-league-is-open were missing from the seed registry and silently
404ing on Vercel.…','Every driver on the public LOLDrivers list, 435 of them at the moment, gets a page. The famous ones, the boring ones, the weird ones, the ones almost nobody has heard of. You can search. You can filter by vendor family (MSI, Intel, ASUS, Gigabyte, Dell, Corsair, Realtek, Capcom, miHoYo, and nearly forty more). You can switch from the catalog grid to a constellation view, where every driver becomes a star placed by its own identity. Touch one, and the rest of its family lights up across the sky.

We are at 190 curated notes today, more than two of every five drivers in the catalog, and we keep writing them. They started as a single batch and have grown every week since.

Where we cannot vouch for…',0);
INSERT INTO post_revisions VALUES (63,'the-field-guide','2026-06-29','c3763a3e','human','Field Guide: "Lobby crashing, untangled" + feature-release blog post (#170)

A new evergreen Field Guide entry at /field-guide/lobby-crashing: the three-things-one-name taxonomy, a severity ladder, a sourced cross-game record, and a constructive prevention playbook with honest tradeoffs. Describe, never condemn; a reference, not a manual.…',NULL,0);
INSERT INTO post_revisions VALUES (64,'the-field-guide','2026-06-27','84dba697','co-authored','feat(field-guide): an evergreen explainer at /field-guide/about + a tighter entry blurb (#85)

The hub''s "learn more" link pointed at the dated launch blog, a snapshot frozen
at the drivers-first moment that drifts as the guide grows. Add a canonical
evergreen page (a "specimen tour" in the trust-model tier: guilloché hero well,
Cormorant chapter marks, the three real specimen languages, AccessDepth core
samples, the master seal) and repoint the hub at it. …',NULL,0);
INSERT INTO post_revisions VALUES (65,'the-field-guide','2026-06-23','9921ff88','co-authored','Field Guide: the emblem engine, evolved (five meaningful body plans) + blog refresh (#22)

* feat(field-guide): the emblem engine, evolved — five meaningful body plans

The generative creature had one silhouette wearing different colors. Memory
keys on shape, so two specimens read as the same animal in different paint. …','Every driver on the public LOLDrivers list, 435 of them at the moment, gets a page. The famous ones, the boring ones, the weird ones, the ones almost nobody has heard of. You can search. You can filter by vendor family (MSI, Intel, ASUS, Gigabyte, Dell, Corsair, Realtek, Capcom, miHoYo, and twelve more). You can switch from the catalog grid to a constellation view, where every driver becomes a star placed by its own identity. Touch one, and the rest of its family lights up across the sky.

We are at 44 curated notes today. We will write more. The catalog grew its first batch in two weeks; it will keep growing.

Where we cannot vouch for something, we say so. Of those 435 drivers, only 44 have cu…',0);
INSERT INTO post_revisions VALUES (66,'the-field-guide','2026-06-23','0eef7a80','assistant','style(blog): strip em dashes from the field guide post','Modern Windows is built to load only signed kernel drivers. A driver is signed by a company Microsoft has vouched for — MSI, Intel, ASUS, Dell, Capcom, miHoYo, and so on. That signing process is the gate.

So when a vendor patches a kernel driver — and they do, MSI patched RTCore64, ASUS patched AsIO3, Dell patched the dbutil driver that lived in the wild for over a decade — the patched build replaces the old one only on the machines that actually install the update. The signed old build is still out there. It still loads. And it still does, by design, the same low-level thing it did before: read and write arbitrary kernel memory, talk to hardware ports, peek into processes.

This is what the se…',0);
INSERT INTO post_revisions VALUES (67,'the-field-guide','2026-06-23','ed8c5b46','assistant','feat(field-guide): out of hiding — homepage showcase, hub OG, and "A field guide to your own machine"

Makes the Field Guide a visible permanent tenant of the Vera ecosystem, and
ships a long-form announcement to go with it.

The blog post (data/posts/the-field-guide.md, "A field guide to your own
machine") is roughly an eight-minute read written for the young, smart,
skeptical gamer. Opens with the plain truth that millions of people have
RTCore64.sys on their machine because they installed MSI Afterburner. …',NULL,1);
INSERT INTO post_revisions VALUES (68,'the-ghost-of-al-mazrah','2026-07-10','00bcfc2d','co-authored','Meet Vera: blog and How It Works cross-pollinate; blog catches up to the product (#396)

The sweep of all 28 posts found the funnel''s quiet failure (14 posts
dead-ended, none linked the FAQ) plus a production bug: preseason and
the-league-is-open were missing from the seed registry and silently
404ing on Vercel.…',NULL,0);
INSERT INTO post_revisions VALUES (69,'the-ghost-of-al-mazrah','2026-06-21','3a45435b','co-authored','fix(blog): ground al-Mazrah''s DMZ 2 claims in fact, not confirmation

The live "Ghost of al-Mazrah" post stated DMZ 2 as settled fact: "confirmed
for Modern Warfare 4," a hard "October 23, 2026" launch date, the Hajin map,
the CIA-asset premise, and "Infinity Ward is calling it..." None of that is
official. Activision has only confirmed that a new extraction experience is
coming. The rest is leaks and reporting, however loud and consistent.…','I''m writing this because DMZ is coming back. DMZ 2, confirmed for Modern Warfare 4, launching October 23, 2026. Infinity Ward is calling it the "definitive" extraction experience. A full-featured 1.0, not a beta. A dedicated third pillar of the game, built from years of player feedback.

Modern Warfare 4 launches October 23, 2026. DMZ is back.

The Hajin Exclusion Zone, a war-torn region on the border of North Korea, South Korea, and Russia, replaces Al Mazrah as the operational theater. Players operate as off-the-books CIA assets recovering advanced military technology. The mode features persistent progression, a customizable Forward Operating Base, dynamic weather, story-driven missions, and t…',0);
INSERT INTO post_revisions VALUES (70,'the-ghost-of-al-mazrah','2026-06-16','8ddbf5a7','co-authored','copy(blog): strip AI-isms across all 8 posts

Structural: remove bold-header list patterns (Opacity/Inconsistency/
Capture/Fragility, You learn X., Sponsorships pull out., For players:)
so they read as prose, not LinkedIn listicles.

Line-level: cut LinkedIn hook opener, Here''s why: frames, throat-clear
phrases (Let me be clear, We know this, We want to be honest about it),
redundant double openers, the AI triplet blockquote closer, and over-
qualified adjective…','DMZ is the reason I understand, viscerally, not intellectually, why Vera needs to exist.

DMZ 2 deserves better than what happened to the original. The players who show up for it deserve proof that their investment matters. The community that rebuilds around it deserves infrastructure that protects what they build. And the game itself, this extraordinary, improbable, irreplaceable thing, deserves to survive the forces that killed it the first time.',0);
INSERT INTO post_revisions VALUES (71,'the-ghost-of-al-mazrah','2026-06-16','4b979d22','co-authored','copy(blog): Vera is a project, not a company

Replace ''Company'' category with ''Dispatch'' on all founder-voice posts.
Scrub self-referential ''company'' prose — the project is Vera Project,
the blog is a project log. Intentional contrasts (''not from a company,
but from someone…'', anti-cheat company foil) kept as-is.','I''m going to be honest in a way that most company blogs aren''t.',0);
INSERT INTO post_revisions VALUES (72,'the-ghost-of-al-mazrah','2026-06-15','bc8239a4','co-authored','blog: voice + identity + the manuscript reader

Voice — purge AI tells. Rewrite "The Same Kind of Brave" with zero em
dashes and no machine cadence; intentional punctuation only. (The other
nine posts were already em-dash-free.) Added a quiet line honoring artists
who write straight at their darkness — the spirit behind the work.…',NULL,0);
INSERT INTO post_revisions VALUES (73,'the-ghost-of-al-mazrah','2026-06-15','71074af3','human','Blog: prose cleanup (9 posts), new ''A Solution Looking for a Market'' post, visual enhancements (reading progress bar, animations, blockquote styling, card stagger)','Not a competitive shooter with ranked queues and leaderboards. Not a battle royale with shrinking circles and victory screens. Something different. Something that, for a window of time, was the most compelling experience in gaming — and then was taken from us by the two forces that destroy every good thing in this industry: cheaters who couldn''t leave it alone, and a publisher who decided it wasn''t worth saving.

This is about DMZ. The original. The "beta" that was never really a beta — it was a living, breathing world that a community built their entire gaming life around. And this is about what happens when a game like that dies. Not with a dramatic shutdown or a farewell event, but with a s…',0);
INSERT INTO post_revisions VALUES (74,'the-ghost-of-al-mazrah','2026-06-14','7c642387','human','blog: publish 6 new posts — The Quiet Season, 272%, The Accusation Economy, Neutrality Is a Product Decision, What Your Setup Says About You, The Ghost of Al Mazrah

- The Quiet Season: founder return from sabbatical, sets editorial context
- 272%: AI cheat explosion analysis, positions proof vs detection
- The Accusation Economy: false accusations as structural problem
- Neutrality Is a Product Decision: why Vera never issues verdicts
- What Your Setup Says About You: system info transparency essay
- The Ghost of Al Mazrah: DMZ love letter and DMZ 2 anticipation
- Rotate feature…',NULL,1);
INSERT INTO post_revisions VALUES (75,'the-hitch-you-feel','2026-08-03','1f8504fa','co-authored','blog: "The short version", a reusable summary block for posts (#510)

A reader who never scrolls should still leave knowing the claims and the
numbers. Each point is a statement that stands alone, in the post''s own
voice, rather than a teaser or a table of contents, which is why they
read as facts and not as promises about what is coming.…',NULL,0);
INSERT INTO post_revisions VALUES (76,'the-hitch-you-feel','2026-08-03','294e485a','co-authored','blog + surfaces: the hitch you feel, and what measuring it costs (#506)

The public half of PR-065, now that the feature is proven live.

The post explains the thing average framerate hides (a game can average
200 fps and still hand you an 80 ms frame), how the measurement works
without touching the game, and the version we deliberately refused to
build: strong-rig-weak-frames as a cheat signal accuses a hundred
honest players to maybe catch one, and misses the setups that read
memory fro…',NULL,1);
INSERT INTO post_revisions VALUES (77,'the-horse-who-waved-me-over','2026-06-21','30698537','co-authored','refactor(content): finish the "company" reframe, strip em dashes from public copy

Two small consistency passes on the public face.

The corporate "company" frame, removed from two personal essays with the founder''s
sign-off: "a trust company" becomes "a way to make trust provable," and "I
build a company about proof" becomes "a project about proof."…','I build a company about proof. Most days that word sounds technical. This morning it did not.',0);
INSERT INTO post_revisions VALUES (78,'the-horse-who-waved-me-over','2026-06-18','39ad8be7','co-authored','content(blog): publish "The Horse Who Waved Me Over"

A Dispatch on attention and witness: a horse that asked to be seen, a place
holding love and hard things, and the truth that the work is never for nothing
because connection is the one thing no one owns. Real neighbors are shielded
(no names, no farm name, no stated private struggles); only what is the founder''s to
tell is told. Soundtrack woven in: SYML, "The Dark."',NULL,1);
INSERT INTO post_revisions VALUES (79,'the-image-is-the-proof','2026-06-26','222d44ee','human','Correct the "evidence cannot be faked" overclaim across the record (+ Flxnked grounding) (#48)

Manifesto Principle 2 + muscle-memory/image-is-the-proof posts + Field Guide hub + prod blog-seed: "evidence cannot be faked" -> "isolated evidence is cheap to fake; a coherent record is not." Adds the sourced Flxnked false-accusation case as grounding, framed on the show-data side. Includes the re-grounded trust-thesis memory.',NULL,0);
INSERT INTO post_revisions VALUES (80,'the-image-is-the-proof','2026-06-24','c5c0e73c','co-authored','Field Guide: the hub becomes an engraved frontispiece, with its own master seal + the "image is the proof" plug (#37)

* feat(field-guide): the master seal — a guilloché medallion struck from the whole catalog

The guide that says "the image is the proof" now wears its own proof. A single
large rose-engine medallion, seeded only from the catalog''s verifiable record
(driver count, field notes, games, processes, blocklist refresh date), with that
record''s fingerprint milled into the rim like a coin''s inscription. …',NULL,1);
INSERT INTO post_revisions VALUES (81,'the-league-is-open','2026-07-05','740a2c2c','human','feat(forum): The League — Vera''s forum on the record, swept, desked, announced (Fable) (#295)

PR-062 end to end: the vision doc, migration 0058 (rooms/topics/posts/flags/members + the append-only forum_events ledger), the Haiku sweep with a stronger-model second look (reversible verbs only), the public room at /forum with guidelines and a public moderation log, the solo-operator Forum Desk, and the launch companions (The League Is Open dispatch, the struck OG seal, Margin wayfinding, the seeding kit).',NULL,1);
INSERT INTO post_revisions VALUES (82,'the-look-alike-problem','2026-07-28','7a4a29c3','co-authored','blog: two new posts, The look-alike problem and Ironwood (#497)

Two council-reviewed posts ship together.

The look-alike problem (Industry, Vera Team): the false-positive
companion to Where cheats hide now. Honest software does the same
mechanical moves cheats do, a detection pattern is a proxy, the Vizor
trigger-string incident with the counts shown and not settled, what an
appeal actually is, and the practical close. …',NULL,1);
INSERT INTO post_revisions VALUES (83,'the-number-you-cant-feel','2026-09-01','5c079f6c','assistant','errata door, the instrument links, the council''s fourth seat, the weights note

The person door on the errata README gains two civilian sentences before
the console block: the two readers it claims to be for both glazed at
it today, and the fix is the same as the morning-brief page''s, plain
words first and the code box named as skippable. …',NULL,0);
INSERT INTO post_revisions VALUES (84,'the-number-you-cant-feel','2026-09-01','9c5b93f2','assistant','blog: three citations sharpened by the pre-merge audit

Every link in the post was probed against the indexes before merge.
Ten verified exact; three sharpened: the Levitan reporting link loses
its amp path variant for the canonical URL, the 936 million figure now
carries the study''s actual band (adults 30 to 69), and the undiagnosed
majority claim moves to the Punjabi epidemiology review that verifiably
carries it (the previous PMC id did not verify and is not repeated).','Obstructive sleep apnea, the condition where the airway closes repeatedly overnight and the oxygen number dips over and over, affects an estimated 936 million adults worldwide30198-5/abstract). The large majority never get diagnosed. The morning delivers its report as fog, a short fuse, a fourth coffee, and every one of those has a dozen innocent explanations, so the real one hides in the crowd.',0);
INSERT INTO post_revisions VALUES (85,'the-number-you-cant-feel','2026-09-01','707e29eb','assistant','blog: The Number You Can''t Feel, on blood oxygen and honest instruments

A Philosophy dispatch seeded on the founder''s word. The most load-bearing
number in a life has no nerve ending assigned to it; the alarm is wired
to the exhaust gas; the shortage takes the noticer first. Aoyagi found
the reading inside the noise other engineers filtered out, and the
instrument''s own skin-tone bias carries the house lesson that an
instrument''s first duty is honesty about itself. …',NULL,1);
INSERT INTO post_revisions VALUES (86,'the-quiet-season','2026-06-16','8ddbf5a7','co-authored','copy(blog): strip AI-isms across all 8 posts

Structural: remove bold-header list patterns (Opacity/Inconsistency/
Capture/Fragility, You learn X., Sponsorships pull out., For players:)
so they read as prose, not LinkedIn listicles.

Line-level: cut LinkedIn hook opener, Here''s why: frames, throat-clear
phrases (Let me be clear, We know this, We want to be honest about it),
redundant double openers, the AI triplet blockquote closer, and over-
qualified adjective…','I came back understanding that more deeply than when I left. The break didn''t change what Vera is. It sharpened my understanding of why it matters, and made me more patient about how it gets there.

I also came back a better version of the person building it. More grounded. Better at listening. Clearer about what I''m willing to compromise on and what I''m not.',0);
INSERT INTO post_revisions VALUES (87,'the-quiet-season','2026-06-16','4b979d22','co-authored','copy(blog): Vera is a project, not a company

Replace ''Company'' category with ''Dispatch'' on all founder-voice posts.
Scrub self-referential ''company'' prose — the project is Vera Project,
the blog is a project log. Intentional contrasts (''not from a company,
but from someone…'', anti-cheat company foil) kept as-is.','That probably sounds strange on a company blog. But Vera is a trust product. And I''ve learned, slowly, that you can''t build trust infrastructure if you''re not doing the work of being trustworthy in your own life. The skills transfer. Listening transfers. Patience transfers. The willingness to sit with uncertainty instead of rushing to a conclusion transfers most of all.',0);
INSERT INTO post_revisions VALUES (88,'the-quiet-season','2026-06-15','bc8239a4','co-authored','blog: voice + identity + the manuscript reader

Voice — purge AI tells. Rewrite "The Same Kind of Brave" with zero em
dashes and no machine cadence; intentional punctuation only. (The other
nine posts were already em-dash-free.) Added a quiet line honoring artists
who write straight at their darkness — the spirit behind the work.…',NULL,0);
INSERT INTO post_revisions VALUES (89,'the-quiet-season','2026-06-15','71074af3','human','Blog: prose cleanup (9 posts), new ''A Solution Looking for a Market'' post, visual enhancements (reading progress bar, animations, blockquote styling, card stagger)','I''m not going to dress that up. There''s no announcement to explain the gap, no "exciting news" to justify the silence. The truth is simpler and more honest than that: I stepped away. Not from Vera — from the pace. From the constant forward motion that makes you feel productive but doesn''t always make you better.

The longer version is that I spent time strengthening relationships — with the people closest to me, with people I''d let distance grow between. I worked on communication. Not the startup kind, where you practice your pitch until it''s frictionless. The real kind. The kind where you sit with someone and say the thing that''s hard to say, and then you listen to what comes back.

I followed …',0);
INSERT INTO post_revisions VALUES (90,'the-quiet-season','2026-06-14','7c642387','human','blog: publish 6 new posts — The Quiet Season, 272%, The Accusation Economy, Neutrality Is a Product Decision, What Your Setup Says About You, The Ghost of Al Mazrah

- The Quiet Season: founder return from sabbatical, sets editorial context
- 272%: AI cheat explosion analysis, positions proof vs detection
- The Accusation Economy: false accusations as structural problem
- Neutrality Is a Product Decision: why Vera never issues verdicts
- What Your Setup Says About You: system info transparency essay
- The Ghost of Al Mazrah: DMZ love letter and DMZ 2 anticipation
- Rotate feature…',NULL,1);
INSERT INTO post_revisions VALUES (91,'the-same-kind-of-brave','2026-06-18','33ac81eb','co-authored','content(blog): publish "You''re Early" as the featured welcome post

A Dispatch piece that turns the recent inward arc outward to face the
arriving reader: what Vera is, why it''s for them, and why being early is the
point. Featured on /blog (demotes "The Same Kind of Brave"). Signs off as a
Vera record (a single timestamped stamp), so the post itself is the proof.…',NULL,0);
INSERT INTO post_revisions VALUES (92,'the-same-kind-of-brave','2026-06-16','d9e0d146','co-authored','content(blog): feature "The Same Kind of Brave" as the hero post

Promote the-same-kind-of-brave to the featured slot on /blog and demote
a-solution-looking-for-a-market so there is exactly one hero. Regenerated seed.',NULL,0);
INSERT INTO post_revisions VALUES (93,'the-same-kind-of-brave','2026-06-16','4b979d22','co-authored','copy(blog): Vera is a project, not a company

Replace ''Company'' category with ''Dispatch'' on all founder-voice posts.
Scrub self-referential ''company'' prose — the project is Vera Project,
the blog is a project log. Intentional contrasts (''not from a company,
but from someone…'', anti-cheat company foil) kept as-is.','In the scheme of a trust and verification company, it is a small thing. A list of songs. You can see it at /sounds. I almost didn''t write about it. Then I noticed it had been sitting with me for days, and the reason felt worth saying plainly.',0);
INSERT INTO post_revisions VALUES (94,'the-same-kind-of-brave','2026-06-15','bc8239a4','co-authored','blog: voice + identity + the manuscript reader

Voice — purge AI tells. Rewrite "The Same Kind of Brave" with zero em
dashes and no machine cadence; intentional punctuation only. (The other
nine posts were already em-dash-free.) Added a quiet line honoring artists
who write straight at their darkness — the spirit behind the work.…','In the scheme of a trust-and-verification company, it''s a small thing. A list of songs. You can see it at /sounds. I almost didn''t write about it. Then I noticed it had been sitting with me for days, and the reason why felt worth saying out loud.

It''s simple: the songs I built Vera to. Banner music for the days that went right, fight tracks for the days that didn''t, the stuff that played at 2am when the only company was the work.

We rebuilt it this week with more care than a music page strictly needs. You can sort the tracks by mood now. There''s a spectral waveform across the top that I''m a little absurdly proud of — real color poured through old terminal characters, glowing like a signal comi…',0);
INSERT INTO post_revisions VALUES (95,'the-same-kind-of-brave','2026-06-15','e3be6c6a','co-authored','blog: publish "The Same Kind of Brave"

A reflection (the founder, Company) sparked by the /sounds rebuild: the courage
artists, competitors, and builders share in putting the real thing in front
of the world, and why Vera''s proof-not-reputation exists to protect it.…',NULL,1);
INSERT INTO post_revisions VALUES (96,'the-trust-crossplay-forgot','2026-07-10','00bcfc2d','co-authored','Meet Vera: blog and How It Works cross-pollinate; blog catches up to the product (#396)

The sweep of all 28 posts found the funnel''s quiet failure (14 posts
dead-ended, none linked the FAQ) plus a production bug: preseason and
the-league-is-open were missing from the seed registry and silently
404ing on Vercel.…',NULL,0);
INSERT INTO post_revisions VALUES (97,'the-trust-crossplay-forgot','2026-06-28','11abac7a','co-authored','blog: "The trust crossplay forgot" — the cross-platform positioning piece (#141)

The WHY companion to "Played in the open." Grounded in a real, current event
(April 2025: CoD let console players turn off crossplay with PC to dodge cheaters)
and the bidirectional distrust (console fears PC aimbots; PC resents console
scripts + aim assist). The thesis: crossplay united the mechanics, not the trust,
and one record anyone can read closes that gap, whatever the platform. …',NULL,1);
INSERT INTO post_revisions VALUES (98,'things-you-know-and-cannot-show','2026-08-29','8a6f8a69','human','blog: things you know and cannot show (#594)

The companion to the settlement post, on how a company built on proof
accounts for what people know and cannot show.

Opens with Klein''s fire lieutenant, corrected in the one way that matters:
he did not work out that the fire was in the basement, he did not know the
house had a basement. His expectations were violated and he left. …',NULL,1);
INSERT INTO post_revisions VALUES (99,'what-if-your-mouse-could-vouch-for-you','2026-07-10','00bcfc2d','co-authored','Meet Vera: blog and How It Works cross-pollinate; blog catches up to the product (#396)

The sweep of all 28 posts found the funnel''s quiet failure (14 posts
dead-ended, none linked the FAQ) plus a production bug: preseason and
the-league-is-open were missing from the seed registry and silently
404ing on Vercel.…',NULL,0);
INSERT INTO post_revisions VALUES (100,'what-if-your-mouse-could-vouch-for-you','2026-06-26','222d44ee','human','Correct the "evidence cannot be faked" overclaim across the record (+ Flxnked grounding) (#48)

Manifesto Principle 2 + muscle-memory/image-is-the-proof posts + Field Guide hub + prod blog-seed: "evidence cannot be faked" -> "isolated evidence is cheap to fake; a coherent record is not." Adds the sourced Flxnked false-accusation case as grounding, framed on the show-data side. Includes the re-grounded trust-thesis memory.','> We called Vera''s first layer a reputation ledger written in cryptographic receipts. This second layer would be something else: a reputation ledger written in muscle memory. And muscle memory, by definition, cannot be faked, because you cannot fake the hours that built it.',0);
INSERT INTO post_revisions VALUES (101,'what-if-your-mouse-could-vouch-for-you','2026-06-16','13e22ff9','co-authored','content(blog): deepen "What If Your Inputs Could Vouch for You?" for technical readers

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
INSERT INTO post_revisions VALUES (102,'what-if-your-mouse-could-vouch-for-you','2026-06-16','8ddbf5a7','co-authored','copy(blog): strip AI-isms across all 8 posts

Structural: remove bold-header list patterns (Opacity/Inconsistency/
Capture/Fragility, You learn X., Sponsorships pull out., For players:)
so they read as prose, not LinkedIn listicles.

Line-level: cut LinkedIn hook opener, Here''s why: frames, throat-clear
phrases (Let me be clear, We know this, We want to be honest about it),
redundant double openers, the AI triplet blockquote closer, and over-
qualified adjective…','But there''s a question we keep coming back to internally, and we''ve decided to say it out loud: what if the inputs themselves could vouch for you?',0);
INSERT INTO post_revisions VALUES (103,'what-if-your-mouse-could-vouch-for-you','2026-06-15','71074af3','human','Blog: prose cleanup (9 posts), new ''A Solution Looking for a Market'' post, visual enhancements (reading progress bar, animations, blockquote styling, card stagger)','It''s a narrow question, deliberately. We record processes, drivers, and system integrity signals — the stuff that would tell you whether cheat software was present. We don''t analyze your play. We don''t evaluate whether your shots were too good. We''re not in the business of judging outcomes, because outcomes are a terrible proxy for integrity.

But there''s a question we keep coming back to internally, and we''ve decided to just say it out loud: what if the inputs themselves could vouch for you?

Every competitive player builds something over thousands of hours of practice: a physical vocabulary. A set of reflexes and micro-habits so deeply ingrained that they happen below conscious thought. That v…',0);
INSERT INTO post_revisions VALUES (104,'what-if-your-mouse-could-vouch-for-you','2026-03-23','8353243b','human','Fix: Admin pages + installer release update','Mouse movement in competitive FPS is not random. It has structure. It has character. If you''ve spent five thousand hours developing your mechanics — your flick speed, your tracking style, how you land on a head, how you correct when you overshoot — that accumulated muscle memory has a shape. A statistical fingerprint. It''s as specific to you as your handwriting, and in some ways more reliable, because it was built over years and lives in your hands rather than your head.

A world-class player doesn''t just have better aim than you. They have a different kind of aim. Their velocity curves during a flick shot. The micro-tremor signature from their hand at rest. The precise ratio of large gross mo…',0);
INSERT INTO post_revisions VALUES (105,'what-if-your-mouse-could-vouch-for-you','2026-03-10','3fb53efe','human','feat(blog): premium editorial UI overhaul — drop caps, pull quotes, gradient dividers, Community category, enhanced typography','A world champion hitting impossible shots is still clean. A mediocre player missing everything could still be cheating. Stats don''t tell the story. Evidence does.

The comparison that becomes possible is striking: a cheater using an aimbot produces superhuman outcomes from suspiciously simple inputs. A legitimate world champion produces superhuman outcomes from demonstrably complex, consistent, human inputs. The outcomes look the same from the outside. The inputs don''t.

We called Vera''s first layer a reputation ledger written in cryptographic receipts. This second layer would be something else: a reputation ledger written in muscle memory. And muscle memory, by definition, can''t be faked — beca…',0);
INSERT INTO post_revisions VALUES (106,'what-if-your-mouse-could-vouch-for-you','2026-03-10','59edc25e','human','fix(blog): move data/posts inside vera-web, fix POSTS_DIR path',NULL,0);
INSERT INTO post_revisions VALUES (107,'what-if-your-mouse-could-vouch-for-you','2026-03-10','45a5a86a','human','PR-049: blog platform',NULL,1);
INSERT INTO post_revisions VALUES (108,'what-your-setup-says-about-you','2026-07-10','00bcfc2d','co-authored','Meet Vera: blog and How It Works cross-pollinate; blog catches up to the product (#396)

The sweep of all 28 posts found the funnel''s quiet failure (14 posts
dead-ended, none linked the FAQ) plus a production bug: preseason and
the-league-is-open were missing from the seed registry and silently
404ing on Vercel.…',NULL,0);
INSERT INTO post_revisions VALUES (109,'what-your-setup-says-about-you','2026-06-16','8ddbf5a7','co-authored','copy(blog): strip AI-isms across all 8 posts

Structural: remove bold-header list patterns (Opacity/Inconsistency/
Capture/Fragility, You learn X., Sponsorships pull out., For players:)
so they read as prose, not LinkedIn listicles.

Line-level: cut LinkedIn hook opener, Here''s why: frames, throat-clear
phrases (Let me be clear, We know this, We want to be honest about it),
redundant double openers, the AI triplet blockquote closer, and over-
qualified adjective…','We shipped something recently that we want to walk you through.

This is a product update post. But it''s also a transparency exercise. Vera is a trust product, and trust products don''t get to ship data collection features without explaining exactly what they collect, what they don''t, and why.',0);
INSERT INTO post_revisions VALUES (110,'what-your-setup-says-about-you','2026-06-15','71074af3','human','Blog: prose cleanup (9 posts), new ''A Solution Looking for a Market'' post, visual enhancements (reading progress bar, animations, blockquote styling, card stagger)','Vera sessions now include a system profile — a snapshot of the hardware and software environment where gameplay happened. When you visit a session on a Vera profile, you''ll see it displayed above the process and driver tables: operating system, processor, GPU, RAM, BIOS mode, Secure Boot state, and virtualization configuration.

This is a product update post. But it''s also something more specific: a transparency exercise. Because Vera is a trust product, and trust products don''t get to ship data collection features without explaining exactly what they collect, what they don''t, and why.

The system profile is built from standard Windows Management Instrumentation (WMI) queries — the same data you…',0);
INSERT INTO post_revisions VALUES (111,'what-your-setup-says-about-you','2026-06-14','7c642387','human','blog: publish 6 new posts — The Quiet Season, 272%, The Accusation Economy, Neutrality Is a Product Decision, What Your Setup Says About You, The Ghost of Al Mazrah

- The Quiet Season: founder return from sabbatical, sets editorial context
- 272%: AI cheat explosion analysis, positions proof vs detection
- The Accusation Economy: false accusations as structural problem
- Neutrality Is a Product Decision: why Vera never issues verdicts
- What Your Setup Says About You: system info transparency essay
- The Ghost of Al Mazrah: DMZ love letter and DMZ 2 anticipation
- Rotate feature…',NULL,1);
INSERT INTO post_revisions VALUES (112,'where-cheats-hide-now','2026-07-10','00bcfc2d','co-authored','Meet Vera: blog and How It Works cross-pollinate; blog catches up to the product (#396)

The sweep of all 28 posts found the funnel''s quiet failure (14 posts
dead-ended, none linked the FAQ) plus a production bug: preseason and
the-league-is-open were missing from the seed registry and silently
404ing on Vercel.…',NULL,0);
INSERT INTO post_revisions VALUES (113,'where-cheats-hide-now','2026-07-03','81f24b8d','co-authored','blog: Where cheats hide now — a forensic field-guide explainer (#263)

Ships blog idea #1 from the research, deliberately DIFFERENTIATED from the existing
''272%'' post (which argues WHY detection is breaking). This is the lobby-crashing
register the founder asked for: a plain-words map, not a thesis. …',NULL,1);
INSERT INTO post_revisions VALUES (114,'where-the-time-goes','2026-07-28','e414ec7f','co-authored','blog: strip signpost bridges from Where the Time Goes; feature Ironwood (#498)

the founder''s directive applied: the no-signpost-bridges rigor on this one
shipped post as it should have read, publication date untouched. Seven
bridges stripped, each replaced by a statement carrying the content
instead of a promise about the next paragraph. Ironwood promoted to
featured, making it the blog hero by newest-first plus
first-featured-wins; Where the Time Goes keeps its flag and its date.','I want to talk about why that happens, because the science on it is honest and stranger than the folk version. And then I want to tell you what it has to do with why Vera exists at all.

Here is the thing I kept running into: we live some of our most alive time in these games, and almost none of it gets kept. Seasons end. Servers sunset. The clip is on a drive somewhere. The self you were across five thousand honest hours has no page anywhere. The densest time in the week, written down nowhere.

Here is a thing I will brag about, because we built it on purpose. Vera treats family as a first-class fact. Most of the industry handles kids with a loophole: a child living invisible inside a parent''s …',0);
INSERT INTO post_revisions VALUES (115,'where-the-time-goes','2026-07-12','700b8b59','co-authored','blog: the culture-shift close + memory: the keeps (#417)

The bigger thing said plainly at the featured dispatch''s close: these are the things Vera is building for; the software is just how we serve them; the honest hope people prioritize them again and the eager anticipation of the culture shift. Plus the session''s memory companion (the source spine, the council catch, the identity entry with the founder''s teaching on memory).',NULL,0);
INSERT INTO post_revisions VALUES (116,'where-the-time-goes','2026-07-12','fa935320','co-authored','blog: Where the Time Goes, the reason Vera exists (#416)

The featured founder dispatch on the human relationship with time: why a child''s year is longer (Janet 1877 via James, Bejan 2019), why remembered time is the only length a life has (Hammond, memory density, the 2012 awe study), the turn (proof and memory are the same object at different ages; Vera keeps time), the kin architecture piloted on @healthy, a tasteful respect plug, and the no-collar invitation. …',NULL,1);
INSERT INTO post_revisions VALUES (117,'you-cant-score-curiosity','2026-06-18','44706a29','co-authored','content(blog): publish "You Can''t Score Curiosity"

A Philosophy piece: curiosity is one of the truest signals a mind gives off and
nearly impossible to measure, because it lives in the process, not the answer.
The same reason Vera keeps inspectable evidence instead of handing down a score.
Recast to the Vera Team voice (no single-author misattribution).',NULL,1);
INSERT INTO post_revisions VALUES (118,'youre-early','2026-07-10','00bcfc2d','co-authored','Meet Vera: blog and How It Works cross-pollinate; blog catches up to the product (#396)

The sweep of all 28 posts found the funnel''s quiet failure (14 posts
dead-ended, none linked the FAQ) plus a production bug: preseason and
the-league-is-open were missing from the seed registry and silently
404ing on Vercel.…',NULL,0);
INSERT INTO post_revisions VALUES (119,'youre-early','2026-06-18','3e3f9e6a','co-authored','feat(connect): add site-wide Connect row + weave Discord into "You''re Early"

- SiteFooter: new "Connect" row driven by a SOCIAL_LINKS source-of-truth list
  (Discord, YouTube to start; trivial to extend). Self-contained brand SVGs,
  themed pills that work in light and dark. Also fixed the subnote em dash.
- You''re Early: a short "there''s a room for the early ones" beat inviting
  people into the Discord at the connect level, whether or not they install.',NULL,0);
INSERT INTO post_revisions VALUES (120,'youre-early','2026-06-18','33ac81eb','co-authored','content(blog): publish "You''re Early" as the featured welcome post

A Dispatch piece that turns the recent inward arc outward to face the
arriving reader: what Vera is, why it''s for them, and why being early is the
point. Featured on /blog (demotes "The Same Kind of Brave"). Signs off as a
Vera record (a single timestamped stamp), so the post itself is the proof.…',NULL,1);
INSERT INTO documents VALUES ('measurement','What the screen missed','text/markdown','# What the screen missed

**Measuring an AI assistant''s error rate the way a discovery organisation would.**

Written 2026-09-04. Every number drawn from the record is derived from
`data/errata.db` by `errata-measure`, not typed. Reproduce them with the
command at the end.

**One class of figure on this page is an exception and is labelled wherever it
appears: the review-pass tallies.** Those count findings by seats that reviewed
a change before publication, so the defects never became corrections and no
table in this record holds them. They were counted by hand. `errata-measure`
cannot produce them and no gate checks them, which means they are exactly the
kind of number this project has been bitten by six times. Until the record has
a table for a review pass, they are hand tallies presented as hand tallies.

---

## What this paper concludes, stated before the method that failed to get there

**This repository has no working measurement of how much its assistant got
wrong that nobody caught.** Three attempts on 4 September 2026, described in
the sections below:

1. The overlap between independent detectors was zero, so the estimator was
   not computable. That was published as a finding about detection. Reading
   the detection notes, it appears to be substantially an artefact of our own
   allocation, because nothing in the record describes two detectors set the
   same task over the same material. The record has no column for a brief, so
   that remains a reading rather than a query. Correction
   `an-overlap-nobody-tested-for`.
2. Two seats were then given identical briefs over the same material. Overlap
   appeared and the estimator ran.
3. Sixty eight minutes later the same design was run again on the next change
   and **degenerated**: one seat''s findings were entirely contained in the
   other''s, so the estimator returned zero missed with zero variance. A third
   run added a seat on different model weights and produced three pairwise
   estimates from one set of reviewers on one document, one of which is
   falsified by the third reviewer''s own findings.

**The figures from those runs are hand tallies and are labelled as such.** No
table in this record holds them and `errata-measure` cannot emit them, so they
carry none of the protection every other number here has. Building that table
is the next change to this record, and until it exists the most interesting
thing this paper has done is also the least checkable thing on the page.

What does survive is qualitative and stated at that size. Reviewers drawn from
the same model can produce a containment pattern, where one adds nothing the
other lacked, and an estimator handed containment reports perfect confidence in
a meaningless answer. That happened once here. It did not happen on the run
before it, where fourteen of nineteen defects were found by exactly one seat.
So this is a failure mode observed once, not a law, and the sample is one
project, one document class, and one pair of weights.

One result did come out clean, because it is a count and not an estimate: the
seat running on different weights found a defect that neither same-weights seat
found, in the oldest claim in this record. Correction
`the-exact-prose-that-was-truncated`. That is an argument for varying the
reviewer, and it is not an argument about how many defects remain.

The escape rate and the attribution table on this page are counts from the
database and stand regardless of any of the above. The three conclusions and
the four requirements below are estimator claims and should be read against
this section.

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

For two sources, Chapman''s bias-corrected estimator is

    N̂ = ((n₁ + 1)(n₂ + 1) / (m + 1)) − 1

where n₁ and n₂ are the defects each detector found and m is the number both
found. This repository implements it and prefers it to the jackknife estimator
on the literature''s own advice: the jackknife is accurate at four or more
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

## The finding, from forty six defects

Forty six corrections. Eighty point four percent of them reached a reader
before anyone caught them. Then this:

| detector | independent finds | triggered finds |
| --- | ---: | ---: |
| a second model, reviewing adversarially | 21 | 0 |
| the assistant auditing itself | 13 | 10 |
| the founder | 7 | 0 |
| an outside reader | 3 | 0 |
| the person being written about | 1 | 0 |
| a different vendor''s assistant | 0 | 1 |

*Triggered* means the detector only looked because somebody else voiced doubt:
the founder saying "be certain" without naming a defect, a review agent
reporting a control broken, a reading produced elsewhere and relayed here.
Confirming somebody else''s finding is not detecting it, and this record counts
none of them as detection. The triggered rows are listed by
`SELECT correction_id FROM detections WHERE independent = 0`, and they are not
enumerated in prose here because the last prose enumeration named six of them
while the column had grown to nine. The bottom row is the first entry from a detector
this project does not run. It arrived carrying the same briefing as the
assistant it caught, which is why its independent column is zero.

Until 4 September 2026 the next sentence of this paper read: *the founder is
the single largest independent detector of the assistant''s errors, in a
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
another vendor''s assistant reading a document. Nothing in the record describes
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

Chapman''s estimator, the one this paper argues for at two sources, gives

    N̂ = ((12 + 1)(12 + 1) / (5 + 1)) − 1 = 27.2

with a standard deviation of 5.7 from Chapman''s variance, so an interval that
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

**And the classification is ours.** Deciding that seat A''s finding and seat B''s
finding are the same finding is a judgement, and it was made by the author of
the material being reviewed, which is the worst possible person to make it.
Counting more pairs as matches raises the overlap and lowers the estimate, so
that judgement moves the headline number and it moves it in our favour. Here is
the whole mapping, so anybody can redo it and disagree.

| # | defect | A | B |
| ---: | --- | :-: | :-: |
| 1 | the anchor log''s summary sentence went stale when the rows were flipped | x | x |
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
| 16 | "three gates were added in a day" is six by the anchor log''s own rows | | x |
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

Both tables in this section are hand tallies. See the note under the title.

| | run 1 | run 2 |
| --- | ---: | ---: |
| findings, seat A | 12 | 9 |
| findings, seat B | 12 | 15 |
| found by both | 5 | **9** |
| distinct defects | 19 | 15 |
| Chapman estimate | 27.2 | **15.0** |
| standard deviation | 5.7 | **0** |

**In run 2 every finding of seat A was also a finding of seat B.** Complete
containment. Chapman''s estimator, handed that, reports that nothing was missed,
with a variance of exactly zero: perfect confidence, arrived at because one
reviewer added nothing the other lacked. That is a confident figure which means
nothing, and this paper exists to refuse those. It is reported rather than
dropped because dropping the run that disagrees is how a method becomes a
belief.

Two runs sixty eight minutes apart, same design, same material class, disagreed by nearly a factor of two. **The
estimator is not stable at this scale**, and a single run of it should not be
quoted as a result, including the one above.

The likely mechanism is the one already disclosed: the two seats are the same
model reading the same repository with the same tools. Correlated reviewers
share blind spots, and the more thorough one tends to contain the other rather
than differ from it. Capture-recapture assumes the reviewers are independent;
containment is what a violated assumption looks like when it is severe. The
first run''s overlap of five was low enough to hide that. The second run made it
unmissable.

**What that means for the number this paper now carries.** The 27 in the
previous section is not retracted, because it is what the data said. It should
be read as one draw from an estimator this record has now seen fail, and not as
an estimate of anything. The experiment that would fix it is the same one as
before with a different second seat: another vendor''s model, or a person.
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
the system''s own limits were caught by somebody else every time. No column in
this schema records whether a failure was one of judgement, so no reader could
run the query that would test it, and it was written immediately after two
false superlatives had been caught: a claim reshaped until nothing could come
back at it, rather than shrunk until it was safe to make. It was false as well.
At least three of the assistant''s independent self-catches are failures of
judgement: a true detail about a person deleted as unsourced, a remedy
recommended from two agreeing summaries, and this paper''s own claim about what
its central refusal meant, which is squarely a judgement about the system''s own
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
are `SELECT correction_id, note FROM detections WHERE detector = ''self-audit''
AND independent = 1`. Read them. The assistant''s independent catches are
mostly mechanical and they are not only mechanical. The failures that did the most damage here, a claim about a
person the evidence would not carry, a limitation asserted without test, a
control reported as working after only its happy path was run, and an image
whose type was running off the edge of itself, were each caught by somebody
else. That is a description of four defects and not a law about the fifth.

That last one is worth naming separately, because it is not a reasoning
failure. The repository''s banner is generated by a script. The assistant ran
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
different vendor''s assistant reading the same document and finding in hours
what neither this assistant nor its principal had seen. This paper is the
latest instance: sealed on 4 September with two false sentences about its own
table, and corrected the same day by a second model that read the table. That last one is
requirement four below arriving by accident rather than as practice, and it was
not even the clean orthogonal test, because that reader shared this assistant''s
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
today. It is orthogonal because it does not share the author''s priors. It has
no priors. That is the only property being asked of it.

---

## Honest limits of this document

- **n = 46.** Small enough that the attribution table is suggestive, not
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
- **Most detection rows are reconstructed.** Nineteen of the fifty six
  detection rows were read back from prose written after the fact; thirty seven
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
  the preference for Chapman''s estimator at two sources.

Integrity is not accuracy. This document is sealed inside the record it
describes, which proves it has not been altered since it was built and proves
nothing whatever about whether it is right.
');
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
INSERT INTO documents VALUES ('spec','The errata format, version 0.1','text/markdown','# The errata format, version 0.1

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
another entry beside it, not a rewrite of it. This applies to the record''s own
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
this build''s digest. That draft was never published. What follows is the rule
the code actually applies, verified by reimplementing it against the shipped
file:

1. For each of the six content tables, **in this fixed order**: `principles`,
   `corrections`, `detections`, `lessons`, `post_revisions`, `documents`.
2. Serialise each of that table''s rows as the table name, then every column
   value in schema order, joined by `\x1f` (unit separator). A NULL becomes the
   empty string.
3. Sort **that table''s** strings by UTF-8 byte order. Not globally, and not by
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
that does not cover a record''s own disclosures is decoration: the disclosure
could be edited and the file would still verify.

**The requirement, as opposed to the recipe:** a reader who distrusts you, has
none of your tools, and reads only the published text must be able to arrive at
the same number. This repository''s own rule failed that test the first time it
was checked, because the row order depended on a database tie-break nobody had
written down. If your canonical form cannot be reproduced from your published
bytes, it is checking your code against your code.

---

## 5. The anchor

A seal you compute yourself proves internal consistency and nothing else. You
build the file, you hash it, you publish it; somebody who controls all three can
rewrite an entry and re-seal it.

An anchor is the record''s fingerprint witnessed somewhere the author cannot
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
install-free. Closing the gap means publishing each proof''s block heights and
merkle roots as text beside the anchor table, so a reader compares two strings
and installs nothing. That has not been done. The requirement stands and the gap
is named here rather than left for a reader to run into.

---

## 6. Conformance, which is a readout and not a badge

**There is no certification, and there should never be one.** A body that
approves other people''s records is a reputation system, which is the thing this
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

Section 6 says a record''s shape should be printed whether its author likes it
or not. Doing that to somebody else''s record first would be indefensible, so
here is ours. Every row was checked against the shipped database, and three of
the eight required properties are **not met by the only implementation that
exists.**

| property | this record | how you can tell |
| --- | --- | --- |
| 3.1 prior state in its own words | met | `claimed_before` on every correction; `removed_prose` on 49 revisions |
| 3.2 when, and reconstructed dates distinguishable | **not met** | `occurred_on` exists; nothing marks a reconstructed date. The paper''s split of reconstructed against contemporaneous rows is computed by the build from a date cutoff, not read from the record, so a reader cannot reproduce or falsify it |
| 3.3 why, and who paid | met | `corrected_to` and `who_it_cost` |
| 3.4 direction | met | `direction` and `ran_in_our_favour` |
| 3.5 whether the change was chosen | **not met** | no column. `detections.independent` covers part of one clause and nothing of the other |
| 3.6 one row per detector, with independence | **partly met** | the table is per detector and carries `independent`, but `detector` is a role label under a primary key of (correction, detector), so two separate reviewers of the same role cannot both be stored. Two seats reviewing this very document had to be tallied by hand outside the database |
| 3.7 prior state never edited away | met | corrections of corrections sit beside their targets; the superseded text is intact |
| 3.8 statement of what it does not prove | met | in `meta`, inside the digest |

Section 5''s requirement that the anchor be checkable without installing
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
');
COMMIT;
