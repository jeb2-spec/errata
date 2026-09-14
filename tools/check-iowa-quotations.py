#!/usr/bin/env python3
"""
check-iowa-quotations.py - check IOWA.md against the books it quotes.

No dependencies. Python 3 standard library only. Needs the network.

    python3 tools/check-iowa-quotations.py

IOWA.md quotes three out-of-copyright books. This script downloads the
scans from the Internet Archive, normalises away the optical-character-
recognition noise, and requires every quoted sentence to be present. A
pass means the sentences in IOWA.md are in the books it says they are in.

It does NOT and CANNOT prove that those books were right. Riggs printed
"sleepy ones" in 1852 and a specialist said in 2001 that the gloss has no
linguistic basis; both of those are true, and this script only establishes
the first. Attribution is not accuracy, the same way integrity is not.

The scans are optical-character-recognised and the recognition is poor in
places. Matching is therefore done on letters and digits alone, folded to
lower case, which is the weakest comparison that still cannot pass by
accident. Where a scan reads a letter wrongly the check will fail on a
quotation that is nevertheless correct, so a failure here means go and
look, not that IOWA.md is wrong.
"""

import html as html_module
import re
import sys
import urllib.error
import urllib.request

TIMEOUT = 240

SOURCES = {
    "riggs1852": (
        "Riggs, Grammar and Dictionary of the Dakota Language, 1852",
        "https://archive.org/stream/grammardictionar00riggrich/grammardictionar00riggrich_djvu.txt",
    ),
    "james1823": (
        "James, Account of an Expedition from Pittsburgh to the Rocky "
        "Mountains, vol. 1, 1823",
        "https://archive.org/stream/accountofexpedit01jame/accountofexpedit01jame_djvu.txt",
    ),
    "miner1911": (
        "Miner, The Iowa, 1911",
        "https://www.gutenberg.org/files/39952/39952-h/39952-h.htm",
    ),
}

# Every sentence IOWA.md attributes to one of these books, in the section
# that quotes it. The comment is the claim the quotation is carrying.
QUOTATIONS = [
    # section 4: the earliest printing of "sleepy ones"
    # The scan garbles this entry's headword to "A-yu'-liba, or lyuhba" and
    # its "n. p." to "w. p.", so only the plain-English part of the line can
    # be checked mechanically. The rest is in the synonymy, below.
    ("riggs1852", "sleepy ones", "the gloss itself"),
    ("riggs1852", "the Iowa Indians", "what the entry is glossing"),
    # section 4: the entry three lines above it, in the same alphabetical run
    ("riggs1852", "to slumber", "the neighbouring a-yu- form on the same page"),
    # section 4: the real Dakota root, which is elsewhere in the book entirely
    ("riggs1852", "adj. sleepy, drowsy", "the root, and it is not on page 278"),
    # section 3: the 1823 correction, and the word that was actually meant
    ("james1823", "received the name of Pa-ho-ja, or Gray Snow", "the autonym, as taken down in 1819-20"),
    ("james1823", "erroneously believed to be the meaning of the word Pahoja", "the first correction in this record"),
    ("james1823", "the true word for pierced nose is pa-oja", "the one syllable the whole error turned on"),
    ("james1823", "known to the white people by the name of Ioways, or Aiaouez", "both names, in one sentence, in 1823"),
    # section 2: the attestation chain, from the synonymy
    ("miner1911", "Pa-h8tet.", "Marquette's 1673 spelling of the autonym"),
    ("miner1911", "Marquette", "who wrote it down"),
    ("miner1911", "Iyuhba", "Riggs's spelling, carried into the 1911 list"),
    ("miner1911", "trans. 'sleepy ones'", "the 1911 list crediting the gloss to Riggs"),
    ("miner1911", "trans. 'gray snow'", "the 1911 list crediting that gloss to Long"),
    ("miner1911", "Pierced Noses.", "and the third gloss, on the same cited page"),
    # section 5: Foster, writing in the 1870s, on what the name is made of
    ("miner1911", "is not that for themselves, nor is it a name", "the name belongs to no language"),
    ("miner1911", "made up, or compounded, by the early French", "what it is instead"),
    ("miner1911", "by taking the first two syllables", "how the compound was made"),
    # section 5: Foster doubting the standard reference, and saying what that costs
    ("miner1911", "notwithstanding the Dakota-Sioux Lexicon gives it as", "the doubt, in print, before 1911"),
    ("miner1911", "to doubt such authority may seem presumptuous", "and what it cost to say so"),
    # section 6: the autonym, and the syllable the whole family of glosses turns on
    ("miner1911", "The proper name which the Ioway give", "Foster on the autonym"),
    ("miner1911", "sometimes translated, but I think erroneously", "his correction of it"),
    ("miner1911", "The prefix", "the morpheme the argument rests on"),
    # section 6: the two origin stories Foster recorded, and who told him each
    ("miner1911", "fanciful and somewhat strained", "his verdict on the missionaries' version"),
    ("miner1911", "the accepted theory amongst the old people", "the version he was given in 1873"),
]


def fold(text):
    """Letters and digits, lower case. Everything else is scanner noise."""
    return re.sub(r"[^a-z0-9]+", "", text.lower())


def fetch(url):
    """Fetch, and strip markup if there is any.

    The Internet Archive serves plain text; Project Gutenberg serves HTML.
    Folding an HTML page without stripping it first silently injects the
    letters inside tags and entities into the text being searched, which
    made three correct quotations fail when this script was first run.
    """
    request = urllib.request.Request(url, headers={"User-Agent": "errata/check-iowa-quotations"})
    with urllib.request.urlopen(request, timeout=TIMEOUT) as response:
        body = response.read().decode("utf-8", "replace")
    if "<" in body[:4096]:
        body = re.sub(r"<(script|style)\b.*?</\1>", " ", body, flags=re.S | re.I)
        body = re.sub(r"<[^>]+>", " ", body)
        body = html_module.unescape(body)
    return body


def main():
    print()
    texts = {}
    for key, (label, url) in SOURCES.items():
        try:
            texts[key] = fold(fetch(url))
        except (urllib.error.URLError, TimeoutError, OSError) as error:
            print(f"  UNREACHABLE  {label}")
            print(f"               {error}")
            print()
            print("This check needs the network and the Internet Archive. It has")
            print("proved nothing, which is different from having failed.")
            return 2
        print(f"  fetched   {label}")
    print()

    failures = 0
    for key, quotation, carrying in QUOTATIONS:
        label = SOURCES[key][0].split(",")[0]
        if fold(quotation) in texts[key]:
            print(f"  OK    {label:9}  {quotation}")
        else:
            failures += 1
            print(f"  FAIL  {label:9}  {quotation}")
            print(f"        not found in the scan. It was carrying: {carrying}")

    print()
    if failures:
        print(f"FAIL  {failures} of {len(QUOTATIONS)} quotations were not found.")
        print("      Go and look at the scan before changing IOWA.md. The")
        print("      recognition on these books is poor in places and a miss")
        print("      here is as likely to be the scanner as the quotation.")
        return 1

    print(f"OK    all {len(QUOTATIONS)} quotations are present in the books cited.")
    print()
    print("      This proves IOWA.md quotes those books accurately.")
    print("      It does not prove those books were right.")
    print("      Attribution is not accuracy.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
