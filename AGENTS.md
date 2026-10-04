# AGENTS.md

<!-- Keshab-managed policy block: preserve these checks and workflow rules. -->

## Check policy

| Change | Required check |
|---|---|
| Any change | `python3 tool/preflight.py` |
| Dart edit | Run the single relevant test file: `flutter test test/<name>_test.dart` |
| Shared surface, risky diff, or Keshab asks | `flutter analyze` and full `flutter test` |

- Do not run `flutter build apk`, `flutter build aab`, `flutter build web`, or `gradlew` locally just to check.
- Do not rerun the full battery after a small edit. CI handles checks that take minutes.

## Working rules

- Push directly to `main` with `python3 tool/agent_loop.py -m "type(scope): summary"`; it runs preflight, checks staged secrets, commits, and pushes.
- Use Conventional Commit messages. Never commit tokens, signing files, `key.properties`, or `google-services.json`.
- CI is manual. Do not wait for a run after pushing; Keshab dispatches it from Actions when ready.
- Ask before changing workflows, secrets, settings, publishing, or making the repository public.

## Project notes

- Keep the demo asset-free and light: the road, cars, skyline, and pickups are drawn with Flutter Canvas.
- Keep the city in a lightweight, software-projected low-poly 3D style; avoid adding a heavy engine or large asset bundles without Keshab's approval.
