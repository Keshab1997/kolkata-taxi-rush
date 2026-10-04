import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'game_session.dart';

class KolkataRoadPainter extends CustomPainter {
  const KolkataRoadPainter({required this.run, required this.driving});

  final KolkataRun run;
  final bool driving;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    _KolkataScene(canvas, size, run).paint(driving: driving);
  }

  @override
  bool shouldRepaint(covariant KolkataRoadPainter oldDelegate) => true;
}

class _Point3 {
  const _Point3(this.x, this.y, this.depth);

  final double x;
  final double y;
  final double depth;
}

class _BuildingSpec {
  const _BuildingSpec({
    required this.x,
    required this.depth,
    required this.width,
    required this.height,
    required this.length,
    required this.color,
    required this.seed,
  });

  final double x;
  final double depth;
  final double width;
  final double height;
  final double length;
  final Color color;
  final int seed;
}

class _KolkataScene {
  _KolkataScene(this.canvas, this.size, this.run)
    : width = size.width,
      height = size.height,
      focal = size.height * 0.94,
      horizon = size.height * 0.30;

  static const double _cameraHeight = 3.55;
  static const double _roadHalfWidth = 1.58;
  static const double _farDepth = 122;
  static const double _nearDepth = 3.8;

  final Canvas canvas;
  final Size size;
  final KolkataRun run;
  final double width;
  final double height;
  final double focal;
  final double horizon;

  void paint({required bool driving}) {
    _drawSky();
    _drawSkyline();
    _drawCityBlocks();
    _drawHowrahBridge();
    _drawRoad();
    _drawStreetProps();
    _drawRoadItems();
    _drawPlayerTaxi(driving: driving);
    _drawVignette();
  }

  Offset _project(_Point3 point) {
    final depth = math.max(1.4, point.depth).toDouble();
    return Offset(
      width * 0.5 + point.x * focal / depth,
      horizon + focal * (_cameraHeight - point.y) / depth,
    );
  }

  double _loopDepth(
    double start, {
    double travelRate = 0.18,
    double span = 108,
  }) {
    final cycle = (start - run.distance * travelRate - 8) % span;
    return 8 + (cycle < 0 ? cycle + span : cycle);
  }

  Color _shade(Color color, double amount) {
    int channel(double value) =>
        (value * 255 * amount).round().clamp(0, 255).toInt();
    final alpha = (color.a * 255).round().clamp(0, 255).toInt();
    return Color.fromARGB(
      alpha,
      channel(color.r),
      channel(color.g),
      channel(color.b),
    );
  }

  void _drawSky() {
    final bounds = Offset.zero & size;
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFF187DAD),
            Color(0xFF58B8D4),
            Color(0xFFFFC58D),
            Color(0xFFF6D4A0),
          ],
          stops: <double>[0, 0.42, 0.77, 1],
        ).createShader(bounds),
    );

    final sun = Offset(width * 0.77, height * 0.12);
    canvas.drawCircle(
      sun,
      width * 0.085,
      Paint()..color = const Color(0xFFFFE1A2).withValues(alpha: 0.13),
    );
    canvas.drawCircle(
      sun,
      width * 0.053,
      Paint()..color = const Color(0xFFFFF1C9),
    );
    _drawCloud(Offset(width * 0.16, height * 0.13), width * 0.21);
    _drawCloud(Offset(width * 0.50, height * 0.09), width * 0.13);

    final haze = Rect.fromLTWH(
      0,
      horizon - height * 0.04,
      width,
      height * 0.12,
    );
    canvas.drawRect(
      haze,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            const Color(0xFFFFDEA9).withValues(alpha: 0),
            const Color(0xFFFFD4A1).withValues(alpha: 0.58),
            const Color(0xFFFFD4A1).withValues(alpha: 0),
          ],
        ).createShader(haze),
    );
  }

  void _drawCloud(Offset center, double cloudWidth) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.55);
    final cloudHeight = cloudWidth * 0.26;
    canvas.drawOval(
      Rect.fromCenter(center: center, width: cloudWidth, height: cloudHeight),
      paint,
    );
    canvas.drawCircle(
      center.translate(-cloudWidth * 0.19, -cloudHeight * 0.13),
      cloudHeight * 0.58,
      paint,
    );
    canvas.drawCircle(
      center.translate(cloudWidth * 0.11, -cloudHeight * 0.2),
      cloudHeight * 0.72,
      paint,
    );
  }

  void _drawSkyline() {
    final skyline = Path()..moveTo(0, horizon + height * 0.035);
    for (var index = 0; index <= 28; index++) {
      final x = width * index / 28;
      final roof = horizon - height * (0.035 + ((index * 13) % 7) * 0.012);
      skyline.lineTo(x, roof);
      skyline.lineTo(x + width * 0.014, roof);
      skyline.lineTo(x + width * 0.014, horizon + height * 0.05);
    }
    skyline
      ..lineTo(width, height * 0.42)
      ..lineTo(0, height * 0.42)
      ..close();
    canvas.drawPath(
      skyline,
      Paint()..color = const Color(0xFF53727A).withValues(alpha: 0.56),
    );
  }

  void _drawCityBlocks() {
    const palette = <Color>[
      Color(0xFFB87557),
      Color(0xFF57818A),
      Color(0xFFD0A276),
      Color(0xFF47717B),
      Color(0xFF9E6250),
      Color(0xFFC19B70),
    ];
    final blocks = <_BuildingSpec>[];

    for (var index = 0; index < 10; index++) {
      for (final side in <int>[-1, 1]) {
        final buildingWidth = 1.05 + (index % 3) * 0.32;
        final depth = _loopDepth(
          14 + index * 12.5 + (side > 0 ? 4.5 : 0),
          travelRate: 0.17,
          span: 112,
        );
        blocks.add(
          _BuildingSpec(
            x: side * (2.12 + buildingWidth * 0.47 + (index % 2) * 0.22),
            depth: depth,
            width: buildingWidth,
            height: 5.7 + ((index * 7) % 6) * 1.15,
            length: 1.7 + (index % 2) * 0.45,
            color: palette[(index + (side > 0 ? 1 : 0)) % palette.length],
            seed: index + (side > 0 ? 10 : 0),
          ),
        );
      }
    }

    blocks.sort((first, second) => second.depth.compareTo(first.depth));
    for (final block in blocks) {
      _drawBuilding(block);
    }

    // A few old civic domes add a recognisable Kolkata skyline at the horizon.
    for (final side in <int>[-1, 1]) {
      final depth = _loopDepth(52 + (side > 0 ? 16 : 0), span: 116);
      final x = side * 3.1;
      _drawBox(
        x: x,
        baseY: 0,
        depth: depth,
        boxWidth: 1.05,
        boxHeight: 7.4,
        boxLength: 1.2,
        color: const Color(0xFF73858A),
      );
      final domeCenter = _project(_Point3(x, 7.65, depth));
      final domeRadius = focal * 0.35 / depth;
      canvas.drawOval(
        Rect.fromCenter(
          center: domeCenter,
          width: domeRadius * 2.1,
          height: domeRadius * 1.25,
        ),
        Paint()..color = const Color(0xFFCFB182),
      );
      canvas.drawRect(
        Rect.fromCenter(
          center: domeCenter.translate(0, domeRadius * 0.48),
          width: domeRadius * 2.0,
          height: domeRadius * 0.75,
        ),
        Paint()..color = const Color(0xFF73858A),
      );
    }
  }

  void _drawBuilding(_BuildingSpec building) {
    _drawBox(
      x: building.x,
      baseY: 0,
      depth: building.depth,
      boxWidth: building.width,
      boxHeight: building.height,
      boxLength: building.length,
      color: building.color,
    );

    final nearDepth = building.depth - building.length / 2 - 0.008;
    final columns = building.width > 1.25 ? 3 : 2;
    final rows = (building.height / 1.35).floor().clamp(3, 7);
    final windowWidth = building.width / (columns + 1) * 0.36;
    final windowHeight = building.height / (rows + 1) * 0.34;

    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        if ((row + column + building.seed) % 5 == 0) continue;
        final centerX =
            building.x -
            building.width / 2 +
            building.width * (column + 1) / (columns + 1);
        final lowerY = building.height * (row + 0.62) / (rows + 0.25);
        final upperY = lowerY + windowHeight;
        final lit = (row * 3 + column + building.seed) % 4 == 0;
        _drawPolygon3d(<_Point3>[
          _Point3(centerX - windowWidth / 2, lowerY, nearDepth),
          _Point3(centerX + windowWidth / 2, lowerY, nearDepth),
          _Point3(centerX + windowWidth / 2, upperY, nearDepth),
          _Point3(centerX - windowWidth / 2, upperY, nearDepth),
        ], lit ? const Color(0xFFFFD487) : const Color(0xFF24414C));
      }
    }

    if (building.seed % 4 == 0) {
      _drawBox(
        x: building.x,
        baseY: 0.55,
        depth: nearDepth - 0.04,
        boxWidth: building.width * 0.92,
        boxHeight: 0.32,
        boxLength: 0.14,
        color: const Color(0xFFD16B49),
      );
    }
  }

  void _drawHowrahBridge() {
    final depth = _loopDepth(36, travelRate: 0.11, span: 110);
    const steel = Color(0xFF365B6A);
    const highlight = Color(0xFF78939A);
    const leftTower = -2.45;
    const rightTower = 2.45;

    for (final x in <double>[leftTower, rightTower]) {
      _drawBox(
        x: x,
        baseY: 0,
        depth: depth,
        boxWidth: 0.28,
        boxHeight: 5.7,
        boxLength: 0.55,
        color: steel,
      );
      _drawBox(
        x: x,
        baseY: 5.6,
        depth: depth,
        boxWidth: 0.62,
        boxHeight: 0.18,
        boxLength: 0.68,
        color: highlight,
      );
    }

    _drawLine3d(
      _Point3(leftTower, 3.15, depth),
      _Point3(rightTower, 3.15, depth),
      steel,
      0.11,
    );
    _drawLine3d(
      _Point3(leftTower, 5.0, depth),
      _Point3(rightTower, 5.0, depth),
      highlight,
      0.075,
    );

    for (var index = 0; index <= 12; index++) {
      final x = leftTower + (rightTower - leftTower) * index / 12;
      _drawLine3d(
        _Point3(x, 3.15, depth - 0.015),
        _Point3(x, 5.0, depth - 0.015),
        steel,
        0.035,
      );
      if (index < 12) {
        final nextX = leftTower + (rightTower - leftTower) * (index + 1) / 12;
        _drawLine3d(
          _Point3(x, 3.15, depth - 0.02),
          _Point3(nextX, 5.0, depth - 0.02),
          highlight,
          0.028,
        );
        _drawLine3d(
          _Point3(nextX, 3.15, depth - 0.025),
          _Point3(x, 5.0, depth - 0.025),
          steel,
          0.028,
        );
      }
    }

    final cablePath = Path();
    for (var index = 0; index <= 18; index++) {
      final t = index / 18;
      final x = leftTower + (rightTower - leftTower) * t;
      final y = 5.05 + 1.85 * 4 * t * (1 - t);
      final point = _project(_Point3(x, y, depth + 0.1));
      if (index == 0) {
        cablePath.moveTo(point.dx, point.dy);
      } else {
        cablePath.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(
      cablePath,
      Paint()
        ..color = highlight
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.2, focal * 0.012 / depth),
    );

    final signDepth = _loopDepth(21, travelRate: 0.12, span: 106);
    _drawBox(
      x: -2.02,
      baseY: 1.55,
      depth: signDepth,
      boxWidth: 1.18,
      boxHeight: 0.52,
      boxLength: 0.12,
      color: const Color(0xFF155D86),
    );
    _drawWorldLabel(
      'HOWRAH BRIDGE',
      _Point3(-2.02, 1.81, signDepth - 0.07),
      0.18,
      Colors.white,
      weight: FontWeight.w900,
    );
  }

  void _drawRoad() {
    final far = _farDepth;
    final near = _nearDepth;
    final shoulder = _roadHalfWidth + 0.58;

    _drawPolygon3d(<_Point3>[
      _Point3(-shoulder, -0.035, far),
      _Point3(-_roadHalfWidth, -0.035, far),
      _Point3(-_roadHalfWidth, -0.035, near),
      _Point3(-shoulder, -0.035, near),
    ], const Color(0xFF9E8668));
    _drawPolygon3d(<_Point3>[
      _Point3(_roadHalfWidth, -0.035, far),
      _Point3(shoulder, -0.035, far),
      _Point3(shoulder, -0.035, near),
      _Point3(_roadHalfWidth, -0.035, near),
    ], const Color(0xFF9E8668));
    _drawPolygon3d(<_Point3>[
      _Point3(-_roadHalfWidth, 0, far),
      _Point3(_roadHalfWidth, 0, far),
      _Point3(_roadHalfWidth, 0, near),
      _Point3(-_roadHalfWidth, 0, near),
    ], const Color(0xFF303A40));

    for (final side in <double>[-1, 1]) {
      _drawLine3d(
        _Point3(side * _roadHalfWidth, 0.025, far),
        _Point3(side * _roadHalfWidth, 0.025, near),
        const Color(0xFFFFC247),
        0.065,
      );
    }

    final scroll = run.roadOffset * 6.4;
    for (var index = 0; index < 22; index++) {
      var dashFar = far - index * 6.1 - scroll;
      while (dashFar < near + 2.8) {
        dashFar += far - near;
      }
      final dashNear = dashFar - 2.8;
      if (dashNear <= near) continue;

      for (final divider in <double>[-0.52, 0.52]) {
        _drawLine3d(
          _Point3(divider, 0.026, dashFar),
          _Point3(divider, 0.026, dashNear),
          Colors.white.withValues(alpha: 0.78),
          0.045,
        );
      }

      if (index % 2 == 0) {
        for (final side in <double>[-1, 1]) {
          _drawPolygon3d(<_Point3>[
            _Point3(side * (_roadHalfWidth + 0.055), 0.005, dashFar),
            _Point3(side * (_roadHalfWidth + 0.17), 0.005, dashFar),
            _Point3(side * (_roadHalfWidth + 0.17), 0.005, dashNear),
            _Point3(side * (_roadHalfWidth + 0.055), 0.005, dashNear),
          ], const Color(0xFFFFD05A));
        }
      }
    }

    // A broad zebra crossing cycles through the middle distance.
    final crossingDepth = _loopDepth(40, travelRate: 0.34, span: 106);
    for (var stripe = 0; stripe < 7; stripe++) {
      final d = crossingDepth - stripe * 0.42;
      _drawPolygon3d(<_Point3>[
        _Point3(-1.35, 0.03, d),
        _Point3(1.35, 0.03, d),
        _Point3(1.35, 0.03, d - 0.19),
        _Point3(-1.35, 0.03, d - 0.19),
      ], Colors.white.withValues(alpha: 0.78));
    }
  }

  void _drawStreetProps() {
    for (var index = 0; index < 12; index++) {
      final depth = _loopDepth(12 + index * 8.8, travelRate: 0.22, span: 104);
      for (final side in <int>[-1, 1]) {
        final x = side * (2.04 + (index % 3) * 0.12);
        if (index % 3 == 0) {
          _drawTree(x, depth, index);
        } else {
          _drawStreetLamp(x, depth, side);
        }
      }
    }
  }

  void _drawTree(double x, double depth, int seed) {
    _drawBox(
      x: x,
      baseY: 0,
      depth: depth,
      boxWidth: 0.15,
      boxHeight: 1.5,
      boxLength: 0.16,
      color: const Color(0xFF75502F),
    );
    final leaves = <Color>[
      const Color(0xFF2F814C),
      const Color(0xFF3D9954),
      const Color(0xFF66A64B),
      const Color(0xFF287044),
    ];
    for (var tier = 0; tier < 3; tier++) {
      _drawCone(
        x: x,
        baseY: 1.22 + tier * 0.62,
        depth: depth,
        radius: 0.78 - tier * 0.12,
        coneHeight: 1.3,
        color: leaves[(seed + tier) % leaves.length],
      );
    }
  }

  void _drawCone({
    required double x,
    required double baseY,
    required double depth,
    required double radius,
    required double coneHeight,
    required Color color,
  }) {
    const facets = 7;
    final peak = _Point3(x, baseY + coneHeight, depth);
    for (var facet = 0; facet < facets; facet++) {
      final firstAngle = math.pi * 2 * facet / facets;
      final secondAngle = math.pi * 2 * (facet + 1) / facets;
      final first = _Point3(
        x + math.cos(firstAngle) * radius,
        baseY,
        depth + math.sin(firstAngle) * radius * 0.32,
      );
      final second = _Point3(
        x + math.cos(secondAngle) * radius,
        baseY,
        depth + math.sin(secondAngle) * radius * 0.32,
      );
      _drawPolygon3d(<_Point3>[
        first,
        second,
        peak,
      ], _shade(color, facet.isEven ? 1.14 : 0.82));
    }
  }

  void _drawStreetLamp(double x, double depth, int side) {
    _drawBox(
      x: x,
      baseY: 0,
      depth: depth,
      boxWidth: 0.075,
      boxHeight: 4.05,
      boxLength: 0.075,
      color: const Color(0xFF243B48),
    );
    final armEnd = x - side * 0.56;
    _drawLine3d(
      _Point3(x, 3.95, depth),
      _Point3(armEnd, 4.1, depth - 0.04),
      const Color(0xFF243B48),
      0.065,
    );
    _drawBox(
      x: armEnd,
      baseY: 3.99,
      depth: depth - 0.06,
      boxWidth: 0.29,
      boxHeight: 0.13,
      boxLength: 0.22,
      color: const Color(0xFFFFD56A),
    );
    final glow = _project(_Point3(armEnd, 3.93, depth - 0.08));
    canvas.drawCircle(
      glow,
      math.max(2.0, focal * 0.11 / depth),
      Paint()..color = const Color(0xFFFFD56A).withValues(alpha: 0.34),
    );
  }

  void _drawRoadItems() {
    final items = List<RoadItem>.of(run.items)
      ..sort((first, second) {
        return _itemDepth(second.progress)
            .compareTo(_itemDepth(first.progress));
      });

    for (final item in items) {
      final depth = _itemDepth(item.progress);
      final x = (item.lane - 1) * 1.04;
      switch (item.kind) {
        case RoadItemKind.traffic:
          final colors = <Color>[
            const Color(0xFFD84F40),
            const Color(0xFF2D9C83),
            const Color(0xFF317FAD),
          ];
          _drawTraffic(
            x: x,
            depth: depth,
            color: colors[item.variant % colors.length],
            variant: item.variant,
          );
        case RoadItemKind.coin:
          _drawCoin(x, depth);
        case RoadItemKind.passenger:
          _drawPassenger(x, depth);
      }
    }
  }

  double _itemDepth(double progress) {
    final p = progress.clamp(0.0, 1.0).toDouble();
    return 6.0 + 104 * math.pow(1 - p, 2.6).toDouble();
  }

  void _drawTraffic({
    required double x,
    required double depth,
    required Color color,
    required int variant,
  }) {
    _drawVehicle(x: x, depth: depth, color: color, style: variant, taxi: false);
  }

  void _drawPlayerTaxi({required bool driving}) {
    final playerDepth = driving ? 6.45 : 6.8;
    final laneX = (run.lane - 1) * 1.04;
    _drawVehicle(
      x: laneX,
      depth: playerDepth,
      color: const Color(0xFFFFC629),
      style: 0,
      taxi: true,
    );
  }

  void _drawVehicle({
    required double x,
    required double depth,
    required Color color,
    required int style,
    required bool taxi,
  }) {
    final isAuto = !taxi && style % 3 == 1;
    final isTram = !taxi && style % 3 == 2;
    final bodyWidth = taxi
        ? 0.9
        : isAuto
        ? 0.66
        : isTram
        ? 1.08
        : 0.76;
    final bodyHeight = taxi
        ? 0.66
        : isAuto
        ? 0.58
        : isTram
        ? 1.25
        : 0.56;
    final bodyLength = taxi
        ? 1.62
        : isAuto
        ? 1.05
        : isTram
        ? 2.45
        : 1.42;
    final bodyBase = 0.16;

    _drawPolygon3d(<_Point3>[
      _Point3(x - bodyWidth * 0.72, 0.018, depth + bodyLength * 0.66),
      _Point3(x + bodyWidth * 0.72, 0.018, depth + bodyLength * 0.66),
      _Point3(x + bodyWidth * 0.72, 0.018, depth - bodyLength * 0.66),
      _Point3(x - bodyWidth * 0.72, 0.018, depth - bodyLength * 0.66),
    ], const Color(0xFF10232A).withValues(alpha: 0.28));

    if (isTram) {
      _drawWheels(x, depth, bodyWidth, bodyLength, count: 4);
      _drawBox(
        x: x,
        baseY: bodyBase,
        depth: depth,
        boxWidth: bodyWidth,
        boxHeight: bodyHeight,
        boxLength: bodyLength,
        color: color,
      );
      _drawTramWindows(x, depth, bodyWidth, bodyHeight, bodyLength);
      _drawLine3d(
        _Point3(x, bodyBase + bodyHeight + 0.12, depth - bodyLength * 0.24),
        _Point3(x, bodyBase + bodyHeight + 1.4, depth + bodyLength * 0.05),
        const Color(0xFF283E4C),
        0.035,
      );
      _drawLine3d(
        _Point3(x, bodyBase + bodyHeight + 1.4, depth + bodyLength * 0.05),
        _Point3(
          x + 0.45,
          bodyBase + bodyHeight + 1.6,
          depth + bodyLength * 0.12,
        ),
        const Color(0xFF283E4C),
        0.035,
      );
      return;
    }

    final cabinWidth = taxi
        ? 0.65
        : isAuto
        ? 0.54
        : 0.56;
    final cabinHeight = taxi
        ? 0.50
        : isAuto
        ? 0.47
        : 0.43;
    final cabinLength = taxi
        ? 0.90
        : isAuto
        ? 0.72
        : 0.78;
    final cabinBase = bodyBase + bodyHeight * 0.72;
    final cabinDepth = depth + (isAuto ? 0.02 : 0.08);

    _drawWheels(x, depth, bodyWidth, bodyLength, count: 2);
    _drawBox(
      x: x,
      baseY: bodyBase,
      depth: depth,
      boxWidth: bodyWidth,
      boxHeight: bodyHeight,
      boxLength: bodyLength,
      color: color,
    );
    _drawBox(
      x: x,
      baseY: cabinBase,
      depth: cabinDepth,
      boxWidth: cabinWidth,
      boxHeight: cabinHeight,
      boxLength: cabinLength,
      color: isAuto ? const Color(0xFF2C5347) : _shade(color, 1.12),
    );

    final windowColor = const Color(0xFF17435A);
    final cabinNear = cabinDepth - cabinLength / 2 - 0.012;
    _drawFrontWindow(
      x: x,
      depth: cabinNear,
      width: cabinWidth * 0.68,
      bottomY: cabinBase + cabinHeight * 0.36,
      topY: cabinBase + cabinHeight * 0.84,
      color: windowColor,
    );
    _drawFrontWindow(
      x: x,
      depth: cabinDepth + cabinLength / 2 + 0.012,
      width: cabinWidth * 0.55,
      bottomY: cabinBase + cabinHeight * 0.38,
      topY: cabinBase + cabinHeight * 0.82,
      color: _shade(windowColor, 0.75),
    );
    _drawSideWindows(
      x: x,
      depth: cabinDepth,
      width: cabinWidth,
      length: cabinLength,
      baseY: cabinBase,
      height: cabinHeight,
      color: windowColor,
      count: isAuto ? 1 : 2,
    );

    final bodyNear = depth - bodyLength / 2 - 0.018;
    if (taxi) {
      for (var square = 0; square < 6; square++) {
        final squareWidth = bodyWidth / 6;
        final left = x - bodyWidth / 2 + square * squareWidth;
        _drawPolygon3d(<_Point3>[
          _Point3(left, bodyBase + 0.15, bodyNear),
          _Point3(left + squareWidth, bodyBase + 0.15, bodyNear),
          _Point3(left + squareWidth, bodyBase + 0.26, bodyNear),
          _Point3(left, bodyBase + 0.26, bodyNear),
        ], square.isEven ? const Color(0xFF20272A) : const Color(0xFFFFF0CC));
      }
    }

    final tailLightWidth = bodyWidth * 0.13;
    for (final side in <double>[-1, 1]) {
      _drawPolygon3d(<_Point3>[
        _Point3(
          x + side * bodyWidth * 0.35 - tailLightWidth / 2,
          bodyBase + 0.34,
          bodyNear,
        ),
        _Point3(
          x + side * bodyWidth * 0.35 + tailLightWidth / 2,
          bodyBase + 0.34,
          bodyNear,
        ),
        _Point3(
          x + side * bodyWidth * 0.35 + tailLightWidth / 2,
          bodyBase + 0.55,
          bodyNear,
        ),
        _Point3(
          x + side * bodyWidth * 0.35 - tailLightWidth / 2,
          bodyBase + 0.55,
          bodyNear,
        ),
      ], const Color(0xFFE34235));
    }

    _drawFrontWindow(
      x: x,
      depth: bodyNear - 0.015,
      width: bodyWidth * 0.38,
      bottomY: bodyBase + 0.04,
      topY: bodyBase + 0.13,
      color: const Color(0xFFD4E2E3),
    );

    if (taxi) {
      final signDepth = cabinDepth - cabinLength * 0.04;
      _drawBox(
        x: x,
        baseY: cabinBase + cabinHeight,
        depth: signDepth,
        boxWidth: 0.38,
        boxHeight: 0.17,
        boxLength: 0.28,
        color: const Color(0xFF183344),
      );
      _drawWorldLabel(
        'TAXI',
        _Point3(x, cabinBase + cabinHeight + 0.08, signDepth - 0.15),
        0.14,
        const Color(0xFFFFD24A),
        weight: FontWeight.w900,
      );
      _drawWorldLabel(
        'WB 04',
        _Point3(x, bodyBase + 0.085, bodyNear - 0.035),
        0.11,
        const Color(0xFF18303B),
        weight: FontWeight.w900,
      );
    }
  }

  void _drawWheels(
    double x,
    double depth,
    double bodyWidth,
    double bodyLength, {
    required int count,
  }) {
    final positions = count == 4
        ? <double>[-0.34, -0.1, 0.1, 0.34]
        : <double>[-0.29, 0.29];
    for (final side in <double>[-1, 1]) {
      for (final relativeDepth in positions) {
        _drawBox(
          x: x + side * bodyWidth * 0.49,
          baseY: 0.07,
          depth: depth + relativeDepth * bodyLength,
          boxWidth: 0.11,
          boxHeight: 0.35,
          boxLength: 0.36,
          color: const Color(0xFF17232A),
        );
      }
    }
  }

  void _drawTramWindows(
    double x,
    double depth,
    double bodyWidth,
    double bodyHeight,
    double bodyLength,
  ) {
    final lowerY = 0.16 + bodyHeight * 0.48;
    final upperY = 0.16 + bodyHeight * 0.82;
    final nearDepth = depth - bodyLength / 2 - 0.014;
    _drawFrontWindow(
      x: x,
      depth: nearDepth,
      width: bodyWidth * 0.64,
      bottomY: lowerY,
      topY: upperY,
      color: const Color(0xFF173F55),
    );
    _drawSideWindows(
      x: x,
      depth: depth,
      width: bodyWidth,
      length: bodyLength,
      baseY: 0.16,
      height: bodyHeight,
      color: const Color(0xFF17435A),
      count: 5,
    );
    for (var door = 0; door < 2; door++) {
      final d = depth - bodyLength * 0.12 + door * bodyLength * 0.42;
      _drawLine3d(
        _Point3(x - bodyWidth / 2, 0.18, d),
        _Point3(x + bodyWidth / 2, 0.18, d),
        const Color(0xFFE4C989),
        0.025,
      );
    }
  }

  void _drawFrontWindow({
    required double x,
    required double depth,
    required double width,
    required double bottomY,
    required double topY,
    required Color color,
  }) {
    _drawPolygon3d(<_Point3>[
      _Point3(x - width / 2, bottomY, depth),
      _Point3(x + width / 2, bottomY, depth),
      _Point3(x + width / 2, topY, depth),
      _Point3(x - width / 2, topY, depth),
    ], color);
  }

  void _drawSideWindows({
    required double x,
    required double depth,
    required double width,
    required double length,
    required double baseY,
    required double height,
    required Color color,
    required int count,
  }) {
    for (final side in <double>[-1, 1]) {
      final sideX = x + side * (width / 2 + 0.006);
      for (var index = 0; index < count; index++) {
        final start = depth - length / 2 + length * (index + 0.18) / count;
        final end = depth - length / 2 + length * (index + 0.75) / count;
        _drawPolygon3d(<_Point3>[
          _Point3(sideX, baseY + height * 0.48, start),
          _Point3(sideX, baseY + height * 0.48, end),
          _Point3(sideX, baseY + height * 0.84, end),
          _Point3(sideX, baseY + height * 0.84, start),
        ], side < 0 ? _shade(color, 0.84) : color);
      }
    }
  }

  void _drawCoin(double x, double depth) {
    final ground = _project(_Point3(x, 0.035, depth));
    final center = _project(_Point3(x, 0.82, depth));
    final radius = math.max(5.0, focal * 0.19 / depth);
    canvas.drawOval(
      Rect.fromCenter(
        center: ground.translate(0, radius * 0.27),
        width: radius * 2.2,
        height: radius * 0.56,
      ),
      Paint()..color = const Color(0xFF06131C).withValues(alpha: 0.26),
    );
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFFFFB51F));
    canvas.drawCircle(
      center,
      radius * 0.76,
      Paint()
        ..color = const Color(0xFFFFE990)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, radius * 0.1),
    );
    _drawScreenLabel(
      '₹',
      center,
      math.max(8.0, radius * 1.05),
      const Color(0xFF7B4A06),
      weight: FontWeight.w900,
    );
  }

  void _drawPassenger(double x, double depth) {
    _drawPolygon3d(<_Point3>[
      _Point3(x - 0.22, 0.015, depth + 0.22),
      _Point3(x + 0.22, 0.015, depth + 0.22),
      _Point3(x + 0.22, 0.015, depth - 0.22),
      _Point3(x - 0.22, 0.015, depth - 0.22),
    ], const Color(0xFF11232A).withValues(alpha: 0.25));
    _drawBox(
      x: x,
      baseY: 0.52,
      depth: depth,
      boxWidth: 0.38,
      boxHeight: 0.68,
      boxLength: 0.28,
      color: const Color(0xFFFFB932),
    );
    _drawBox(
      x: x,
      baseY: 1.22,
      depth: depth - 0.02,
      boxWidth: 0.31,
      boxHeight: 0.12,
      boxLength: 0.31,
      color: const Color(0xFFB8794D),
    );
    canvas.drawCircle(
      _project(_Point3(x, 1.48, depth - 0.03)),
      math.max(2.0, focal * 0.15 / depth),
      Paint()..color = const Color(0xFFB8794D),
    );
    for (final side in <double>[-1, 1]) {
      _drawLine3d(
        _Point3(x + side * 0.09, 0.54, depth - 0.12),
        _Point3(x + side * 0.13, 0.06, depth - 0.13),
        const Color(0xFF263B50),
        0.09,
      );
    }
  }

  void _drawVignette() {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, -0.1),
          radius: 1.05,
          colors: <Color>[Colors.transparent, Color(0x4A06131D)],
          stops: <double>[0.56, 1],
        ).createShader(Offset.zero & size),
    );
  }

  void _drawBox({
    required double x,
    required double baseY,
    required double depth,
    required double boxWidth,
    required double boxHeight,
    required double boxLength,
    required Color color,
  }) {
    final left = x - boxWidth / 2;
    final right = x + boxWidth / 2;
    final bottom = baseY;
    final top = baseY + boxHeight;
    final near = depth - boxLength / 2;
    final far = depth + boxLength / 2;

    // Inner side face, rear-facing face, then the sunlit roof.
    final innerX = x >= 0 ? left : right;
    _drawPolygon3d(<_Point3>[
      _Point3(innerX, bottom, near),
      _Point3(innerX, bottom, far),
      _Point3(innerX, top, far),
      _Point3(innerX, top, near),
    ], _shade(color, 0.69));
    _drawPolygon3d(
      <_Point3>[
        _Point3(left, bottom, near),
        _Point3(right, bottom, near),
        _Point3(right, top, near),
        _Point3(left, top, near),
      ],
      _shade(color, 0.91),
      outline: color.withValues(alpha: 0.4),
    );
    _drawPolygon3d(<_Point3>[
      _Point3(left, top, near),
      _Point3(right, top, near),
      _Point3(right, top, far),
      _Point3(left, top, far),
    ], _shade(color, 1.15));
  }

  void _drawLine3d(
    _Point3 first,
    _Point3 second,
    Color color,
    double worldWidth,
  ) {
    final firstPoint = _project(first);
    final secondPoint = _project(second);
    final averageDepth = (first.depth + second.depth) / 2;
    canvas.drawLine(
      firstPoint,
      secondPoint,
      Paint()
        ..color = color
        ..strokeWidth = math.max(0.65, focal * worldWidth / averageDepth)
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawPolygon3d(List<_Point3> points, Color color, {Color? outline}) {
    if (points.length < 3) return;
    final projected = points.map(_project).toList(growable: false);
    final path = Path()..moveTo(projected.first.dx, projected.first.dy);
    for (final point in projected.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
    if (outline != null) {
      canvas.drawPath(
        path,
        Paint()
          ..color = outline
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.65,
      );
    }
  }

  void _drawWorldLabel(
    String text,
    _Point3 point,
    double worldFontSize,
    Color color, {
    FontWeight weight = FontWeight.w700,
  }) {
    final projected = _project(point);
    final fontSize = math.max(5.0, focal * worldFontSize / point.depth);
    _drawScreenLabel(text, projected, fontSize, color, weight: weight);
  }

  void _drawScreenLabel(
    String text,
    Offset center,
    double fontSize,
    Color color, {
    FontWeight weight = FontWeight.w700,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: weight,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      textAlign: TextAlign.center,
    )..layout();
    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }
}
