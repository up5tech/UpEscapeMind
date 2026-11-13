import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/providers/app_providers.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/content/content_strings.dart';
import '../../../domain/models/content/content_models.dart';
import '../../../domain/models/progress.dart';

/// Chapter selection + room map, driven by the bundled content catalog and
/// persisted [GameProgress]. Room navigation itself lands in Phase 5; tiles
/// render state (locked / unlocked / current) now.
class ChaptersScreen extends ConsumerWidget {
  const ChaptersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final catalogAsync = ref.watch(contentCatalogProvider);
    final stringsAsync = ref.watch(contentStringsProvider);
    final progress = ref.watch(gameProgressProvider).value;
    final locale = ref.watch(appLocaleProvider)?.languageCode ?? 'vi';

    return AppScaffold(
      title: l10n.chaptersTitle,
      showBackButton: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.menu_book_outlined),
          tooltip: l10n.journalTitle,
          onPressed: () => context.pushNamed('journal'),
        ),
      ],
      body: catalogAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (catalog) => stringsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (strings) => _ChapterList(
            catalog: catalog,
            strings: strings,
            progress: progress,
            locale: locale,
            l10n: l10n,
          ),
        ),
      ),
    );
  }
}

class _ChapterList extends StatelessWidget {
  const _ChapterList({
    required this.catalog,
    required this.strings,
    required this.progress,
    required this.locale,
    required this.l10n,
  });

  final ContentCatalog catalog;
  final ContentStrings strings;
  final GameProgress? progress;
  final String locale;
  final AppLocalizations l10n;

  String s(String key) => strings.forLocale(locale, key);

  @override
  Widget build(BuildContext context) {
    final chapters = [...catalog.chapters]
      ..sort((a, b) => a.order.compareTo(b.order));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final chapter in chapters)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _ChapterCard(
              chapter: chapter,
              catalog: catalog,
              status: _chapterStatus(chapter),
              title: s(chapter.titleKey),
              l10n: l10n,
              rooms: [
                for (final roomId in chapter.roomIds)
                  if (catalog.roomsById[roomId] != null)
                    catalog.roomsById[roomId]!,
              ],
              strings: strings,
              progress: progress,
              locale: locale,
            ),
          ),
      ],
    );
  }

  String _chapterStatus(ChapterDefinition chapter) {
    if (progress == null) return l10n.chapterAvailable;
    if (progress!.completedChapterIds.contains(chapter.id)) {
      return l10n.chapterCompleted;
    }
    final touched = chapter.roomIds.any(
      (id) => progress!.isRoomUnlocked(id) || progress!.currentRoomId == id,
    );
    return touched ? l10n.chapterInProgress : l10n.chapterAvailable;
  }
}

class _ChapterCard extends StatelessWidget {
  const _ChapterCard({
    required this.chapter,
    required this.catalog,
    required this.status,
    required this.title,
    required this.l10n,
    required this.rooms,
    required this.strings,
    required this.progress,
    required this.locale,
  });

  final ChapterDefinition chapter;
  final ContentCatalog catalog;
  final String status;
  final String title;
  final AppLocalizations l10n;
  final List<RoomDefinition> rooms;
  final ContentStrings strings;
  final GameProgress? progress;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SectionCard(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            status,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          for (final room in rooms)
            _RoomTile(
              room: room,
              title: strings.forLocale(locale, room.titleKey),
              unlocked: _isUnlocked(room),
              completed: _isRoomComplete(room),
              current: progress?.currentRoomId == room.id,
              l10n: l10n,
              onTap: _isUnlocked(room)
                  ? () => context.pushNamed(
                      'room',
                      pathParameters: {'roomId': room.id},
                    )
                  : null,
            ),
          if (progress?.completedChapterIds.contains(chapter.id) ?? false)
            TextButton(
              key: ValueKey('chapter_view_summary_${chapter.id}'),
              onPressed: () => context.pushNamed(
                'chapterSummary',
                pathParameters: {'chapterId': chapter.id},
              ),
              child: Text(l10n.viewSummary),
            ),
        ],
      ),
    );
  }

  /// Phase 8 room completion state: every authored puzzle of the room
  /// solved. Transition-only rooms never show the mark.
  bool _isRoomComplete(RoomDefinition room) {
    final progress = this.progress;
    if (progress == null) return false;
    final puzzles = [
      for (final p in catalog.puzzles)
        if (p.roomId == room.id) p,
    ];
    if (puzzles.isEmpty) return false;
    return puzzles.every((p) => progress.isPuzzleSolved(p.id));
  }

  bool _isUnlocked(RoomDefinition room) {
    if (progress == null) {
      // No save yet: only the chapter's entry room is reachable.
      return room.id == chapter.roomIds.first;
    }
    return progress!.isRoomUnlocked(room.id);
  }
}

class _RoomTile extends StatelessWidget {
  const _RoomTile({
    required this.room,
    required this.title,
    required this.unlocked,
    required this.current,
    required this.completed,
    required this.l10n,
    this.onTap,
  });

  final RoomDefinition room;
  final String title;
  final bool unlocked;
  final bool current;

  /// All authored puzzles of this room solved (Phase 8 room state).
  final bool completed;
  final AppLocalizations l10n;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
      trailing: !unlocked
          ? Text(
              l10n.chapterLocked,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.disabledText,
              ),
            )
          : completed
          ? Icon(
              key: ValueKey('room_complete_${room.id}'),
              Icons.check_circle,
              size: 20,
              color: AppColors.brass,
            )
          : null,
      onTap: unlocked ? onTap : null,
    );
  }
}
