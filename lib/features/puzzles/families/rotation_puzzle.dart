import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/models/content/content_models.dart';
import '../../../domain/validators/puzzle_validator.dart';
import '../../../domain/validators/rotation_validator.dart';
import '../puzzle_sessions.dart';
import '../puzzle_widgets.dart';

/// `rotation` family UI: one or more dials aligned to absolute target
/// angles. Drag to turn, or use the ± buttons for accessibility. The
/// answer is checked explicitly; angles persist within the session.
class RotationPuzzle extends ConsumerStatefulWidget {
  const RotationPuzzle({super.key, required this.puzzle, required this.s});

  final PuzzleDefinition puzzle;
  final String Function(String) s;

  @override
  ConsumerState<RotationPuzzle> createState() => _RotationPuzzleState();
}

class _RotationPuzzleState extends ConsumerState<RotationPuzzle> {
  late final RotationValidator _validator;
  late final List<double> _angles;
  bool _wrong = false;
  bool _solved = false;

  @override
  void initState() {
    super.initState();
    _validator = RotationValidator.parse(
      initialState: widget.puzzle.initialState,
      solutionConfig: widget.puzzle.solutionConfig,
      validationConfig: widget.puzzle.validationConfig,
      where: 'puzzle "${widget.puzzle.id}"',
    );
    _angles = List<double>.from(_validator.startAngles);
    final stored = ref.read(puzzleSessionsProvider.notifier).inputFor(
      widget.puzzle.id,
    );
    if (stored is List<double> && stored.length == _angles.length) {
      for (var i = 0; i < stored.length; i++) {
        _angles[i] = _validator.snap(stored[i]);
      }
    }
  }

  void _syncSession() {
    ref
        .read(puzzleSessionsProvider.notifier)
        .setInput(widget.puzzle.id, List<double>.unmodifiable(_angles));
  }

  void _setAngle(int index, double degrees) {
    if (_solved) return;
    setState(() {
      _wrong = false;
      _angles[index] = _validator.snap(degrees);
    });
    _syncSession();
  }

  double get _nudgeStep {
    final d = _validator.detents;
    return d == null ? 15 : 360 / d;
  }

  Future<void> _submit() async {
    final verdict = await submitPuzzleAttempt(
      context,
      ref,
      widget.puzzle,
      List<double>.unmodifiable(_angles),
    );
    if (!mounted) return;
    if (verdict == PuzzleVerdict.correct) {
      setState(() => _solved = true);
      await finishPuzzleSolved(context);
    } else if (verdict == PuzzleVerdict.incorrect) {
      setState(() => _wrong = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.s(widget.puzzle.titleKey),
      showBackButton: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              PuzzleInstructions(
                text: widget.s(widget.puzzle.instructionsKey),
              ),
              const SizedBox(height: 24),
              for (var i = 0; i < _angles.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _DialControl(
                    index: i,
                    angle: _angles[i],
                    onAngleChanged: (a) => _setAngle(i, a),
                    nudge: _nudgeStep,
                    label: _validator.detents == null
                        ? '${_angles[i].round()}°'
                        : '${idLabel(widget.puzzle.initialState, 'dial_$i', widget.s)} · ${_angles[i].round()}°',
                  ),
                ),
              PuzzleFeedback(visible: _wrong),
              const SizedBox(height: 16),
              PuzzleActionRow(
                onCheck: _submit,
                onReset: () {
                  setState(() {
                    _wrong = false;
                    _angles
                      ..clear()
                      ..addAll(_validator.startAngles);
                  });
                  ref
                      .read(puzzleSessionsProvider.notifier)
                      .clearInput(widget.puzzle.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialControl extends StatelessWidget {
  const _DialControl({
    required this.index,
    required this.angle,
    required this.onAngleChanged,
    required this.nudge,
    required this.label,
  });

  final int index;
  final double angle;
  final ValueChanged<double> onAngleChanged;
  final double nudge;
  final String label;

  static double _angleAt(Size size, Offset local) {
    final delta = local - Offset(size.width / 2, size.height / 2);
    // 0° points up; clockwise.
    final radians = math.atan2(delta.dx, -delta.dy);
    return normalizeAngle(radians * 180 / math.pi);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Semantics(
          label: label,
          child: GestureDetector(
            onPanUpdate: (event) {
              onAngleChanged(_angleAt(const Size(180, 180), event.localPosition));
            },
            onTapUp: (event) {
              onAngleChanged(_angleAt(const Size(180, 180), event.localPosition));
            },
            child: SizedBox(
              key: ValueKey('rotation_dial_$index'),
              width: 180,
              height: 180,
              child: CustomPaint(
                painter: _DialPainter(angle: angle),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              key: ValueKey('rotation_minus_$index'),
              onPressed: () => onAngleChanged(angle - nudge),
              icon: const Icon(Icons.rotate_left),
              color: AppColors.parchmentText,
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.parchmentText,
              ),
            ),
            IconButton(
              key: ValueKey('rotation_plus_$index'),
              onPressed: () => onAngleChanged(angle + nudge),
              icon: const Icon(Icons.rotate_right),
              color: AppColors.parchmentText,
            ),
          ],
        ),
      ],
    );
  }
}

class _DialPainter extends CustomPainter {
  const _DialPainter({required this.angle});

  final double angle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 8;

    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = AppColors.brass;
    canvas.drawCircle(center, radius, rim);

    final fill = Paint()..color = AppColors.charcoal;
    canvas.drawCircle(center, radius - 2, fill);

    // Fixed pointer at the top (0°).
    final pointer = Paint()..color = AppColors.parchmentText;
    canvas.drawCircle(Offset(center.dx, center.dy - radius - 2), 5, pointer);

    // Rotating marker.
    final radians = angle * math.pi / 180;
    final markerEnd = center +
        Offset(radius * math.sin(radians), -radius * math.cos(radians));
    final marker = Paint()
      ..color = AppColors.clockRed
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, markerEnd, marker);

    final hub = Paint()..color = AppColors.brass;
    canvas.drawCircle(center, 6, hub);
  }

  @override
  bool shouldRepaint(_DialPainter oldDelegate) => oldDelegate.angle != angle;
}
