import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../domain/models/content/hotspot_definition.dart';

/// A hotspot resolved for display: definition + localized label.
class RoomHotspotView {
  const RoomHotspotView({required this.definition, required this.label});

  final HotspotDefinition definition;
  final String label;
}

/// Renders a room background with normalized-coordinate hotspots overlaid.
///
/// The background is letterboxed (`BoxFit.contain`-equivalent) inside the
/// available space; hotspot bounds are fractions of the *image*, so they
/// stay aligned at any aspect ratio. Each hotspot gets a forgiving touch
/// target (>= [_kMinTouchTarget] logical px) centered on its bounds.
class RoomScene extends StatefulWidget {
  const RoomScene({
    super.key,
    required this.backgroundAsset,
    required this.sceneLabel,
    required this.hotspots,
    required this.onHotspotTap,
    this.showLabels = false,
  });

  final String backgroundAsset;
  final String sceneLabel;
  final List<RoomHotspotView> hotspots;
  final ValueChanged<RoomHotspotView> onHotspotTap;

  /// Optional reading aid: localised object names over each hotspot. It
  /// names the object only — never the clue value or the solution.
  final bool showLabels;

  /// Minimum touch-target edge in logical pixels.
  static const double minTouchTarget = 56;

  @override
  State<RoomScene> createState() => _RoomSceneState();
}

class _RoomSceneState extends State<RoomScene> {
  ImageStream? _imageStream;
  ImageStreamListener? _listener;
  Size? _imageSize;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_imageStream == null) _resolveImageSize();
  }

  @override
  void didUpdateWidget(RoomScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.backgroundAsset != widget.backgroundAsset) {
      _imageStream?.removeListener(_listener!);
      _imageStream = null;
      _resolveImageSize();
    }
  }

  void _resolveImageSize() {
    final stream = AssetImage(widget.backgroundAsset)
        .resolve(createLocalImageConfiguration(context));
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        if (!mounted) return;
        setState(() {
          _imageSize = Size(
            info.image.width.toDouble(),
            info.image.height.toDouble(),
          );
        });
        stream.removeListener(listener);
      },
      onError: (_, _) {
        stream.removeListener(listener);
      },
    );
    _imageStream = stream;
    _listener = listener;
    stream.addListener(listener);
  }

  @override
  void dispose() {
    _imageStream?.removeListener(_listener!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageSize = _imageSize;
    if (imageSize == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final box = constraints.biggest;
        // Contain-fit: scale so the whole image is visible, centered.
        final scale = math.min(
          box.width / imageSize.width,
          box.height / imageSize.height,
        );
        final dispW = imageSize.width * scale;
        final dispH = imageSize.height * scale;
        final originX = (box.width - dispW) / 2;
        final originY = (box.height - dispH) / 2;

        return Stack(
          children: [
            Positioned(
              left: originX,
              top: originY,
              width: dispW,
              height: dispH,
              child: Image.asset(
                widget.backgroundAsset,
                fit: BoxFit.fill,
                semanticLabel: widget.sceneLabel,
              ),
            ),
            for (final hotspot in widget.hotspots)
              _positionedHotspot(hotspot, originX, originY, dispW, dispH, box),
            // Labels are drawn after the tap targets and ignore pointers, so
            // enabling the reading aid never blocks an interaction.
            if (widget.showLabels)
              for (final hotspot in widget.hotspots)
                _positionedLabel(hotspot, originX, originY, dispW, dispH, box),
          ],
        );
      },
    );
  }

  /// Localised object name chip centred on a hotspot. Purely informational:
  /// it does not change hit testing or reveal puzzle values.
  Widget _positionedLabel(
    RoomHotspotView hotspot,
    double originX,
    double originY,
    double dispW,
    double dispH,
    Size box,
  ) {
    const chipWidth = 124.0;
    const chipHeight = 26.0;
    final b = hotspot.definition.bounds;
    final cx = originX + (b.x + b.width / 2) * dispW;
    final cy = originY + (b.y + b.height / 2) * dispH;
    final halfW = chipWidth / 2;
    final left = cx.clamp(
      math.min(halfW, box.width / 2),
      math.max(halfW, box.width - halfW),
    );
    final top = cy.clamp(
      math.min(chipHeight / 2, box.height / 2),
      math.max(chipHeight / 2, box.height - chipHeight / 2),
    );

    return Positioned(
      key: ValueKey('hotspot_label_${hotspot.definition.id}'),
      left: left - halfW,
      top: top - chipHeight / 2,
      width: chipWidth,
      height: chipHeight,
      child: IgnorePointer(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: chipWidth),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceOverlay,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.brass.withValues(alpha: 0.85),
                ),
              ),
              child: Text(
                hotspot.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.parchmentText,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _positionedHotspot(
    RoomHotspotView hotspot,
    double originX,
    double originY,
    double dispW,
    double dispH,
    Size box,
  ) {
    final b = hotspot.definition.bounds;

    // Raw bounds in screen px.
    var left = originX + b.x * dispW;
    var top = originY + b.y * dispH;
    var width = b.width * dispW;
    var height = b.height * dispH;

    // Expand to the minimum touch target, keeping the bounds center fixed.
    final targetW = math.max(width, RoomScene.minTouchTarget);
    final targetH = math.max(height, RoomScene.minTouchTarget);
    left -= (targetW - width) / 2;
    top -= (targetH - height) / 2;
    width = targetW;
    height = targetH;

    // Clamp inside the scene box so targets never leave the viewport.
    left = left.clamp(0.0, math.max(0.0, box.width - width));
    top = top.clamp(0.0, math.max(0.0, box.height - height));

    return Positioned(
      key: ValueKey('hotspot_${hotspot.definition.id}'),
      left: left,
      top: top,
      width: width,
      height: height,
      child: _HotspotTarget(
        label: hotspot.label,
        onTap: () => widget.onHotspotTap(hotspot),
      ),
    );
  }
}

/// Transparent tap target showing a subtle marker at the hotspot center.
class _HotspotTarget extends StatefulWidget {
  const _HotspotTarget({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_HotspotTarget> createState() => _HotspotTargetState();
}

class _HotspotTargetState extends State<_HotspotTarget> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) {
          if (!MediaQuery.disableAnimationsOf(context)) {
            setState(() => _pressed = true);
          }
        },
        onTapUp: (_) {
          if (_pressed) setState(() => _pressed = false);
        },
        onTapCancel: () {
          if (_pressed) setState(() => _pressed = false);
        },
        child: Center(
          child: AnimatedOpacity(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 120),
            opacity: MediaQuery.disableAnimationsOf(context) || _pressed
                ? 0.95
                : 0.65,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _pressed ? AppColors.amber : AppColors.brass,
                border: Border.all(color: AppColors.parchmentText, width: 1.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
