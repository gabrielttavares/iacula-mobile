// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_activity_doc.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPrayerActivityDocCollection on Isar {
  IsarCollection<PrayerActivityDoc> get prayerActivityDocs => this.collection();
}

const PrayerActivityDocSchema = CollectionSchema(
  name: r'PrayerActivityDoc',
  id: -5036865371717428942,
  properties: {
    r'activityId': PropertySchema(
      id: 0,
      name: r'activityId',
      type: IsarType.string,
    ),
    r'activityType': PropertySchema(
      id: 1,
      name: r'activityType',
      type: IsarType.string,
      enumMap: _PrayerActivityDocactivityTypeEnumValueMap,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'date': PropertySchema(
      id: 3,
      name: r'date',
      type: IsarType.string,
    ),
    r'durationSeconds': PropertySchema(
      id: 4,
      name: r'durationSeconds',
      type: IsarType.long,
    ),
    r'featureSlug': PropertySchema(
      id: 5,
      name: r'featureSlug',
      type: IsarType.string,
    )
  },
  estimateSize: _prayerActivityDocEstimateSize,
  serialize: _prayerActivityDocSerialize,
  deserialize: _prayerActivityDocDeserialize,
  deserializeProp: _prayerActivityDocDeserializeProp,
  idName: r'id',
  indexes: {
    r'activityId': IndexSchema(
      id: 8968520805042838249,
      name: r'activityId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'activityId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'date',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _prayerActivityDocGetId,
  getLinks: _prayerActivityDocGetLinks,
  attach: _prayerActivityDocAttach,
  version: '3.1.0+1',
);

int _prayerActivityDocEstimateSize(
  PrayerActivityDoc object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.activityId.length * 3;
  bytesCount += 3 + object.activityType.name.length * 3;
  bytesCount += 3 + object.date.length * 3;
  {
    final value = object.featureSlug;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _prayerActivityDocSerialize(
  PrayerActivityDoc object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.activityId);
  writer.writeString(offsets[1], object.activityType.name);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.date);
  writer.writeLong(offsets[4], object.durationSeconds);
  writer.writeString(offsets[5], object.featureSlug);
}

PrayerActivityDoc _prayerActivityDocDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PrayerActivityDoc();
  object.activityId = reader.readString(offsets[0]);
  object.activityType = _PrayerActivityDocactivityTypeValueEnumMap[
          reader.readStringOrNull(offsets[1])] ??
      PrayerActivityTypeDoc.prayer;
  object.createdAt = reader.readDateTime(offsets[2]);
  object.date = reader.readString(offsets[3]);
  object.durationSeconds = reader.readLong(offsets[4]);
  object.featureSlug = reader.readStringOrNull(offsets[5]);
  object.id = id;
  return object;
}

P _prayerActivityDocDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (_PrayerActivityDocactivityTypeValueEnumMap[
              reader.readStringOrNull(offset)] ??
          PrayerActivityTypeDoc.prayer) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _PrayerActivityDocactivityTypeEnumValueMap = {
  r'prayer': r'prayer',
  r'meditation': r'meditation',
  r'examination': r'examination',
  r'rosary': r'rosary',
  r'challenge': r'challenge',
  r'nightPrayer': r'nightPrayer',
  r'liturgyOfHours': r'liturgyOfHours',
  r'journal': r'journal',
};
const _PrayerActivityDocactivityTypeValueEnumMap = {
  r'prayer': PrayerActivityTypeDoc.prayer,
  r'meditation': PrayerActivityTypeDoc.meditation,
  r'examination': PrayerActivityTypeDoc.examination,
  r'rosary': PrayerActivityTypeDoc.rosary,
  r'challenge': PrayerActivityTypeDoc.challenge,
  r'nightPrayer': PrayerActivityTypeDoc.nightPrayer,
  r'liturgyOfHours': PrayerActivityTypeDoc.liturgyOfHours,
  r'journal': PrayerActivityTypeDoc.journal,
};

Id _prayerActivityDocGetId(PrayerActivityDoc object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _prayerActivityDocGetLinks(
    PrayerActivityDoc object) {
  return [];
}

void _prayerActivityDocAttach(
    IsarCollection<dynamic> col, Id id, PrayerActivityDoc object) {
  object.id = id;
}

extension PrayerActivityDocByIndex on IsarCollection<PrayerActivityDoc> {
  Future<PrayerActivityDoc?> getByActivityId(String activityId) {
    return getByIndex(r'activityId', [activityId]);
  }

  PrayerActivityDoc? getByActivityIdSync(String activityId) {
    return getByIndexSync(r'activityId', [activityId]);
  }

  Future<bool> deleteByActivityId(String activityId) {
    return deleteByIndex(r'activityId', [activityId]);
  }

  bool deleteByActivityIdSync(String activityId) {
    return deleteByIndexSync(r'activityId', [activityId]);
  }

  Future<List<PrayerActivityDoc?>> getAllByActivityId(
      List<String> activityIdValues) {
    final values = activityIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'activityId', values);
  }

  List<PrayerActivityDoc?> getAllByActivityIdSync(
      List<String> activityIdValues) {
    final values = activityIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'activityId', values);
  }

  Future<int> deleteAllByActivityId(List<String> activityIdValues) {
    final values = activityIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'activityId', values);
  }

  int deleteAllByActivityIdSync(List<String> activityIdValues) {
    final values = activityIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'activityId', values);
  }

  Future<Id> putByActivityId(PrayerActivityDoc object) {
    return putByIndex(r'activityId', object);
  }

  Id putByActivityIdSync(PrayerActivityDoc object, {bool saveLinks = true}) {
    return putByIndexSync(r'activityId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByActivityId(List<PrayerActivityDoc> objects) {
    return putAllByIndex(r'activityId', objects);
  }

  List<Id> putAllByActivityIdSync(List<PrayerActivityDoc> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'activityId', objects, saveLinks: saveLinks);
  }
}

extension PrayerActivityDocQueryWhereSort
    on QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QWhere> {
  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PrayerActivityDocQueryWhere
    on QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QWhereClause> {
  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterWhereClause>
      activityIdEqualTo(String activityId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'activityId',
        value: [activityId],
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterWhereClause>
      activityIdNotEqualTo(String activityId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'activityId',
              lower: [],
              upper: [activityId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'activityId',
              lower: [activityId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'activityId',
              lower: [activityId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'activityId',
              lower: [],
              upper: [activityId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterWhereClause>
      dateEqualTo(String date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterWhereClause>
      dateNotEqualTo(String date) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PrayerActivityDocQueryFilter
    on QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QFilterCondition> {
  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      activityIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      activityIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      activityIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      activityIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activityId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      activityIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'activityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      activityIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'activityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      activityIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'activityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      activityIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'activityId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      activityIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activityId',
        value: '',
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      activityIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'activityId',
        value: '',
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      activityTypeEqualTo(
    PrayerActivityTypeDoc value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      activityTypeGreaterThan(
    PrayerActivityTypeDoc value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      activityTypeLessThan(
    PrayerActivityTypeDoc value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      activityTypeBetween(
    PrayerActivityTypeDoc lower,
    PrayerActivityTypeDoc upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activityType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      activityTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'activityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      activityTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'activityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      activityTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'activityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      activityTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'activityType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      activityTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activityType',
        value: '',
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      activityTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'activityType',
        value: '',
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      dateEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      dateGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      dateLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      dateBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      dateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      dateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      dateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      dateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'date',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      dateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: '',
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      dateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'date',
        value: '',
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      durationSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'durationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      durationSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'durationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      durationSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'durationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      durationSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'durationSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      featureSlugIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'featureSlug',
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      featureSlugIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'featureSlug',
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      featureSlugEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'featureSlug',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      featureSlugGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'featureSlug',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      featureSlugLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'featureSlug',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      featureSlugBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'featureSlug',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      featureSlugStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'featureSlug',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      featureSlugEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'featureSlug',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      featureSlugContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'featureSlug',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      featureSlugMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'featureSlug',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      featureSlugIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'featureSlug',
        value: '',
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      featureSlugIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'featureSlug',
        value: '',
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterFilterCondition>
      idBetween(
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
}

extension PrayerActivityDocQueryObject
    on QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QFilterCondition> {}

extension PrayerActivityDocQueryLinks
    on QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QFilterCondition> {}

extension PrayerActivityDocQuerySortBy
    on QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QSortBy> {
  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterSortBy>
      sortByActivityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityId', Sort.asc);
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterSortBy>
      sortByActivityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityId', Sort.desc);
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterSortBy>
      sortByActivityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityType', Sort.asc);
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterSortBy>
      sortByActivityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityType', Sort.desc);
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterSortBy>
      sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterSortBy>
      sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterSortBy>
      sortByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.asc);
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterSortBy>
      sortByDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.desc);
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterSortBy>
      sortByFeatureSlug() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'featureSlug', Sort.asc);
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterSortBy>
      sortByFeatureSlugDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'featureSlug', Sort.desc);
    });
  }
}

extension PrayerActivityDocQuerySortThenBy
    on QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QSortThenBy> {
  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterSortBy>
      thenByActivityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityId', Sort.asc);
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterSortBy>
      thenByActivityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityId', Sort.desc);
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterSortBy>
      thenByActivityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityType', Sort.asc);
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterSortBy>
      thenByActivityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityType', Sort.desc);
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterSortBy>
      thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterSortBy>
      thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterSortBy>
      thenByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.asc);
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterSortBy>
      thenByDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.desc);
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterSortBy>
      thenByFeatureSlug() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'featureSlug', Sort.asc);
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterSortBy>
      thenByFeatureSlugDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'featureSlug', Sort.desc);
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension PrayerActivityDocQueryWhereDistinct
    on QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QDistinct> {
  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QDistinct>
      distinctByActivityId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activityId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QDistinct>
      distinctByActivityType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activityType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QDistinct> distinctByDate(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QDistinct>
      distinctByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationSeconds');
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QDistinct>
      distinctByFeatureSlug({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'featureSlug', caseSensitive: caseSensitive);
    });
  }
}

extension PrayerActivityDocQueryProperty
    on QueryBuilder<PrayerActivityDoc, PrayerActivityDoc, QQueryProperty> {
  QueryBuilder<PrayerActivityDoc, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PrayerActivityDoc, String, QQueryOperations>
      activityIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activityId');
    });
  }

  QueryBuilder<PrayerActivityDoc, PrayerActivityTypeDoc, QQueryOperations>
      activityTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activityType');
    });
  }

  QueryBuilder<PrayerActivityDoc, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<PrayerActivityDoc, String, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<PrayerActivityDoc, int, QQueryOperations>
      durationSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationSeconds');
    });
  }

  QueryBuilder<PrayerActivityDoc, String?, QQueryOperations>
      featureSlugProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'featureSlug');
    });
  }
}
