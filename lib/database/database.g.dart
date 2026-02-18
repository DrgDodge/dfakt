// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, orderIndex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String name;
  final int orderIndex;
  const Category({
    required this.id,
    required this.name,
    required this.orderIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      orderIndex: Value(orderIndex),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  Category copyWith({int? id, String? name, int? orderIndex}) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    orderIndex: orderIndex ?? this.orderIndex,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, orderIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.orderIndex == this.orderIndex);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> orderIndex;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.orderIndex = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.orderIndex = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? orderIndex,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (orderIndex != null) 'order_index': orderIndex,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? orderIndex,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, Reminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isEventMeta = const VerificationMeta(
    'isEvent',
  );
  @override
  late final GeneratedColumn<bool> isEvent = GeneratedColumn<bool>(
    'is_event',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_event" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _recurrenceMeta = const VerificationMeta(
    'recurrence',
  );
  @override
  late final GeneratedColumn<String> recurrence = GeneratedColumn<String>(
    'recurrence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    isCompleted,
    categoryId,
    imagePath,
    orderIndex,
    dueDate,
    endDate,
    isEvent,
    recurrence,
    color,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Reminder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('is_event')) {
      context.handle(
        _isEventMeta,
        isEvent.isAcceptableOrUnknown(data['is_event']!, _isEventMeta),
      );
    }
    if (data.containsKey('recurrence')) {
      context.handle(
        _recurrenceMeta,
        recurrence.isAcceptableOrUnknown(data['recurrence']!, _recurrenceMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reminder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      isEvent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_event'],
      )!,
      recurrence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      ),
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class Reminder extends DataClass implements Insertable<Reminder> {
  final int id;
  final String title;
  final bool isCompleted;
  final int categoryId;
  final String? imagePath;
  final int orderIndex;
  final DateTime? dueDate;
  final DateTime? endDate;
  final bool isEvent;
  final String recurrence;
  final int? color;
  const Reminder({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.categoryId,
    this.imagePath,
    required this.orderIndex,
    this.dueDate,
    this.endDate,
    required this.isEvent,
    required this.recurrence,
    this.color,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['category_id'] = Variable<int>(categoryId);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    map['order_index'] = Variable<int>(orderIndex);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['is_event'] = Variable<bool>(isEvent);
    map['recurrence'] = Variable<String>(recurrence);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<int>(color);
    }
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      title: Value(title),
      isCompleted: Value(isCompleted),
      categoryId: Value(categoryId),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      orderIndex: Value(orderIndex),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      isEvent: Value(isEvent),
      recurrence: Value(recurrence),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
    );
  }

  factory Reminder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reminder(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      isEvent: serializer.fromJson<bool>(json['isEvent']),
      recurrence: serializer.fromJson<String>(json['recurrence']),
      color: serializer.fromJson<int?>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'categoryId': serializer.toJson<int>(categoryId),
      'imagePath': serializer.toJson<String?>(imagePath),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'isEvent': serializer.toJson<bool>(isEvent),
      'recurrence': serializer.toJson<String>(recurrence),
      'color': serializer.toJson<int?>(color),
    };
  }

  Reminder copyWith({
    int? id,
    String? title,
    bool? isCompleted,
    int? categoryId,
    Value<String?> imagePath = const Value.absent(),
    int? orderIndex,
    Value<DateTime?> dueDate = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
    bool? isEvent,
    String? recurrence,
    Value<int?> color = const Value.absent(),
  }) => Reminder(
    id: id ?? this.id,
    title: title ?? this.title,
    isCompleted: isCompleted ?? this.isCompleted,
    categoryId: categoryId ?? this.categoryId,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    orderIndex: orderIndex ?? this.orderIndex,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    isEvent: isEvent ?? this.isEvent,
    recurrence: recurrence ?? this.recurrence,
    color: color.present ? color.value : this.color,
  );
  Reminder copyWithCompanion(RemindersCompanion data) {
    return Reminder(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      isEvent: data.isEvent.present ? data.isEvent.value : this.isEvent,
      recurrence: data.recurrence.present
          ? data.recurrence.value
          : this.recurrence,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reminder(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('categoryId: $categoryId, ')
          ..write('imagePath: $imagePath, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('dueDate: $dueDate, ')
          ..write('endDate: $endDate, ')
          ..write('isEvent: $isEvent, ')
          ..write('recurrence: $recurrence, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    isCompleted,
    categoryId,
    imagePath,
    orderIndex,
    dueDate,
    endDate,
    isEvent,
    recurrence,
    color,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reminder &&
          other.id == this.id &&
          other.title == this.title &&
          other.isCompleted == this.isCompleted &&
          other.categoryId == this.categoryId &&
          other.imagePath == this.imagePath &&
          other.orderIndex == this.orderIndex &&
          other.dueDate == this.dueDate &&
          other.endDate == this.endDate &&
          other.isEvent == this.isEvent &&
          other.recurrence == this.recurrence &&
          other.color == this.color);
}

class RemindersCompanion extends UpdateCompanion<Reminder> {
  final Value<int> id;
  final Value<String> title;
  final Value<bool> isCompleted;
  final Value<int> categoryId;
  final Value<String?> imagePath;
  final Value<int> orderIndex;
  final Value<DateTime?> dueDate;
  final Value<DateTime?> endDate;
  final Value<bool> isEvent;
  final Value<String> recurrence;
  final Value<int?> color;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.isEvent = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.color = const Value.absent(),
  });
  RemindersCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.isCompleted = const Value.absent(),
    required int categoryId,
    this.imagePath = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.isEvent = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.color = const Value.absent(),
  }) : title = Value(title),
       categoryId = Value(categoryId);
  static Insertable<Reminder> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<bool>? isCompleted,
    Expression<int>? categoryId,
    Expression<String>? imagePath,
    Expression<int>? orderIndex,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? endDate,
    Expression<bool>? isEvent,
    Expression<String>? recurrence,
    Expression<int>? color,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (categoryId != null) 'category_id': categoryId,
      if (imagePath != null) 'image_path': imagePath,
      if (orderIndex != null) 'order_index': orderIndex,
      if (dueDate != null) 'due_date': dueDate,
      if (endDate != null) 'end_date': endDate,
      if (isEvent != null) 'is_event': isEvent,
      if (recurrence != null) 'recurrence': recurrence,
      if (color != null) 'color': color,
    });
  }

  RemindersCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<bool>? isCompleted,
    Value<int>? categoryId,
    Value<String?>? imagePath,
    Value<int>? orderIndex,
    Value<DateTime?>? dueDate,
    Value<DateTime?>? endDate,
    Value<bool>? isEvent,
    Value<String>? recurrence,
    Value<int?>? color,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      categoryId: categoryId ?? this.categoryId,
      imagePath: imagePath ?? this.imagePath,
      orderIndex: orderIndex ?? this.orderIndex,
      dueDate: dueDate ?? this.dueDate,
      endDate: endDate ?? this.endDate,
      isEvent: isEvent ?? this.isEvent,
      recurrence: recurrence ?? this.recurrence,
      color: color ?? this.color,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (isEvent.present) {
      map['is_event'] = Variable<bool>(isEvent.value);
    }
    if (recurrence.present) {
      map['recurrence'] = Variable<String>(recurrence.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('categoryId: $categoryId, ')
          ..write('imagePath: $imagePath, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('dueDate: $dueDate, ')
          ..write('endDate: $endDate, ')
          ..write('isEvent: $isEvent, ')
          ..write('recurrence: $recurrence, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }
}

class $SubRemindersTable extends SubReminders
    with TableInfo<$SubRemindersTable, SubReminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubRemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reminderIdMeta = const VerificationMeta(
    'reminderId',
  );
  @override
  late final GeneratedColumn<int> reminderId = GeneratedColumn<int>(
    'reminder_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES reminders (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    isCompleted,
    reminderId,
    imagePath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sub_reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<SubReminder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('reminder_id')) {
      context.handle(
        _reminderIdMeta,
        reminderId.isAcceptableOrUnknown(data['reminder_id']!, _reminderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_reminderIdMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SubReminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubReminder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      reminderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_id'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
    );
  }

  @override
  $SubRemindersTable createAlias(String alias) {
    return $SubRemindersTable(attachedDatabase, alias);
  }
}

class SubReminder extends DataClass implements Insertable<SubReminder> {
  final int id;
  final String title;
  final bool isCompleted;
  final int reminderId;
  final String? imagePath;
  const SubReminder({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.reminderId,
    this.imagePath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['reminder_id'] = Variable<int>(reminderId);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    return map;
  }

  SubRemindersCompanion toCompanion(bool nullToAbsent) {
    return SubRemindersCompanion(
      id: Value(id),
      title: Value(title),
      isCompleted: Value(isCompleted),
      reminderId: Value(reminderId),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
    );
  }

  factory SubReminder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubReminder(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      reminderId: serializer.fromJson<int>(json['reminderId']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'reminderId': serializer.toJson<int>(reminderId),
      'imagePath': serializer.toJson<String?>(imagePath),
    };
  }

  SubReminder copyWith({
    int? id,
    String? title,
    bool? isCompleted,
    int? reminderId,
    Value<String?> imagePath = const Value.absent(),
  }) => SubReminder(
    id: id ?? this.id,
    title: title ?? this.title,
    isCompleted: isCompleted ?? this.isCompleted,
    reminderId: reminderId ?? this.reminderId,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
  );
  SubReminder copyWithCompanion(SubRemindersCompanion data) {
    return SubReminder(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      reminderId: data.reminderId.present
          ? data.reminderId.value
          : this.reminderId,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubReminder(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('reminderId: $reminderId, ')
          ..write('imagePath: $imagePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, isCompleted, reminderId, imagePath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubReminder &&
          other.id == this.id &&
          other.title == this.title &&
          other.isCompleted == this.isCompleted &&
          other.reminderId == this.reminderId &&
          other.imagePath == this.imagePath);
}

class SubRemindersCompanion extends UpdateCompanion<SubReminder> {
  final Value<int> id;
  final Value<String> title;
  final Value<bool> isCompleted;
  final Value<int> reminderId;
  final Value<String?> imagePath;
  const SubRemindersCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.reminderId = const Value.absent(),
    this.imagePath = const Value.absent(),
  });
  SubRemindersCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.isCompleted = const Value.absent(),
    required int reminderId,
    this.imagePath = const Value.absent(),
  }) : title = Value(title),
       reminderId = Value(reminderId);
  static Insertable<SubReminder> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<bool>? isCompleted,
    Expression<int>? reminderId,
    Expression<String>? imagePath,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (reminderId != null) 'reminder_id': reminderId,
      if (imagePath != null) 'image_path': imagePath,
    });
  }

  SubRemindersCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<bool>? isCompleted,
    Value<int>? reminderId,
    Value<String?>? imagePath,
  }) {
    return SubRemindersCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      reminderId: reminderId ?? this.reminderId,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (reminderId.present) {
      map['reminder_id'] = Variable<int>(reminderId.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubRemindersCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('reminderId: $reminderId, ')
          ..write('imagePath: $imagePath')
          ..write(')'))
        .toString();
  }
}

class $ExercisesTable extends Exercises
    with TableInfo<$ExercisesTable, Exercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<Exercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Exercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }
}

class Exercise extends DataClass implements Insertable<Exercise> {
  final int id;
  final String name;
  const Exercise({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(id: Value(id), name: Value(name));
  }

  factory Exercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exercise(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Exercise copyWith({int? id, String? name}) =>
      Exercise(id: id ?? this.id, name: name ?? this.name);
  Exercise copyWithCompanion(ExercisesCompanion data) {
    return Exercise(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exercise(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exercise && other.id == this.id && other.name == this.name);
}

class ExercisesCompanion extends UpdateCompanion<Exercise> {
  final Value<int> id;
  final Value<String> name;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  ExercisesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<Exercise> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  ExercisesCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return ExercisesCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $GymLogsTable extends GymLogs with TableInfo<$GymLogsTable, GymLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GymLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setsMeta = const VerificationMeta('sets');
  @override
  late final GeneratedColumn<int> sets = GeneratedColumn<int>(
    'sets',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    exerciseId,
    date,
    weight,
    reps,
    sets,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gym_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<GymLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    } else if (isInserting) {
      context.missing(_repsMeta);
    }
    if (data.containsKey('sets')) {
      context.handle(
        _setsMeta,
        sets.isAcceptableOrUnknown(data['sets']!, _setsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GymLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GymLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      sets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sets'],
      )!,
    );
  }

  @override
  $GymLogsTable createAlias(String alias) {
    return $GymLogsTable(attachedDatabase, alias);
  }
}

class GymLog extends DataClass implements Insertable<GymLog> {
  final int id;
  final int exerciseId;
  final DateTime date;
  final double weight;
  final int reps;
  final int sets;
  const GymLog({
    required this.id,
    required this.exerciseId,
    required this.date,
    required this.weight,
    required this.reps,
    required this.sets,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['exercise_id'] = Variable<int>(exerciseId);
    map['date'] = Variable<DateTime>(date);
    map['weight'] = Variable<double>(weight);
    map['reps'] = Variable<int>(reps);
    map['sets'] = Variable<int>(sets);
    return map;
  }

  GymLogsCompanion toCompanion(bool nullToAbsent) {
    return GymLogsCompanion(
      id: Value(id),
      exerciseId: Value(exerciseId),
      date: Value(date),
      weight: Value(weight),
      reps: Value(reps),
      sets: Value(sets),
    );
  }

  factory GymLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GymLog(
      id: serializer.fromJson<int>(json['id']),
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      date: serializer.fromJson<DateTime>(json['date']),
      weight: serializer.fromJson<double>(json['weight']),
      reps: serializer.fromJson<int>(json['reps']),
      sets: serializer.fromJson<int>(json['sets']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'exerciseId': serializer.toJson<int>(exerciseId),
      'date': serializer.toJson<DateTime>(date),
      'weight': serializer.toJson<double>(weight),
      'reps': serializer.toJson<int>(reps),
      'sets': serializer.toJson<int>(sets),
    };
  }

  GymLog copyWith({
    int? id,
    int? exerciseId,
    DateTime? date,
    double? weight,
    int? reps,
    int? sets,
  }) => GymLog(
    id: id ?? this.id,
    exerciseId: exerciseId ?? this.exerciseId,
    date: date ?? this.date,
    weight: weight ?? this.weight,
    reps: reps ?? this.reps,
    sets: sets ?? this.sets,
  );
  GymLog copyWithCompanion(GymLogsCompanion data) {
    return GymLog(
      id: data.id.present ? data.id.value : this.id,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      date: data.date.present ? data.date.value : this.date,
      weight: data.weight.present ? data.weight.value : this.weight,
      reps: data.reps.present ? data.reps.value : this.reps,
      sets: data.sets.present ? data.sets.value : this.sets,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GymLog(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('date: $date, ')
          ..write('weight: $weight, ')
          ..write('reps: $reps, ')
          ..write('sets: $sets')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, exerciseId, date, weight, reps, sets);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GymLog &&
          other.id == this.id &&
          other.exerciseId == this.exerciseId &&
          other.date == this.date &&
          other.weight == this.weight &&
          other.reps == this.reps &&
          other.sets == this.sets);
}

class GymLogsCompanion extends UpdateCompanion<GymLog> {
  final Value<int> id;
  final Value<int> exerciseId;
  final Value<DateTime> date;
  final Value<double> weight;
  final Value<int> reps;
  final Value<int> sets;
  const GymLogsCompanion({
    this.id = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.date = const Value.absent(),
    this.weight = const Value.absent(),
    this.reps = const Value.absent(),
    this.sets = const Value.absent(),
  });
  GymLogsCompanion.insert({
    this.id = const Value.absent(),
    required int exerciseId,
    required DateTime date,
    required double weight,
    required int reps,
    this.sets = const Value.absent(),
  }) : exerciseId = Value(exerciseId),
       date = Value(date),
       weight = Value(weight),
       reps = Value(reps);
  static Insertable<GymLog> custom({
    Expression<int>? id,
    Expression<int>? exerciseId,
    Expression<DateTime>? date,
    Expression<double>? weight,
    Expression<int>? reps,
    Expression<int>? sets,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (date != null) 'date': date,
      if (weight != null) 'weight': weight,
      if (reps != null) 'reps': reps,
      if (sets != null) 'sets': sets,
    });
  }

  GymLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? exerciseId,
    Value<DateTime>? date,
    Value<double>? weight,
    Value<int>? reps,
    Value<int>? sets,
  }) {
    return GymLogsCompanion(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      sets: sets ?? this.sets,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (sets.present) {
      map['sets'] = Variable<int>(sets.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GymLogsCompanion(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('date: $date, ')
          ..write('weight: $weight, ')
          ..write('reps: $reps, ')
          ..write('sets: $sets')
          ..write(')'))
        .toString();
  }
}

class $WeightLogsTable extends WeightLogs
    with TableInfo<$WeightLogsTable, WeightLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeightLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyFatMeta = const VerificationMeta(
    'bodyFat',
  );
  @override
  late final GeneratedColumn<double> bodyFat = GeneratedColumn<double>(
    'body_fat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _muscleMassMeta = const VerificationMeta(
    'muscleMass',
  );
  @override
  late final GeneratedColumn<double> muscleMass = GeneratedColumn<double>(
    'muscle_mass',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, date, weight, bodyFat, muscleMass];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weight_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeightLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('body_fat')) {
      context.handle(
        _bodyFatMeta,
        bodyFat.isAcceptableOrUnknown(data['body_fat']!, _bodyFatMeta),
      );
    }
    if (data.containsKey('muscle_mass')) {
      context.handle(
        _muscleMassMeta,
        muscleMass.isAcceptableOrUnknown(data['muscle_mass']!, _muscleMassMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WeightLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeightLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      )!,
      bodyFat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}body_fat'],
      ),
      muscleMass: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}muscle_mass'],
      ),
    );
  }

  @override
  $WeightLogsTable createAlias(String alias) {
    return $WeightLogsTable(attachedDatabase, alias);
  }
}

class WeightLog extends DataClass implements Insertable<WeightLog> {
  final int id;
  final DateTime date;
  final double weight;
  final double? bodyFat;
  final double? muscleMass;
  const WeightLog({
    required this.id,
    required this.date,
    required this.weight,
    this.bodyFat,
    this.muscleMass,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['weight'] = Variable<double>(weight);
    if (!nullToAbsent || bodyFat != null) {
      map['body_fat'] = Variable<double>(bodyFat);
    }
    if (!nullToAbsent || muscleMass != null) {
      map['muscle_mass'] = Variable<double>(muscleMass);
    }
    return map;
  }

  WeightLogsCompanion toCompanion(bool nullToAbsent) {
    return WeightLogsCompanion(
      id: Value(id),
      date: Value(date),
      weight: Value(weight),
      bodyFat: bodyFat == null && nullToAbsent
          ? const Value.absent()
          : Value(bodyFat),
      muscleMass: muscleMass == null && nullToAbsent
          ? const Value.absent()
          : Value(muscleMass),
    );
  }

  factory WeightLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeightLog(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      weight: serializer.fromJson<double>(json['weight']),
      bodyFat: serializer.fromJson<double?>(json['bodyFat']),
      muscleMass: serializer.fromJson<double?>(json['muscleMass']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'weight': serializer.toJson<double>(weight),
      'bodyFat': serializer.toJson<double?>(bodyFat),
      'muscleMass': serializer.toJson<double?>(muscleMass),
    };
  }

  WeightLog copyWith({
    int? id,
    DateTime? date,
    double? weight,
    Value<double?> bodyFat = const Value.absent(),
    Value<double?> muscleMass = const Value.absent(),
  }) => WeightLog(
    id: id ?? this.id,
    date: date ?? this.date,
    weight: weight ?? this.weight,
    bodyFat: bodyFat.present ? bodyFat.value : this.bodyFat,
    muscleMass: muscleMass.present ? muscleMass.value : this.muscleMass,
  );
  WeightLog copyWithCompanion(WeightLogsCompanion data) {
    return WeightLog(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      weight: data.weight.present ? data.weight.value : this.weight,
      bodyFat: data.bodyFat.present ? data.bodyFat.value : this.bodyFat,
      muscleMass: data.muscleMass.present
          ? data.muscleMass.value
          : this.muscleMass,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeightLog(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('weight: $weight, ')
          ..write('bodyFat: $bodyFat, ')
          ..write('muscleMass: $muscleMass')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, weight, bodyFat, muscleMass);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeightLog &&
          other.id == this.id &&
          other.date == this.date &&
          other.weight == this.weight &&
          other.bodyFat == this.bodyFat &&
          other.muscleMass == this.muscleMass);
}

class WeightLogsCompanion extends UpdateCompanion<WeightLog> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<double> weight;
  final Value<double?> bodyFat;
  final Value<double?> muscleMass;
  const WeightLogsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.weight = const Value.absent(),
    this.bodyFat = const Value.absent(),
    this.muscleMass = const Value.absent(),
  });
  WeightLogsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required double weight,
    this.bodyFat = const Value.absent(),
    this.muscleMass = const Value.absent(),
  }) : date = Value(date),
       weight = Value(weight);
  static Insertable<WeightLog> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<double>? weight,
    Expression<double>? bodyFat,
    Expression<double>? muscleMass,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (weight != null) 'weight': weight,
      if (bodyFat != null) 'body_fat': bodyFat,
      if (muscleMass != null) 'muscle_mass': muscleMass,
    });
  }

  WeightLogsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<double>? weight,
    Value<double?>? bodyFat,
    Value<double?>? muscleMass,
  }) {
    return WeightLogsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      bodyFat: bodyFat ?? this.bodyFat,
      muscleMass: muscleMass ?? this.muscleMass,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (bodyFat.present) {
      map['body_fat'] = Variable<double>(bodyFat.value);
    }
    if (muscleMass.present) {
      map['muscle_mass'] = Variable<double>(muscleMass.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeightLogsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('weight: $weight, ')
          ..write('bodyFat: $bodyFat, ')
          ..write('muscleMass: $muscleMass')
          ..write(')'))
        .toString();
  }
}

class $NutritionLogsTable extends NutritionLogs
    with TableInfo<$NutritionLogsTable, NutritionLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NutritionLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<int> calories = GeneratedColumn<int>(
    'calories',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinMeta = const VerificationMeta(
    'protein',
  );
  @override
  late final GeneratedColumn<int> protein = GeneratedColumn<int>(
    'protein',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbsMeta = const VerificationMeta('carbs');
  @override
  late final GeneratedColumn<int> carbs = GeneratedColumn<int>(
    'carbs',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, date, calories, protein, carbs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nutrition_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<NutritionLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    } else if (isInserting) {
      context.missing(_caloriesMeta);
    }
    if (data.containsKey('protein')) {
      context.handle(
        _proteinMeta,
        protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta),
      );
    } else if (isInserting) {
      context.missing(_proteinMeta);
    }
    if (data.containsKey('carbs')) {
      context.handle(
        _carbsMeta,
        carbs.isAcceptableOrUnknown(data['carbs']!, _carbsMeta),
      );
    } else if (isInserting) {
      context.missing(_carbsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NutritionLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NutritionLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calories'],
      )!,
      protein: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}protein'],
      )!,
      carbs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}carbs'],
      )!,
    );
  }

  @override
  $NutritionLogsTable createAlias(String alias) {
    return $NutritionLogsTable(attachedDatabase, alias);
  }
}

class NutritionLog extends DataClass implements Insertable<NutritionLog> {
  final int id;
  final DateTime date;
  final int calories;
  final int protein;
  final int carbs;
  const NutritionLog({
    required this.id,
    required this.date,
    required this.calories,
    required this.protein,
    required this.carbs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['calories'] = Variable<int>(calories);
    map['protein'] = Variable<int>(protein);
    map['carbs'] = Variable<int>(carbs);
    return map;
  }

  NutritionLogsCompanion toCompanion(bool nullToAbsent) {
    return NutritionLogsCompanion(
      id: Value(id),
      date: Value(date),
      calories: Value(calories),
      protein: Value(protein),
      carbs: Value(carbs),
    );
  }

  factory NutritionLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NutritionLog(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      calories: serializer.fromJson<int>(json['calories']),
      protein: serializer.fromJson<int>(json['protein']),
      carbs: serializer.fromJson<int>(json['carbs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'calories': serializer.toJson<int>(calories),
      'protein': serializer.toJson<int>(protein),
      'carbs': serializer.toJson<int>(carbs),
    };
  }

  NutritionLog copyWith({
    int? id,
    DateTime? date,
    int? calories,
    int? protein,
    int? carbs,
  }) => NutritionLog(
    id: id ?? this.id,
    date: date ?? this.date,
    calories: calories ?? this.calories,
    protein: protein ?? this.protein,
    carbs: carbs ?? this.carbs,
  );
  NutritionLog copyWithCompanion(NutritionLogsCompanion data) {
    return NutritionLog(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      calories: data.calories.present ? data.calories.value : this.calories,
      protein: data.protein.present ? data.protein.value : this.protein,
      carbs: data.carbs.present ? data.carbs.value : this.carbs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NutritionLog(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, calories, protein, carbs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NutritionLog &&
          other.id == this.id &&
          other.date == this.date &&
          other.calories == this.calories &&
          other.protein == this.protein &&
          other.carbs == this.carbs);
}

class NutritionLogsCompanion extends UpdateCompanion<NutritionLog> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<int> calories;
  final Value<int> protein;
  final Value<int> carbs;
  const NutritionLogsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.calories = const Value.absent(),
    this.protein = const Value.absent(),
    this.carbs = const Value.absent(),
  });
  NutritionLogsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required int calories,
    required int protein,
    required int carbs,
  }) : date = Value(date),
       calories = Value(calories),
       protein = Value(protein),
       carbs = Value(carbs);
  static Insertable<NutritionLog> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<int>? calories,
    Expression<int>? protein,
    Expression<int>? carbs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (calories != null) 'calories': calories,
      if (protein != null) 'protein': protein,
      if (carbs != null) 'carbs': carbs,
    });
  }

  NutritionLogsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<int>? calories,
    Value<int>? protein,
    Value<int>? carbs,
  }) {
    return NutritionLogsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (calories.present) {
      map['calories'] = Variable<int>(calories.value);
    }
    if (protein.present) {
      map['protein'] = Variable<int>(protein.value);
    }
    if (carbs.present) {
      map['carbs'] = Variable<int>(carbs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NutritionLogsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs')
          ..write(')'))
        .toString();
  }
}

class $UserGoalsTable extends UserGoals
    with TableInfo<$UserGoalsTable, UserGoal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserGoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dailyCalorieGoalMeta = const VerificationMeta(
    'dailyCalorieGoal',
  );
  @override
  late final GeneratedColumn<int> dailyCalorieGoal = GeneratedColumn<int>(
    'daily_calorie_goal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2000),
  );
  static const VerificationMeta _userNameMeta = const VerificationMeta(
    'userName',
  );
  @override
  late final GeneratedColumn<String> userName = GeneratedColumn<String>(
    'user_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, dailyCalorieGoal, userName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserGoal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('daily_calorie_goal')) {
      context.handle(
        _dailyCalorieGoalMeta,
        dailyCalorieGoal.isAcceptableOrUnknown(
          data['daily_calorie_goal']!,
          _dailyCalorieGoalMeta,
        ),
      );
    }
    if (data.containsKey('user_name')) {
      context.handle(
        _userNameMeta,
        userName.isAcceptableOrUnknown(data['user_name']!, _userNameMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserGoal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserGoal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dailyCalorieGoal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_calorie_goal'],
      )!,
      userName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_name'],
      ),
    );
  }

  @override
  $UserGoalsTable createAlias(String alias) {
    return $UserGoalsTable(attachedDatabase, alias);
  }
}

class UserGoal extends DataClass implements Insertable<UserGoal> {
  final int id;
  final int dailyCalorieGoal;
  final String? userName;
  const UserGoal({
    required this.id,
    required this.dailyCalorieGoal,
    this.userName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['daily_calorie_goal'] = Variable<int>(dailyCalorieGoal);
    if (!nullToAbsent || userName != null) {
      map['user_name'] = Variable<String>(userName);
    }
    return map;
  }

  UserGoalsCompanion toCompanion(bool nullToAbsent) {
    return UserGoalsCompanion(
      id: Value(id),
      dailyCalorieGoal: Value(dailyCalorieGoal),
      userName: userName == null && nullToAbsent
          ? const Value.absent()
          : Value(userName),
    );
  }

  factory UserGoal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserGoal(
      id: serializer.fromJson<int>(json['id']),
      dailyCalorieGoal: serializer.fromJson<int>(json['dailyCalorieGoal']),
      userName: serializer.fromJson<String?>(json['userName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dailyCalorieGoal': serializer.toJson<int>(dailyCalorieGoal),
      'userName': serializer.toJson<String?>(userName),
    };
  }

  UserGoal copyWith({
    int? id,
    int? dailyCalorieGoal,
    Value<String?> userName = const Value.absent(),
  }) => UserGoal(
    id: id ?? this.id,
    dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
    userName: userName.present ? userName.value : this.userName,
  );
  UserGoal copyWithCompanion(UserGoalsCompanion data) {
    return UserGoal(
      id: data.id.present ? data.id.value : this.id,
      dailyCalorieGoal: data.dailyCalorieGoal.present
          ? data.dailyCalorieGoal.value
          : this.dailyCalorieGoal,
      userName: data.userName.present ? data.userName.value : this.userName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserGoal(')
          ..write('id: $id, ')
          ..write('dailyCalorieGoal: $dailyCalorieGoal, ')
          ..write('userName: $userName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dailyCalorieGoal, userName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserGoal &&
          other.id == this.id &&
          other.dailyCalorieGoal == this.dailyCalorieGoal &&
          other.userName == this.userName);
}

class UserGoalsCompanion extends UpdateCompanion<UserGoal> {
  final Value<int> id;
  final Value<int> dailyCalorieGoal;
  final Value<String?> userName;
  const UserGoalsCompanion({
    this.id = const Value.absent(),
    this.dailyCalorieGoal = const Value.absent(),
    this.userName = const Value.absent(),
  });
  UserGoalsCompanion.insert({
    this.id = const Value.absent(),
    this.dailyCalorieGoal = const Value.absent(),
    this.userName = const Value.absent(),
  });
  static Insertable<UserGoal> custom({
    Expression<int>? id,
    Expression<int>? dailyCalorieGoal,
    Expression<String>? userName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dailyCalorieGoal != null) 'daily_calorie_goal': dailyCalorieGoal,
      if (userName != null) 'user_name': userName,
    });
  }

  UserGoalsCompanion copyWith({
    Value<int>? id,
    Value<int>? dailyCalorieGoal,
    Value<String?>? userName,
  }) {
    return UserGoalsCompanion(
      id: id ?? this.id,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      userName: userName ?? this.userName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dailyCalorieGoal.present) {
      map['daily_calorie_goal'] = Variable<int>(dailyCalorieGoal.value);
    }
    if (userName.present) {
      map['user_name'] = Variable<String>(userName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserGoalsCompanion(')
          ..write('id: $id, ')
          ..write('dailyCalorieGoal: $dailyCalorieGoal, ')
          ..write('userName: $userName')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $SubRemindersTable subReminders = $SubRemindersTable(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $GymLogsTable gymLogs = $GymLogsTable(this);
  late final $WeightLogsTable weightLogs = $WeightLogsTable(this);
  late final $NutritionLogsTable nutritionLogs = $NutritionLogsTable(this);
  late final $UserGoalsTable userGoals = $UserGoalsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    reminders,
    subReminders,
    exercises,
    gymLogs,
    weightLogs,
    nutritionLogs,
    userGoals,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reminders', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'reminders',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sub_reminders', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'exercises',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('gym_logs', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String name,
      Value<int> orderIndex,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> orderIndex,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RemindersTable, List<Reminder>>
  _remindersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reminders,
    aliasName: $_aliasNameGenerator(db.categories.id, db.reminders.categoryId),
  );

  $$RemindersTableProcessedTableManager get remindersRefs {
    final manager = $$RemindersTableTableManager(
      $_db,
      $_db.reminders,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> remindersRefs(
    Expression<bool> Function($$RemindersTableFilterComposer f) f,
  ) {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableFilterComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  Expression<T> remindersRefs<T extends Object>(
    Expression<T> Function($$RemindersTableAnnotationComposer a) f,
  ) {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableAnnotationComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({bool remindersRefs})
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                orderIndex: orderIndex,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int> orderIndex = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                orderIndex: orderIndex,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({remindersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (remindersRefs) db.reminders],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (remindersRefs)
                    await $_getPrefetchedData<
                      Category,
                      $CategoriesTable,
                      Reminder
                    >(
                      currentTable: table,
                      referencedTable: $$CategoriesTableReferences
                          ._remindersRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).remindersRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({bool remindersRefs})
    >;
typedef $$RemindersTableCreateCompanionBuilder =
    RemindersCompanion Function({
      Value<int> id,
      required String title,
      Value<bool> isCompleted,
      required int categoryId,
      Value<String?> imagePath,
      Value<int> orderIndex,
      Value<DateTime?> dueDate,
      Value<DateTime?> endDate,
      Value<bool> isEvent,
      Value<String> recurrence,
      Value<int?> color,
    });
typedef $$RemindersTableUpdateCompanionBuilder =
    RemindersCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<bool> isCompleted,
      Value<int> categoryId,
      Value<String?> imagePath,
      Value<int> orderIndex,
      Value<DateTime?> dueDate,
      Value<DateTime?> endDate,
      Value<bool> isEvent,
      Value<String> recurrence,
      Value<int?> color,
    });

final class $$RemindersTableReferences
    extends BaseReferences<_$AppDatabase, $RemindersTable, Reminder> {
  $$RemindersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.reminders.categoryId, db.categories.id),
      );

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SubRemindersTable, List<SubReminder>>
  _subRemindersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.subReminders,
    aliasName: $_aliasNameGenerator(
      db.reminders.id,
      db.subReminders.reminderId,
    ),
  );

  $$SubRemindersTableProcessedTableManager get subRemindersRefs {
    final manager = $$SubRemindersTableTableManager(
      $_db,
      $_db.subReminders,
    ).filter((f) => f.reminderId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_subRemindersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEvent => $composableBuilder(
    column: $table.isEvent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> subRemindersRefs(
    Expression<bool> Function($$SubRemindersTableFilterComposer f) f,
  ) {
    final $$SubRemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subReminders,
      getReferencedColumn: (t) => t.reminderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubRemindersTableFilterComposer(
            $db: $db,
            $table: $db.subReminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEvent => $composableBuilder(
    column: $table.isEvent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<bool> get isEvent =>
      $composableBuilder(column: $table.isEvent, builder: (column) => column);

  GeneratedColumn<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> subRemindersRefs<T extends Object>(
    Expression<T> Function($$SubRemindersTableAnnotationComposer a) f,
  ) {
    final $$SubRemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subReminders,
      getReferencedColumn: (t) => t.reminderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubRemindersTableAnnotationComposer(
            $db: $db,
            $table: $db.subReminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemindersTable,
          Reminder,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (Reminder, $$RemindersTableReferences),
          Reminder,
          PrefetchHooks Function({bool categoryId, bool subRemindersRefs})
        > {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> isEvent = const Value.absent(),
                Value<String> recurrence = const Value.absent(),
                Value<int?> color = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                title: title,
                isCompleted: isCompleted,
                categoryId: categoryId,
                imagePath: imagePath,
                orderIndex: orderIndex,
                dueDate: dueDate,
                endDate: endDate,
                isEvent: isEvent,
                recurrence: recurrence,
                color: color,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<bool> isCompleted = const Value.absent(),
                required int categoryId,
                Value<String?> imagePath = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> isEvent = const Value.absent(),
                Value<String> recurrence = const Value.absent(),
                Value<int?> color = const Value.absent(),
              }) => RemindersCompanion.insert(
                id: id,
                title: title,
                isCompleted: isCompleted,
                categoryId: categoryId,
                imagePath: imagePath,
                orderIndex: orderIndex,
                dueDate: dueDate,
                endDate: endDate,
                isEvent: isEvent,
                recurrence: recurrence,
                color: color,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RemindersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({categoryId = false, subRemindersRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (subRemindersRefs) db.subReminders,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable: $$RemindersTableReferences
                                        ._categoryIdTable(db),
                                    referencedColumn: $$RemindersTableReferences
                                        ._categoryIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (subRemindersRefs)
                        await $_getPrefetchedData<
                          Reminder,
                          $RemindersTable,
                          SubReminder
                        >(
                          currentTable: table,
                          referencedTable: $$RemindersTableReferences
                              ._subRemindersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RemindersTableReferences(
                                db,
                                table,
                                p0,
                              ).subRemindersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.reminderId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemindersTable,
      Reminder,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (Reminder, $$RemindersTableReferences),
      Reminder,
      PrefetchHooks Function({bool categoryId, bool subRemindersRefs})
    >;
typedef $$SubRemindersTableCreateCompanionBuilder =
    SubRemindersCompanion Function({
      Value<int> id,
      required String title,
      Value<bool> isCompleted,
      required int reminderId,
      Value<String?> imagePath,
    });
typedef $$SubRemindersTableUpdateCompanionBuilder =
    SubRemindersCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<bool> isCompleted,
      Value<int> reminderId,
      Value<String?> imagePath,
    });

final class $$SubRemindersTableReferences
    extends BaseReferences<_$AppDatabase, $SubRemindersTable, SubReminder> {
  $$SubRemindersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RemindersTable _reminderIdTable(_$AppDatabase db) =>
      db.reminders.createAlias(
        $_aliasNameGenerator(db.subReminders.reminderId, db.reminders.id),
      );

  $$RemindersTableProcessedTableManager get reminderId {
    final $_column = $_itemColumn<int>('reminder_id')!;

    final manager = $$RemindersTableTableManager(
      $_db,
      $_db.reminders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reminderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SubRemindersTableFilterComposer
    extends Composer<_$AppDatabase, $SubRemindersTable> {
  $$SubRemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  $$RemindersTableFilterComposer get reminderId {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reminderId,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableFilterComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubRemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $SubRemindersTable> {
  $$SubRemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  $$RemindersTableOrderingComposer get reminderId {
    final $$RemindersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reminderId,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableOrderingComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubRemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubRemindersTable> {
  $$SubRemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  $$RemindersTableAnnotationComposer get reminderId {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reminderId,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableAnnotationComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubRemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubRemindersTable,
          SubReminder,
          $$SubRemindersTableFilterComposer,
          $$SubRemindersTableOrderingComposer,
          $$SubRemindersTableAnnotationComposer,
          $$SubRemindersTableCreateCompanionBuilder,
          $$SubRemindersTableUpdateCompanionBuilder,
          (SubReminder, $$SubRemindersTableReferences),
          SubReminder,
          PrefetchHooks Function({bool reminderId})
        > {
  $$SubRemindersTableTableManager(_$AppDatabase db, $SubRemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubRemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubRemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubRemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<int> reminderId = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
              }) => SubRemindersCompanion(
                id: id,
                title: title,
                isCompleted: isCompleted,
                reminderId: reminderId,
                imagePath: imagePath,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<bool> isCompleted = const Value.absent(),
                required int reminderId,
                Value<String?> imagePath = const Value.absent(),
              }) => SubRemindersCompanion.insert(
                id: id,
                title: title,
                isCompleted: isCompleted,
                reminderId: reminderId,
                imagePath: imagePath,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SubRemindersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({reminderId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (reminderId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.reminderId,
                                referencedTable: $$SubRemindersTableReferences
                                    ._reminderIdTable(db),
                                referencedColumn: $$SubRemindersTableReferences
                                    ._reminderIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SubRemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubRemindersTable,
      SubReminder,
      $$SubRemindersTableFilterComposer,
      $$SubRemindersTableOrderingComposer,
      $$SubRemindersTableAnnotationComposer,
      $$SubRemindersTableCreateCompanionBuilder,
      $$SubRemindersTableUpdateCompanionBuilder,
      (SubReminder, $$SubRemindersTableReferences),
      SubReminder,
      PrefetchHooks Function({bool reminderId})
    >;
typedef $$ExercisesTableCreateCompanionBuilder =
    ExercisesCompanion Function({Value<int> id, required String name});
typedef $$ExercisesTableUpdateCompanionBuilder =
    ExercisesCompanion Function({Value<int> id, Value<String> name});

final class $$ExercisesTableReferences
    extends BaseReferences<_$AppDatabase, $ExercisesTable, Exercise> {
  $$ExercisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GymLogsTable, List<GymLog>> _gymLogsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.gymLogs,
    aliasName: $_aliasNameGenerator(db.exercises.id, db.gymLogs.exerciseId),
  );

  $$GymLogsTableProcessedTableManager get gymLogsRefs {
    final manager = $$GymLogsTableTableManager(
      $_db,
      $_db.gymLogs,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gymLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> gymLogsRefs(
    Expression<bool> Function($$GymLogsTableFilterComposer f) f,
  ) {
    final $$GymLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gymLogs,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GymLogsTableFilterComposer(
            $db: $db,
            $table: $db.gymLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> gymLogsRefs<T extends Object>(
    Expression<T> Function($$GymLogsTableAnnotationComposer a) f,
  ) {
    final $$GymLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gymLogs,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GymLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.gymLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExercisesTable,
          Exercise,
          $$ExercisesTableFilterComposer,
          $$ExercisesTableOrderingComposer,
          $$ExercisesTableAnnotationComposer,
          $$ExercisesTableCreateCompanionBuilder,
          $$ExercisesTableUpdateCompanionBuilder,
          (Exercise, $$ExercisesTableReferences),
          Exercise,
          PrefetchHooks Function({bool gymLogsRefs})
        > {
  $$ExercisesTableTableManager(_$AppDatabase db, $ExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => ExercisesCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  ExercisesCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gymLogsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (gymLogsRefs) db.gymLogs],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (gymLogsRefs)
                    await $_getPrefetchedData<
                      Exercise,
                      $ExercisesTable,
                      GymLog
                    >(
                      currentTable: table,
                      referencedTable: $$ExercisesTableReferences
                          ._gymLogsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ExercisesTableReferences(db, table, p0).gymLogsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.exerciseId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExercisesTable,
      Exercise,
      $$ExercisesTableFilterComposer,
      $$ExercisesTableOrderingComposer,
      $$ExercisesTableAnnotationComposer,
      $$ExercisesTableCreateCompanionBuilder,
      $$ExercisesTableUpdateCompanionBuilder,
      (Exercise, $$ExercisesTableReferences),
      Exercise,
      PrefetchHooks Function({bool gymLogsRefs})
    >;
typedef $$GymLogsTableCreateCompanionBuilder =
    GymLogsCompanion Function({
      Value<int> id,
      required int exerciseId,
      required DateTime date,
      required double weight,
      required int reps,
      Value<int> sets,
    });
typedef $$GymLogsTableUpdateCompanionBuilder =
    GymLogsCompanion Function({
      Value<int> id,
      Value<int> exerciseId,
      Value<DateTime> date,
      Value<double> weight,
      Value<int> reps,
      Value<int> sets,
    });

final class $$GymLogsTableReferences
    extends BaseReferences<_$AppDatabase, $GymLogsTable, GymLog> {
  $$GymLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias(
        $_aliasNameGenerator(db.gymLogs.exerciseId, db.exercises.id),
      );

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GymLogsTableFilterComposer
    extends Composer<_$AppDatabase, $GymLogsTable> {
  $$GymLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sets => $composableBuilder(
    column: $table.sets,
    builder: (column) => ColumnFilters(column),
  );

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GymLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $GymLogsTable> {
  $$GymLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sets => $composableBuilder(
    column: $table.sets,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GymLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GymLogsTable> {
  $$GymLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get sets =>
      $composableBuilder(column: $table.sets, builder: (column) => column);

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GymLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GymLogsTable,
          GymLog,
          $$GymLogsTableFilterComposer,
          $$GymLogsTableOrderingComposer,
          $$GymLogsTableAnnotationComposer,
          $$GymLogsTableCreateCompanionBuilder,
          $$GymLogsTableUpdateCompanionBuilder,
          (GymLog, $$GymLogsTableReferences),
          GymLog,
          PrefetchHooks Function({bool exerciseId})
        > {
  $$GymLogsTableTableManager(_$AppDatabase db, $GymLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GymLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GymLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GymLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> exerciseId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<int> sets = const Value.absent(),
              }) => GymLogsCompanion(
                id: id,
                exerciseId: exerciseId,
                date: date,
                weight: weight,
                reps: reps,
                sets: sets,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int exerciseId,
                required DateTime date,
                required double weight,
                required int reps,
                Value<int> sets = const Value.absent(),
              }) => GymLogsCompanion.insert(
                id: id,
                exerciseId: exerciseId,
                date: date,
                weight: weight,
                reps: reps,
                sets: sets,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GymLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable: $$GymLogsTableReferences
                                    ._exerciseIdTable(db),
                                referencedColumn: $$GymLogsTableReferences
                                    ._exerciseIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GymLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GymLogsTable,
      GymLog,
      $$GymLogsTableFilterComposer,
      $$GymLogsTableOrderingComposer,
      $$GymLogsTableAnnotationComposer,
      $$GymLogsTableCreateCompanionBuilder,
      $$GymLogsTableUpdateCompanionBuilder,
      (GymLog, $$GymLogsTableReferences),
      GymLog,
      PrefetchHooks Function({bool exerciseId})
    >;
typedef $$WeightLogsTableCreateCompanionBuilder =
    WeightLogsCompanion Function({
      Value<int> id,
      required DateTime date,
      required double weight,
      Value<double?> bodyFat,
      Value<double?> muscleMass,
    });
typedef $$WeightLogsTableUpdateCompanionBuilder =
    WeightLogsCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<double> weight,
      Value<double?> bodyFat,
      Value<double?> muscleMass,
    });

class $$WeightLogsTableFilterComposer
    extends Composer<_$AppDatabase, $WeightLogsTable> {
  $$WeightLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bodyFat => $composableBuilder(
    column: $table.bodyFat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get muscleMass => $composableBuilder(
    column: $table.muscleMass,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WeightLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $WeightLogsTable> {
  $$WeightLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bodyFat => $composableBuilder(
    column: $table.bodyFat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get muscleMass => $composableBuilder(
    column: $table.muscleMass,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeightLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeightLogsTable> {
  $$WeightLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<double> get bodyFat =>
      $composableBuilder(column: $table.bodyFat, builder: (column) => column);

  GeneratedColumn<double> get muscleMass => $composableBuilder(
    column: $table.muscleMass,
    builder: (column) => column,
  );
}

class $$WeightLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeightLogsTable,
          WeightLog,
          $$WeightLogsTableFilterComposer,
          $$WeightLogsTableOrderingComposer,
          $$WeightLogsTableAnnotationComposer,
          $$WeightLogsTableCreateCompanionBuilder,
          $$WeightLogsTableUpdateCompanionBuilder,
          (
            WeightLog,
            BaseReferences<_$AppDatabase, $WeightLogsTable, WeightLog>,
          ),
          WeightLog,
          PrefetchHooks Function()
        > {
  $$WeightLogsTableTableManager(_$AppDatabase db, $WeightLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeightLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeightLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeightLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<double?> bodyFat = const Value.absent(),
                Value<double?> muscleMass = const Value.absent(),
              }) => WeightLogsCompanion(
                id: id,
                date: date,
                weight: weight,
                bodyFat: bodyFat,
                muscleMass: muscleMass,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required double weight,
                Value<double?> bodyFat = const Value.absent(),
                Value<double?> muscleMass = const Value.absent(),
              }) => WeightLogsCompanion.insert(
                id: id,
                date: date,
                weight: weight,
                bodyFat: bodyFat,
                muscleMass: muscleMass,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeightLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeightLogsTable,
      WeightLog,
      $$WeightLogsTableFilterComposer,
      $$WeightLogsTableOrderingComposer,
      $$WeightLogsTableAnnotationComposer,
      $$WeightLogsTableCreateCompanionBuilder,
      $$WeightLogsTableUpdateCompanionBuilder,
      (WeightLog, BaseReferences<_$AppDatabase, $WeightLogsTable, WeightLog>),
      WeightLog,
      PrefetchHooks Function()
    >;
typedef $$NutritionLogsTableCreateCompanionBuilder =
    NutritionLogsCompanion Function({
      Value<int> id,
      required DateTime date,
      required int calories,
      required int protein,
      required int carbs,
    });
typedef $$NutritionLogsTableUpdateCompanionBuilder =
    NutritionLogsCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<int> calories,
      Value<int> protein,
      Value<int> carbs,
    });

class $$NutritionLogsTableFilterComposer
    extends Composer<_$AppDatabase, $NutritionLogsTable> {
  $$NutritionLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NutritionLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $NutritionLogsTable> {
  $$NutritionLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NutritionLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NutritionLogsTable> {
  $$NutritionLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<int> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<int> get carbs =>
      $composableBuilder(column: $table.carbs, builder: (column) => column);
}

class $$NutritionLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NutritionLogsTable,
          NutritionLog,
          $$NutritionLogsTableFilterComposer,
          $$NutritionLogsTableOrderingComposer,
          $$NutritionLogsTableAnnotationComposer,
          $$NutritionLogsTableCreateCompanionBuilder,
          $$NutritionLogsTableUpdateCompanionBuilder,
          (
            NutritionLog,
            BaseReferences<_$AppDatabase, $NutritionLogsTable, NutritionLog>,
          ),
          NutritionLog,
          PrefetchHooks Function()
        > {
  $$NutritionLogsTableTableManager(_$AppDatabase db, $NutritionLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NutritionLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NutritionLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NutritionLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> calories = const Value.absent(),
                Value<int> protein = const Value.absent(),
                Value<int> carbs = const Value.absent(),
              }) => NutritionLogsCompanion(
                id: id,
                date: date,
                calories: calories,
                protein: protein,
                carbs: carbs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required int calories,
                required int protein,
                required int carbs,
              }) => NutritionLogsCompanion.insert(
                id: id,
                date: date,
                calories: calories,
                protein: protein,
                carbs: carbs,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NutritionLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NutritionLogsTable,
      NutritionLog,
      $$NutritionLogsTableFilterComposer,
      $$NutritionLogsTableOrderingComposer,
      $$NutritionLogsTableAnnotationComposer,
      $$NutritionLogsTableCreateCompanionBuilder,
      $$NutritionLogsTableUpdateCompanionBuilder,
      (
        NutritionLog,
        BaseReferences<_$AppDatabase, $NutritionLogsTable, NutritionLog>,
      ),
      NutritionLog,
      PrefetchHooks Function()
    >;
typedef $$UserGoalsTableCreateCompanionBuilder =
    UserGoalsCompanion Function({
      Value<int> id,
      Value<int> dailyCalorieGoal,
      Value<String?> userName,
    });
typedef $$UserGoalsTableUpdateCompanionBuilder =
    UserGoalsCompanion Function({
      Value<int> id,
      Value<int> dailyCalorieGoal,
      Value<String?> userName,
    });

class $$UserGoalsTableFilterComposer
    extends Composer<_$AppDatabase, $UserGoalsTable> {
  $$UserGoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyCalorieGoal => $composableBuilder(
    column: $table.dailyCalorieGoal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserGoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserGoalsTable> {
  $$UserGoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyCalorieGoal => $composableBuilder(
    column: $table.dailyCalorieGoal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserGoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserGoalsTable> {
  $$UserGoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get dailyCalorieGoal => $composableBuilder(
    column: $table.dailyCalorieGoal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userName =>
      $composableBuilder(column: $table.userName, builder: (column) => column);
}

class $$UserGoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserGoalsTable,
          UserGoal,
          $$UserGoalsTableFilterComposer,
          $$UserGoalsTableOrderingComposer,
          $$UserGoalsTableAnnotationComposer,
          $$UserGoalsTableCreateCompanionBuilder,
          $$UserGoalsTableUpdateCompanionBuilder,
          (UserGoal, BaseReferences<_$AppDatabase, $UserGoalsTable, UserGoal>),
          UserGoal,
          PrefetchHooks Function()
        > {
  $$UserGoalsTableTableManager(_$AppDatabase db, $UserGoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserGoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserGoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserGoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> dailyCalorieGoal = const Value.absent(),
                Value<String?> userName = const Value.absent(),
              }) => UserGoalsCompanion(
                id: id,
                dailyCalorieGoal: dailyCalorieGoal,
                userName: userName,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> dailyCalorieGoal = const Value.absent(),
                Value<String?> userName = const Value.absent(),
              }) => UserGoalsCompanion.insert(
                id: id,
                dailyCalorieGoal: dailyCalorieGoal,
                userName: userName,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserGoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserGoalsTable,
      UserGoal,
      $$UserGoalsTableFilterComposer,
      $$UserGoalsTableOrderingComposer,
      $$UserGoalsTableAnnotationComposer,
      $$UserGoalsTableCreateCompanionBuilder,
      $$UserGoalsTableUpdateCompanionBuilder,
      (UserGoal, BaseReferences<_$AppDatabase, $UserGoalsTable, UserGoal>),
      UserGoal,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$SubRemindersTableTableManager get subReminders =>
      $$SubRemindersTableTableManager(_db, _db.subReminders);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db, _db.exercises);
  $$GymLogsTableTableManager get gymLogs =>
      $$GymLogsTableTableManager(_db, _db.gymLogs);
  $$WeightLogsTableTableManager get weightLogs =>
      $$WeightLogsTableTableManager(_db, _db.weightLogs);
  $$NutritionLogsTableTableManager get nutritionLogs =>
      $$NutritionLogsTableTableManager(_db, _db.nutritionLogs);
  $$UserGoalsTableTableManager get userGoals =>
      $$UserGoalsTableTableManager(_db, _db.userGoals);
}
