import '../../core/errors/app_exceptions.dart';
import '../../domain/models/content/content_models.dart';

/// Development-time content validation (PLAN.md §10.3, Phase 2).
///
/// Runs after parsing and verifies cross-file integrity: ID references,
/// hotspot bounds, asset existence, puzzle-type config, hint counts,
/// localization keys, and circular unlock dependencies.
///
/// All problems are collected and reported together with file/field context
/// so authors can fix a batch in one pass.
abstract final class ContentValidator {
  /// Per-type required `solutionConfig` keys. Phase 7 validators may demand
  /// more, but these are the minimum a puzzle definition must declare.
  static const Map<PuzzleType, List<String>> _requiredSolutionKeys = {
    PuzzleType.observation: ['targets'],
    PuzzleType.keypad: ['code'],
    PuzzleType.symbolMatching: ['symbols'],
    PuzzleType.sequence: ['order'],
    PuzzleType.rotation: ['steps'],
    PuzzleType.logicDeduction: ['answer'],
    PuzzleType.itemUse: ['requiredItemId'],
    PuzzleType.itemCombination: ['recipeId'],
    PuzzleType.hiddenObject: ['regions'],
    PuzzleType.mechanicalState: ['targetState'],
  };

  static Future<void> validate(
    ContentCatalog catalog, {
    Future<bool> Function(String assetPath)? assetExists,
    Set<String>? localizationKeys,
  }) async {
    final errors = <String>[];

    _checkDuplicateIds(catalog, errors);
    _checkChapters(catalog, errors, localizationKeys);
    _checkRooms(catalog, errors, localizationKeys);
    _checkPuzzles(catalog, errors, localizationKeys);
    _checkItems(catalog, errors, localizationKeys);
    _checkCombinations(catalog, errors, localizationKeys);
    _checkClues(catalog, errors, localizationKeys);
    _checkCircularUnlocks(catalog, errors);

    if (assetExists != null) {
      await _checkAssets(catalog, assetExists, errors);
    }

    if (errors.isNotEmpty) {
      throw ContentValidationException(
        'content validation failed (${errors.length} problem(s)):\n'
        '${errors.map((e) => '  - $e').join('\n')}',
      );
    }
  }

  // ------------------------------------------------------------------ ids

  static void _checkDuplicateIds(ContentCatalog c, List<String> errors) {
    void check<T>(String kind, List<T> defs, String Function(T) idOf) {
      final seen = <String>{};
      for (final def in defs) {
        final id = idOf(def);
        if (!seen.add(id)) {
          errors.add('duplicate $kind id "$id"');
        }
      }
    }

    check('chapter', c.chapters, (d) => d.id);
    check('room', c.rooms, (d) => d.id);
    check('puzzle', c.puzzles, (d) => d.id);
    check('item', c.items, (d) => d.id);
    check('item_combination', c.combinations, (d) => d.id);
    check('clue', c.clues, (d) => d.id);
  }

  // ------------------------------------------------------------- chapters

  static void _checkChapters(
    ContentCatalog c,
    List<String> errors,
    Set<String>? localizationKeys,
  ) {
    final roomChapter = {for (final r in c.rooms) r.id: r.chapterId};
    final orders = <int>{};

    for (final chapter in c.chapters) {
      if (!orders.add(chapter.order)) {
        errors.add('chapter "${chapter.id}": duplicate order ${chapter.order}');
      }
      if (chapter.roomIds.isEmpty) {
        errors.add('chapter "${chapter.id}": roomIds must not be empty');
      }
      for (final roomId in chapter.roomIds) {
        final owner = roomChapter[roomId];
        if (owner == null) {
          errors.add(
            'chapter "${chapter.id}": roomIds references unknown room "$roomId"',
          );
        } else if (owner != chapter.id) {
          errors.add(
            'chapter "${chapter.id}": room "$roomId" belongs to "$owner"',
          );
        }
      }
      for (final pre in chapter.unlockConditions) {
        _checkPrerequisite(c, pre, 'chapter "${chapter.id}"', errors);
      }
      _checkKey(
        chapter.titleKey,
        'chapter "${chapter.id}".titleKey',
        errors,
        localizationKeys: localizationKeys,
      );
    }
  }

  // ---------------------------------------------------------------- rooms

  static void _checkRooms(
    ContentCatalog c,
    List<String> errors,
    Set<String>? localizationKeys,
  ) {
    for (final room in c.rooms) {
      _checkKey(
        room.titleKey,
        'room "${room.id}".titleKey',
        errors,
        localizationKeys: localizationKeys,
      );
      if (room.descriptionKey != null) {
        _checkKey(
          room.descriptionKey!,
          'room "${room.id}".descriptionKey',
          errors,
          localizationKeys: localizationKeys,
        );
      }

      for (final pre in room.entryConditions) {
        _checkPrerequisite(c, pre, 'room "${room.id}".entryConditions', errors);
      }
      for (final exit in room.exitConnections) {
        if (!c.roomsById.containsKey(exit.targetRoomId)) {
          errors.add(
            'room "${room.id}": exitConnections references unknown room '
            '"${exit.targetRoomId}"',
          );
        }
        if (exit.labelKey != null) {
          _checkKey(
            exit.labelKey!,
            'room "${room.id}".exit.labelKey',
            errors,
            localizationKeys: localizationKeys,
          );
        }
      }

      final hotspotIds = <String>{};
      for (final hotspot in room.hotspots) {
        final where = 'room "${room.id}" hotspot "${hotspot.id}"';
        if (!hotspotIds.add(hotspot.id)) {
          errors.add('$where: duplicate hotspot id within room');
        }
        _checkHotspotBounds(hotspot, where, errors);
        _checkKey(
          hotspot.labelKey,
          '$where.labelKey',
          errors,
          localizationKeys: localizationKeys,
        );
        if (hotspot.descriptionKey != null) {
          _checkKey(
            hotspot.descriptionKey!,
            '$where.descriptionKey',
            errors,
            localizationKeys: localizationKeys,
          );
        }
        for (final pre in hotspot.visibilityConditions) {
          _checkPrerequisite(c, pre, '$where.visibilityConditions', errors);
        }
        _checkHotspotTarget(c, room, hotspot, errors);
      }
    }
  }

  static void _checkHotspotBounds(
    HotspotDefinition hotspot,
    String where,
    List<String> errors,
  ) {
    const eps = 1e-6;
    final b = hotspot.bounds;
    final problems = <String>[
      if (b.x < -eps || b.y < -eps) 'negative origin',
      if (b.width <= 0 || b.height <= 0) 'non-positive size',
      if (b.x + b.width > 1 + eps || b.y + b.height > 1 + eps)
        'extends past scene edge',
    ];
    if (problems.isNotEmpty) {
      errors.add(
        '$where: invalid bounds (${problems.join(', ')}) '
        'x=${b.x} y=${b.y} w=${b.width} h=${b.height}',
      );
    }
  }

  static void _checkHotspotTarget(
    ContentCatalog c,
    RoomDefinition room,
    HotspotDefinition hotspot,
    List<String> errors,
  ) {
    final where = 'room "${room.id}" hotspot "${hotspot.id}"';
    final target = hotspot.targetId;

    switch (hotspot.interactionType) {
      case HotspotInteraction.puzzle:
        if (target == null) {
          errors.add('$where: interactionType "puzzle" requires targetId');
          return;
        }
        final puzzle = c.puzzlesById[target];
        if (puzzle == null) {
          errors.add('$where: unknown puzzle target "$target"');
          return;
        }
        if (puzzle.roomId != room.id) {
          errors.add(
            '$where: puzzle "$target" belongs to room "${puzzle.roomId}"',
          );
        }
        if (puzzle.hotspotId != hotspot.id) {
          errors.add(
            '$where: puzzle "$target" points at hotspot '
            '"${puzzle.hotspotId}", not "${hotspot.id}"',
          );
        }
      case HotspotInteraction.collectItem:
        if (target == null || !c.itemsById.containsKey(target)) {
          errors.add('$where: collect_item requires a known item targetId');
        }
      case HotspotInteraction.discoverClue:
        if (target == null || !c.cluesById.containsKey(target)) {
          errors.add('$where: discover_clue requires a known clue targetId');
        }
      case HotspotInteraction.navigate:
        if (target == null || !c.roomsById.containsKey(target)) {
          errors.add('$where: navigate requires a known room targetId');
        }
      case HotspotInteraction.inspect:
      case HotspotInteraction.useItem:
        break; // targetId optional
    }
  }

  // -------------------------------------------------------------- puzzles

  static void _checkPuzzles(
    ContentCatalog c,
    List<String> errors,
    Set<String>? localizationKeys,
  ) {
    for (final puzzle in c.puzzles) {
      final where = 'puzzle "${puzzle.id}"';

      final room = c.roomsById[puzzle.roomId];
      if (room == null) {
        errors.add('$where: unknown roomId "${puzzle.roomId}"');
      } else {
        HotspotDefinition? hotspot;
        for (final h in room.hotspots) {
          if (h.id == puzzle.hotspotId) hotspot = h;
        }
        if (hotspot == null) {
          errors.add(
            '$where: hotspotId "${puzzle.hotspotId}" not found in room '
            '"${puzzle.roomId}"',
          );
        } else if (hotspot.interactionType != HotspotInteraction.puzzle ||
            hotspot.targetId != puzzle.id) {
          errors.add(
            '$where: hotspot "${puzzle.hotspotId}" does not reference this '
            'puzzle',
          );
        }
      }

      _checkKey(
        puzzle.titleKey,
        '$where.titleKey',
        errors,
        localizationKeys: localizationKeys,
      );
      _checkKey(
        puzzle.instructionsKey,
        '$where.instructionsKey',
        errors,
        localizationKeys: localizationKeys,
      );

      for (final key in _requiredSolutionKeys[puzzle.type] ?? const []) {
        if (!puzzle.solutionConfig.containsKey(key)) {
          errors.add(
            '$where: solutionConfig missing required key "$key" '
            'for type "${puzzle.type.jsonValue}"',
          );
        }
      }

      for (final pre in puzzle.prerequisites) {
        _checkPrerequisite(c, pre, '$where.prerequisites', errors);
      }
      for (final action in puzzle.successActions) {
        _checkSuccessAction(c, action, where, errors);
      }
      for (final hint in puzzle.hints) {
        _checkKey(
          hint.textKey,
          '$where.hints[level ${hint.level}].textKey',
          errors,
          localizationKeys: localizationKeys,
        );
      }
      if (puzzle.hints.length > 3) {
        errors.add('$where: more than 3 hints');
      }
    }
  }

  static void _checkSuccessAction(
    ContentCatalog c,
    SuccessAction action,
    String where,
    List<String> errors,
  ) {
    final ok = switch (action.type) {
      SuccessActionType.unlockRoom => c.roomsById.containsKey(action.targetId),
      SuccessActionType.collectItem ||
      SuccessActionType.consumeItem => c.itemsById.containsKey(action.targetId),
      SuccessActionType.discoverClue => c.cluesById.containsKey(
        action.targetId,
      ),
      SuccessActionType.completeChapter => c.chaptersById.containsKey(
        action.targetId,
      ),
    };
    if (!ok) {
      errors.add(
        '$where: successActions references unknown '
        '${action.type.jsonValue} target "${action.targetId}"',
      );
    }
  }

  // ---------------------------------------------------------------- items

  static void _checkItems(
    ContentCatalog c,
    List<String> errors,
    Set<String>? localizationKeys,
  ) {
    for (final item in c.items) {
      final where = 'item "${item.id}"';
      _checkKey(
        item.nameKey,
        '$where.nameKey',
        errors,
        localizationKeys: localizationKeys,
      );
      _checkKey(
        item.descriptionKey,
        '$where.descriptionKey',
        errors,
        localizationKeys: localizationKeys,
      );
      _checkKey(
        item.iconAsset,
        '$where.iconAsset',
        errors,
        localizationKeys: null,
      ); // asset path, checked separately
    }
  }

  static void _checkCombinations(
    ContentCatalog c,
    List<String> errors,
    Set<String>? localizationKeys,
  ) {
    for (final combo in c.combinations) {
      final where = 'item_combination "${combo.id}"';
      _checkKey(
        combo.resultMessageKey,
        '$where.resultMessageKey',
        errors,
        localizationKeys: localizationKeys,
      );

      if (combo.inputItemIds.toSet().length != combo.inputItemIds.length) {
        errors.add('$where: duplicate entries in inputItemIds');
      }
      for (final inputId in combo.inputItemIds) {
        if (!c.itemsById.containsKey(inputId)) {
          errors.add('$where: unknown input item "$inputId"');
        }
      }
      if (!c.itemsById.containsKey(combo.resultItemId)) {
        errors.add('$where: unknown result item "${combo.resultItemId}"');
      }
      if (combo.inputItemIds.contains(combo.resultItemId)) {
        errors.add('$where: resultItemId appears in inputItemIds');
      }
    }
    _checkCombinationCycles(c, errors);
  }

  /// Detects cycles like A+B→C, C+D→A which would make recipes
  /// non-terminating if inputs are retained.
  static void _checkCombinationCycles(ContentCatalog c, List<String> errors) {
    // Edge: result item -> each input item it was produced from is not a
    // dependency cycle; a real cycle needs produced item feeding back as an
    // input of a combination whose result is an ancestor. Model graph as
    // item -> combinations that consume it; DFS for a path back to start.
    final producedBy = <String, List<ItemCombinationDefinition>>{};
    for (final combo in c.combinations) {
      for (final input in combo.inputItemIds) {
        producedBy.putIfAbsent(input, () => []).add(combo);
      }
    }

    for (final combo in c.combinations) {
      final stack = <String>[combo.resultItemId];
      final visited = <String>{};
      while (stack.isNotEmpty) {
        final itemId = stack.removeLast();
        if (!visited.add(itemId)) continue;
        final nextCombos = producedBy[itemId];
        if (nextCombos == null) continue;
        for (final next in nextCombos) {
          if (next.id == combo.id) continue;
          for (final input in next.inputItemIds) {
            if (input == combo.resultItemId) {
              errors.add(
                'item_combination cycle involving "${combo.id}" and '
                '"${next.id}" via item "$input"',
              );
            } else {
              stack.add(input);
            }
          }
        }
      }
    }
  }

  // ----------------------------------------------------------------- clues

  static void _checkClues(
    ContentCatalog c,
    List<String> errors,
    Set<String>? localizationKeys,
  ) {
    for (final clue in c.clues) {
      final where = 'clue "${clue.id}"';
      _checkKey(
        clue.titleKey,
        '$where.titleKey',
        errors,
        localizationKeys: localizationKeys,
      );
      _checkKey(
        clue.bodyKey,
        '$where.bodyKey',
        errors,
        localizationKeys: localizationKeys,
      );
      if (!c.roomsById.containsKey(clue.sourceRoomId)) {
        errors.add('$where: unknown sourceRoomId "${clue.sourceRoomId}"');
      }
    }
  }

  // ------------------------------------------------------- prerequisites

  static void _checkPrerequisite(
    ContentCatalog c,
    Prerequisite pre,
    String where,
    List<String> errors,
  ) {
    final ok = switch (pre.type) {
      PrerequisiteType.roomUnlocked => c.roomsById.containsKey(pre.targetId),
      PrerequisiteType.puzzleSolved => c.puzzlesById.containsKey(pre.targetId),
      PrerequisiteType.itemCollected ||
      PrerequisiteType.itemConsumed => c.itemsById.containsKey(pre.targetId),
      PrerequisiteType.clueDiscovered => c.cluesById.containsKey(pre.targetId),
      PrerequisiteType.chapterCompleted => c.chaptersById.containsKey(
        pre.targetId,
      ),
    };
    if (!ok) {
      errors.add(
        '$where: ${pre.type.jsonValue} references unknown id '
        '"${pre.targetId}"',
      );
    }
  }

  // ------------------------------------------------- circular unlocks

  /// Builds a dependency graph over unlock-relevant entities and reports
  /// cycles (e.g. room A requires puzzle B which requires room A).
  static void _checkCircularUnlocks(ContentCatalog c, List<String> errors) {
    final graph = <String, Set<String>>{};

    void addEdges(String node, Iterable<Prerequisite> pres) {
      for (final pre in pres) {
        final target = switch (pre.type) {
          PrerequisiteType.roomUnlocked => 'room:${pre.targetId}',
          PrerequisiteType.puzzleSolved => 'puzzle:${pre.targetId}',
          PrerequisiteType.chapterCompleted => 'chapter:${pre.targetId}',
          _ => null,
        };
        if (target != null) graph.putIfAbsent(node, () => {}).add(target);
      }
    }

    for (final chapter in c.chapters) {
      addEdges('chapter:${chapter.id}', chapter.unlockConditions);
    }
    for (final room in c.rooms) {
      addEdges('room:${room.id}', room.entryConditions);
      for (final hotspot in room.hotspots) {
        addEdges(
          'hotspot:${room.id}/${hotspot.id}',
          hotspot.visibilityConditions,
        );
      }
    }
    for (final puzzle in c.puzzles) {
      addEdges('puzzle:${puzzle.id}', puzzle.prerequisites);
    }

    // Iterative DFS with colors: 0=unvisited,1=in-stack,2=done.
    final color = <String, int>{};
    final stack = <String>[];

    bool visit(String node) {
      color[node] = 1;
      stack.add(node);
      for (final next in graph[node] ?? const <String>{}) {
        final state = color[next] ?? 0;
        if (state == 1) {
          final cycleStart = stack.indexOf(next);
          final cycle = [...stack.sublist(cycleStart), next];
          errors.add('circular unlock dependency: ${cycle.join(' -> ')}');
          return true;
        }
        if (state == 0 && visit(next)) return true;
      }
      stack.removeLast();
      color[node] = 2;
      return false;
    }

    for (final node in graph.keys) {
      if ((color[node] ?? 0) == 0) visit(node);
    }
  }

  // ---------------------------------------------------------------- assets

  static Future<void> _checkAssets(
    ContentCatalog c,
    Future<bool> Function(String) assetExists,
    List<String> errors,
  ) async {
    final paths = <String>{};
    for (final room in c.rooms) {
      paths.add(room.backgroundAsset);
      paths.addAll(room.foregroundAssets);
      if (room.ambientAudioAsset != null) paths.add(room.ambientAudioAsset!);
      for (final hotspot in room.hotspots) {
        if (hotspot.inspectionAsset != null) {
          paths.add(hotspot.inspectionAsset!);
        }
      }
    }
    for (final item in c.items) {
      paths.add(item.iconAsset);
      if (item.inspectionAsset != null) paths.add(item.inspectionAsset!);
    }

    for (final path in paths.toList()..sort()) {
      if (!path.startsWith('assets/')) {
        errors.add('asset path "$path" must start with "assets/"');
        continue;
      }
      if (!await assetExists(path)) {
        errors.add('missing asset file "$path"');
      }
    }
  }

  // ------------------------------------------------------- localization

  /// Records whether [key] exists in the provided localization key set.
  /// No-op when [localizationKeys] is null (runtime loads may skip this).
  static void _checkKey(
    String key,
    String where,
    List<String> errors, {
    required Set<String>? localizationKeys,
  }) {
    if (localizationKeys == null) return;
    if (!localizationKeys.contains(key)) {
      errors.add('$where: localization key "$key" not found in arb files');
    }
  }
}
