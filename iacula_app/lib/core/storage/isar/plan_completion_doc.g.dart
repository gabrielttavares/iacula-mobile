// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_completion_doc.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPlanCompletionDocCollection on Isar {
  IsarCollection<PlanCompletionDoc> get planCompletionDocs => this.collection();
}

const PlanCompletionDocSchema = CollectionSchema(
  name: r'PlanCompletionDoc',
  id: 5551192542346274244,
  properties: {
    r'completedAt': PropertySchema(
      id: 0,
      name: r'completedAt',
      type: IsarType.dateTime,
    ),
    r'completionId': PropertySchema(
      id: 1,
      name: r'completionId',
      type: IsarType.string,
    ),
    r'date': PropertySchema(
      id: 2,
      name: r'date',
      type: IsarType.string,
    ),
    r'itemId': PropertySchema(
      id: 3,
      name: r'itemId',
      type: IsarType.string,
    )
  },
  estimateSize: _planCompletionDocEstimateSize,
  serialize: _planCompletionDocSerialize,
  deserialize: _planCompletionDocDeserialize,
  deserializeProp: _planCompletionDocDeserializeProp,
  idName: r'id',
  indexes: {
    r'completionId': IndexSchema(
      id: 5329090822865473160,
      name: r'completionId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'completionId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'itemId': IndexSchema(
      id: -5342806140158601489,
      name: r'itemId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'itemId',
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
  getId: _planCompletionDocGetId,
  getLinks: _planCompletionDocGetLinks,
  attach: _planCompletionDocAttach,
  version: '3.1.0+1',
);

int _planCompletionDocEstimateSize(
  PlanCompletionDoc object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.completionId.length * 3;
  bytesCount += 3 + object.date.length * 3;
  bytesCount += 3 + object.itemId.length * 3;
  return bytesCount;
}

void _planCompletionDocSerialize(
  PlanCompletionDoc object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.completedAt);
  writer.writeString(offsets[1], object.completionId);
  writer.writeString(offsets[2], object.date);
  writer.writeString(offsets[3], object.itemId);
}

PlanCompletionDoc _planCompletionDocDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlanCompletionDoc();
  object.completedAt = reader.readDateTime(offsets[0]);
  object.completionId = reader.readString(offsets[1]);
  object.date = reader.readString(offsets[2]);
  object.id = id;
  object.itemId = reader.readString(offsets[3]);
  return object;
}

P _planCompletionDocDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _planCompletionDocGetId(PlanCompletionDoc object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _planCompletionDocGetLinks(
    PlanCompletionDoc object) {
  return [];
}

void _planCompletionDocAttach(
    IsarCollection<dynamic> col, Id id, PlanCompletionDoc object) {
  object.id = id;
}

extension PlanCompletionDocByIndex on IsarCollection<PlanCompletionDoc> {
  Future<PlanCompletionDoc?> getByCompletionId(String completionId) {
    return getByIndex(r'completionId', [completionId]);
  }

  PlanCompletionDoc? getByCompletionIdSync(String completionId) {
    return getByIndexSync(r'completionId', [completionId]);
  }

  Future<bool> deleteByCompletionId(String completionId) {
    return deleteByIndex(r'completionId', [completionId]);
  }

  bool deleteByCompletionIdSync(String completionId) {
    return deleteByIndexSync(r'completionId', [completionId]);
  }

  Future<List<PlanCompletionDoc?>> getAllByCompletionId(
      List<String> completionIdValues) {
    final values = completionIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'completionId', values);
  }

  List<PlanCompletionDoc?> getAllByCompletionIdSync(
      List<String> completionIdValues) {
    final values = completionIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'completionId', values);
  }

  Future<int> deleteAllByCompletionId(List<String> completionIdValues) {
    final values = completionIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'completionId', values);
  }

  int deleteAllByCompletionIdSync(List<String> completionIdValues) {
    final values = completionIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'completionId', values);
  }

  Future<Id> putByCompletionId(PlanCompletionDoc object) {
    return putByIndex(r'completionId', object);
  }

  Id putByCompletionIdSync(PlanCompletionDoc object, {bool saveLinks = true}) {
    return putByIndexSync(r'completionId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCompletionId(List<PlanCompletionDoc> objects) {
    return putAllByIndex(r'completionId', objects);
  }

  List<Id> putAllByCompletionIdSync(List<PlanCompletionDoc> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'completionId', objects, saveLinks: saveLinks);
  }
}

extension PlanCompletionDocQueryWhereSort
    on QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QWhere> {
  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PlanCompletionDocQueryWhere
    on QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QWhereClause> {
  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterWhereClause>
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

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterWhereClause>
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

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterWhereClause>
      completionIdEqualTo(String completionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'completionId',
        value: [completionId],
      ));
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterWhereClause>
      completionIdNotEqualTo(String completionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'completionId',
              lower: [],
              upper: [completionId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'completionId',
              lower: [completionId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'completionId',
              lower: [completionId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'completionId',
              lower: [],
              upper: [completionId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterWhereClause>
      itemIdEqualTo(String itemId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'itemId',
        value: [itemId],
      ));
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterWhereClause>
      itemIdNotEqualTo(String itemId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'itemId',
              lower: [],
              upper: [itemId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'itemId',
              lower: [itemId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'itemId',
              lower: [itemId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'itemId',
              lower: [],
              upper: [itemId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterWhereClause>
      dateEqualTo(String date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterWhereClause>
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

extension PlanCompletionDocQueryFilter
    on QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QFilterCondition> {
  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
      completedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
      completedAtGreaterThan(
    DateTime value, {
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

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
      completedAtLessThan(
    DateTime value, {
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

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
      completedAtBetween(
    DateTime lower,
    DateTime upper, {
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

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
      completionIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
      completionIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
      completionIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
      completionIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
      completionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'completionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
      completionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'completionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
      completionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'completionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
      completionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'completionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
      completionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completionId',
        value: '',
      ));
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
      completionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'completionId',
        value: '',
      ));
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
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

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
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

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
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

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
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

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
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

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
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

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
      dateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
      dateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'date',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
      dateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: '',
      ));
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
      dateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'date',
        value: '',
      ));
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
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

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
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

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
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

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
      itemIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
      itemIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
      itemIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
      itemIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'itemId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
      itemIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
      itemIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
      itemIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
      itemIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'itemId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
      itemIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemId',
        value: '',
      ));
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterFilterCondition>
      itemIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'itemId',
        value: '',
      ));
    });
  }
}

extension PlanCompletionDocQueryObject
    on QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QFilterCondition> {}

extension PlanCompletionDocQueryLinks
    on QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QFilterCondition> {}

extension PlanCompletionDocQuerySortBy
    on QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QSortBy> {
  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterSortBy>
      sortByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterSortBy>
      sortByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterSortBy>
      sortByCompletionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionId', Sort.asc);
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterSortBy>
      sortByCompletionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionId', Sort.desc);
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterSortBy>
      sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterSortBy>
      sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterSortBy>
      sortByItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.asc);
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterSortBy>
      sortByItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.desc);
    });
  }
}

extension PlanCompletionDocQuerySortThenBy
    on QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QSortThenBy> {
  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterSortBy>
      thenByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterSortBy>
      thenByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterSortBy>
      thenByCompletionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionId', Sort.asc);
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterSortBy>
      thenByCompletionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionId', Sort.desc);
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterSortBy>
      thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterSortBy>
      thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterSortBy>
      thenByItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.asc);
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QAfterSortBy>
      thenByItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.desc);
    });
  }
}

extension PlanCompletionDocQueryWhereDistinct
    on QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QDistinct> {
  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QDistinct>
      distinctByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedAt');
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QDistinct>
      distinctByCompletionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completionId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QDistinct> distinctByDate(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QDistinct>
      distinctByItemId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itemId', caseSensitive: caseSensitive);
    });
  }
}

extension PlanCompletionDocQueryProperty
    on QueryBuilder<PlanCompletionDoc, PlanCompletionDoc, QQueryProperty> {
  QueryBuilder<PlanCompletionDoc, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PlanCompletionDoc, DateTime, QQueryOperations>
      completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedAt');
    });
  }

  QueryBuilder<PlanCompletionDoc, String, QQueryOperations>
      completionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completionId');
    });
  }

  QueryBuilder<PlanCompletionDoc, String, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<PlanCompletionDoc, String, QQueryOperations> itemIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itemId');
    });
  }
}
