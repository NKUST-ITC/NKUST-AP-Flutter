# Live integration tests

Tests in this directory hit the real NKUST websites
(`acad.nkust.edu.tw`, `webap.nkust.edu.tw`, `stdsys.nkust.edu.tw`). They
are **skipped by default** so `dart test` stays hermetic; opt in via
`--tags`.

## Running

```bash
# anonymous tests only (no credentials, only network)
dart test -P live-anonymous -r expanded

# everything, including authenticated flow (requires creds)
NKUST_USER=<student_id> NKUST_PASS=<webap_password> \
  dart test -P live -r expanded
```

`-r expanded` makes the per-step `print()` log show inline so you can
see exactly what each test hit and what came back. Without it the
default reporter only prints test names.

The presets are defined in `dart_test.yaml`; default `dart test`
excludes them via `exclude_tags`.

Tests without credentials self-skip with a clear reason; nothing fails
just because env vars are missing.

If `NKUST_USER` / `NKUST_PASS` are unset, the authenticated tests
self-skip with a clear message — they will not fail the run.

## What's covered

| File | Tag(s) | Side effects |
|---|---|---|
| `notifications_live_test.dart` | `live`, `live-anonymous` | none — read-only POST to acad |
| `authenticated_live_test.dart` | `live` | logs into webap, **no writes** (no bus booking, no leave submission, no preference persistence — uses an in-memory `KeyValueStore`) |

## What's intentionally NOT covered

- Bus booking / cancellation (would create real reservations)
- Leave submission (would file a real leave application)
- Password-error paths (account lockout after 5 wrong attempts)

These need either a sandbox account / endpoint we don't have, or careful
manual smoke testing.

## When live tests fail

Failures usually fall into one of three buckets:

1. **Captcha OCR miss** — the Euclidean-distance solver is ~95 % accurate
   per attempt; `WebApHelper.login` already retries up to 5 times. If
   you see `CaptchaException` after that, re-run; if it persists, the
   templates in `assets/eucdist/` may have drifted from what the server
   now ships.
2. **HTML / API drift** — the school changed the page structure. Update
   the relevant parser in `lib/src/parsers/`.
3. **Server-side outage / maintenance window** — webap is taken down for
   patching every now and then. Re-run later before debugging.

## Don't run on CI by default

The `tags.live` skip-by-default in `dart_test.yaml` keeps these out of
the normal CI pipeline. If you want a separate live-test workflow,
trigger it manually with credentials in GitHub Actions secrets — never
commit credentials to the repo.
