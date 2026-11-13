import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/models/content/content_models.dart';
import '../../../domain/validators/puzzle_validator.dart';
import '../../../domain/validators/tap_region_validator.dart';
import '../puzzle_sessions.dart';
import '../puzzle_widgets.dart';

/// `hidden_object` and `observation` family UI: taps on normalized
/// regions of a scene image (`initialState.imageAsset`).
///
/// - hidden_object: find the one region described by the clues.
/// - observation: tap the authored regions in sequence; a wrong tap
///   gently resets the chain without touching durable state.
class TapRegionPuzzle extends ConsumerStatefulWidget {
  const TapRegionPuzzle({
    super.key,
    required this.puzzle,
    required this.s,
    this.hintAction,
  });

  final PuzzleDefinition puzzle;
  final String Function(String) s;

  /// AppBar lightbulb action opened by [PuzzleScreen] (Phase 8).
  final Widget? hintAction;

  @override
  ConsumerState<TapRegionPuzzle> createState() => _TapRegionPuzzleState();
}

class _TapRegionPuzzleState extends ConsumerState<TapRegionPuzzle> {
  late final TapRegionValidator _validator;
  final List<String> _taps = [];
  Size? _imageSize;
  ImageStream? _imageStream;
  ImageStreamListener? _listener;
  bool _wrong = false;
  bool _solved = false;

  String get _imageAsset {
    final raw = widget.puzzle.initialState['imageAsset'];
    return raw is String && raw.isNotEmpty
        ? raw
        : 'assets/art/rooms/room_sample.png';
  }

  bool get _ordered => _validator.isOrdered;

  @override
  void initState() {
    super.initState();
    _validator = TapRegionValidator.parse(
      solutionConfig: widget.puzzle.solutionConfig,
      validationConfig: widget.puzzle.validationConfig,
      where: 'puzzle "${widget.puzzle.id}"',
      ordered: widget.puzzle.type == PuzzleType.observation,
    );
    final stored = ref.read(puzzleSessionsProvider.notifier).inputFor(
      widget.puzzle.id,
    );
    if (_ordered && stored is List<String>) {
      _taps.addAll(stored);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_imageStream == null) _resolveImageSize();
  }

  void _resolveImageSize() {
    final stream =
        AssetImage(_imageAsset).resolve(createLocalImageConfiguration(context));
    late final ImageStreamListener listener;
    listener = ImageStreamListener((info, _) {
      if (!mounted) return;
      setState(() {
        _imageSize = Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        );
      });
      stream.removeListener(listener);
    }, onError: (_, _) {
      stream.removeListener(listener);
    });
    _imageStream = stream;
    _listener = listener;
    stream.addListener(listener);
  }

  @override
  void dispose() {
    _imageStream?.removeListener(_listener!);
    super.dispose();
  }

  void _syncSession() {
    ref
        .read(puzzleSessionsProvider.notifier)
        .setInput(widget.puzzle.id, List<String>.unmodifiable(_taps));
  }

  Future<void> _handleTap(TapPoint point) async {
    if (_solved) return;
    final hit = _validator.hitRegionId(point);
    if (hit == null) return; // tap outside any candidate — no feedback

    if (_ordered) {
      setState(() {
        _wrong = false;
        _taps.add(hit);
      });
      _syncSession();
      final result = await submitPuzzleAttempt(
        context,
        ref,
        widget.puzzle,
        List<String>.unmodifiable(_taps),
      );
      if (!mounted) return;
      if (result.verdict == PuzzleVerdict.correct) {
        setState(() => _solved = true);
        await finishPuzzleSolved(
          context,
          newlyCompletedChapterIds: result.newlyCompletedChapterIds,
        );
      } else if (result.verdict == PuzzleVerdict.incorrect) {
        setState(() {
          _wrong = true;
          _taps.clear();
        });
        _syncSession();
      }
    } else {
      final result = await submitPuzzleAttempt(
        context,
        ref,
        widget.puzzle,
        TapPoint(point.x, point.y),
      );
      if (!mounted) return;
      if (result.verdict == PuzzleVerdict.correct) {
        setState(() => _solved = true);
        await finishPuzzleSolved(
          context,
          newlyCompletedChapterIds: result.newlyCompletedChapterIds,
        );
      } else {
        setState(() => _wrong = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final imageSize = _imageSize;
    return AppScaffold(
      title: widget.s(widget.puzzle.titleKey),
      showBackButton: true,
      actions: [if (widget.hintAction != null) widget.hintAction!],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PuzzleInstructions(
                text: widget.s(widget.puzzle.instructionsKey),
              ),
              const SizedBox(height: 12),
              PuzzleFeedback(visible: _wrong),
              if (_ordered)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    l10n.observationProgress(
                      _taps.length,
                      _validator.targets?.length ?? 0,
                    ),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ),
              Expanded(
                child: imageSize == null
                    ? const Center(child: CircularProgressIndicator())
                    : _scene(imageSize),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scene(Size imageSize) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final box = constraints.biggest;
        final scale = math.min(
          box.width / imageSize.width,
          box.height / imageSize.height,
        );
        final dispW = imageSize.width * scale;
        final dispH = imageSize.height * scale;
        final originX = (box.width - dispW) / 2;
        final originY = (box.height - dispH) / 2;

        return GestureDetector(
          key: const ValueKey('tap_scene'),
          behavior: HitTestBehavior.opaque,
          onTapUp: (event) {
            final local = event.localPosition;
            final nx = (local.dx - originX) / dispW;
            final ny = (local.dy - originY) / dispH;
            if (nx < 0 || nx > 1 || ny < 0 || ny > 1) return;
            _handleTap(TapPoint(nx, ny));
          },
          child: Stack(
            children: [
              Positioned(
                left: originX,
                top: originY,
                width: dispW,
                height: dispH,
                child: Image.asset(
                  _imageAsset,
                  fit: BoxFit.fill,
                  semanticLabel: widget.s(widget.puzzle.titleKey),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
