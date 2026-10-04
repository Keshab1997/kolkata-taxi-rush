import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kolkata_taxi_rush/game/game_session.dart';

void main() {
  group('KolkataRun', () {
    test('starts in the centre lane and clamps steering to three lanes', () {
      final run = KolkataRun(random: Random(1));

      expect(run.lane, 1);
      run.moveLeft();
      run.moveLeft();
      expect(run.lane, 0);
      run.moveRight();
      run.moveRight();
      run.moveRight();
      expect(run.lane, 2);
    });

    test('collects a coin and a passenger in the current lane', () {
      final run = KolkataRun(random: Random(2));
      run.items
        ..add(RoadItem(lane: 1, kind: RoadItemKind.coin, progress: 0.835))
        ..add(RoadItem(lane: 1, kind: RoadItemKind.passenger, progress: 0.835));

      run.update(0.02);

      expect(run.coins, 1);
      expect(run.passengers, 1);
      expect(run.items, isEmpty);
      expect(run.crashed, isFalse);
    });

    test(
      'traffic in another lane is safe, but same-lane traffic ends the run',
      () {
        final run = KolkataRun(random: Random(3));
        run.items.add(
          RoadItem(lane: 0, kind: RoadItemKind.traffic, progress: 0.835),
        );
        run.update(0.02);
        expect(run.crashed, isFalse);

        run.items.add(
          RoadItem(lane: 1, kind: RoadItemKind.traffic, progress: 0.835),
        );
        run.update(0.02);
        expect(run.crashed, isTrue);
      },
    );

    test('reset restores a fresh ride', () {
      final run = KolkataRun(random: Random(4));
      run.moveLeft();
      run.coins = 8;
      run.passengers = 2;
      run.distance = 120;
      run.crashed = true;
      run.items.add(RoadItem(lane: 1, kind: RoadItemKind.coin));

      run.reset();

      expect(run.lane, 1);
      expect(run.coins, 0);
      expect(run.passengers, 0);
      expect(run.distanceMeters, 0);
      expect(run.crashed, isFalse);
      expect(run.items, isEmpty);
    });
  });
}
