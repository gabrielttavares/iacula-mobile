// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_progress_doc.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetChallengeProgressDocCollection on Isar {
  IsarCollection<ChallengeProgressDoc> get challengeProgressDocs =>
      this.collection();
}

const ChallengeProgressDocSchema = CollectionSchema(
  name: r'ChallengeProgressDoc',
  id: 6235687510441278842,
  properties: {
    r'challengeId': PropertySchema(
      id: 0,
      name: r'challengeId',
      type: IsarType.string,
    ),
    r'completedAt': PropertySchema(
      id: 1,
      name: r'completedAt',
      type: IsarType.dateTime,
    ),
    r'completedDaysJson': PropertySchema(
      id: 2,
      name: r'completedDaysJson',
      type: IsarType.string,
    ),
    r'isCompleted': PropertySchema(
      id: 3,
      name: r'isCompleted',
      type: IsarType.bool,
    ),
    r'startDate': PropertySchema(
      id: 4,
      name: r'startDate',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _challengeProgressDocEstimateSize,
  serialize: _challengeProgressDocSerialize,
  deserialize: _challengeProgressDocDeserialize,
  deserializeProp: _challengeProgressDocDeserializeProp,
  idName: r'id',
  indexes: {
    r'challengeId': IndexSchema(
      id: 4483557487511118379,
      name: r'challengeId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'challengeId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _challengeProgressDocGetId,
  getLinks: _challengeProgressDocGetLinks,
  attach: _challengeProgressDocAttach,
  version: '3.1.0+1',
);

int _challengeProgressDocEstimateSize(
  ChallengeProgressDoc object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.challengeId.length * 3;
  bytesCount += 3 + object.completedDaysJson.length * 3;
  return bytesCount;
}

void _challengeProgressDocSerialize(
  ChallengeProgressDoc object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.challengeId);
  writer.writeDateTime(offsets[1], object.completedAt);
  writer.writeString(offsets[2], object.completedDaysJson);
  writer.writeBool(offsets[3], object.isCompleted);
  writer.writeDateTime(offsets[4], object.startDate);
}

ChallengeProgressDoc _challengeProgressDocDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ChallengeProgressDoc();
  object.challengeId = reader.readString(offsets[0]);
  object.completedAt = reader.readDateTimeOrNull(offsets[1]);
  object.completedDaysJson = reader.readString(offsets[2]);
  object.id = id;
  object.isCompleted = reader.readBool(offsets[3]);
  object.startDate = reader.readDateTime(offsets[4]);
  return object;
}

P _challengeProgressDocDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _challengeProgressDocGetId(ChallengeProgressDoc object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _challengeProgressDocGetLinks(
    ChallengeProgressDoc object) {
  return [];
}

void _challengeProgressDocAttach(
    IsarCollection<dynamic> col, Id id, ChallengeProgressDoc object) {
  object.id = id;
}

extension ChallengeProgressDocByIndex on IsarCollection<ChallengeProgressDoc> {
  Future<ChallengeProgressDoc?> getByChallengeId(String challengeId) {
    return getByIndex(r'challengeId', [challengeId]);
  }

  ChallengeProgressDoc? getByChallengeIdSync(String challengeId) {
    return getByIndexSync(r'challengeId', [challengeId]);
  }

  Future<bool> deleteByChallengeId(String challengeId) {
    return deleteByIndex(r'challengeId', [challengeId]);
  }

  bool deleteByChallengeIdSync(String challengeId) {
    return deleteByIndexSync(r'challengeId', [challengeId]);
  }

  Future<List<ChallengeProgressDoc?>> getAllByChallengeId(
      List<String> challengeIdValues) {
    final values = challengeIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'challengeId', values);
  }

  List<ChallengeProgressDoc?> getAllByChallengeIdSync(
      List<String> challengeIdValues) {
    final values = challengeIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'challengeId', values);
  }

  Future<int> deleteAllByChallengeId(List<String> challengeIdValues) {
    final values = challengeIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'challengeId', values);
  }

  int deleteAllByChallengeIdSync(List<String> challengeIdValues) {
    final values = challengeIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'challengeId', values);
  }

  Future<Id> putByChallengeId(ChallengeProgressDoc object) {
    return putByIndex(r'challengeId', object);
  }

  Id putByChallengeIdSync(ChallengeProgressDoc object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'challengeId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByChallengeId(List<ChallengeProgressDoc> objects) {
    return putAllByIndex(r'challengeId', objects);
  }

  List<Id> putAllByChallengeIdSync(List<ChallengeProgressDoc> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'challengeId', objects, saveLinks: saveLinks);
  }
}

extension ChallengeProgressDocQueryWhereSort
    on QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QWhere> {
  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ChallengeProgressDocQueryWhere
    on QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QWhereClause> {
  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QAfterWhereClause>
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

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QAfterWhereClause>
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

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QAfterWhereClause>
      challengeIdEqualTo(String challengeId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'challengeId',
        value: [challengeId],
      ));
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QAfterWhereClause>
      challengeIdNotEqualTo(String challengeId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'challengeId',
              lower: [],
              upper: [challengeId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'challengeId',
              lower: [challengeId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'challengeId',
              lower: [challengeId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'challengeId',
              lower: [],
              upper: [challengeId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ChallengeProgressDocQueryFilter on QueryBuilder<ChallengeProgressDoc,
    ChallengeProgressDoc, QFilterCondition> {
  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc,
      QAfterFilterCondition> challengeIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'challengeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc,
      QAfterFilterCondition> challengeIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'challengeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc,
      QAfterFilterCondition> challengeIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'challengeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc,
      QAfterFilterCondition> challengeIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'challengeId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc,
      QAfterFilterCondition> challengeIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'challengeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc,
      QAfterFilterCondition> challengeIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'challengeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc,
          QAfterFilterCondition>
      challengeIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'challengeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc,
          QAfterFilterCondition>
      challengeIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'challengeId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc,
      QAfterFilterCondition> challengeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'challengeId',
        value: '',
      ));
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc,
      QAfterFilterCondition> challengeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'challengeId',
        value: '',
      ));
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc,
      QAfterFilterCondition> completedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc,
      QAfterFilterCondition> completedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc,
      QAfterFilterCondition> completedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc,
      QAfterFilterCondition> completedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc,
      QAfterFilterCondition> completedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc,
      QAfterFilterCondition> completedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc,
      QAfterFilterCondition> completedDaysJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedDaysJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc,
      QAfterFilterCondition> completedDaysJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedDaysJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc,
      QAfterFilterCondition> completedDaysJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedDaysJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc,
      QAfterFilterCondition> completedDaysJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedDaysJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc,
      QAfterFilterCondition> completedDaysJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'completedDaysJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc,
      QAfterFilterCondition> completedDaysJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'completedDaysJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc,
          QAfterFilterCondition>
      completedDaysJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'completedDaysJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc,
          QAfterFilterCondition>
      completedDaysJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'completedDaysJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc,
      QAfterFilterCondition> completedDaysJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedDaysJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc,
      QAfterFilterCondition> completedDaysJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'completedDaysJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc,
      QAfterFilterCondition> isCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc,
      QAfterFilterCondition> startDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc,
      QAfterFilterCondition> startDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc,
      QAfterFilterCondition> startDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc,
      QAfterFilterCondition> startDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ChallengeProgressDocQueryObject on QueryBuilder<ChallengeProgressDoc,
    ChallengeProgressDoc, QFilterCondition> {}

extension ChallengeProgressDocQueryLinks on QueryBuilder<ChallengeProgressDoc,
    ChallengeProgressDoc, QFilterCondition> {}

extension ChallengeProgressDocQuerySortBy
    on QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QSortBy> {
  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QAfterSortBy>
      sortByChallengeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'challengeId', Sort.asc);
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QAfterSortBy>
      sortByChallengeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'challengeId', Sort.desc);
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QAfterSortBy>
      sortByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QAfterSortBy>
      sortByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QAfterSortBy>
      sortByCompletedDaysJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedDaysJson', Sort.asc);
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QAfterSortBy>
      sortByCompletedDaysJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedDaysJson', Sort.desc);
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QAfterSortBy>
      sortByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QAfterSortBy>
      sortByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QAfterSortBy>
      sortByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QAfterSortBy>
      sortByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }
}

extension ChallengeProgressDocQuerySortThenBy
    on QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QSortThenBy> {
  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QAfterSortBy>
      thenByChallengeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'challengeId', Sort.asc);
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QAfterSortBy>
      thenByChallengeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'challengeId', Sort.desc);
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QAfterSortBy>
      thenByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QAfterSortBy>
      thenByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QAfterSortBy>
      thenByCompletedDaysJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedDaysJson', Sort.asc);
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QAfterSortBy>
      thenByCompletedDaysJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedDaysJson', Sort.desc);
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QAfterSortBy>
      thenByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QAfterSortBy>
      thenByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QAfterSortBy>
      thenByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QAfterSortBy>
      thenByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }
}

extension ChallengeProgressDocQueryWhereDistinct
    on QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QDistinct> {
  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QDistinct>
      distinctByChallengeId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'challengeId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QDistinct>
      distinctByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedAt');
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QDistinct>
      distinctByCompletedDaysJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedDaysJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QDistinct>
      distinctByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCompleted');
    });
  }

  QueryBuilder<ChallengeProgressDoc, ChallengeProgressDoc, QDistinct>
      distinctByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startDate');
    });
  }
}

extension ChallengeProgressDocQueryProperty on QueryBuilder<
    ChallengeProgressDoc, ChallengeProgressDoc, QQueryProperty> {
  QueryBuilder<ChallengeProgressDoc, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ChallengeProgressDoc, String, QQueryOperations>
      challengeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'challengeId');
    });
  }

  QueryBuilder<ChallengeProgressDoc, DateTime?, QQueryOperations>
      completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedAt');
    });
  }

  QueryBuilder<ChallengeProgressDoc, String, QQueryOperations>
      completedDaysJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedDaysJson');
    });
  }

  QueryBuilder<ChallengeProgressDoc, bool, QQueryOperations>
      isCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCompleted');
    });
  }

  QueryBuilder<ChallengeProgressDoc, DateTime, QQueryOperations>
      startDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startDate');
    });
  }
}
