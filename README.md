# Kolkata Taxi Rush

A lightweight, playable Flutter arcade game with a custom low-poly 3D street scene. The city blocks, Howrah Bridge, street furniture, traffic, and taxi are built from perspective-projected 3D shapes and drawn on Flutter Canvas—no large engine, asset download, or third-party runtime package required.

## Demo features

- Perspective city road with moving street props, sunset lighting, Howrah Bridge truss, and low-poly buildings.
- Yellow Kolkata taxi, green auto-rickshaws, traffic cars, and a blue tram.
- Three-lane steering with swipe, touch buttons, or keyboard controls.
- Dodge traffic; collect coins and passenger pickups.
- Speed and distance HUD, pause, restart, and crash summary.
- Responsive portrait game stage for phones and browser preview.

## Run it locally

```bash
flutter pub get
flutter run -d chrome
```

Or run on a connected device with `flutter run`. On desktop/web, use **← / →** or **A / D**; on touch screens, swipe or tap the left/right arrows.

This is a compact low-poly 3D-style arcade runner, not a large open-world simulator. Its software-projected scene is intentionally kept light for lower-memory machines.

## Manual GitHub Actions

Both workflows are manual—nothing runs on a push:

- **Flutter CI - Format, Analyze and Test**: runs the hosted format, analyze, and test checks.
- **Flutter Web Preview**: builds the Flutter web app and publishes it under `preview/<branch>` on the `gh-pages` branch. After a successful run from `main`, the preview URL is `https://keshab1997.github.io/kolkata-taxi-rush/preview/main/`.

Before the first web-preview run, configure **Settings → Pages → Build and deployment → Deploy from a branch**, selecting `gh-pages` and `/(root)`. The workflow does not alter Pages settings or run automatically; dispatch it only when you're ready to publish the demo preview.
