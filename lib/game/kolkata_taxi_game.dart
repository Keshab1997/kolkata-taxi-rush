import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'game_session.dart';
import 'road_painter.dart';

enum _GameMode { title, driving, paused, gameOver }

class KolkataTaxiGame extends StatefulWidget {
  const KolkataTaxiGame({super.key});

  @override
  State<KolkataTaxiGame> createState() => _KolkataTaxiGameState();
}

class _KolkataTaxiGameState extends State<KolkataTaxiGame>
    with TickerProviderStateMixin {
  final KolkataRun _run = KolkataRun();
  late final Ticker _ticker;
  Duration? _lastElapsed;
  _GameMode _mode = _GameMode.title;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  void _onTick(Duration elapsed) {
    if (_mode != _GameMode.driving || !mounted) return;
    final previous = _lastElapsed;
    _lastElapsed = elapsed;
    if (previous == null) return;

    _run.update(
      (elapsed - previous).inMicroseconds / Duration.microsecondsPerSecond,
    );
    if (_run.crashed) {
      _ticker.stop();
      _lastElapsed = null;
      setState(() => _mode = _GameMode.gameOver);
      return;
    }
    setState(() {});
  }

  void _startRide() {
    _ticker.stop();
    _run.reset();
    _lastElapsed = null;
    setState(() => _mode = _GameMode.driving);
    _ticker.start();
  }

  void _pauseRide() {
    _ticker.stop();
    _lastElapsed = null;
    setState(() => _mode = _GameMode.paused);
  }

  void _resumeRide() {
    _lastElapsed = null;
    setState(() => _mode = _GameMode.driving);
    _ticker.start();
  }

  void _returnToTitle() {
    _ticker.stop();
    _lastElapsed = null;
    _run.reset();
    setState(() => _mode = _GameMode.title);
  }

  void _changeLane(int direction) {
    if (_mode != _GameMode.driving) return;
    setState(() {
      if (direction < 0) {
        _run.moveLeft();
      } else {
        _run.moveRight();
      }
    });
  }

  void _onSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < 120) return;
    _changeLane(velocity < 0 ? -1 : 1);
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (_mode == _GameMode.title &&
        event.logicalKey == LogicalKeyboardKey.enter) {
      _startRide();
      return KeyEventResult.handled;
    }
    if (_mode != _GameMode.driving) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.keyA) {
      _changeLane(-1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
        event.logicalKey == LogicalKeyboardKey.keyD) {
      _changeLane(1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _pauseRide();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF081824),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : 780.0;
            final availableWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : 430.0;
            final gameWidth = math.min(
              520.0,
              math.min(availableWidth, availableHeight * 0.64),
            );

            return Center(
              child: SizedBox(
                width: gameWidth,
                height: availableHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Focus(
                    autofocus: true,
                    onKeyEvent: _onKeyEvent,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        CustomPaint(
                          painter: KolkataRoadPainter(
                            run: _run,
                            driving: _mode == _GameMode.driving,
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onHorizontalDragEnd: _onSwipe,
                          child: const SizedBox.expand(),
                        ),
                        if (_mode == _GameMode.title) _buildTitleOverlay(),
                        if (_mode == _GameMode.driving) _buildHud(),
                        if (_mode == _GameMode.paused) _buildPauseOverlay(),
                        if (_mode == _GameMode.gameOver)
                          _buildGameOverOverlay(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTitleOverlay() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC52E),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x44000000),
                      blurRadius: 14,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_taxi_rounded,
                  color: Color(0xFF172A38),
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'KOLKATA',
                      style: TextStyle(
                        color: Color(0xFFFFD353),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.1,
                      ),
                    ),
                    Text(
                      'TAXI RUSH',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              _badge('PLAYABLE DEMO'),
            ],
          ),
          const SizedBox(height: 42),
          const Text(
            'THE CITY OF JOY,\nAT FULL SPEED.',
            style: TextStyle(
              color: Color(0xFFFFF6D9),
              fontSize: 13,
              fontWeight: FontWeight.w800,
              height: 1.25,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'KOLKATA',
            style: TextStyle(
              color: Color(0xFFFFCB35),
              fontSize: 43,
              height: 0.96,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.8,
              shadows: <Shadow>[
                Shadow(
                  color: Color(0xAA713E09),
                  offset: Offset(2, 4),
                  blurRadius: 1,
                ),
              ],
            ),
          ),
          const Text(
            'TAXI RUSH',
            style: TextStyle(
              color: Colors.white,
              fontSize: 35,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
              shadows: <Shadow>[
                Shadow(
                  color: Color(0xAA173143),
                  offset: Offset(2, 4),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Pick up fares. Dodge traffic. Own the streets.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              shadows: const <Shadow>[
                Shadow(color: Color(0x77213B4B), blurRadius: 5),
              ],
            ),
          ),
          const Spacer(),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _featureChip(Icons.alt_route_rounded, '3 lanes'),
              _featureChip(Icons.person_pin_circle_rounded, 'Pick up fares'),
              _featureChip(Icons.savings_rounded, 'Collect coins'),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: FilledButton.icon(
              onPressed: _startRide,
              icon: const Icon(Icons.play_arrow_rounded, size: 25),
              label: const Text('START YOUR RIDE'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFC52E),
                foregroundColor: const Color(0xFF1A2A35),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 8,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'SWIPE OR USE THE ARROW KEYS TO STEER',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.84),
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.05,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHud() {
    return Stack(
      children: <Widget>[
        Positioned(
          top: 12,
          left: 14,
          right: 14,
          child: Row(
            children: <Widget>[
              _statChip(
                Icons.monetization_on_rounded,
                'COINS',
                '${_run.coins}',
                const Color(0xFFFFD14A),
              ),
              const SizedBox(width: 8),
              _statChip(
                Icons.route_rounded,
                'DISTANCE',
                '${_run.distanceMeters} m',
                Colors.white,
              ),
              const Spacer(),
              Material(
                color: const Color(0xD90C1C2A),
                borderRadius: BorderRadius.circular(16),
                child: IconButton(
                  tooltip: 'Pause ride',
                  onPressed: _pauseRide,
                  icon: const Icon(Icons.pause_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 76,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xD90C1C2A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.person_pin_circle_rounded,
                  size: 18,
                  color: Color(0xFFFFD14A),
                ),
                const SizedBox(width: 6),
                Text(
                  'PASSENGERS  ${_run.passengers}/3',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 18,
          left: 18,
          right: 18,
          child: Row(
            children: <Widget>[
              _steerButton(Icons.arrow_left_rounded, 'Move left', -1),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xD90C1C2A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '${_run.speedKmh}',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const Text(
                      'KM/H',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _steerButton(Icons.arrow_right_rounded, 'Move right', 1),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPauseOverlay() {
    return _modalOverlay(
      eyebrow: 'RIDE PAUSED',
      title: 'Take a breather.',
      subtitle: 'Your taxi is waiting right here.',
      primaryLabel: 'RESUME RIDE',
      primaryIcon: Icons.play_arrow_rounded,
      onPrimary: _resumeRide,
      secondaryLabel: 'RESTART RIDE',
      onSecondary: _startRide,
    );
  }

  Widget _buildGameOverOverlay() {
    return _modalOverlay(
      eyebrow: 'TRAFFIC JAM!',
      title: '${_run.distanceMeters} m',
      subtitle: 'Coins  ${_run.coins}     Passengers  ${_run.passengers}',
      primaryLabel: 'DRIVE AGAIN',
      primaryIcon: Icons.replay_rounded,
      onPrimary: _startRide,
      secondaryLabel: 'BACK TO TITLE',
      onSecondary: _returnToTitle,
    );
  }

  Widget _modalOverlay({
    required String eyebrow,
    required String title,
    required String subtitle,
    required String primaryLabel,
    required IconData primaryIcon,
    required VoidCallback onPrimary,
    required String secondaryLabel,
    required VoidCallback onSecondary,
  }) {
    return ColoredBox(
      color: const Color(0xB8081721),
      child: Center(
        child: Container(
          width: 330,
          margin: const EdgeInsets.all(22),
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
          decoration: BoxDecoration(
            color: const Color(0xFF102637),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 30,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                eyebrow,
                style: const TextStyle(
                  color: Color(0xFFFFCF48),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: onPrimary,
                  icon: Icon(primaryIcon),
                  label: Text(primaryLabel),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC52E),
                    foregroundColor: const Color(0xFF1A2A35),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              TextButton(onPressed: onSecondary, child: Text(secondaryLabel)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String label, String value, Color accent) {
    return Container(
      constraints: const BoxConstraints(minWidth: 82),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xD90C1C2A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 17, color: accent),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                style: const TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _steerButton(IconData icon, String label, int direction) {
    return Material(
      color: const Color(0xE6102432),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => _changeLane(direction),
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 66,
          height: 58,
          child: Tooltip(
            message: label,
            child: Icon(icon, size: 37, color: const Color(0xFFFFD14A)),
          ),
        ),
      ),
    );
  }

  Widget _featureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xB8122C3B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 15, color: const Color(0xFFFFD14A)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _badge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xAA0D2938),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
