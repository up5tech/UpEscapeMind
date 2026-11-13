import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/providers/app_providers.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/models/chapter.dart';
import '../../../domain/models/progress.dart';
import '../../../domain/models/room.dart';

/// Chapter selection + the five Chapter 1 areas (room map).
///
/// Rooms render as a read-only list for now; tapping becomes navigation in
/// Phase 5 once the room screen exists. Locked rooms are shown but disabled.
class ChaptersScreen extends ConsumerWidget {
  const ChaptersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final progress = ref.watch(gameProgressProvider).value;

    return AppScaffold(
      title: l10n.chaptersTitle,
      showBackButton: true,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: _chapterTitle(l10n, Chapter.chapter1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _chapterStatusLabel(l10n, progress),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 16),
                for (final roomId in Chapter.chapter1.roomIds)
                  _RoomTile(
                    room: _roomFor(roomId),
                    title: _roomTitle(l10n, roomId),
                    unlocked:
                        progress?.isRoomUnlocked(roomId) ??
                        roomId == Chapter.chapter1.roomIds.first,
                    current: progress?.currentRoomId == roomId,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Room _roomFor(String roomId) =>
      Room(id: roomId, chapterId: Chapter.chapter1.id, titleKey: roomId);

  String _chapterTitle(AppLocalizations l10n, Chapter chapter) {
    return chapter.id == Chapter.chapter1.id ? l10n.chapter1Title : chapter.id;
  }

  String _chapterStatusLabel(AppLocalizations l10n, GameProgress? progress) {
    // Chapter completion state is finalized in Phase 8.
    return progress == null ? l10n.chapterAvailable : l10n.chapterInProgress;
  }

  String _roomTitle(AppLocalizations l10n, String roomId) {
    switch (roomId) {
      case 'room_entrance':
        return l10n.roomEntranceTitle;
      case 'room_study':
        return l10n.roomStudyTitle;
      case 'room_workshop':
        return l10n.roomWorkshopTitle;
      case 'room_gallery':
        return l10n.roomGalleryTitle;
      case 'room_observatory':
        return l10n.roomObservatoryTitle;
      default:
        return roomId;
    }
  }
}

class _RoomTile extends StatelessWidget {
  const _RoomTile({
    required this.room,
    required this.title,
    required this.unlocked,
    required this.current,
  });

  final Room room;
  final String title;
  final bool unlocked;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        unlocked ? Icons.meeting_room_outlined : Icons.lock_outline,
        color: unlocked ? AppColors.brass : AppColors.disabledText,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: unlocked ? AppColors.primaryText : AppColors.disabledText,
        ),
      ),
      subtitle: current
          ? Text(
              l10n.chapterInProgress,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.amber,
              ),
            )
          : null,
      trailing: unlocked
          ? null
          : Text(
              l10n.chapterLocked,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.disabledText,
              ),
            ),
      onTap: null, // Room navigation lands in Phase 5.
    );
  }
}
