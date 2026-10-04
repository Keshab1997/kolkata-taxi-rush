import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'game_session.dart';

class KolkataRoadPainter extends CustomPainter {
  const KolkataRoadPainter({required this.run, required this.driving});

  final KolkataRun run;
  final bool driving;

  static const _roadTop = Color(0xFF526473);
  static const _roadBottom = Color(0xFF172530);
  static const _taxiYellow = Color(0xFFFFC52E);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final width = size.width;
    final height = size.height;
    final bounds = Offset.zero & size;

    canvas.drawRect(
      bounds,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFF69C8F4),
            Color(0xFFB9E8F5),
            Color(0xFFFFD69A),
          ],
          stops: <double>[0, 0.46, 1],
        ).createShader(bounds),
    );

    _drawSunAndClouds(canvas, width, height);
    _drawSkyline(canvas, width, height);
    _drawHowrahBridge(canvas, width, height);
    _drawRoad(canvas, width, height);
    _drawRoadside(canvas, width, height);
    _drawRoadItems(canvas, width, height);

    final taxiProgress = driving ? 0.91 : 0.79;
    final taxiY = driving ? height * 0.925 : height * 0.815;
    final taxiWidth = width * (driving ? 0.265 : 0.285);
    _drawCar(
      canvas,
      centerX: _laneCenter(width, taxiProgress, run.lane),
      bottomY: taxiY,
      carWidth: taxiWidth,
      color: _taxiYellow,
      isTaxi: true,
      showTaxiSign: true,
    );

    _drawVignette(canvas, size);
  }

  void _drawSunAndClouds(Canvas canvas, double width, double height) {
    final sunCenter = Offset(width * 0.79, height * 0.105);
    canvas.drawCircle(
      sunCenter,
      width * 0.055,
      Paint()..color = const Color(0xFFFFF0B5).withValues(alpha: 0.84),
    );
    canvas.drawCircle(
      sunCenter,
      width * 0.075,
      Paint()..color = const Color(0xFFFFF0B5).withValues(alpha: 0.18),
    );

    _drawCloud(canvas, Offset(width * 0.18, height * 0.105), width * 0.15);
    _drawCloud(canvas, Offset(width * 0.57, height * 0.075), width * 0.105);
  }

  void _drawCloud(Canvas canvas, Offset center, double cloudWidth) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.58);
    final cloudHeight = cloudWidth * 0.32;
    canvas.drawOval(
      Rect.fromCenter(center: center, width: cloudWidth, height: cloudHeight),
      paint,
    );
    canvas.drawCircle(
      center.translate(-cloudWidth * 0.18, -cloudHeight * 0.12),
      cloudHeight * 0.55,
      paint,
    );
    canvas.drawCircle(
      center.translate(cloudWidth * 0.1, -cloudHeight * 0.25),
      cloudHeight * 0.75,
      paint,
    );
  }

  void _drawSkyline(Canvas canvas, double width, double height) {
    final colors = <Color>[
      const Color(0xFF496F7E),
      const Color(0xFF3F6876),
      const Color(0xFF567B80),
      const Color(0xFF355C6C),
    ];
    for (var index = 0; index < 22; index++) {
      final buildingWidth = width * (0.035 + (index % 3) * 0.008);
      final x = width * index / 21 - buildingWidth * 0.35;
      final buildingHeight = height * (0.075 + ((index * 7) % 5) * 0.014);
      final top = height * (0.215 - ((index * 3) % 4) * 0.009);
      final rect = Rect.fromLTWH(x, top, buildingWidth, buildingHeight);
      final color = colors[index % colors.length];

      canvas.drawRect(rect, Paint()..color = color.withValues(alpha: 0.76));
      canvas.drawRect(
        Rect.fromLTWH(x, top, buildingWidth, height * 0.009),
        Paint()..color = const Color(0xFF284E5C).withValues(alpha: 0.65),
      );

      final windowPaint = Paint()
        ..color = const Color(0xFFFFE9AD).withValues(alpha: 0.48);
      final windowSize = width * 0.004;
      for (var row = 0; row < 3; row++) {
        for (var column = 0; column < 2; column++) {
          canvas.drawRect(
            Rect.fromLTWH(
              x + buildingWidth * (0.25 + column * 0.38),
              top + height * (0.015 + row * 0.017),
              windowSize,
              windowSize * 1.5,
            ),
            windowPaint,
          );
        }
      }
    }

    // A small domed silhouette nods to Kolkata's old civic architecture.
    final domePaint = Paint()
      ..color = const Color(0xFF536E78).withValues(alpha: 0.82);
    final domeX = width * 0.88;
    final domeY = height * 0.235;
    canvas.drawRect(
      Rect.fromLTWH(domeX - width * 0.055, domeY, width * 0.11, height * 0.075),
      domePaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(
        domeX - width * 0.035,
        domeY - height * 0.04,
        width * 0.07,
        height * 0.08,
      ),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = domePaint.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width * 0.009,
    );
    canvas.drawLine(
      Offset(domeX, domeY - height * 0.04),
      Offset(domeX, domeY - height * 0.065),
      Paint()
        ..color = domePaint.color
        ..strokeWidth = width * 0.006,
    );
  }

  void _drawHowrahBridge(Canvas canvas, double width, double height) {
    final bridgeColor = const Color(0xFF213F50).withValues(alpha: 0.78);
    final bridgePaint = Paint()
      ..color = bridgeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 0.012
      ..strokeCap = StrokeCap.round;
    final deckY = height * 0.286;

    canvas.drawLine(
      Offset(width * 0.015, deckY),
      Offset(width * 0.985, deckY),
      bridgePaint,
    );
    canvas.drawLine(
      Offset(width * 0.11, height * 0.21),
      Offset(width * 0.89, height * 0.21),
      bridgePaint..strokeWidth = width * 0.007,
    );

    final arch = Path()
      ..moveTo(width * 0.13, deckY)
      ..quadraticBezierTo(width * 0.5, height * 0.06, width * 0.87, deckY);
    canvas.drawPath(arch, bridgePaint..strokeWidth = width * 0.01);

    for (var index = 0; index <= 12; index++) {
      final x = width * (0.14 + index * 0.06);
      final t = (x / width - 0.13) / 0.74;
      final archY = height * (0.286 - 0.225 * 4 * t * (1 - t));
      canvas.drawLine(
        Offset(x, archY),
        Offset(x, deckY),
        bridgePaint..strokeWidth = width * 0.004,
      );
    }

    for (final x in <double>[width * 0.28, width * 0.72]) {
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(x, height * 0.235),
          width: width * 0.025,
          height: height * 0.105,
        ),
        Paint()..color = bridgeColor,
      );
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(x, height * 0.185),
          width: width * 0.06,
          height: height * 0.012,
        ),
        Paint()..color = bridgeColor,
      );
    }
  }

  void _drawRoad(Canvas canvas, double width, double height) {
    final center = width / 2;
    final topY = height * 0.287;
    final bottomY = height * 1.04;
    final topHalf = width * 0.145;
    final bottomHalf = width * 0.79;

    final leftPavement = Path()
      ..moveTo(0, topY)
      ..lineTo(center - topHalf, topY)
      ..lineTo(center - bottomHalf, bottomY)
      ..lineTo(0, bottomY)
      ..close();
    final rightPavement = Path()
      ..moveTo(width, topY)
      ..lineTo(center + topHalf, topY)
      ..lineTo(center + bottomHalf, bottomY)
      ..lineTo(width, bottomY)
      ..close();
    canvas.drawPath(leftPavement, Paint()..color = const Color(0xFFB7A17A));
    canvas.drawPath(rightPavement, Paint()..color = const Color(0xFFB7A17A));

    final road = Path()
      ..moveTo(center - topHalf, topY)
      ..lineTo(center + topHalf, topY)
      ..lineTo(center + bottomHalf, bottomY)
      ..lineTo(center - bottomHalf, bottomY)
      ..close();
    final roadBounds = Rect.fromLTWH(0, topY, width, height - topY);
    canvas.drawPath(
      road,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[_roadTop, Color(0xFF344552), _roadBottom],
        ).createShader(roadBounds),
    );

    _drawRoadEdges(canvas, width, height, topY, bottomY, topHalf, bottomHalf);
    _drawLaneDashes(canvas, width, height, topY, bottomY, topHalf, bottomHalf);

    // Tiny road sign at the left shoulder.
    final sign = Rect.fromLTWH(
      width * 0.045,
      height * 0.305,
      width * 0.19,
      height * 0.055,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(sign, Radius.circular(width * 0.012)),
      Paint()..color = const Color(0xFF155A85),
    );
    _drawLabel(
      canvas,
      'HOWRAH',
      Offset(sign.center.dx, sign.center.dy),
      width * 0.022,
      Colors.white,
      weight: FontWeight.w800,
    );
  }

  void _drawRoadEdges(
    Canvas canvas,
    double width,
    double height,
    double topY,
    double bottomY,
    double topHalf,
    double bottomHalf,
  ) {
    final center = width / 2;
    final edgePaint = Paint()
      ..color = const Color(0xFFFFD15C)
      ..strokeWidth = width * 0.014
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(center - topHalf, topY),
      Offset(center - bottomHalf, bottomY),
      edgePaint,
    );
    canvas.drawLine(
      Offset(center + topHalf, topY),
      Offset(center + bottomHalf, bottomY),
      edgePaint,
    );

    for (var index = 0; index < 12; index++) {
      final progress = (index / 12 + run.roadOffset * 0.72) % 1;
      final projected = math.pow(progress, 1.45).toDouble();
      final y = topY + (bottomY - topY) * projected;
      final half = topHalf + (bottomHalf - topHalf) * projected;
      final block = width * (0.012 + progress * 0.019);
      final color = index.isEven
          ? const Color(0xFFFFD351)
          : const Color(0xFF253744);
      for (final side in <double>[-1, 1]) {
        final x = center + side * (half + block * 0.55);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(x, y),
              width: block,
              height: block * 1.3,
            ),
            Radius.circular(block * 0.12),
          ),
          Paint()..color = color,
        );
      }
    }
  }

  void _drawLaneDashes(
    Canvas canvas,
    double width,
    double height,
    double topY,
    double bottomY,
    double topHalf,
    double bottomHalf,
  ) {
    final center = width / 2;
    for (final divider in <double>[-1, 1]) {
      for (var index = 0; index < 14; index++) {
        final progress = (index / 14 + run.roadOffset) % 1;
        final endProgress = math.min(1.0, progress + 0.018 + progress * 0.035);
        final t1 = math.pow(progress, 1.45).toDouble();
        final t2 = math.pow(endProgress, 1.45).toDouble();
        final half1 = topHalf + (bottomHalf - topHalf) * t1;
        final half2 = topHalf + (bottomHalf - topHalf) * t2;
        final x1 = center + divider * half1 / 3;
        final x2 = center + divider * half2 / 3;
        final y1 = topY + (bottomY - topY) * t1;
        final y2 = topY + (bottomY - topY) * t2;
        canvas.drawLine(
          Offset(x1, y1),
          Offset(x2, y2),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.78)
            ..strokeWidth = width * (0.003 + progress * 0.006)
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }

  void _drawRoadside(Canvas canvas, double width, double height) {
    final topY = height * 0.287;
    final bottomY = height * 1.04;
    final topHalf = width * 0.145;
    final bottomHalf = width * 0.79;
    final center = width / 2;

    for (var index = 0; index < 9; index++) {
      final progress = (index / 9 + run.roadOffset * 0.54) % 1;
      final projected = math.pow(progress, 1.48).toDouble();
      final y = topY + (bottomY - topY) * projected;
      final half = topHalf + (bottomHalf - topHalf) * projected;
      final scale = 0.26 + progress * 1.0;

      for (final side in <double>[-1, 1]) {
        final x = center + side * (half + width * (0.035 + progress * 0.018));
        if (x < -width * 0.12 || x > width * 1.12) continue;
        if (index.isEven) {
          _drawTree(canvas, Offset(x, y), width * 0.072 * scale);
        } else {
          _drawStreetLamp(canvas, Offset(x, y), width * 0.11 * scale);
        }
      }
    }
  }

  void _drawTree(Canvas canvas, Offset base, double size) {
    final trunkWidth = size * 0.14;
    final trunkHeight = size * 0.72;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          base.dx - trunkWidth / 2,
          base.dy - trunkHeight,
          trunkWidth,
          trunkHeight,
        ),
        Radius.circular(trunkWidth * 0.3),
      ),
      Paint()..color = const Color(0xFF72512F),
    );
    for (var index = 0; index < 4; index++) {
      final center = Offset(
        base.dx + (index % 2 == 0 ? -1 : 1) * size * 0.16,
        base.dy - trunkHeight - size * (0.28 + (index ~/ 2) * 0.22),
      );
      canvas.drawCircle(
        center,
        size * (0.31 + (index % 2) * 0.025),
        Paint()
          ..color = <Color>[
            const Color(0xFF25784C),
            const Color(0xFF368F50),
            const Color(0xFF68A947),
            const Color(0xFF2C7047),
          ][index],
      );
    }
  }

  void _drawStreetLamp(Canvas canvas, Offset base, double height) {
    final polePaint = Paint()
      ..color = const Color(0xFF243A43)
      ..strokeWidth = height * 0.055
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(base, base.translate(0, -height), polePaint);
    canvas.drawLine(
      base.translate(0, -height),
      base.translate(height * 0.27, -height * 1.08),
      polePaint,
    );
    canvas.drawCircle(
      base.translate(height * 0.27, -height * 1.08),
      height * 0.105,
      Paint()..color = const Color(0xFFFFE797),
    );
  }

  void _drawRoadItems(Canvas canvas, double width, double height) {
    final orderedItems = List<RoadItem>.of(run.items)
      ..sort((first, second) => first.progress.compareTo(second.progress));

    for (final item in orderedItems) {
      final progress = item.progress.clamp(0.0, 1.0).toDouble();
      final projected = math.pow(progress, 1.45).toDouble();
      final y = height * 0.287 + height * 0.75 * projected;
      final x = _laneCenter(width, progress, item.lane);

      switch (item.kind) {
        case RoadItemKind.traffic:
          final carWidth = width * (0.048 + progress * 0.077);
          final trafficColors = <Color>[
            const Color(0xFFD95642),
            const Color(0xFF2F82A6),
            const Color(0xFF328267),
          ];
          _drawCar(
            canvas,
            centerX: x,
            bottomY: y,
            carWidth: carWidth,
            color: trafficColors[item.lane],
            isTaxi: false,
            showTaxiSign: false,
          );
        case RoadItemKind.coin:
          _drawCoin(
            canvas,
            Offset(x, y - width * progress * 0.025),
            width * (0.014 + progress * 0.018),
          );
        case RoadItemKind.passenger:
          _drawPassenger(
            canvas,
            Offset(x, y),
            width * (0.045 + progress * 0.045),
          );
      }
    }
  }

  double _laneCenter(double width, double progress, int lane) {
    final center = width / 2;
    final projected = math.pow(progress.clamp(0.0, 1.0), 1.45).toDouble();
    final halfRoad = width * (0.145 + (0.79 - 0.145) * projected);
    return center + (lane - 1) * halfRoad * (2 / 3);
  }

  void _drawCoin(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(
      center.translate(0, radius * 0.25),
      radius * 1.3,
      Paint()..color = const Color(0xFF291D0A).withValues(alpha: 0.22),
    );
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFFFFB91F));
    canvas.drawCircle(
      center,
      radius * 0.76,
      Paint()
        ..color = const Color(0xFFFFE582)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, radius * 0.12),
    );
    _drawLabel(
      canvas,
      '₹',
      center,
      math.max(7.0, radius * 1.15),
      const Color(0xFF7A4D0B),
      weight: FontWeight.w900,
    );
  }

  void _drawPassenger(Canvas canvas, Offset base, double scale) {
    final headRadius = scale * 0.19;
    canvas.drawCircle(
      base.translate(0, -scale * 1.04),
      headRadius,
      Paint()..color = const Color(0xFFB8794D),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          base.dx - scale * 0.22,
          base.dy - scale * 0.86,
          scale * 0.44,
          scale * 0.54,
        ),
        Radius.circular(scale * 0.12),
      ),
      Paint()..color = const Color(0xFFFFB932),
    );
    final limbPaint = Paint()
      ..color = const Color(0xFF263B50)
      ..strokeWidth = math.max(1.4, scale * 0.105)
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      base.translate(-scale * 0.1, -scale * 0.35),
      base.translate(-scale * 0.16, 0),
      limbPaint,
    );
    canvas.drawLine(
      base.translate(scale * 0.1, -scale * 0.35),
      base.translate(scale * 0.16, 0),
      limbPaint,
    );
    canvas.drawLine(
      base.translate(-scale * 0.18, -scale * 0.72),
      base.translate(-scale * 0.34, -scale * 0.45),
      limbPaint,
    );
    canvas.drawLine(
      base.translate(scale * 0.18, -scale * 0.72),
      base.translate(scale * 0.32, -scale * 0.5),
      limbPaint,
    );
  }

  void _drawCar(
    Canvas canvas, {
    required double centerX,
    required double bottomY,
    required double carWidth,
    required Color color,
    required bool isTaxi,
    required bool showTaxiSign,
  }) {
    final carHeight = carWidth * 1.46;
    final left = centerX - carWidth / 2;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, bottomY - carHeight * 0.035),
        width: carWidth * 1.14,
        height: carHeight * 0.16,
      ),
      Paint()..color = const Color(0xFF09141A).withValues(alpha: 0.34),
    );

    final wheelPaint = Paint()..color = const Color(0xFF18232A);
    for (final side in <double>[-1, 1]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            centerX + side * carWidth * 0.39 - carWidth * 0.055,
            bottomY - carHeight * 0.39,
            carWidth * 0.11,
            carHeight * 0.29,
          ),
          Radius.circular(carWidth * 0.04),
        ),
        wheelPaint,
      );
    }

    final body = Path()
      ..moveTo(left + carWidth * 0.12, bottomY - carHeight * 0.1)
      ..lineTo(left + carWidth * 0.07, bottomY - carHeight * 0.47)
      ..quadraticBezierTo(
        left + carWidth * 0.08,
        bottomY - carHeight * 0.59,
        left + carWidth * 0.2,
        bottomY - carHeight * 0.62,
      )
      ..lineTo(left + carWidth * 0.27, bottomY - carHeight * 0.9)
      ..quadraticBezierTo(
        centerX,
        bottomY - carHeight * 1.02,
        left + carWidth * 0.73,
        bottomY - carHeight * 0.9,
      )
      ..lineTo(left + carWidth * 0.8, bottomY - carHeight * 0.62)
      ..quadraticBezierTo(
        left + carWidth * 0.92,
        bottomY - carHeight * 0.59,
        left + carWidth * 0.93,
        bottomY - carHeight * 0.47,
      )
      ..lineTo(left + carWidth * 0.88, bottomY - carHeight * 0.1)
      ..quadraticBezierTo(
        centerX,
        bottomY - carHeight * 0.02,
        left + carWidth * 0.12,
        bottomY - carHeight * 0.1,
      )
      ..close();
    canvas.drawPath(body, Paint()..color = color);
    canvas.drawPath(
      body,
      Paint()
        ..color = const Color(0xFF744A18).withValues(alpha: 0.42)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, carWidth * 0.018),
    );

    final rearWindow = Path()
      ..moveTo(left + carWidth * 0.25, bottomY - carHeight * 0.63)
      ..lineTo(left + carWidth * 0.31, bottomY - carHeight * 0.86)
      ..quadraticBezierTo(
        centerX,
        bottomY - carHeight * 0.93,
        left + carWidth * 0.69,
        bottomY - carHeight * 0.86,
      )
      ..lineTo(left + carWidth * 0.75, bottomY - carHeight * 0.63)
      ..close();
    canvas.drawPath(rearWindow, Paint()..color = const Color(0xFF244659));
    canvas.drawLine(
      Offset(centerX, bottomY - carHeight * 0.9),
      Offset(centerX, bottomY - carHeight * 0.64),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.24)
        ..strokeWidth = math.max(1.0, carWidth * 0.014),
    );
    canvas.drawLine(
      Offset(left + carWidth * 0.26, bottomY - carHeight * 0.59),
      Offset(left + carWidth * 0.74, bottomY - carHeight * 0.59),
      Paint()
        ..color = const Color(0xFFFFE47B).withValues(alpha: 0.75)
        ..strokeWidth = math.max(1.0, carWidth * 0.022),
    );

    for (final side in <double>[-1, 1]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            centerX + side * carWidth * 0.31 - carWidth * 0.055,
            bottomY - carHeight * 0.49,
            carWidth * 0.11,
            carHeight * 0.1,
          ),
          Radius.circular(carWidth * 0.025),
        ),
        Paint()..color = const Color(0xFFD6382F),
      );
    }

    if (isTaxi) {
      final stripeY = bottomY - carHeight * 0.31;
      for (var index = 0; index < 6; index++) {
        final stripeColor = index.isEven
            ? const Color(0xFF242527)
            : const Color(0xFFFFF1CC);
        canvas.drawRect(
          Rect.fromLTWH(
            left + carWidth * (0.2 + index * 0.1),
            stripeY,
            carWidth * 0.1,
            carHeight * 0.075,
          ),
          Paint()..color = stripeColor,
        );
      }
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          left + carWidth * 0.3,
          bottomY - carHeight * 0.22,
          carWidth * 0.4,
          carHeight * 0.105,
        ),
        Radius.circular(carWidth * 0.025),
      ),
      Paint()..color = const Color(0xFFCAD5D7),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          left + carWidth * 0.4,
          bottomY - carHeight * 0.205,
          carWidth * 0.2,
          carHeight * 0.065,
        ),
        Radius.circular(carWidth * 0.012),
      ),
      Paint()..color = const Color(0xFF293A43),
    );

    if (showTaxiSign) {
      final sign = Rect.fromLTWH(
        centerX - carWidth * 0.16,
        bottomY - carHeight * 1.02,
        carWidth * 0.32,
        carHeight * 0.09,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(sign, Radius.circular(carWidth * 0.025)),
        Paint()..color = const Color(0xFF172A37),
      );
      _drawLabel(
        canvas,
        'TAXI',
        sign.center,
        math.max(6.0, carWidth * 0.075),
        const Color(0xFFFFD249),
        weight: FontWeight.w900,
      );
    }
  }

  void _drawLabel(
    Canvas canvas,
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

  void _drawVignette(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment.center,
          radius: 0.92,
          colors: <Color>[Colors.transparent, Color(0x33051A28)],
          stops: <double>[0.55, 1],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant KolkataRoadPainter oldDelegate) => true;
}
