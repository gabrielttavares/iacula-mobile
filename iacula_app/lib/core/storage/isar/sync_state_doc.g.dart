// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_state_doc.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSyncStateDocCollection on Isar {
  IsarCollection<SyncStateDoc> get syncStateDocs => this.collection();
}

const SyncStateDocSchema = CollectionSchema(
  name: r'SyncStateDoc',
  id: 3482222898139063929,
  properties: {
    r'lastError': PropertySchema(
      id: 0,
      name: r'lastError',
      type: IsarType.string,
    ),
    r'lastPullAt': PropertySchema(
      id: 1,
      name: r'lastPullAt',
      type: IsarType.dateTime,
    ),
    r'lastPushAt': PropertySchema(
      id: 2,
      name: r'lastPushAt',
      type: IsarType.dateTime,
    ),
    r'lastSyncedAt': PropertySchema(
      id: 3,
      name: r'lastSyncedAt',
      type: IsarType.dateTime,
    ),
    r'module': PropertySchema(
      id: 4,
      name: r'module',
      type: IsarType.string,
    )
  },
  estimateSize: _syncStateDocEstimateSize,
  serialize: _syncStateDocSerialize,
  deserialize: _syncStateDocDeserialize,
  deserializeProp: _syncStateDocDeserializeProp,
  idName: r'id',
  indexes: {
    r'module': IndexSchema(
      id: -8372774152552671714,
      name: r'module',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'module',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _syncStateDocGetId,
  getLinks: _syncStateDocGetLinks,
  attach: _syncStateDocAttach,
  version: '3.1.0+1',
);

int _syncStateDocEstimateSize(
  SyncStateDoc object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.lastError;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.module.length * 3;
  return bytesCount;
}

void _syncStateDocSerialize(
  SyncStateDoc object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.lastError);
  writer.writeDateTime(offsets[1], object.lastPullAt);
  writer.writeDateTime(offsets[2], object.lastPushAt);
  writer.writeDateTime(offsets[3], object.lastSyncedAt);
  writer.writeString(offsets[4], object.module);
}

SyncStateDoc _syncStateDocDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SyncStateDoc();
  object.id = id;
  object.lastError = reader.readStringOrNull(offsets[0]);
  object.lastPullAt = reader.readDateTimeOrNull(offsets[1]);
  object.lastPushAt = reader.readDateTimeOrNull(offsets[2]);
  object.lastSyncedAt = reader.readDateTimeOrNull(offsets[3]);
  object.module = reader.readString(offsets[4]);
  return object;
}

P _syncStateDocDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _syncStateDocGetId(SyncStateDoc object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _syncStateDocGetLinks(SyncStateDoc object) {
  return [];
}

void _syncStateDocAttach(
    IsarCollection<dynamic> col, Id id, SyncStateDoc object) {
  object.id = id;
}

extension SyncStateDocByIndex on IsarCollection<SyncStateDoc> {
  Future<SyncStateDoc?> getByModule(String module) {
    return getByIndex(r'module', [module]);
  }

  SyncStateDoc? getByModuleSync(String module) {
    return getByIndexSync(r'module', [module]);
  }

  Future<bool> deleteByModule(String module) {
    return deleteByIndex(r'module', [module]);
  }

  bool deleteByModuleSync(String module) {
    return deleteByIndexSync(r'module', [module]);
  }

  Future<List<SyncStateDoc?>> getAllByModule(List<String> moduleValues) {
    final values = moduleValues.map((e) => [e]).toList();
    return getAllByIndex(r'module', values);
  }

  List<SyncStateDoc?> getAllByModuleSync(List<String> moduleValues) {
    final values = moduleValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'module', values);
  }

  Future<int> deleteAllByModule(List<String> moduleValues) {
    final values = moduleValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'module', values);
  }

  int deleteAllByModuleSync(List<String> moduleValues) {
    final values = moduleValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'module', values);
  }

  Future<Id> putByModule(SyncStateDoc object) {
    return putByIndex(r'module', object);
  }

  Id putByModuleSync(SyncStateDoc object, {bool saveLinks = true}) {
    return putByIndexSync(r'module', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByModule(List<SyncStateDoc> objects) {
    return putAllByIndex(r'module', objects);
  }

  List<Id> putAllByModuleSync(List<SyncStateDoc> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'module', objects, saveLinks: saveLinks);
  }
}

extension SyncStateDocQueryWhereSort
    on QueryBuilder<SyncStateDoc, SyncStateDoc, QWhere> {
  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SyncStateDocQueryWhere
    on QueryBuilder<SyncStateDoc, SyncStateDoc, QWhereClause> {
  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterWhereClause> moduleEqualTo(
      String module) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'module',
        value: [module],
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterWhereClause> moduleNotEqualTo(
      String module) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'module',
              lower: [],
              upper: [module],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'module',
              lower: [module],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'module',
              lower: [module],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'module',
              lower: [],
              upper: [module],
              includeUpper: false,
            ));
      }
    });
  }
}

extension SyncStateDocQueryFilter
    on QueryBuilder<SyncStateDoc, SyncStateDoc, QFilterCondition> {
  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      lastErrorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastError',
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      lastErrorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastError',
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      lastErrorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      lastErrorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      lastErrorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      lastErrorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastError',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      lastErrorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      lastErrorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      lastErrorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      lastErrorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastError',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      lastErrorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastError',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      lastErrorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastError',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      lastPullAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastPullAt',
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      lastPullAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastPullAt',
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      lastPullAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPullAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      lastPullAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastPullAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      lastPullAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastPullAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      lastPullAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastPullAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      lastPushAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastPushAt',
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      lastPushAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastPushAt',
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      lastPushAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPushAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      lastPushAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastPushAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      lastPushAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastPushAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      lastPushAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastPushAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      lastSyncedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSyncedAt',
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      lastSyncedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSyncedAt',
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      lastSyncedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSyncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      lastSyncedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSyncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      lastSyncedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSyncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      lastSyncedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSyncedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition> moduleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'module',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      moduleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'module',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      moduleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'module',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition> moduleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'module',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      moduleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'module',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      moduleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'module',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      moduleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'module',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition> moduleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'module',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      moduleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'module',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterFilterCondition>
      moduleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'module',
        value: '',
      ));
    });
  }
}

extension SyncStateDocQueryObject
    on QueryBuilder<SyncStateDoc, SyncStateDoc, QFilterCondition> {}

extension SyncStateDocQueryLinks
    on QueryBuilder<SyncStateDoc, SyncStateDoc, QFilterCondition> {}

extension SyncStateDocQuerySortBy
    on QueryBuilder<SyncStateDoc, SyncStateDoc, QSortBy> {
  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterSortBy> sortByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterSortBy> sortByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterSortBy> sortByLastPullAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPullAt', Sort.asc);
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterSortBy>
      sortByLastPullAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPullAt', Sort.desc);
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterSortBy> sortByLastPushAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPushAt', Sort.asc);
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterSortBy>
      sortByLastPushAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPushAt', Sort.desc);
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterSortBy> sortByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterSortBy>
      sortByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterSortBy> sortByModule() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'module', Sort.asc);
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterSortBy> sortByModuleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'module', Sort.desc);
    });
  }
}

extension SyncStateDocQuerySortThenBy
    on QueryBuilder<SyncStateDoc, SyncStateDoc, QSortThenBy> {
  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterSortBy> thenByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterSortBy> thenByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterSortBy> thenByLastPullAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPullAt', Sort.asc);
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterSortBy>
      thenByLastPullAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPullAt', Sort.desc);
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterSortBy> thenByLastPushAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPushAt', Sort.asc);
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterSortBy>
      thenByLastPushAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPushAt', Sort.desc);
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterSortBy> thenByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterSortBy>
      thenByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterSortBy> thenByModule() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'module', Sort.asc);
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QAfterSortBy> thenByModuleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'module', Sort.desc);
    });
  }
}

extension SyncStateDocQueryWhereDistinct
    on QueryBuilder<SyncStateDoc, SyncStateDoc, QDistinct> {
  QueryBuilder<SyncStateDoc, SyncStateDoc, QDistinct> distinctByLastError(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastError', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QDistinct> distinctByLastPullAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPullAt');
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QDistinct> distinctByLastPushAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPushAt');
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QDistinct> distinctByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncedAt');
    });
  }

  QueryBuilder<SyncStateDoc, SyncStateDoc, QDistinct> distinctByModule(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'module', caseSensitive: caseSensitive);
    });
  }
}

extension SyncStateDocQueryProperty
    on QueryBuilder<SyncStateDoc, SyncStateDoc, QQueryProperty> {
  QueryBuilder<SyncStateDoc, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SyncStateDoc, String?, QQueryOperations> lastErrorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastError');
    });
  }

  QueryBuilder<SyncStateDoc, DateTime?, QQueryOperations> lastPullAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPullAt');
    });
  }

  QueryBuilder<SyncStateDoc, DateTime?, QQueryOperations> lastPushAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPushAt');
    });
  }

  QueryBuilder<SyncStateDoc, DateTime?, QQueryOperations>
      lastSyncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncedAt');
    });
  }

  QueryBuilder<SyncStateDoc, String, QQueryOperations> moduleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'module');
    });
  }
}
