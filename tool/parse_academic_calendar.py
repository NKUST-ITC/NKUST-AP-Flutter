#!/usr/bin/env python3
"""Turn NKUST's academic-calendar PDFs into the JSON the app reads.

The registry publishes one PDF per semester and a Google Sheet, exported as
CSV, that lists them. This reads that CSV, parses every Chinese-language PDF
it names, and writes one JSON document per semester plus an index.

Run it through uv so pymupdf does not have to be installed globally:

    uv run --with pymupdf --with certifi \\
        tool/parse_academic_calendar.py --out assets/calendar
"""

from __future__ import annotations

import argparse
import csv
import datetime
import io
import json
import re
import ssl
import sys
import urllib.request
from dataclasses import dataclass
from pathlib import Path

CSV_URL = (
    "https://docs.google.com/spreadsheets/d/e/"
    "2PACX-1vSgjFXXnuyCosq2gWkvldnFtNPQl8mDU1d13UVIOx_IInPPeSsTXDUlTThakD_"
    "NAZKhM16O_1TwgOlT/pub?gid=1497644044&single=true&output=csv"
)
SITE = "https://acad.nkust.edu.tw"

# acad.nkust.edu.tw serves its leaf and then jumps straight to the TWCA root,
# leaving out the intermediate that joins them. Browsers and macOS paper over
# it by fetching the missing certificate themselves; OpenSSL does not, so the
# handshake fails everywhere else, CI included. Ship the intermediate instead
# of turning verification off. It is a public CA certificate, good until 2030,
# and it still has to chain to a root certifi already trusts.
INTERMEDIATE = Path(__file__).with_name("twca_secure_ssl_ca.pem")


def ssl_context() -> ssl.SSLContext:
    import certifi

    context = ssl.create_default_context(cafile=certifi.where())
    context.load_verify_locations(cafile=str(INTERMEDIATE))
    return context

# 課(9/7-9/16)115-1 學期選課加退選
#   unit   dates          title
EVENT = re.compile(
    r"^(?P<unit>[^()（）]{0,4})[(（]"
    r"(?P<dates>\d{1,2}\s*/\s*\d{1,2}[^)）]*)"
    r"[)）](?P<title>.+)$"
)
RANGE = re.compile(
    r"^(\d{1,2})\s*/\s*(\d{1,2})\s*[-~－～]\s*(\d{1,2})\s*/\s*(\d{1,2})\s*$"
)
SINGLE = re.compile(r"^(\d{1,2})\s*/\s*(\d{1,2})\s*(前|起|截止)?\s*$")

# 國立高雄科技大學115 學年度第一學期行事曆
HEADING = re.compile(r"(\d{3})\s*學年度第(一|二)學期行事曆")
ORDINAL = {"一": 1, "二": 2}


class ParseError(Exception):
    pass


@dataclass(frozen=True)
class Semester:
    year: int  # ROC academic year, e.g. 115
    term: int  # 1 or 2

    @property
    def code(self) -> str:
        return f"{self.year}-{self.term}"

    def gregorian(self, month: int) -> int:
        """Calendar year a bare M/D in this semester belongs to.

        A semester's PDF only ever spans one turn of the new year. The first
        runs August to January, so months before August have rolled over; the
        second runs February to August and never does.
        """
        base = self.year + 1911
        if self.term == 1:
            return base if month >= 8 else base + 1
        return base + 1


def fetch(url: str, context: ssl.SSLContext) -> bytes:
    request = urllib.request.Request(url, headers={"User-Agent": "nkust-ap"})
    with urllib.request.urlopen(request, timeout=60, context=context) as response:
        return response.read()


def list_pdfs(csv_bytes: bytes) -> list[tuple[str, str]]:
    """(name, absolute url) for the Chinese-language calendars, newest first."""
    rows = csv.DictReader(io.StringIO(csv_bytes.decode("utf-8-sig")))
    found: list[tuple[str, str]] = []
    for row in rows:
        if (row.get("Subgroup") or "").strip() != "中文版":
            continue
        url = (row.get("URL") or "").strip()
        if not url.lower().endswith(".pdf"):
            continue
        found.append(
            (
                (row.get("Filename") or "").strip(),
                url if url.startswith("http") else SITE + url,
            )
        )
    return found


def read_pdf_lines(data: bytes) -> list[str]:
    import pymupdf  # imported late so --help works without it

    with pymupdf.open(stream=data, filetype="pdf") as document:
        text = "\n".join(page.get_text() for page in document)
    return [line.strip() for line in text.splitlines() if line.strip()]


def read_semester(lines: list[str]) -> Semester:
    for line in lines[:5]:
        match = HEADING.search(line.replace(" ", ""))
        if match:
            return Semester(int(match.group(1)), ORDINAL[match.group(2)])
    raise ParseError("no 學年度第X學期行事曆 heading in the first five lines")


def parse_events(lines: list[str], semester: Semester) -> list[dict[str, str]]:
    events: list[dict[str, str]] = []
    for line in lines:
        match = EVENT.match(line)
        if not match:
            continue
        dates = match.group("dates").strip()
        # Titles arrive with the spacing the PDF used for glyph layout, which
        # is not spacing anyone typed: 115-1 學期選課 is one word.
        title = re.sub(r"\s+", "", match.group("title")).strip()
        if not title:
            continue

        span = RANGE.match(dates)
        if span:
            m1, d1, m2, d2 = (int(g) for g in span.groups())
            start = f"{semester.gregorian(m1):04d}-{m1:02d}-{d1:02d}"
            end_year = semester.gregorian(m2)
            # A range that runs backwards has crossed into the new year.
            if (m2, d2) < (m1, d1):
                end_year = semester.gregorian(m1) + 1
            end = f"{end_year:04d}-{m2:02d}-{d2:02d}"
            events.append({"start": start, "end": end, "title": title})
            continue

        point = SINGLE.match(dates)
        if point:
            month, day, suffix = int(point.group(1)), int(point.group(2)), point.group(3)
            if suffix:
                # 「(9/7 前)申請休退學」 reads as a deadline, and the deadline is
                # the whole meaning, so it has to survive into the title.
                title = f"{title}（{month}/{day} {suffix}）"
            stamp = f"{semester.gregorian(month):04d}-{month:02d}-{day:02d}"
            events.append({"start": stamp, "end": stamp, "title": title})
            continue

        raise ParseError(f"unrecognised date field {dates!r} in {line!r}")

    if not events:
        raise ParseError("no events matched")
    events.sort(key=lambda e: (e["start"], e["end"], e["title"]))
    return events


def pick_current(parsed: dict[str, list[dict[str, str]]], today: str) -> str:
    """The semester a reader is actually in.

    Not simply the newest one on the sheet: the registry publishes both of
    next year's calendars well before either starts, so through the autumn
    the latest document describes a semester nobody has reached yet.
    """
    spans = {
        code: (min(e["start"] for e in events), max(e["end"] for e in events))
        for code, events in parsed.items()
    }
    order = sorted(spans, key=lambda c: spans[c][0])
    for code in order:
        start, end = spans[code]
        if start <= today <= end:
            return code
    for code in order:
        if today < spans[code][0]:
            return code
    return order[-1]


def semester_key(code: str) -> tuple[int, ...]:
    return tuple(int(part) for part in code.split("-"))


def surrounding(parsed: dict[str, list[dict[str, str]]], current: str) -> list[str]:
    """The current semester and whichever neighbours have been published.

    Week one still looks back at last semester's make-up exams, and from the
    midterms on the question is when the next one starts. Either side may be
    absent — the archive begins somewhere, and the registry posts a calendar
    months after the one it follows — so a missing neighbour just shortens
    the window.
    """
    order = sorted(parsed, key=semester_key)
    at = order.index(current)
    return order[max(at - 1, 0) : at + 2]


def merge(
    parsed: dict[str, list[dict[str, str]]], codes: list[str]
) -> list[dict[str, str]]:
    """Those semesters as one calendar, in date order.

    Consecutive semesters overlap by a few days and the registry prints some
    of the entries in that seam on both sheets, so identical ones collapse.
    """
    seen: set[tuple[str, str, str]] = set()
    events: list[dict[str, str]] = []
    for code in codes:
        for event in parsed[code]:
            key = (event["start"], event["end"], event["title"])
            if key not in seen:
                seen.add(key)
                events.append(event)
    events.sort(key=lambda e: (e["start"], e["end"], e["title"]))
    return events


def write_json(path: Path, payload: object) -> bool:
    """Writes only when the content changes, so reruns leave a clean tree."""
    text = json.dumps(payload, ensure_ascii=False, indent=2) + "\n"
    if path.exists() and path.read_text(encoding="utf-8") == text:
        return False
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")
    return True


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path, default=Path("assets/calendar"))
    parser.add_argument(
        "--current",
        type=Path,
        help=(
            "also write the current semester and its neighbours here, for "
            "the bundled asset"
        ),
    )
    parser.add_argument("--csv-url", default=CSV_URL)
    parser.add_argument(
        "--min-events",
        type=int,
        default=20,
        help=(
            "fail if a semester yields fewer than this many events; a layout "
            "change that breaks the line format shows up as a handful of "
            "matches rather than an error, and must not quietly ship"
        ),
    )
    parser.add_argument(
        "--pdf",
        type=Path,
        nargs="*",
        help="parse these local files instead of going to the network",
    )
    args = parser.parse_args()

    sources: list[tuple[str, bytes]] = []
    if args.pdf:
        sources = [(str(p), p.read_bytes()) for p in args.pdf]
    else:
        context = ssl_context()
        for name, url in list_pdfs(fetch(args.csv_url, context)):
            sources.append((name, fetch(url, context)))
        if not sources:
            print("no Chinese calendars listed in the CSV", file=sys.stderr)
            return 1

    parsed: dict[str, list[dict[str, str]]] = {}
    for name, data in sources:
        lines = read_pdf_lines(data)
        try:
            semester = read_semester(lines)
            events = parse_events(lines, semester)
        except ParseError as error:
            print(f"{name}: {error}", file=sys.stderr)
            return 1
        if len(events) < args.min_events:
            print(
                f"{name}: only {len(events)} events, expected at least "
                f"{args.min_events} — the PDF layout has probably changed",
                file=sys.stderr,
            )
            return 1
        if semester.code in parsed:
            print(f"{name}: {semester.code} seen twice", file=sys.stderr)
            return 1
        parsed[semester.code] = events
        print(f"{name} -> {semester.code}: {len(events)} events", file=sys.stderr)

    changed: list[str] = []
    for code, events in parsed.items():
        if write_json(args.out / f"{code}.json", events):
            changed.append(f"{code}.json")

    codes = sorted(parsed, key=semester_key)
    if write_json(args.out / "index.json", codes):
        changed.append("index.json")

    if args.current and parsed:
        current = pick_current(parsed, datetime.date.today().isoformat())
        bundled = surrounding(parsed, current)
        print(
            f"current semester: {current}, bundling {', '.join(bundled)}",
            file=sys.stderr,
        )
        if write_json(args.current, merge(parsed, bundled)):
            changed.append(str(args.current))

    print("changed: " + (", ".join(changed) if changed else "nothing"), file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
