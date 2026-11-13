// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SaveSlotsTable extends SaveSlots
    with TableInfo<$SaveSlotsTable, SaveSlot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaveSlotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentRoomIdMeta = const VerificationMeta(
    'currentRoomId',
  );
  @override
  late final GeneratedColumn<String> currentRoomId = GeneratedColumn<String>(
    'current_room_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _playTimeMsMeta = const VerificationMeta(
    'playTimeMs',
  );
  @override
  late final GeneratedColumn<int> playTimeMs = GeneratedColumn<int>(
    'play_time_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schemaVersion,
    currentRoomId,
    playTimeMs,
    updatedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'save_slots';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaveSlot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_schemaVersionMeta);
    }
    if (data.containsKey('current_room_id')) {
      context.handle(
        _currentRoomIdMeta,
        currentRoomId.isAcceptableOrUnknown(
          data['current_room_id']!,
          _currentRoomIdMeta,
        ),
      );
    }
    if (data.containsKey('play_time_ms')) {
      context.handle(
        _playTimeMsMeta,
        playTimeMs.isAcceptableOrUnknown(
          data['play_time_ms']!,
          _playTimeMsMeta,
        ),
      );
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaveSlot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaveSlot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
      currentRoomId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_room_id'],
      ),
      playTimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}play_time_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $SaveSlotsTable createAlias(String alias) {
    return $SaveSlotsTable(attachedDatabase, alias);
  }
}

class SaveSlot extends DataClass implements Insertable<SaveSlot> {
  final String id;

  /// Save schema version — bump with migrations in `AppDatabase.onUpgrade`.
  final int schemaVersion;
  final String? currentRoomId;
  final int playTimeMs;
  final int updatedAtMs;
  const SaveSlot({
    required this.id,
    required this.schemaVersion,
    this.currentRoomId,
    required this.playTimeMs,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['schema_version'] = Variable<int>(schemaVersion);
    if (!nullToAbsent || currentRoomId != null) {
      map['current_room_id'] = Variable<String>(currentRoomId);
    }
    map['play_time_ms'] = Variable<int>(playTimeMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  SaveSlotsCompanion toCompanion(bool nullToAbsent) {
    return SaveSlotsCompanion(
      id: Value(id),
      schemaVersion: Value(schemaVersion),
      currentRoomId: currentRoomId == null && nullToAbsent
          ? const Value.absent()
          : Value(currentRoomId),
      playTimeMs: Value(playTimeMs),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory SaveSlot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaveSlot(
      id: serializer.fromJson<String>(json['id']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      currentRoomId: serializer.fromJson<String?>(json['currentRoomId']),
      playTimeMs: serializer.fromJson<int>(json['playTimeMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'currentRoomId': serializer.toJson<String?>(currentRoomId),
      'playTimeMs': serializer.toJson<int>(playTimeMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  SaveSlot copyWith({
    String? id,
    int? schemaVersion,
    Value<String?> currentRoomId = const Value.absent(),
    int? playTimeMs,
    int? updatedAtMs,
  }) => SaveSlot(
    id: id ?? this.id,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    currentRoomId: currentRoomId.present
        ? currentRoomId.value
        : this.currentRoomId,
    playTimeMs: playTimeMs ?? this.playTimeMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  SaveSlot copyWithCompanion(SaveSlotsCompanion data) {
    return SaveSlot(
      id: data.id.present ? data.id.value : this.id,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      currentRoomId: data.currentRoomId.present
          ? data.currentRoomId.value
          : this.currentRoomId,
      playTimeMs: data.playTimeMs.present
          ? data.playTimeMs.value
          : this.playTimeMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaveSlot(')
          ..write('id: $id, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('currentRoomId: $currentRoomId, ')
          ..write('playTimeMs: $playTimeMs, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, schemaVersion, currentRoomId, playTimeMs, updatedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaveSlot &&
          other.id == this.id &&
          other.schemaVersion == this.schemaVersion &&
          other.currentRoomId == this.currentRoomId &&
          other.playTimeMs == this.playTimeMs &&
          other.updatedAtMs == this.updatedAtMs);
}

class SaveSlotsCompanion extends UpdateCompanion<SaveSlot> {
  final Value<String> id;
  final Value<int> schemaVersion;
  final Value<String?> currentRoomId;
  final Value<int> playTimeMs;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const SaveSlotsCompanion({
    this.id = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.currentRoomId = const Value.absent(),
    this.playTimeMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SaveSlotsCompanion.insert({
    required String id,
    required int schemaVersion,
    this.currentRoomId = const Value.absent(),
    this.playTimeMs = const Value.absent(),
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       schemaVersion = Value(schemaVersion),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<SaveSlot> custom({
    Expression<String>? id,
    Expression<int>? schemaVersion,
    Expression<String>? currentRoomId,
    Expression<int>? playTimeMs,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (currentRoomId != null) 'current_room_id': currentRoomId,
      if (playTimeMs != null) 'play_time_ms': playTimeMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SaveSlotsCompanion copyWith({
    Value<String>? id,
    Value<int>? schemaVersion,
    Value<String?>? currentRoomId,
    Value<int>? playTimeMs,
    Value<int>? updatedAtMs,
    Value<int>? rowid,
  }) {
    return SaveSlotsCompanion(
      id: id ?? this.id,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      currentRoomId: currentRoomId ?? this.currentRoomId,
      playTimeMs: playTimeMs ?? this.playTimeMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (currentRoomId.present) {
      map['current_room_id'] = Variable<String>(currentRoomId.value);
    }
    if (playTimeMs.present) {
      map['play_time_ms'] = Variable<int>(playTimeMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaveSlotsCompanion(')
          ..write('id: $id, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('currentRoomId: $currentRoomId, ')
          ..write('playTimeMs: $playTimeMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UnlockedRoomsTable extends UnlockedRooms
    with TableInfo<$UnlockedRoomsTable, UnlockedRoom> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnlockedRoomsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _saveSlotIdMeta = const VerificationMeta(
    'saveSlotId',
  );
  @override
  late final GeneratedColumn<String> saveSlotId = GeneratedColumn<String>(
    'save_slot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
    'room_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [saveSlotId, roomId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'unlocked_rooms';
  @override
  VerificationContext validateIntegrity(
    Insertable<UnlockedRoom> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('save_slot_id')) {
      context.handle(
        _saveSlotIdMeta,
        saveSlotId.isAcceptableOrUnknown(
          data['save_slot_id']!,
          _saveSlotIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_saveSlotIdMeta);
    }
    if (data.containsKey('room_id')) {
      context.handle(
        _roomIdMeta,
        roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {saveSlotId, roomId};
  @override
  UnlockedRoom map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UnlockedRoom(
      saveSlotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}save_slot_id'],
      )!,
      roomId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_id'],
      )!,
    );
  }

  @override
  $UnlockedRoomsTable createAlias(String alias) {
    return $UnlockedRoomsTable(attachedDatabase, alias);
  }
}

class UnlockedRoom extends DataClass implements Insertable<UnlockedRoom> {
  final String saveSlotId;
  final String roomId;
  const UnlockedRoom({required this.saveSlotId, required this.roomId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['save_slot_id'] = Variable<String>(saveSlotId);
    map['room_id'] = Variable<String>(roomId);
    return map;
  }

  UnlockedRoomsCompanion toCompanion(bool nullToAbsent) {
    return UnlockedRoomsCompanion(
      saveSlotId: Value(saveSlotId),
      roomId: Value(roomId),
    );
  }

  factory UnlockedRoom.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UnlockedRoom(
      saveSlotId: serializer.fromJson<String>(json['saveSlotId']),
      roomId: serializer.fromJson<String>(json['roomId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'saveSlotId': serializer.toJson<String>(saveSlotId),
      'roomId': serializer.toJson<String>(roomId),
    };
  }

  UnlockedRoom copyWith({String? saveSlotId, String? roomId}) => UnlockedRoom(
    saveSlotId: saveSlotId ?? this.saveSlotId,
    roomId: roomId ?? this.roomId,
  );
  UnlockedRoom copyWithCompanion(UnlockedRoomsCompanion data) {
    return UnlockedRoom(
      saveSlotId: data.saveSlotId.present
          ? data.saveSlotId.value
          : this.saveSlotId,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UnlockedRoom(')
          ..write('saveSlotId: $saveSlotId, ')
          ..write('roomId: $roomId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(saveSlotId, roomId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UnlockedRoom &&
          other.saveSlotId == this.saveSlotId &&
          other.roomId == this.roomId);
}

class UnlockedRoomsCompanion extends UpdateCompanion<UnlockedRoom> {
  final Value<String> saveSlotId;
  final Value<String> roomId;
  final Value<int> rowid;
  const UnlockedRoomsCompanion({
    this.saveSlotId = const Value.absent(),
    this.roomId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UnlockedRoomsCompanion.insert({
    required String saveSlotId,
    required String roomId,
    this.rowid = const Value.absent(),
  }) : saveSlotId = Value(saveSlotId),
       roomId = Value(roomId);
  static Insertable<UnlockedRoom> custom({
    Expression<String>? saveSlotId,
    Expression<String>? roomId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (saveSlotId != null) 'save_slot_id': saveSlotId,
      if (roomId != null) 'room_id': roomId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UnlockedRoomsCompanion copyWith({
    Value<String>? saveSlotId,
    Value<String>? roomId,
    Value<int>? rowid,
  }) {
    return UnlockedRoomsCompanion(
      saveSlotId: saveSlotId ?? this.saveSlotId,
      roomId: roomId ?? this.roomId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (saveSlotId.present) {
      map['save_slot_id'] = Variable<String>(saveSlotId.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UnlockedRoomsCompanion(')
          ..write('saveSlotId: $saveSlotId, ')
          ..write('roomId: $roomId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SolvedPuzzlesTable extends SolvedPuzzles
    with TableInfo<$SolvedPuzzlesTable, SolvedPuzzle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SolvedPuzzlesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _saveSlotIdMeta = const VerificationMeta(
    'saveSlotId',
  );
  @override
  late final GeneratedColumn<String> saveSlotId = GeneratedColumn<String>(
    'save_slot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _puzzleIdMeta = const VerificationMeta(
    'puzzleId',
  );
  @override
  late final GeneratedColumn<String> puzzleId = GeneratedColumn<String>(
    'puzzle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _solvedAtMsMeta = const VerificationMeta(
    'solvedAtMs',
  );
  @override
  late final GeneratedColumn<int> solvedAtMs = GeneratedColumn<int>(
    'solved_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [saveSlotId, puzzleId, solvedAtMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'solved_puzzles';
  @override
  VerificationContext validateIntegrity(
    Insertable<SolvedPuzzle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('save_slot_id')) {
      context.handle(
        _saveSlotIdMeta,
        saveSlotId.isAcceptableOrUnknown(
          data['save_slot_id']!,
          _saveSlotIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_saveSlotIdMeta);
    }
    if (data.containsKey('puzzle_id')) {
      context.handle(
        _puzzleIdMeta,
        puzzleId.isAcceptableOrUnknown(data['puzzle_id']!, _puzzleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_puzzleIdMeta);
    }
    if (data.containsKey('solved_at_ms')) {
      context.handle(
        _solvedAtMsMeta,
        solvedAtMs.isAcceptableOrUnknown(
          data['solved_at_ms']!,
          _solvedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_solvedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {saveSlotId, puzzleId};
  @override
  SolvedPuzzle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SolvedPuzzle(
      saveSlotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}save_slot_id'],
      )!,
      puzzleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}puzzle_id'],
      )!,
      solvedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}solved_at_ms'],
      )!,
    );
  }

  @override
  $SolvedPuzzlesTable createAlias(String alias) {
    return $SolvedPuzzlesTable(attachedDatabase, alias);
  }
}

class SolvedPuzzle extends DataClass implements Insertable<SolvedPuzzle> {
  final String saveSlotId;
  final String puzzleId;
  final int solvedAtMs;
  const SolvedPuzzle({
    required this.saveSlotId,
    required this.puzzleId,
    required this.solvedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['save_slot_id'] = Variable<String>(saveSlotId);
    map['puzzle_id'] = Variable<String>(puzzleId);
    map['solved_at_ms'] = Variable<int>(solvedAtMs);
    return map;
  }

  SolvedPuzzlesCompanion toCompanion(bool nullToAbsent) {
    return SolvedPuzzlesCompanion(
      saveSlotId: Value(saveSlotId),
      puzzleId: Value(puzzleId),
      solvedAtMs: Value(solvedAtMs),
    );
  }

  factory SolvedPuzzle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SolvedPuzzle(
      saveSlotId: serializer.fromJson<String>(json['saveSlotId']),
      puzzleId: serializer.fromJson<String>(json['puzzleId']),
      solvedAtMs: serializer.fromJson<int>(json['solvedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'saveSlotId': serializer.toJson<String>(saveSlotId),
      'puzzleId': serializer.toJson<String>(puzzleId),
      'solvedAtMs': serializer.toJson<int>(solvedAtMs),
    };
  }

  SolvedPuzzle copyWith({
    String? saveSlotId,
    String? puzzleId,
    int? solvedAtMs,
  }) => SolvedPuzzle(
    saveSlotId: saveSlotId ?? this.saveSlotId,
    puzzleId: puzzleId ?? this.puzzleId,
    solvedAtMs: solvedAtMs ?? this.solvedAtMs,
  );
  SolvedPuzzle copyWithCompanion(SolvedPuzzlesCompanion data) {
    return SolvedPuzzle(
      saveSlotId: data.saveSlotId.present
          ? data.saveSlotId.value
          : this.saveSlotId,
      puzzleId: data.puzzleId.present ? data.puzzleId.value : this.puzzleId,
      solvedAtMs: data.solvedAtMs.present
          ? data.solvedAtMs.value
          : this.solvedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SolvedPuzzle(')
          ..write('saveSlotId: $saveSlotId, ')
          ..write('puzzleId: $puzzleId, ')
          ..write('solvedAtMs: $solvedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(saveSlotId, puzzleId, solvedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SolvedPuzzle &&
          other.saveSlotId == this.saveSlotId &&
          other.puzzleId == this.puzzleId &&
          other.solvedAtMs == this.solvedAtMs);
}

class SolvedPuzzlesCompanion extends UpdateCompanion<SolvedPuzzle> {
  final Value<String> saveSlotId;
  final Value<String> puzzleId;
  final Value<int> solvedAtMs;
  final Value<int> rowid;
  const SolvedPuzzlesCompanion({
    this.saveSlotId = const Value.absent(),
    this.puzzleId = const Value.absent(),
    this.solvedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SolvedPuzzlesCompanion.insert({
    required String saveSlotId,
    required String puzzleId,
    required int solvedAtMs,
    this.rowid = const Value.absent(),
  }) : saveSlotId = Value(saveSlotId),
       puzzleId = Value(puzzleId),
       solvedAtMs = Value(solvedAtMs);
  static Insertable<SolvedPuzzle> custom({
    Expression<String>? saveSlotId,
    Expression<String>? puzzleId,
    Expression<int>? solvedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (saveSlotId != null) 'save_slot_id': saveSlotId,
      if (puzzleId != null) 'puzzle_id': puzzleId,
      if (solvedAtMs != null) 'solved_at_ms': solvedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SolvedPuzzlesCompanion copyWith({
    Value<String>? saveSlotId,
    Value<String>? puzzleId,
    Value<int>? solvedAtMs,
    Value<int>? rowid,
  }) {
    return SolvedPuzzlesCompanion(
      saveSlotId: saveSlotId ?? this.saveSlotId,
      puzzleId: puzzleId ?? this.puzzleId,
      solvedAtMs: solvedAtMs ?? this.solvedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (saveSlotId.present) {
      map['save_slot_id'] = Variable<String>(saveSlotId.value);
    }
    if (puzzleId.present) {
      map['puzzle_id'] = Variable<String>(puzzleId.value);
    }
    if (solvedAtMs.present) {
      map['solved_at_ms'] = Variable<int>(solvedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SolvedPuzzlesCompanion(')
          ..write('saveSlotId: $saveSlotId, ')
          ..write('puzzleId: $puzzleId, ')
          ..write('solvedAtMs: $solvedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PuzzleStatesTable extends PuzzleStates
    with TableInfo<$PuzzleStatesTable, PuzzleState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PuzzleStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _saveSlotIdMeta = const VerificationMeta(
    'saveSlotId',
  );
  @override
  late final GeneratedColumn<String> saveSlotId = GeneratedColumn<String>(
    'save_slot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _puzzleIdMeta = const VerificationMeta(
    'puzzleId',
  );
  @override
  late final GeneratedColumn<String> puzzleId = GeneratedColumn<String>(
    'puzzle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateJsonMeta = const VerificationMeta(
    'stateJson',
  );
  @override
  late final GeneratedColumn<String> stateJson = GeneratedColumn<String>(
    'state_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [saveSlotId, puzzleId, stateJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'puzzle_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<PuzzleState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('save_slot_id')) {
      context.handle(
        _saveSlotIdMeta,
        saveSlotId.isAcceptableOrUnknown(
          data['save_slot_id']!,
          _saveSlotIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_saveSlotIdMeta);
    }
    if (data.containsKey('puzzle_id')) {
      context.handle(
        _puzzleIdMeta,
        puzzleId.isAcceptableOrUnknown(data['puzzle_id']!, _puzzleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_puzzleIdMeta);
    }
    if (data.containsKey('state_json')) {
      context.handle(
        _stateJsonMeta,
        stateJson.isAcceptableOrUnknown(data['state_json']!, _stateJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_stateJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {saveSlotId, puzzleId};
  @override
  PuzzleState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PuzzleState(
      saveSlotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}save_slot_id'],
      )!,
      puzzleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}puzzle_id'],
      )!,
      stateJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state_json'],
      )!,
    );
  }

  @override
  $PuzzleStatesTable createAlias(String alias) {
    return $PuzzleStatesTable(attachedDatabase, alias);
  }
}

class PuzzleState extends DataClass implements Insertable<PuzzleState> {
  final String saveSlotId;
  final String puzzleId;
  final String stateJson;
  const PuzzleState({
    required this.saveSlotId,
    required this.puzzleId,
    required this.stateJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['save_slot_id'] = Variable<String>(saveSlotId);
    map['puzzle_id'] = Variable<String>(puzzleId);
    map['state_json'] = Variable<String>(stateJson);
    return map;
  }

  PuzzleStatesCompanion toCompanion(bool nullToAbsent) {
    return PuzzleStatesCompanion(
      saveSlotId: Value(saveSlotId),
      puzzleId: Value(puzzleId),
      stateJson: Value(stateJson),
    );
  }

  factory PuzzleState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PuzzleState(
      saveSlotId: serializer.fromJson<String>(json['saveSlotId']),
      puzzleId: serializer.fromJson<String>(json['puzzleId']),
      stateJson: serializer.fromJson<String>(json['stateJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'saveSlotId': serializer.toJson<String>(saveSlotId),
      'puzzleId': serializer.toJson<String>(puzzleId),
      'stateJson': serializer.toJson<String>(stateJson),
    };
  }

  PuzzleState copyWith({
    String? saveSlotId,
    String? puzzleId,
    String? stateJson,
  }) => PuzzleState(
    saveSlotId: saveSlotId ?? this.saveSlotId,
    puzzleId: puzzleId ?? this.puzzleId,
    stateJson: stateJson ?? this.stateJson,
  );
  PuzzleState copyWithCompanion(PuzzleStatesCompanion data) {
    return PuzzleState(
      saveSlotId: data.saveSlotId.present
          ? data.saveSlotId.value
          : this.saveSlotId,
      puzzleId: data.puzzleId.present ? data.puzzleId.value : this.puzzleId,
      stateJson: data.stateJson.present ? data.stateJson.value : this.stateJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PuzzleState(')
          ..write('saveSlotId: $saveSlotId, ')
          ..write('puzzleId: $puzzleId, ')
          ..write('stateJson: $stateJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(saveSlotId, puzzleId, stateJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PuzzleState &&
          other.saveSlotId == this.saveSlotId &&
          other.puzzleId == this.puzzleId &&
          other.stateJson == this.stateJson);
}

class PuzzleStatesCompanion extends UpdateCompanion<PuzzleState> {
  final Value<String> saveSlotId;
  final Value<String> puzzleId;
  final Value<String> stateJson;
  final Value<int> rowid;
  const PuzzleStatesCompanion({
    this.saveSlotId = const Value.absent(),
    this.puzzleId = const Value.absent(),
    this.stateJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PuzzleStatesCompanion.insert({
    required String saveSlotId,
    required String puzzleId,
    required String stateJson,
    this.rowid = const Value.absent(),
  }) : saveSlotId = Value(saveSlotId),
       puzzleId = Value(puzzleId),
       stateJson = Value(stateJson);
  static Insertable<PuzzleState> custom({
    Expression<String>? saveSlotId,
    Expression<String>? puzzleId,
    Expression<String>? stateJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (saveSlotId != null) 'save_slot_id': saveSlotId,
      if (puzzleId != null) 'puzzle_id': puzzleId,
      if (stateJson != null) 'state_json': stateJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PuzzleStatesCompanion copyWith({
    Value<String>? saveSlotId,
    Value<String>? puzzleId,
    Value<String>? stateJson,
    Value<int>? rowid,
  }) {
    return PuzzleStatesCompanion(
      saveSlotId: saveSlotId ?? this.saveSlotId,
      puzzleId: puzzleId ?? this.puzzleId,
      stateJson: stateJson ?? this.stateJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (saveSlotId.present) {
      map['save_slot_id'] = Variable<String>(saveSlotId.value);
    }
    if (puzzleId.present) {
      map['puzzle_id'] = Variable<String>(puzzleId.value);
    }
    if (stateJson.present) {
      map['state_json'] = Variable<String>(stateJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PuzzleStatesCompanion(')
          ..write('saveSlotId: $saveSlotId, ')
          ..write('puzzleId: $puzzleId, ')
          ..write('stateJson: $stateJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CollectedItemsTable extends CollectedItems
    with TableInfo<$CollectedItemsTable, CollectedItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectedItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _saveSlotIdMeta = const VerificationMeta(
    'saveSlotId',
  );
  @override
  late final GeneratedColumn<String> saveSlotId = GeneratedColumn<String>(
    'save_slot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [saveSlotId, itemId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collected_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollectedItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('save_slot_id')) {
      context.handle(
        _saveSlotIdMeta,
        saveSlotId.isAcceptableOrUnknown(
          data['save_slot_id']!,
          _saveSlotIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_saveSlotIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {saveSlotId, itemId};
  @override
  CollectedItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectedItem(
      saveSlotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}save_slot_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
    );
  }

  @override
  $CollectedItemsTable createAlias(String alias) {
    return $CollectedItemsTable(attachedDatabase, alias);
  }
}

class CollectedItem extends DataClass implements Insertable<CollectedItem> {
  final String saveSlotId;
  final String itemId;
  const CollectedItem({required this.saveSlotId, required this.itemId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['save_slot_id'] = Variable<String>(saveSlotId);
    map['item_id'] = Variable<String>(itemId);
    return map;
  }

  CollectedItemsCompanion toCompanion(bool nullToAbsent) {
    return CollectedItemsCompanion(
      saveSlotId: Value(saveSlotId),
      itemId: Value(itemId),
    );
  }

  factory CollectedItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectedItem(
      saveSlotId: serializer.fromJson<String>(json['saveSlotId']),
      itemId: serializer.fromJson<String>(json['itemId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'saveSlotId': serializer.toJson<String>(saveSlotId),
      'itemId': serializer.toJson<String>(itemId),
    };
  }

  CollectedItem copyWith({String? saveSlotId, String? itemId}) => CollectedItem(
    saveSlotId: saveSlotId ?? this.saveSlotId,
    itemId: itemId ?? this.itemId,
  );
  CollectedItem copyWithCompanion(CollectedItemsCompanion data) {
    return CollectedItem(
      saveSlotId: data.saveSlotId.present
          ? data.saveSlotId.value
          : this.saveSlotId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectedItem(')
          ..write('saveSlotId: $saveSlotId, ')
          ..write('itemId: $itemId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(saveSlotId, itemId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectedItem &&
          other.saveSlotId == this.saveSlotId &&
          other.itemId == this.itemId);
}

class CollectedItemsCompanion extends UpdateCompanion<CollectedItem> {
  final Value<String> saveSlotId;
  final Value<String> itemId;
  final Value<int> rowid;
  const CollectedItemsCompanion({
    this.saveSlotId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectedItemsCompanion.insert({
    required String saveSlotId,
    required String itemId,
    this.rowid = const Value.absent(),
  }) : saveSlotId = Value(saveSlotId),
       itemId = Value(itemId);
  static Insertable<CollectedItem> custom({
    Expression<String>? saveSlotId,
    Expression<String>? itemId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (saveSlotId != null) 'save_slot_id': saveSlotId,
      if (itemId != null) 'item_id': itemId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectedItemsCompanion copyWith({
    Value<String>? saveSlotId,
    Value<String>? itemId,
    Value<int>? rowid,
  }) {
    return CollectedItemsCompanion(
      saveSlotId: saveSlotId ?? this.saveSlotId,
      itemId: itemId ?? this.itemId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (saveSlotId.present) {
      map['save_slot_id'] = Variable<String>(saveSlotId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectedItemsCompanion(')
          ..write('saveSlotId: $saveSlotId, ')
          ..write('itemId: $itemId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConsumedItemsTable extends ConsumedItems
    with TableInfo<$ConsumedItemsTable, ConsumedItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConsumedItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _saveSlotIdMeta = const VerificationMeta(
    'saveSlotId',
  );
  @override
  late final GeneratedColumn<String> saveSlotId = GeneratedColumn<String>(
    'save_slot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [saveSlotId, itemId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'consumed_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConsumedItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('save_slot_id')) {
      context.handle(
        _saveSlotIdMeta,
        saveSlotId.isAcceptableOrUnknown(
          data['save_slot_id']!,
          _saveSlotIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_saveSlotIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {saveSlotId, itemId};
  @override
  ConsumedItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConsumedItem(
      saveSlotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}save_slot_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
    );
  }

  @override
  $ConsumedItemsTable createAlias(String alias) {
    return $ConsumedItemsTable(attachedDatabase, alias);
  }
}

class ConsumedItem extends DataClass implements Insertable<ConsumedItem> {
  final String saveSlotId;
  final String itemId;
  const ConsumedItem({required this.saveSlotId, required this.itemId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['save_slot_id'] = Variable<String>(saveSlotId);
    map['item_id'] = Variable<String>(itemId);
    return map;
  }

  ConsumedItemsCompanion toCompanion(bool nullToAbsent) {
    return ConsumedItemsCompanion(
      saveSlotId: Value(saveSlotId),
      itemId: Value(itemId),
    );
  }

  factory ConsumedItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConsumedItem(
      saveSlotId: serializer.fromJson<String>(json['saveSlotId']),
      itemId: serializer.fromJson<String>(json['itemId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'saveSlotId': serializer.toJson<String>(saveSlotId),
      'itemId': serializer.toJson<String>(itemId),
    };
  }

  ConsumedItem copyWith({String? saveSlotId, String? itemId}) => ConsumedItem(
    saveSlotId: saveSlotId ?? this.saveSlotId,
    itemId: itemId ?? this.itemId,
  );
  ConsumedItem copyWithCompanion(ConsumedItemsCompanion data) {
    return ConsumedItem(
      saveSlotId: data.saveSlotId.present
          ? data.saveSlotId.value
          : this.saveSlotId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConsumedItem(')
          ..write('saveSlotId: $saveSlotId, ')
          ..write('itemId: $itemId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(saveSlotId, itemId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConsumedItem &&
          other.saveSlotId == this.saveSlotId &&
          other.itemId == this.itemId);
}

class ConsumedItemsCompanion extends UpdateCompanion<ConsumedItem> {
  final Value<String> saveSlotId;
  final Value<String> itemId;
  final Value<int> rowid;
  const ConsumedItemsCompanion({
    this.saveSlotId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConsumedItemsCompanion.insert({
    required String saveSlotId,
    required String itemId,
    this.rowid = const Value.absent(),
  }) : saveSlotId = Value(saveSlotId),
       itemId = Value(itemId);
  static Insertable<ConsumedItem> custom({
    Expression<String>? saveSlotId,
    Expression<String>? itemId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (saveSlotId != null) 'save_slot_id': saveSlotId,
      if (itemId != null) 'item_id': itemId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConsumedItemsCompanion copyWith({
    Value<String>? saveSlotId,
    Value<String>? itemId,
    Value<int>? rowid,
  }) {
    return ConsumedItemsCompanion(
      saveSlotId: saveSlotId ?? this.saveSlotId,
      itemId: itemId ?? this.itemId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (saveSlotId.present) {
      map['save_slot_id'] = Variable<String>(saveSlotId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConsumedItemsCompanion(')
          ..write('saveSlotId: $saveSlotId, ')
          ..write('itemId: $itemId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DiscoveredCluesTable extends DiscoveredClues
    with TableInfo<$DiscoveredCluesTable, DiscoveredClue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiscoveredCluesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _saveSlotIdMeta = const VerificationMeta(
    'saveSlotId',
  );
  @override
  late final GeneratedColumn<String> saveSlotId = GeneratedColumn<String>(
    'save_slot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clueIdMeta = const VerificationMeta('clueId');
  @override
  late final GeneratedColumn<String> clueId = GeneratedColumn<String>(
    'clue_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [saveSlotId, clueId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'discovered_clues';
  @override
  VerificationContext validateIntegrity(
    Insertable<DiscoveredClue> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('save_slot_id')) {
      context.handle(
        _saveSlotIdMeta,
        saveSlotId.isAcceptableOrUnknown(
          data['save_slot_id']!,
          _saveSlotIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_saveSlotIdMeta);
    }
    if (data.containsKey('clue_id')) {
      context.handle(
        _clueIdMeta,
        clueId.isAcceptableOrUnknown(data['clue_id']!, _clueIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clueIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {saveSlotId, clueId};
  @override
  DiscoveredClue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiscoveredClue(
      saveSlotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}save_slot_id'],
      )!,
      clueId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clue_id'],
      )!,
    );
  }

  @override
  $DiscoveredCluesTable createAlias(String alias) {
    return $DiscoveredCluesTable(attachedDatabase, alias);
  }
}

class DiscoveredClue extends DataClass implements Insertable<DiscoveredClue> {
  final String saveSlotId;
  final String clueId;
  const DiscoveredClue({required this.saveSlotId, required this.clueId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['save_slot_id'] = Variable<String>(saveSlotId);
    map['clue_id'] = Variable<String>(clueId);
    return map;
  }

  DiscoveredCluesCompanion toCompanion(bool nullToAbsent) {
    return DiscoveredCluesCompanion(
      saveSlotId: Value(saveSlotId),
      clueId: Value(clueId),
    );
  }

  factory DiscoveredClue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiscoveredClue(
      saveSlotId: serializer.fromJson<String>(json['saveSlotId']),
      clueId: serializer.fromJson<String>(json['clueId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'saveSlotId': serializer.toJson<String>(saveSlotId),
      'clueId': serializer.toJson<String>(clueId),
    };
  }

  DiscoveredClue copyWith({String? saveSlotId, String? clueId}) =>
      DiscoveredClue(
        saveSlotId: saveSlotId ?? this.saveSlotId,
        clueId: clueId ?? this.clueId,
      );
  DiscoveredClue copyWithCompanion(DiscoveredCluesCompanion data) {
    return DiscoveredClue(
      saveSlotId: data.saveSlotId.present
          ? data.saveSlotId.value
          : this.saveSlotId,
      clueId: data.clueId.present ? data.clueId.value : this.clueId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiscoveredClue(')
          ..write('saveSlotId: $saveSlotId, ')
          ..write('clueId: $clueId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(saveSlotId, clueId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiscoveredClue &&
          other.saveSlotId == this.saveSlotId &&
          other.clueId == this.clueId);
}

class DiscoveredCluesCompanion extends UpdateCompanion<DiscoveredClue> {
  final Value<String> saveSlotId;
  final Value<String> clueId;
  final Value<int> rowid;
  const DiscoveredCluesCompanion({
    this.saveSlotId = const Value.absent(),
    this.clueId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DiscoveredCluesCompanion.insert({
    required String saveSlotId,
    required String clueId,
    this.rowid = const Value.absent(),
  }) : saveSlotId = Value(saveSlotId),
       clueId = Value(clueId);
  static Insertable<DiscoveredClue> custom({
    Expression<String>? saveSlotId,
    Expression<String>? clueId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (saveSlotId != null) 'save_slot_id': saveSlotId,
      if (clueId != null) 'clue_id': clueId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DiscoveredCluesCompanion copyWith({
    Value<String>? saveSlotId,
    Value<String>? clueId,
    Value<int>? rowid,
  }) {
    return DiscoveredCluesCompanion(
      saveSlotId: saveSlotId ?? this.saveSlotId,
      clueId: clueId ?? this.clueId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (saveSlotId.present) {
      map['save_slot_id'] = Variable<String>(saveSlotId.value);
    }
    if (clueId.present) {
      map['clue_id'] = Variable<String>(clueId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiscoveredCluesCompanion(')
          ..write('saveSlotId: $saveSlotId, ')
          ..write('clueId: $clueId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CompletedChaptersTable extends CompletedChapters
    with TableInfo<$CompletedChaptersTable, CompletedChapter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompletedChaptersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _saveSlotIdMeta = const VerificationMeta(
    'saveSlotId',
  );
  @override
  late final GeneratedColumn<String> saveSlotId = GeneratedColumn<String>(
    'save_slot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMsMeta = const VerificationMeta(
    'completedAtMs',
  );
  @override
  late final GeneratedColumn<int> completedAtMs = GeneratedColumn<int>(
    'completed_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [saveSlotId, chapterId, completedAtMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'completed_chapters';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompletedChapter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('save_slot_id')) {
      context.handle(
        _saveSlotIdMeta,
        saveSlotId.isAcceptableOrUnknown(
          data['save_slot_id']!,
          _saveSlotIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_saveSlotIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('completed_at_ms')) {
      context.handle(
        _completedAtMsMeta,
        completedAtMs.isAcceptableOrUnknown(
          data['completed_at_ms']!,
          _completedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {saveSlotId, chapterId};
  @override
  CompletedChapter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompletedChapter(
      saveSlotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}save_slot_id'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      )!,
      completedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at_ms'],
      )!,
    );
  }

  @override
  $CompletedChaptersTable createAlias(String alias) {
    return $CompletedChaptersTable(attachedDatabase, alias);
  }
}

class CompletedChapter extends DataClass
    implements Insertable<CompletedChapter> {
  final String saveSlotId;
  final String chapterId;
  final int completedAtMs;
  const CompletedChapter({
    required this.saveSlotId,
    required this.chapterId,
    required this.completedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['save_slot_id'] = Variable<String>(saveSlotId);
    map['chapter_id'] = Variable<String>(chapterId);
    map['completed_at_ms'] = Variable<int>(completedAtMs);
    return map;
  }

  CompletedChaptersCompanion toCompanion(bool nullToAbsent) {
    return CompletedChaptersCompanion(
      saveSlotId: Value(saveSlotId),
      chapterId: Value(chapterId),
      completedAtMs: Value(completedAtMs),
    );
  }

  factory CompletedChapter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompletedChapter(
      saveSlotId: serializer.fromJson<String>(json['saveSlotId']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      completedAtMs: serializer.fromJson<int>(json['completedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'saveSlotId': serializer.toJson<String>(saveSlotId),
      'chapterId': serializer.toJson<String>(chapterId),
      'completedAtMs': serializer.toJson<int>(completedAtMs),
    };
  }

  CompletedChapter copyWith({
    String? saveSlotId,
    String? chapterId,
    int? completedAtMs,
  }) => CompletedChapter(
    saveSlotId: saveSlotId ?? this.saveSlotId,
    chapterId: chapterId ?? this.chapterId,
    completedAtMs: completedAtMs ?? this.completedAtMs,
  );
  CompletedChapter copyWithCompanion(CompletedChaptersCompanion data) {
    return CompletedChapter(
      saveSlotId: data.saveSlotId.present
          ? data.saveSlotId.value
          : this.saveSlotId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      completedAtMs: data.completedAtMs.present
          ? data.completedAtMs.value
          : this.completedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompletedChapter(')
          ..write('saveSlotId: $saveSlotId, ')
          ..write('chapterId: $chapterId, ')
          ..write('completedAtMs: $completedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(saveSlotId, chapterId, completedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompletedChapter &&
          other.saveSlotId == this.saveSlotId &&
          other.chapterId == this.chapterId &&
          other.completedAtMs == this.completedAtMs);
}

class CompletedChaptersCompanion extends UpdateCompanion<CompletedChapter> {
  final Value<String> saveSlotId;
  final Value<String> chapterId;
  final Value<int> completedAtMs;
  final Value<int> rowid;
  const CompletedChaptersCompanion({
    this.saveSlotId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.completedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompletedChaptersCompanion.insert({
    required String saveSlotId,
    required String chapterId,
    required int completedAtMs,
    this.rowid = const Value.absent(),
  }) : saveSlotId = Value(saveSlotId),
       chapterId = Value(chapterId),
       completedAtMs = Value(completedAtMs);
  static Insertable<CompletedChapter> custom({
    Expression<String>? saveSlotId,
    Expression<String>? chapterId,
    Expression<int>? completedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (saveSlotId != null) 'save_slot_id': saveSlotId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (completedAtMs != null) 'completed_at_ms': completedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompletedChaptersCompanion copyWith({
    Value<String>? saveSlotId,
    Value<String>? chapterId,
    Value<int>? completedAtMs,
    Value<int>? rowid,
  }) {
    return CompletedChaptersCompanion(
      saveSlotId: saveSlotId ?? this.saveSlotId,
      chapterId: chapterId ?? this.chapterId,
      completedAtMs: completedAtMs ?? this.completedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (saveSlotId.present) {
      map['save_slot_id'] = Variable<String>(saveSlotId.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (completedAtMs.present) {
      map['completed_at_ms'] = Variable<int>(completedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompletedChaptersCompanion(')
          ..write('saveSlotId: $saveSlotId, ')
          ..write('chapterId: $chapterId, ')
          ..write('completedAtMs: $completedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RevealedHintsTable extends RevealedHints
    with TableInfo<$RevealedHintsTable, RevealedHint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RevealedHintsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _saveSlotIdMeta = const VerificationMeta(
    'saveSlotId',
  );
  @override
  late final GeneratedColumn<String> saveSlotId = GeneratedColumn<String>(
    'save_slot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _puzzleIdMeta = const VerificationMeta(
    'puzzleId',
  );
  @override
  late final GeneratedColumn<String> puzzleId = GeneratedColumn<String>(
    'puzzle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxLevelMeta = const VerificationMeta(
    'maxLevel',
  );
  @override
  late final GeneratedColumn<int> maxLevel = GeneratedColumn<int>(
    'max_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [saveSlotId, puzzleId, maxLevel];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'revealed_hints';
  @override
  VerificationContext validateIntegrity(
    Insertable<RevealedHint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('save_slot_id')) {
      context.handle(
        _saveSlotIdMeta,
        saveSlotId.isAcceptableOrUnknown(
          data['save_slot_id']!,
          _saveSlotIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_saveSlotIdMeta);
    }
    if (data.containsKey('puzzle_id')) {
      context.handle(
        _puzzleIdMeta,
        puzzleId.isAcceptableOrUnknown(data['puzzle_id']!, _puzzleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_puzzleIdMeta);
    }
    if (data.containsKey('max_level')) {
      context.handle(
        _maxLevelMeta,
        maxLevel.isAcceptableOrUnknown(data['max_level']!, _maxLevelMeta),
      );
    } else if (isInserting) {
      context.missing(_maxLevelMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {saveSlotId, puzzleId};
  @override
  RevealedHint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RevealedHint(
      saveSlotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}save_slot_id'],
      )!,
      puzzleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}puzzle_id'],
      )!,
      maxLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_level'],
      )!,
    );
  }

  @override
  $RevealedHintsTable createAlias(String alias) {
    return $RevealedHintsTable(attachedDatabase, alias);
  }
}

class RevealedHint extends DataClass implements Insertable<RevealedHint> {
  final String saveSlotId;
  final String puzzleId;
  final int maxLevel;
  const RevealedHint({
    required this.saveSlotId,
    required this.puzzleId,
    required this.maxLevel,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['save_slot_id'] = Variable<String>(saveSlotId);
    map['puzzle_id'] = Variable<String>(puzzleId);
    map['max_level'] = Variable<int>(maxLevel);
    return map;
  }

  RevealedHintsCompanion toCompanion(bool nullToAbsent) {
    return RevealedHintsCompanion(
      saveSlotId: Value(saveSlotId),
      puzzleId: Value(puzzleId),
      maxLevel: Value(maxLevel),
    );
  }

  factory RevealedHint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RevealedHint(
      saveSlotId: serializer.fromJson<String>(json['saveSlotId']),
      puzzleId: serializer.fromJson<String>(json['puzzleId']),
      maxLevel: serializer.fromJson<int>(json['maxLevel']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'saveSlotId': serializer.toJson<String>(saveSlotId),
      'puzzleId': serializer.toJson<String>(puzzleId),
      'maxLevel': serializer.toJson<int>(maxLevel),
    };
  }

  RevealedHint copyWith({
    String? saveSlotId,
    String? puzzleId,
    int? maxLevel,
  }) => RevealedHint(
    saveSlotId: saveSlotId ?? this.saveSlotId,
    puzzleId: puzzleId ?? this.puzzleId,
    maxLevel: maxLevel ?? this.maxLevel,
  );
  RevealedHint copyWithCompanion(RevealedHintsCompanion data) {
    return RevealedHint(
      saveSlotId: data.saveSlotId.present
          ? data.saveSlotId.value
          : this.saveSlotId,
      puzzleId: data.puzzleId.present ? data.puzzleId.value : this.puzzleId,
      maxLevel: data.maxLevel.present ? data.maxLevel.value : this.maxLevel,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RevealedHint(')
          ..write('saveSlotId: $saveSlotId, ')
          ..write('puzzleId: $puzzleId, ')
          ..write('maxLevel: $maxLevel')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(saveSlotId, puzzleId, maxLevel);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RevealedHint &&
          other.saveSlotId == this.saveSlotId &&
          other.puzzleId == this.puzzleId &&
          other.maxLevel == this.maxLevel);
}

class RevealedHintsCompanion extends UpdateCompanion<RevealedHint> {
  final Value<String> saveSlotId;
  final Value<String> puzzleId;
  final Value<int> maxLevel;
  final Value<int> rowid;
  const RevealedHintsCompanion({
    this.saveSlotId = const Value.absent(),
    this.puzzleId = const Value.absent(),
    this.maxLevel = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RevealedHintsCompanion.insert({
    required String saveSlotId,
    required String puzzleId,
    required int maxLevel,
    this.rowid = const Value.absent(),
  }) : saveSlotId = Value(saveSlotId),
       puzzleId = Value(puzzleId),
       maxLevel = Value(maxLevel);
  static Insertable<RevealedHint> custom({
    Expression<String>? saveSlotId,
    Expression<String>? puzzleId,
    Expression<int>? maxLevel,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (saveSlotId != null) 'save_slot_id': saveSlotId,
      if (puzzleId != null) 'puzzle_id': puzzleId,
      if (maxLevel != null) 'max_level': maxLevel,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RevealedHintsCompanion copyWith({
    Value<String>? saveSlotId,
    Value<String>? puzzleId,
    Value<int>? maxLevel,
    Value<int>? rowid,
  }) {
    return RevealedHintsCompanion(
      saveSlotId: saveSlotId ?? this.saveSlotId,
      puzzleId: puzzleId ?? this.puzzleId,
      maxLevel: maxLevel ?? this.maxLevel,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (saveSlotId.present) {
      map['save_slot_id'] = Variable<String>(saveSlotId.value);
    }
    if (puzzleId.present) {
      map['puzzle_id'] = Variable<String>(puzzleId.value);
    }
    if (maxLevel.present) {
      map['max_level'] = Variable<int>(maxLevel.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RevealedHintsCompanion(')
          ..write('saveSlotId: $saveSlotId, ')
          ..write('puzzleId: $puzzleId, ')
          ..write('maxLevel: $maxLevel, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SaveSlotsTable saveSlots = $SaveSlotsTable(this);
  late final $UnlockedRoomsTable unlockedRooms = $UnlockedRoomsTable(this);
  late final $SolvedPuzzlesTable solvedPuzzles = $SolvedPuzzlesTable(this);
  late final $PuzzleStatesTable puzzleStates = $PuzzleStatesTable(this);
  late final $CollectedItemsTable collectedItems = $CollectedItemsTable(this);
  late final $ConsumedItemsTable consumedItems = $ConsumedItemsTable(this);
  late final $DiscoveredCluesTable discoveredClues = $DiscoveredCluesTable(
    this,
  );
  late final $CompletedChaptersTable completedChapters =
      $CompletedChaptersTable(this);
  late final $RevealedHintsTable revealedHints = $RevealedHintsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    saveSlots,
    unlockedRooms,
    solvedPuzzles,
    puzzleStates,
    collectedItems,
    consumedItems,
    discoveredClues,
    completedChapters,
    revealedHints,
  ];
}

typedef $$SaveSlotsTableCreateCompanionBuilder = SaveSlotsCompanion Function({
  required String id,
  required int schemaVersion,
  Value<String?> currentRoomId,
  Value<int> playTimeMs,
  required int updatedAtMs,
  Value<int> rowid,
});
typedef $$SaveSlotsTableUpdateCompanionBuilder = SaveSlotsCompanion Function({
  Value<String> id,
  Value<int> schemaVersion,
  Value<String?> currentRoomId,
  Value<int> playTimeMs,
  Value<int> updatedAtMs,
  Value<int> rowid,
});

class $$SaveSlotsTableFilterComposer
    extends Composer<_$AppDatabase, $SaveSlotsTable> {
  $$SaveSlotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentRoomId => $composableBuilder(
    column: $table.currentRoomId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playTimeMs => $composableBuilder(
    column: $table.playTimeMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SaveSlotsTableOrderingComposer
    extends Composer<_$AppDatabase, $SaveSlotsTable> {
  $$SaveSlotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentRoomId => $composableBuilder(
    column: $table.currentRoomId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playTimeMs => $composableBuilder(
    column: $table.playTimeMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SaveSlotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaveSlotsTable> {
  $$SaveSlotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentRoomId => $composableBuilder(
    column: $table.currentRoomId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get playTimeMs => $composableBuilder(
    column: $table.playTimeMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );
}

class $$SaveSlotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SaveSlotsTable,
          SaveSlot,
          $$SaveSlotsTableFilterComposer,
          $$SaveSlotsTableOrderingComposer,
          $$SaveSlotsTableAnnotationComposer,
          $$SaveSlotsTableCreateCompanionBuilder,
          $$SaveSlotsTableUpdateCompanionBuilder,
          (SaveSlot, BaseReferences<_$AppDatabase, $SaveSlotsTable, SaveSlot>),
          SaveSlot,
          PrefetchHooks Function()
        > {
  $$SaveSlotsTableTableManager(_$AppDatabase db, $SaveSlotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaveSlotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaveSlotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaveSlotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<String?> currentRoomId = const Value.absent(),
                Value<int> playTimeMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SaveSlotsCompanion(
                id: id,
                schemaVersion: schemaVersion,
                currentRoomId: currentRoomId,
                playTimeMs: playTimeMs,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int schemaVersion,
                Value<String?> currentRoomId = const Value.absent(),
                Value<int> playTimeMs = const Value.absent(),
                required int updatedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => SaveSlotsCompanion.insert(
                id: id,
                schemaVersion: schemaVersion,
                currentRoomId: currentRoomId,
                playTimeMs: playTimeMs,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SaveSlotsTable, SaveSlot>(table),
                  BaseReferences<_$AppDatabase, $SaveSlotsTable, SaveSlot>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SaveSlotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SaveSlotsTable,
      SaveSlot,
      $$SaveSlotsTableFilterComposer,
      $$SaveSlotsTableOrderingComposer,
      $$SaveSlotsTableAnnotationComposer,
      $$SaveSlotsTableCreateCompanionBuilder,
      $$SaveSlotsTableUpdateCompanionBuilder,
      (SaveSlot, BaseReferences<_$AppDatabase, $SaveSlotsTable, SaveSlot>),
      SaveSlot,
      PrefetchHooks Function()
    >;
typedef $$UnlockedRoomsTableCreateCompanionBuilder =
    UnlockedRoomsCompanion Function({
      required String saveSlotId,
      required String roomId,
      Value<int> rowid,
    });
typedef $$UnlockedRoomsTableUpdateCompanionBuilder =
    UnlockedRoomsCompanion Function({
      Value<String> saveSlotId,
      Value<String> roomId,
      Value<int> rowid,
    });

class $$UnlockedRoomsTableFilterComposer
    extends Composer<_$AppDatabase, $UnlockedRoomsTable> {
  $$UnlockedRoomsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get saveSlotId => $composableBuilder(
    column: $table.saveSlotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UnlockedRoomsTableOrderingComposer
    extends Composer<_$AppDatabase, $UnlockedRoomsTable> {
  $$UnlockedRoomsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get saveSlotId => $composableBuilder(
    column: $table.saveSlotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UnlockedRoomsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UnlockedRoomsTable> {
  $$UnlockedRoomsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get saveSlotId => $composableBuilder(
    column: $table.saveSlotId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);
}

class $$UnlockedRoomsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UnlockedRoomsTable,
          UnlockedRoom,
          $$UnlockedRoomsTableFilterComposer,
          $$UnlockedRoomsTableOrderingComposer,
          $$UnlockedRoomsTableAnnotationComposer,
          $$UnlockedRoomsTableCreateCompanionBuilder,
          $$UnlockedRoomsTableUpdateCompanionBuilder,
          (
            UnlockedRoom,
            BaseReferences<_$AppDatabase, $UnlockedRoomsTable, UnlockedRoom>,
          ),
          UnlockedRoom,
          PrefetchHooks Function()
        > {
  $$UnlockedRoomsTableTableManager(_$AppDatabase db, $UnlockedRoomsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnlockedRoomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UnlockedRoomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UnlockedRoomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> saveSlotId = const Value.absent(),
                Value<String> roomId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UnlockedRoomsCompanion(
                saveSlotId: saveSlotId,
                roomId: roomId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String saveSlotId,
                required String roomId,
                Value<int> rowid = const Value.absent(),
              }) => UnlockedRoomsCompanion.insert(
                saveSlotId: saveSlotId,
                roomId: roomId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UnlockedRoomsTable, UnlockedRoom>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $UnlockedRoomsTable,
                    UnlockedRoom
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UnlockedRoomsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UnlockedRoomsTable,
      UnlockedRoom,
      $$UnlockedRoomsTableFilterComposer,
      $$UnlockedRoomsTableOrderingComposer,
      $$UnlockedRoomsTableAnnotationComposer,
      $$UnlockedRoomsTableCreateCompanionBuilder,
      $$UnlockedRoomsTableUpdateCompanionBuilder,
      (
        UnlockedRoom,
        BaseReferences<_$AppDatabase, $UnlockedRoomsTable, UnlockedRoom>,
      ),
      UnlockedRoom,
      PrefetchHooks Function()
    >;
typedef $$SolvedPuzzlesTableCreateCompanionBuilder =
    SolvedPuzzlesCompanion Function({
      required String saveSlotId,
      required String puzzleId,
      required int solvedAtMs,
      Value<int> rowid,
    });
typedef $$SolvedPuzzlesTableUpdateCompanionBuilder =
    SolvedPuzzlesCompanion Function({
      Value<String> saveSlotId,
      Value<String> puzzleId,
      Value<int> solvedAtMs,
      Value<int> rowid,
    });

class $$SolvedPuzzlesTableFilterComposer
    extends Composer<_$AppDatabase, $SolvedPuzzlesTable> {
  $$SolvedPuzzlesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get saveSlotId => $composableBuilder(
    column: $table.saveSlotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get puzzleId => $composableBuilder(
    column: $table.puzzleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get solvedAtMs => $composableBuilder(
    column: $table.solvedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SolvedPuzzlesTableOrderingComposer
    extends Composer<_$AppDatabase, $SolvedPuzzlesTable> {
  $$SolvedPuzzlesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get saveSlotId => $composableBuilder(
    column: $table.saveSlotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get puzzleId => $composableBuilder(
    column: $table.puzzleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get solvedAtMs => $composableBuilder(
    column: $table.solvedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SolvedPuzzlesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SolvedPuzzlesTable> {
  $$SolvedPuzzlesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get saveSlotId => $composableBuilder(
    column: $table.saveSlotId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get puzzleId =>
      $composableBuilder(column: $table.puzzleId, builder: (column) => column);

  GeneratedColumn<int> get solvedAtMs => $composableBuilder(
    column: $table.solvedAtMs,
    builder: (column) => column,
  );
}

class $$SolvedPuzzlesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SolvedPuzzlesTable,
          SolvedPuzzle,
          $$SolvedPuzzlesTableFilterComposer,
          $$SolvedPuzzlesTableOrderingComposer,
          $$SolvedPuzzlesTableAnnotationComposer,
          $$SolvedPuzzlesTableCreateCompanionBuilder,
          $$SolvedPuzzlesTableUpdateCompanionBuilder,
          (
            SolvedPuzzle,
            BaseReferences<_$AppDatabase, $SolvedPuzzlesTable, SolvedPuzzle>,
          ),
          SolvedPuzzle,
          PrefetchHooks Function()
        > {
  $$SolvedPuzzlesTableTableManager(_$AppDatabase db, $SolvedPuzzlesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SolvedPuzzlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SolvedPuzzlesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SolvedPuzzlesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> saveSlotId = const Value.absent(),
                Value<String> puzzleId = const Value.absent(),
                Value<int> solvedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SolvedPuzzlesCompanion(
                saveSlotId: saveSlotId,
                puzzleId: puzzleId,
                solvedAtMs: solvedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String saveSlotId,
                required String puzzleId,
                required int solvedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => SolvedPuzzlesCompanion.insert(
                saveSlotId: saveSlotId,
                puzzleId: puzzleId,
                solvedAtMs: solvedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SolvedPuzzlesTable, SolvedPuzzle>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SolvedPuzzlesTable,
                    SolvedPuzzle
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SolvedPuzzlesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SolvedPuzzlesTable,
      SolvedPuzzle,
      $$SolvedPuzzlesTableFilterComposer,
      $$SolvedPuzzlesTableOrderingComposer,
      $$SolvedPuzzlesTableAnnotationComposer,
      $$SolvedPuzzlesTableCreateCompanionBuilder,
      $$SolvedPuzzlesTableUpdateCompanionBuilder,
      (
        SolvedPuzzle,
        BaseReferences<_$AppDatabase, $SolvedPuzzlesTable, SolvedPuzzle>,
      ),
      SolvedPuzzle,
      PrefetchHooks Function()
    >;
typedef $$PuzzleStatesTableCreateCompanionBuilder =
    PuzzleStatesCompanion Function({
      required String saveSlotId,
      required String puzzleId,
      required String stateJson,
      Value<int> rowid,
    });
typedef $$PuzzleStatesTableUpdateCompanionBuilder =
    PuzzleStatesCompanion Function({
      Value<String> saveSlotId,
      Value<String> puzzleId,
      Value<String> stateJson,
      Value<int> rowid,
    });

class $$PuzzleStatesTableFilterComposer
    extends Composer<_$AppDatabase, $PuzzleStatesTable> {
  $$PuzzleStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get saveSlotId => $composableBuilder(
    column: $table.saveSlotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get puzzleId => $composableBuilder(
    column: $table.puzzleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stateJson => $composableBuilder(
    column: $table.stateJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PuzzleStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $PuzzleStatesTable> {
  $$PuzzleStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get saveSlotId => $composableBuilder(
    column: $table.saveSlotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get puzzleId => $composableBuilder(
    column: $table.puzzleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stateJson => $composableBuilder(
    column: $table.stateJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PuzzleStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PuzzleStatesTable> {
  $$PuzzleStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get saveSlotId => $composableBuilder(
    column: $table.saveSlotId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get puzzleId =>
      $composableBuilder(column: $table.puzzleId, builder: (column) => column);

  GeneratedColumn<String> get stateJson =>
      $composableBuilder(column: $table.stateJson, builder: (column) => column);
}

class $$PuzzleStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PuzzleStatesTable,
          PuzzleState,
          $$PuzzleStatesTableFilterComposer,
          $$PuzzleStatesTableOrderingComposer,
          $$PuzzleStatesTableAnnotationComposer,
          $$PuzzleStatesTableCreateCompanionBuilder,
          $$PuzzleStatesTableUpdateCompanionBuilder,
          (
            PuzzleState,
            BaseReferences<_$AppDatabase, $PuzzleStatesTable, PuzzleState>,
          ),
          PuzzleState,
          PrefetchHooks Function()
        > {
  $$PuzzleStatesTableTableManager(_$AppDatabase db, $PuzzleStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PuzzleStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PuzzleStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PuzzleStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> saveSlotId = const Value.absent(),
                Value<String> puzzleId = const Value.absent(),
                Value<String> stateJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PuzzleStatesCompanion(
                saveSlotId: saveSlotId,
                puzzleId: puzzleId,
                stateJson: stateJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String saveSlotId,
                required String puzzleId,
                required String stateJson,
                Value<int> rowid = const Value.absent(),
              }) => PuzzleStatesCompanion.insert(
                saveSlotId: saveSlotId,
                puzzleId: puzzleId,
                stateJson: stateJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PuzzleStatesTable, PuzzleState>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PuzzleStatesTable,
                    PuzzleState
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PuzzleStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PuzzleStatesTable,
      PuzzleState,
      $$PuzzleStatesTableFilterComposer,
      $$PuzzleStatesTableOrderingComposer,
      $$PuzzleStatesTableAnnotationComposer,
      $$PuzzleStatesTableCreateCompanionBuilder,
      $$PuzzleStatesTableUpdateCompanionBuilder,
      (
        PuzzleState,
        BaseReferences<_$AppDatabase, $PuzzleStatesTable, PuzzleState>,
      ),
      PuzzleState,
      PrefetchHooks Function()
    >;
typedef $$CollectedItemsTableCreateCompanionBuilder =
    CollectedItemsCompanion Function({
      required String saveSlotId,
      required String itemId,
      Value<int> rowid,
    });
typedef $$CollectedItemsTableUpdateCompanionBuilder =
    CollectedItemsCompanion Function({
      Value<String> saveSlotId,
      Value<String> itemId,
      Value<int> rowid,
    });

class $$CollectedItemsTableFilterComposer
    extends Composer<_$AppDatabase, $CollectedItemsTable> {
  $$CollectedItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get saveSlotId => $composableBuilder(
    column: $table.saveSlotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CollectedItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectedItemsTable> {
  $$CollectedItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get saveSlotId => $composableBuilder(
    column: $table.saveSlotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CollectedItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectedItemsTable> {
  $$CollectedItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get saveSlotId => $composableBuilder(
    column: $table.saveSlotId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);
}

class $$CollectedItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectedItemsTable,
          CollectedItem,
          $$CollectedItemsTableFilterComposer,
          $$CollectedItemsTableOrderingComposer,
          $$CollectedItemsTableAnnotationComposer,
          $$CollectedItemsTableCreateCompanionBuilder,
          $$CollectedItemsTableUpdateCompanionBuilder,
          (
            CollectedItem,
            BaseReferences<_$AppDatabase, $CollectedItemsTable, CollectedItem>,
          ),
          CollectedItem,
          PrefetchHooks Function()
        > {
  $$CollectedItemsTableTableManager(
    _$AppDatabase db,
    $CollectedItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectedItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectedItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectedItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> saveSlotId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectedItemsCompanion(
                saveSlotId: saveSlotId,
                itemId: itemId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String saveSlotId,
                required String itemId,
                Value<int> rowid = const Value.absent(),
              }) => CollectedItemsCompanion.insert(
                saveSlotId: saveSlotId,
                itemId: itemId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CollectedItemsTable, CollectedItem>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CollectedItemsTable,
                    CollectedItem
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CollectedItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectedItemsTable,
      CollectedItem,
      $$CollectedItemsTableFilterComposer,
      $$CollectedItemsTableOrderingComposer,
      $$CollectedItemsTableAnnotationComposer,
      $$CollectedItemsTableCreateCompanionBuilder,
      $$CollectedItemsTableUpdateCompanionBuilder,
      (
        CollectedItem,
        BaseReferences<_$AppDatabase, $CollectedItemsTable, CollectedItem>,
      ),
      CollectedItem,
      PrefetchHooks Function()
    >;
typedef $$ConsumedItemsTableCreateCompanionBuilder =
    ConsumedItemsCompanion Function({
      required String saveSlotId,
      required String itemId,
      Value<int> rowid,
    });
typedef $$ConsumedItemsTableUpdateCompanionBuilder =
    ConsumedItemsCompanion Function({
      Value<String> saveSlotId,
      Value<String> itemId,
      Value<int> rowid,
    });

class $$ConsumedItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ConsumedItemsTable> {
  $$ConsumedItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get saveSlotId => $composableBuilder(
    column: $table.saveSlotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConsumedItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConsumedItemsTable> {
  $$ConsumedItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get saveSlotId => $composableBuilder(
    column: $table.saveSlotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConsumedItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConsumedItemsTable> {
  $$ConsumedItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get saveSlotId => $composableBuilder(
    column: $table.saveSlotId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);
}

class $$ConsumedItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConsumedItemsTable,
          ConsumedItem,
          $$ConsumedItemsTableFilterComposer,
          $$ConsumedItemsTableOrderingComposer,
          $$ConsumedItemsTableAnnotationComposer,
          $$ConsumedItemsTableCreateCompanionBuilder,
          $$ConsumedItemsTableUpdateCompanionBuilder,
          (
            ConsumedItem,
            BaseReferences<_$AppDatabase, $ConsumedItemsTable, ConsumedItem>,
          ),
          ConsumedItem,
          PrefetchHooks Function()
        > {
  $$ConsumedItemsTableTableManager(_$AppDatabase db, $ConsumedItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConsumedItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConsumedItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConsumedItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> saveSlotId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConsumedItemsCompanion(
                saveSlotId: saveSlotId,
                itemId: itemId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String saveSlotId,
                required String itemId,
                Value<int> rowid = const Value.absent(),
              }) => ConsumedItemsCompanion.insert(
                saveSlotId: saveSlotId,
                itemId: itemId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ConsumedItemsTable, ConsumedItem>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ConsumedItemsTable,
                    ConsumedItem
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConsumedItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConsumedItemsTable,
      ConsumedItem,
      $$ConsumedItemsTableFilterComposer,
      $$ConsumedItemsTableOrderingComposer,
      $$ConsumedItemsTableAnnotationComposer,
      $$ConsumedItemsTableCreateCompanionBuilder,
      $$ConsumedItemsTableUpdateCompanionBuilder,
      (
        ConsumedItem,
        BaseReferences<_$AppDatabase, $ConsumedItemsTable, ConsumedItem>,
      ),
      ConsumedItem,
      PrefetchHooks Function()
    >;
typedef $$DiscoveredCluesTableCreateCompanionBuilder =
    DiscoveredCluesCompanion Function({
      required String saveSlotId,
      required String clueId,
      Value<int> rowid,
    });
typedef $$DiscoveredCluesTableUpdateCompanionBuilder =
    DiscoveredCluesCompanion Function({
      Value<String> saveSlotId,
      Value<String> clueId,
      Value<int> rowid,
    });

class $$DiscoveredCluesTableFilterComposer
    extends Composer<_$AppDatabase, $DiscoveredCluesTable> {
  $$DiscoveredCluesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get saveSlotId => $composableBuilder(
    column: $table.saveSlotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clueId => $composableBuilder(
    column: $table.clueId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DiscoveredCluesTableOrderingComposer
    extends Composer<_$AppDatabase, $DiscoveredCluesTable> {
  $$DiscoveredCluesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get saveSlotId => $composableBuilder(
    column: $table.saveSlotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clueId => $composableBuilder(
    column: $table.clueId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DiscoveredCluesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DiscoveredCluesTable> {
  $$DiscoveredCluesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get saveSlotId => $composableBuilder(
    column: $table.saveSlotId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clueId =>
      $composableBuilder(column: $table.clueId, builder: (column) => column);
}

class $$DiscoveredCluesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DiscoveredCluesTable,
          DiscoveredClue,
          $$DiscoveredCluesTableFilterComposer,
          $$DiscoveredCluesTableOrderingComposer,
          $$DiscoveredCluesTableAnnotationComposer,
          $$DiscoveredCluesTableCreateCompanionBuilder,
          $$DiscoveredCluesTableUpdateCompanionBuilder,
          (
            DiscoveredClue,
            BaseReferences<
              _$AppDatabase,
              $DiscoveredCluesTable,
              DiscoveredClue
            >,
          ),
          DiscoveredClue,
          PrefetchHooks Function()
        > {
  $$DiscoveredCluesTableTableManager(
    _$AppDatabase db,
    $DiscoveredCluesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiscoveredCluesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiscoveredCluesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiscoveredCluesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> saveSlotId = const Value.absent(),
                Value<String> clueId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DiscoveredCluesCompanion(
                saveSlotId: saveSlotId,
                clueId: clueId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String saveSlotId,
                required String clueId,
                Value<int> rowid = const Value.absent(),
              }) => DiscoveredCluesCompanion.insert(
                saveSlotId: saveSlotId,
                clueId: clueId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DiscoveredCluesTable, DiscoveredClue>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DiscoveredCluesTable,
                    DiscoveredClue
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DiscoveredCluesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DiscoveredCluesTable,
      DiscoveredClue,
      $$DiscoveredCluesTableFilterComposer,
      $$DiscoveredCluesTableOrderingComposer,
      $$DiscoveredCluesTableAnnotationComposer,
      $$DiscoveredCluesTableCreateCompanionBuilder,
      $$DiscoveredCluesTableUpdateCompanionBuilder,
      (
        DiscoveredClue,
        BaseReferences<_$AppDatabase, $DiscoveredCluesTable, DiscoveredClue>,
      ),
      DiscoveredClue,
      PrefetchHooks Function()
    >;
typedef $$CompletedChaptersTableCreateCompanionBuilder =
    CompletedChaptersCompanion Function({
      required String saveSlotId,
      required String chapterId,
      required int completedAtMs,
      Value<int> rowid,
    });
typedef $$CompletedChaptersTableUpdateCompanionBuilder =
    CompletedChaptersCompanion Function({
      Value<String> saveSlotId,
      Value<String> chapterId,
      Value<int> completedAtMs,
      Value<int> rowid,
    });

class $$CompletedChaptersTableFilterComposer
    extends Composer<_$AppDatabase, $CompletedChaptersTable> {
  $$CompletedChaptersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get saveSlotId => $composableBuilder(
    column: $table.saveSlotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAtMs => $composableBuilder(
    column: $table.completedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CompletedChaptersTableOrderingComposer
    extends Composer<_$AppDatabase, $CompletedChaptersTable> {
  $$CompletedChaptersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get saveSlotId => $composableBuilder(
    column: $table.saveSlotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAtMs => $composableBuilder(
    column: $table.completedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompletedChaptersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompletedChaptersTable> {
  $$CompletedChaptersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get saveSlotId => $composableBuilder(
    column: $table.saveSlotId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<int> get completedAtMs => $composableBuilder(
    column: $table.completedAtMs,
    builder: (column) => column,
  );
}

class $$CompletedChaptersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompletedChaptersTable,
          CompletedChapter,
          $$CompletedChaptersTableFilterComposer,
          $$CompletedChaptersTableOrderingComposer,
          $$CompletedChaptersTableAnnotationComposer,
          $$CompletedChaptersTableCreateCompanionBuilder,
          $$CompletedChaptersTableUpdateCompanionBuilder,
          (
            CompletedChapter,
            BaseReferences<
              _$AppDatabase,
              $CompletedChaptersTable,
              CompletedChapter
            >,
          ),
          CompletedChapter,
          PrefetchHooks Function()
        > {
  $$CompletedChaptersTableTableManager(
    _$AppDatabase db,
    $CompletedChaptersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompletedChaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompletedChaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompletedChaptersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> saveSlotId = const Value.absent(),
                Value<String> chapterId = const Value.absent(),
                Value<int> completedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompletedChaptersCompanion(
                saveSlotId: saveSlotId,
                chapterId: chapterId,
                completedAtMs: completedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String saveSlotId,
                required String chapterId,
                required int completedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => CompletedChaptersCompanion.insert(
                saveSlotId: saveSlotId,
                chapterId: chapterId,
                completedAtMs: completedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CompletedChaptersTable, CompletedChapter>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CompletedChaptersTable,
                    CompletedChapter
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CompletedChaptersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompletedChaptersTable,
      CompletedChapter,
      $$CompletedChaptersTableFilterComposer,
      $$CompletedChaptersTableOrderingComposer,
      $$CompletedChaptersTableAnnotationComposer,
      $$CompletedChaptersTableCreateCompanionBuilder,
      $$CompletedChaptersTableUpdateCompanionBuilder,
      (
        CompletedChapter,
        BaseReferences<
          _$AppDatabase,
          $CompletedChaptersTable,
          CompletedChapter
        >,
      ),
      CompletedChapter,
      PrefetchHooks Function()
    >;
typedef $$RevealedHintsTableCreateCompanionBuilder =
    RevealedHintsCompanion Function({
      required String saveSlotId,
      required String puzzleId,
      required int maxLevel,
      Value<int> rowid,
    });
typedef $$RevealedHintsTableUpdateCompanionBuilder =
    RevealedHintsCompanion Function({
      Value<String> saveSlotId,
      Value<String> puzzleId,
      Value<int> maxLevel,
      Value<int> rowid,
    });

class $$RevealedHintsTableFilterComposer
    extends Composer<_$AppDatabase, $RevealedHintsTable> {
  $$RevealedHintsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get saveSlotId => $composableBuilder(
    column: $table.saveSlotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get puzzleId => $composableBuilder(
    column: $table.puzzleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxLevel => $composableBuilder(
    column: $table.maxLevel,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RevealedHintsTableOrderingComposer
    extends Composer<_$AppDatabase, $RevealedHintsTable> {
  $$RevealedHintsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get saveSlotId => $composableBuilder(
    column: $table.saveSlotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get puzzleId => $composableBuilder(
    column: $table.puzzleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxLevel => $composableBuilder(
    column: $table.maxLevel,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RevealedHintsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RevealedHintsTable> {
  $$RevealedHintsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get saveSlotId => $composableBuilder(
    column: $table.saveSlotId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get puzzleId =>
      $composableBuilder(column: $table.puzzleId, builder: (column) => column);

  GeneratedColumn<int> get maxLevel =>
      $composableBuilder(column: $table.maxLevel, builder: (column) => column);
}

class $$RevealedHintsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RevealedHintsTable,
          RevealedHint,
          $$RevealedHintsTableFilterComposer,
          $$RevealedHintsTableOrderingComposer,
          $$RevealedHintsTableAnnotationComposer,
          $$RevealedHintsTableCreateCompanionBuilder,
          $$RevealedHintsTableUpdateCompanionBuilder,
          (
            RevealedHint,
            BaseReferences<_$AppDatabase, $RevealedHintsTable, RevealedHint>,
          ),
          RevealedHint,
          PrefetchHooks Function()
        > {
  $$RevealedHintsTableTableManager(_$AppDatabase db, $RevealedHintsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RevealedHintsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RevealedHintsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RevealedHintsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> saveSlotId = const Value.absent(),
                Value<String> puzzleId = const Value.absent(),
                Value<int> maxLevel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RevealedHintsCompanion(
                saveSlotId: saveSlotId,
                puzzleId: puzzleId,
                maxLevel: maxLevel,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String saveSlotId,
                required String puzzleId,
                required int maxLevel,
                Value<int> rowid = const Value.absent(),
              }) => RevealedHintsCompanion.insert(
                saveSlotId: saveSlotId,
                puzzleId: puzzleId,
                maxLevel: maxLevel,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RevealedHintsTable, RevealedHint>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $RevealedHintsTable,
                    RevealedHint
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RevealedHintsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RevealedHintsTable,
      RevealedHint,
      $$RevealedHintsTableFilterComposer,
      $$RevealedHintsTableOrderingComposer,
      $$RevealedHintsTableAnnotationComposer,
      $$RevealedHintsTableCreateCompanionBuilder,
      $$RevealedHintsTableUpdateCompanionBuilder,
      (
        RevealedHint,
        BaseReferences<_$AppDatabase, $RevealedHintsTable, RevealedHint>,
      ),
      RevealedHint,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SaveSlotsTableTableManager get saveSlots =>
      $$SaveSlotsTableTableManager(_db, _db.saveSlots);
  $$UnlockedRoomsTableTableManager get unlockedRooms =>
      $$UnlockedRoomsTableTableManager(_db, _db.unlockedRooms);
  $$SolvedPuzzlesTableTableManager get solvedPuzzles =>
      $$SolvedPuzzlesTableTableManager(_db, _db.solvedPuzzles);
  $$PuzzleStatesTableTableManager get puzzleStates =>
      $$PuzzleStatesTableTableManager(_db, _db.puzzleStates);
  $$CollectedItemsTableTableManager get collectedItems =>
      $$CollectedItemsTableTableManager(_db, _db.collectedItems);
  $$ConsumedItemsTableTableManager get consumedItems =>
      $$ConsumedItemsTableTableManager(_db, _db.consumedItems);
  $$DiscoveredCluesTableTableManager get discoveredClues =>
      $$DiscoveredCluesTableTableManager(_db, _db.discoveredClues);
  $$CompletedChaptersTableTableManager get completedChapters =>
      $$CompletedChaptersTableTableManager(_db, _db.completedChapters);
  $$RevealedHintsTableTableManager get revealedHints =>
      $$RevealedHintsTableTableManager(_db, _db.revealedHints);
}
