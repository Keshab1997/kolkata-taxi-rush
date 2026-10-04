import 'dart:math';

enum RoadItemKind { traffic, coin, passenger }

class RoadItem {
  RoadItem({
    required this.lane,
    required this.kind,
    this.progress = 0,
    this.variant = 0,
  });

  final int lane;
  final RoadItemKind kind;
  final int variant;
  double progress;
}

/// Small, renderer-independent rules model for one Kolkata Taxi Rush ride.
class KolkataRun {
  KolkataRun({Random? random}) : _random = random ?? Random();

  final Random _random;
  final List<RoadItem> items = <RoadItem>[];

  int lane = 1;
  int coins = 0;
  int passengers = 0;
  double distance = 0;
  double roadOffset = 0;
  double _spawnTimer = 0;
  bool crashed = false;

  int get distanceMeters => distance.floor();

  int get speedKmh => min(142, 58 + (distance * 0.066).round());

  void reset() {
    items.clear();
    lane = 1;
    coins = 0;
    passengers = 0;
    distance = 0;
    roadOffset = 0;
    _spawnTimer = 0;
    crashed = false;
  }

  void moveLeft() => lane = max(0, lane - 1);

  void moveRight() => lane = min(2, lane + 1);

  void update(double elapsedSeconds) {
    if (crashed || elapsedSeconds <= 0) return;

    // Clamp long frames (for example, after the browser tab is backgrounded).
    final dt = elapsedSeconds.clamp(0.0, 0.1).toDouble();
    distance += dt * (18 + speedKmh * 0.22);
    roadOffset = (roadOffset + dt * (0.7 + speedKmh / 150)) % 1;

    _spawnTimer += dt;
    final spawnInterval = (0.92 - distance / 6500).clamp(0.58, 0.92).toDouble();
    while (_spawnTimer >= spawnInterval) {
      _spawnTimer -= spawnInterval;
      _spawnItem();
    }

    final approachSpeed = 0.24 + speedKmh / 520;
    for (var index = items.length - 1; index >= 0; index--) {
      final item = items[index];
      item.progress += dt * approachSpeed;

      if (item.lane == lane && item.progress >= 0.84 && item.progress <= 0.98) {
        if (item.kind == RoadItemKind.traffic) {
          crashed = true;
          return;
        }
        if (item.kind == RoadItemKind.coin) coins++;
        if (item.kind == RoadItemKind.passenger) passengers++;
        items.removeAt(index);
      } else if (item.progress > 1.04) {
        items.removeAt(index);
      }
    }
  }

  void _spawnItem() {
    final roll = _random.nextDouble();
    final kind = roll < 0.58
        ? RoadItemKind.traffic
        : roll < 0.86
        ? RoadItemKind.coin
        : RoadItemKind.passenger;
    final variant = kind == RoadItemKind.traffic ? _random.nextInt(3) : 0;
    items.add(
      RoadItem(
        lane: _random.nextInt(3),
        kind: kind,
        progress: 0,
        variant: variant,
      ),
    );
  }
}
