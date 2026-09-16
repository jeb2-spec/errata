#!/usr/bin/env python3
"""
check-iowa-quotations.py - check IOWA.md against the sources it quotes.

No dependencies. Python 3 standard library only. Needs the network.

    python3 tools/check-iowa-quotations.py

Three phases, in increasing strictness, because the sources differ in how
faithfully they can be compared.

  EXACT   For sources that are clean digital text: Project Gutenberg and
          the Iowa Tribe of Oklahoma's own page. Every character must
          match, punctuation included. Line breaks are collapsed first,
          because line wrapping is typesetting and not text, and so is
          markdown emphasis. Nothing else is normalised away.

  FOLD    For sources that exist only as optical-character-recognised
          scans, where the recognition mangles accents and italic letters
          and an exact comparison would fail on correct quotations.
          Matching is on letters and digits alone, folded to lower case.

  COUNTS  Every number this file states about its own table is derived
          from that table and compared. Nothing about the record's size
          is allowed to be a typed word. This phase exists because those
          counts kept going stale, repeatedly, in one session, and more
          than once after the rule about it had been read. The tally of
          how many times is itself a derivable number and is therefore
          not written here: the rows are in IOWA.md section 1, whose
          slugs begin `counts-` and `a-gate-`.

          And note what this phase does NOT cover: it reads IOWA.md and
          README.md. When it was added, the next stale number appeared
          within the hour in a YAML frontmatter field and a pull request
          description, neither of which any gate reads. A gate covers
          where you pointed it. The error goes where you did not.

  PROSE   No em dash outside a block quotation, which is a standing house
          rule for this project's public writing. Inside a quotation the
          source's punctuation stands as printed: reproducing a source
          faithfully outranks house style, always.

WHY THE THIRD PHASE, AND WHY EXACT EXISTS AT ALL. The first version of
this script had only FOLD. Folding strips every character that is not a
letter or a digit, so it could not see an em dash substituted for an en
dash, or an ASCII apostrophe substituted for U+2019. Those are exactly
the substitutions IOWA.md had made, in six of six quotations checked,
including the one from the Iowa Tribe of Oklahoma. A verifier had been
built that was structurally incapable of detecting the class of error
its author was making, and it passed 24 of 24 while six quotations were
wrong. The corrections are `six-quotations-altered-in-transcription` and
`a-verifier-blind-to-its-own-class-of-error` in section 1 of IOWA.md.

It does NOT and CANNOT prove that those sources were right. Riggs printed
"sleepy ones" in 1852 and a specialist said in 2001 that the gloss has no
linguistic basis; both of those are true, and this script only establishes
the first. Attribution is not accuracy, the same way integrity is not.
"""

import html as html_module
import re
import sys
import urllib.error
import urllib.request
from pathlib import Path

TIMEOUT = 240
ROOT = Path(__file__).resolve().parent.parent
IOWA_MD = ROOT / "IOWA.md"
README = ROOT / "README.md"

EM = "—"
EN = "–"
RSQ = "’"

# mode: "exact" for clean digital text, "fold" for an OCR scan.
SOURCES = {
    "riggs1852": (
        "Riggs, Grammar and Dictionary of the Dakota Language, 1852",
        "https://archive.org/stream/grammardictionar00riggrich/grammardictionar00riggrich_djvu.txt",
        "fold",
    ),
    "james1823": (
        "James, Account of an Expedition from Pittsburgh to the Rocky "
        "Mountains, vol. 1, 1823",
        "https://archive.org/stream/accountofexpedit01jame/accountofexpedit01jame_djvu.txt",
        "fold",
    ),
    "miner1911": (
        "Miner, The Iowa, 1911",
        "https://www.gutenberg.org/files/39952/39952-h/39952-h.htm",
        "exact",
    ),
    "iowatribeok": (
        "Iowa Tribe of Oklahoma, About Us",
        "https://iowanation.org/about-us/",
        "exact",
    ),
}

QUOTATIONS = [
    # --- Riggs 1852, section 4. OCR only; the scan garbles this entry's
    # headword to "A-yu'-liba, or lyuhba" and its "n. p." to "w. p.", so
    # only the plain-English part of the line can be compared at all.
    ("riggs1852", "sleepy ones", "the gloss itself", True),
    ("riggs1852", "the Iowa Indians", "what the entry is glossing", True),
    ("riggs1852", "to slumber", "the neighbouring a-yu- form on the same page", True),
    ("riggs1852", "adj. sleepy, drowsy", "the root, and it is not on page 278", True),
    # --- James 1823, section 3. OCR only.
    ("james1823", "received the name of Pa-ho-ja, or Gray Snow", "the autonym, taken down 1819-20", True),
    ("james1823", "erroneously believed to be the meaning of the word Pahoja", "the first correction in this record", True),
    ("james1823", "the true word for pierced nose is pa-oja", "the one syllable the error turned on", True),
    ("james1823", "known to the white people by the name of Ioways, or Aiaouez", "both names, one sentence, 1823", True),
    # --- Miner 1911, sections 2 and 5. Clean text, so every character counts.
    ("miner1911", "Pa-h8tet." + EM + "Marquette", "the 1673 entry, set closed up as the book sets it", True),
    ("miner1911", "(trans. " + RSQ.replace(RSQ, "‘") + "sleepy ones" + RSQ + ")", "the list crediting the gloss to Riggs", False),
    ("miner1911", "(trans. ‘gray snow" + RSQ + ")", "the list crediting that gloss to Long", False),
    ("miner1911", "Pierced Noses.", "the third gloss, on the same cited page", False),
    ("miner1911", "them" + EM + "that of Ioway" + EM + "(or Iowa, which is the form the "
                  "word takes when applied to the State)" + EM + "is not that for themselves, "
                  "nor is it a name which belongs to the language of any one Indian tribe",
     "the name belongs to no language, as printed", True),
    ("miner1911", "made up, or compounded, by the early French, from the Dakota-Sioux "
                  "designation for them of Ayu" + RSQ + "h" + RSQ + "äpä, by taking the first two syllables",
     "what it is instead, with the source's own diacritics", True),
    ("miner1911", "name for them of Äyu´h" + RSQ + "äpä, notwithstanding the "
                  "Dakota-Sioux Lexicon gives it as meaning the Drowsy-Ones, and to doubt "
                  "such authority may seem presumptuous",
     "Foster doubting the standard reference, and what it cost him", True),
    ("miner1911", "is Pähutch" + RSQ + "æ, Dusty-Heads: sometimes translated, but I think erroneously",
     "Foster on the autonym, and his correction of it", False),
    ("miner1911", "Wähōtch" + RSQ + "ærä, the Gray-Ones", "the Ho-Chunk name, corroborating grey", True),
    ("miner1911", "fanciful and somewhat strained", "his verdict on the missionaries' version", False),
    ("miner1911", "the accepted theory amongst the old people", "the version he was given in 1873", False),
    ("miner1911", "“Ayu" + RSQ + "hpä, n. p. (sleepy ones:) the Ioway Indians.”",
     "Riggs as Foster prints him, which is not how Riggs printed it", False),
    # --- The Iowa Tribe of Oklahoma, section 6. The most important quotation
    # in the document, and until this version it was not checked at all.
    ("iowatribeok", "we call ourselves Baxoje (Bah Kho-je), meaning, “People of the Grey Snow.”",
     "the autonym, in the words of the people whose name it is", True),
    ("iowatribeok", "we had lost some of the translation to the story " + EN + " it could have been another tribe",
     "an EN dash, which IOWA.md had printed as an EM dash", True),
    ("iowatribeok", "Other versions of this story have been printed, but this is the one that we have been told.",
     "their own provenance marker, which is the best sentence in the file", True),
]


def fold(text):
    """Letters and digits, lower case. Everything else is scanner noise."""
    return re.sub(r"[^a-z0-9]+", "", text.lower())


def flatten(text):
    """Collapse whitespace only. Line wrapping is typesetting, not text."""
    return re.sub(r"\s+", " ", text).strip()


def tight(text):
    """Remove whitespace entirely; keep every other character.

    Whitespace here is an artifact of three things that are not the text:
    line wrapping in the book, line wrapping in IOWA.md, and the spaces
    this script inserts when it strips HTML tags. Everything that is not
    whitespace is the text, and must match. The cost of this choice is
    stated in the docstring: spacing around a dash inside a quotation is
    not machine-checked, so check it by eye against the scan.
    """
    return re.sub(r"\s+", "", text)


def fetch(url):
    """Fetch, and strip markup if there is any."""
    request = urllib.request.Request(url, headers={"User-Agent": "errata/check-iowa-quotations"})
    with urllib.request.urlopen(request, timeout=TIMEOUT) as response:
        body = response.read().decode("utf-8", "replace")
    if "<" in body[:4096]:
        body = re.sub(r"<(script|style)\b.*?</\1>", " ", body, flags=re.S | re.I)
        body = re.sub(r"<[^>]+>", " ", body)
        body = html_module.unescape(body)
    return body


def markdown_text(md):
    """IOWA.md as comparable text: emphasis and quote markers are mine.

    Fenced code blocks are removed first, and that is a correction rather
    than a nicety. IOWA.md section 12 prints a sample of THIS SCRIPT'S own
    output. While that sample was in the haystack, a quotation could pass
    the "does IOWA.md print it" test purely by appearing in the echo of a
    previous run, and one did. A checker that reads its own transcript is
    checking itself. See `a-gate-that-matched-its-own-echo`.
    """
    md = re.sub(r"^```[\s\S]*?^```", "", md, flags=re.M)
    stripped = re.sub(r"^\s*>\s?", "", md, flags=re.M)
    stripped = stripped.replace("*", "").replace("`", "")
    return flatten(stripped)


NUMBER_WORDS = {
    1: "one", 2: "two", 3: "three", 4: "four", 5: "five", 6: "six",
    7: "seven", 8: "eight", 9: "nine", 10: "ten", 11: "eleven",
    12: "twelve", 13: "thirteen", 14: "fourteen", 15: "fifteen",
    16: "sixteen", 17: "seventeen", 18: "eighteen", 19: "nineteen",
    20: "twenty",
}


def parse_table(md):
    """Read section 1's table. This is the only source of truth for size."""
    rows = []
    for line in md.split("\n"):
        if not line.startswith("| `"):
            continue
        cells = [c.strip() for c in line.strip("|").split("|")]
        if len(cells) < 6:
            continue
        rows.append({"slug": cells[0].strip("`"), "found_by": cells[2],
                     "direction": cells[4], "who_paid": cells[5]})
    return rows


def check_counts(md, rows, readme=""):
    """Derive every number the prose states, and require the prose to agree."""
    total = len(rows)
    # A word boundary, not a prefix. Matching "me" as a prefix counted
    # Melendy, 1893 as one of mine, which is how a counting gate quietly
    # credits a nineteenth-century historian's error to its own author.
    mine = sum(1 for r in rows if re.match(r"me\b", r["found_by"], re.I))
    theirs = total - mine
    shipped = sum(1 for r in rows if "after it shipped" in r["found_by"])
    favoured = sum(1 for r in rows
                   if re.match(r"me\b", r["found_by"], re.I)
                   and r["direction"].strip() == "in my favour")
    w = NUMBER_WORDS

    required = [
        (f"The record, in {w[total]} rows", "the section 1 heading"),
        (f"The findings are short. {w[total].capitalize()} corrections.", "the abstract"),
        (f"{w[total].capitalize()} corrections. {w[theirs].capitalize()} of them are "
         f"other people's and {w[mine]} are mine.", "the section 1 summary"),
        (f"{w[shipped].capitalize()} were caught\nafter", "how many reached a reader"),
        (f"{w[favoured].capitalize()} of the {w[mine]} that are mine ran the same way",
         "the direction finding"),
        (f"{w[total].capitalize()} claims", "the language-model section"),
        (f"{w[total].capitalize()} corrections. Not one ran against the state.", "the short version"),
    ]
    problems = []
    for needle, what in required:
        if needle not in md:
            problems.append((needle, what))
    # The README describes the same table, so it goes stale the same way.
    readme_needle = (f"{w[total].capitalize()} corrections, {w[mine]} of them its "
                     f"author's own, {w[shipped]} of those found only after it was published.")
    if readme and readme_needle not in readme:
        problems.append((readme_needle, "README.md section 12"))
    return total, mine, theirs, shipped, favoured, problems


def check_prose(md):
    """No em dash outside a block quotation. Report the quoted ones."""
    problems, quoted = [], []
    for number, line in enumerate(md.split("\n"), 1):
        if EM not in line:
            continue
        (quoted if line.lstrip().startswith(">") or "`" in line else problems).append(
            (number, line.strip())
        )
    return problems, quoted


def main():
    md = IOWA_MD.read_text(encoding="utf-8")
    haystack = markdown_text(md)
    print()

    texts = {}
    for key, (label, url, _mode) in SOURCES.items():
        try:
            texts[key] = fetch(url)
        except (urllib.error.URLError, TimeoutError, OSError) as error:
            print(f"  UNREACHABLE  {label}\n               {error}\n")
            print("This check needs the network. It has proved nothing, which is")
            print("different from having failed.")
            return 2
        print(f"  fetched   {label}")
    print()

    failures = 0
    for key, quotation, carrying, printed in QUOTATIONS:
        label, _url, mode = SOURCES[key]
        short = label.split(",")[0]
        source = texts[key]
        if mode == "exact":
            found = tight(quotation) in tight(source)
            in_file = (not printed) or tight(quotation) in tight(haystack)
        else:
            found = fold(quotation) in fold(source)
            in_file = (not printed) or fold(quotation) in fold(haystack)

        shown = quotation if len(quotation) <= 58 else quotation[:55] + "..."
        if found and in_file:
            print(f"  OK    {mode:5} {short:9}  {shown}")
        else:
            failures += 1
            where = "the source" if not found else "IOWA.md"
            print(f"  FAIL  {mode:5} {short:9}  {shown}")
            print(f"        not found in {where}. It was carrying: {carrying}")

    rows = parse_table(md)
    readme = README.read_text(encoding="utf-8") if README.exists() else ""
    total, mine, theirs, shipped, favoured, count_problems = check_counts(md, rows, readme)
    print()
    print(f"  derived from the table: {total} rows, {mine} mine, {theirs} theirs, "
          f"{shipped} found after it shipped, {favoured} of mine in my favour")
    for needle, what in count_problems:
        failures += 1
        print(f"  FAIL  counts            {what} does not match the table")
        print(f"        the table requires this sentence: {needle!r}")
    if not count_problems:
        print(f"  OK    counts            every stated number matches the table")

    problems, quoted = check_prose(md)
    print()
    for number, line in problems:
        failures += 1
        print(f"  FAIL  prose             em dash in IOWA.md's own prose, line {number}")
        print(f"        {line[:88]}")
    if not problems:
        print(f"  OK    prose             no em dash outside a quotation")
    print(f"  note  prose             {len(quoted)} em dash(es) inside quoted material, "
          f"line(s) {', '.join(str(n) for n, _ in quoted) or 'none'}")
    print(f"                          those are the sources' punctuation, not ours. "
          f"Check them against the scan, never edit them to taste.")

    print()
    if failures:
        print(f"FAIL  {failures} check(s) did not pass.")
        print("      For an OCR source, go and look at the scan before changing")
        print("      IOWA.md: a miss may be the scanner. For an exact source it")
        print("      is a real difference, and the quotation is the thing to fix.")
        return 1

    print(f"OK    all {len(QUOTATIONS)} quotations match, and the prose is clean.")
    print()
    print("      This proves IOWA.md quotes those sources accurately.")
    print("      It does not prove those sources were right.")
    print("      Attribution is not accuracy.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
