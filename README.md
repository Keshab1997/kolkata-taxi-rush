# Kolkata Taxi Rush

A small, playable Flutter arcade-game demo inspired by the Kolkata Taxi Rush concept image. It uses Flutter's `CustomPainter` and a lightweight Dart game loop—no 3D engine, downloaded assets, or third-party runtime packages required.

## Demo features

- Three-lane Kolkata road with a stylized Howrah Bridge skyline and yellow Ambassador-style taxi.
- Swipe, arrow buttons, or keyboard controls to change lanes.
- Dodge traffic and collect coins and passenger pickups.
- Distance and speed HUD, pause, restart, and crash summary.
- Responsive portrait layout for mobile, with a browser-friendly presentation frame.

## Run it locally

```bash
flutter pub get
flutter run -d chrome
```

Or run on a connected device with `flutter run`. On desktop/web, use **← / →** or **A / D**; on touch screens, swipe or tap the left/right arrows.

This is a compact 2D/2.5D prototype, not a full 3D city game. All scene art is drawn in Dart so the demo stays small and should be practical to experiment with on lower-memory machines.

## Manual GitHub Actions

Both workflows are manual—nothing runs on a push:

- **Flutter CI - Format, Analyze and Test**: runs the hosted format, analyze, and test checks.
- **Flutter Web Preview**: builds the Flutter web app and publishes it under `preview/<branch>` on the `gh-pages` branch. After a successful run from `main`, the preview URL is `https://keshab1997.github.io/kolkata-taxi-rush/preview/main/`.

Before the first web-preview run, configure **Settings → Pages → Build and deployment → Deploy from a branch**, selecting `gh-pages` and `/(root)`. GitHub Pages may require a paid plan for a private source repository; the published site is normally public even when its source repository is private. The workflow does not alter Pages settings or run automatically; dispatch it only when you're ready to publish the demo preview.
