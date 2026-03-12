// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'examination_reflection_doc.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetExaminationReflectionDocCollection on Isar {
  IsarCollection<ExaminationReflectionDoc> get examinationReflectionDocs =>
      this.collection();
}

const ExaminationReflectionDocSchema = CollectionSchema(
  name: r'ExaminationReflectionDoc',
  id: 4489800180096734885,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'reflectionId': PropertySchema(
      id: 1,
      name: r'reflectionId',
      type: IsarType.string,
    ),
    r'sectionTitle': PropertySchema(
      id: 2,
      name: r'sectionTitle',
      type: IsarType.string,
    ),
    r'sortOrder': PropertySchema(
      id: 3,
      name: r'sortOrder',
      type: IsarType.long,
    ),
    r'text': PropertySchema(
      id: 4,
      name: r'text',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 5,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _examinationReflectionDocEstimateSize,
  serialize: _examinationReflectionDocSerialize,
  deserialize: _examinationReflectionDocDeserialize,
  deserializeProp: _examinationReflectionDocDeserializeProp,
  idName: r'id',
  indexes: {
    r'reflectionId': IndexSchema(
      id: 989399751142999877,
      name: r'reflectionId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'reflectionId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _examinationReflectionDocGetId,
  getLinks: _examinationReflectionDocGetLinks,
  attach: _examinationReflectionDocAttach,
  version: '3.1.0+1',
);

int _examinationReflectionDocEstimateSize(
  ExaminationReflectionDoc object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.reflectionId.length * 3;
  bytesCount += 3 + object.sectionTitle.length * 3;
  bytesCount += 3 + object.text.length * 3;
  return bytesCount;
}

void _examinationReflectionDocSerialize(
  ExaminationReflectionDoc object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.reflectionId);
  writer.writeString(offsets[2], object.sectionTitle);
  writer.writeLong(offsets[3], object.sortOrder);
  writer.writeString(offsets[4], object.text);
  writer.writeDateTime(offsets[5], object.updatedAt);
}

ExaminationReflectionDoc _examinationReflectionDocDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ExaminationReflectionDoc();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.id = id;
  object.reflectionId = reader.readString(offsets[1]);
  object.sectionTitle = reader.readString(offsets[2]);
  object.sortOrder = reader.readLong(offsets[3]);
  object.text = reader.readString(offsets[4]);
  object.updatedAt = reader.readDateTime(offsets[5]);
  return object;
}

P _examinationReflectionDocDeserializeProp<P>(
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
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _examinationReflectionDocGetId(ExaminationReflectionDoc object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _examinationReflectionDocGetLinks(
    ExaminationReflectionDoc object) {
  return [];
}

void _examinationReflectionDocAttach(
    IsarCollection<dynamic> col, Id id, ExaminationReflectionDoc object) {
  object.id = id;
}

extension ExaminationReflectionDocByIndex
    on IsarCollection<ExaminationReflectionDoc> {
  Future<ExaminationReflectionDoc?> getByReflectionId(String reflectionId) {
    return getByIndex(r'reflectionId', [reflectionId]);
  }

  ExaminationReflectionDoc? getByReflectionIdSync(String reflectionId) {
    return getByIndexSync(r'reflectionId', [reflectionId]);
  }

  Future<bool> deleteByReflectionId(String reflectionId) {
    return deleteByIndex(r'reflectionId', [reflectionId]);
  }

  bool deleteByReflectionIdSync(String reflectionId) {
    return deleteByIndexSync(r'reflectionId', [reflectionId]);
  }

  Future<List<ExaminationReflectionDoc?>> getAllByReflectionId(
      List<String> reflectionIdValues) {
    final values = reflectionIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'reflectionId', values);
  }

  List<ExaminationReflectionDoc?> getAllByReflectionIdSync(
      List<String> reflectionIdValues) {
    final values = reflectionIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'reflectionId', values);
  }

  Future<int> deleteAllByReflectionId(List<String> reflectionIdValues) {
    final values = reflectionIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'reflectionId', values);
  }

  int deleteAllByReflectionIdSync(List<String> reflectionIdValues) {
    final values = reflectionIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'reflectionId', values);
  }

  Future<Id> putByReflectionId(ExaminationReflectionDoc object) {
    return putByIndex(r'reflectionId', object);
  }

  Id putByReflectionIdSync(ExaminationReflectionDoc object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'reflectionId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByReflectionId(
      List<ExaminationReflectionDoc> objects) {
    return putAllByIndex(r'reflectionId', objects);
  }

  List<Id> putAllByReflectionIdSync(List<ExaminationReflectionDoc> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'reflectionId', objects, saveLinks: saveLinks);
  }
}

extension ExaminationReflectionDocQueryWhereSort on QueryBuilder<
    ExaminationReflectionDoc, ExaminationReflectionDoc, QWhere> {
  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ExaminationReflectionDocQueryWhere on QueryBuilder<
    ExaminationReflectionDoc, ExaminationReflectionDoc, QWhereClause> {
  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterWhereClause> idBetween(
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

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterWhereClause> reflectionIdEqualTo(String reflectionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'reflectionId',
        value: [reflectionId],
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterWhereClause> reflectionIdNotEqualTo(String reflectionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'reflectionId',
              lower: [],
              upper: [reflectionId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'reflectionId',
              lower: [reflectionId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'reflectionId',
              lower: [reflectionId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'reflectionId',
              lower: [],
              upper: [reflectionId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ExaminationReflectionDocQueryFilter on QueryBuilder<
    ExaminationReflectionDoc, ExaminationReflectionDoc, QFilterCondition> {
  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
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

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
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

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
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

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> reflectionIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reflectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> reflectionIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reflectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> reflectionIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reflectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> reflectionIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reflectionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> reflectionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reflectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> reflectionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reflectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
          QAfterFilterCondition>
      reflectionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reflectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
          QAfterFilterCondition>
      reflectionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reflectionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> reflectionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reflectionId',
        value: '',
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> reflectionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reflectionId',
        value: '',
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> sectionTitleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sectionTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> sectionTitleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sectionTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> sectionTitleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sectionTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> sectionTitleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sectionTitle',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> sectionTitleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sectionTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> sectionTitleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sectionTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
          QAfterFilterCondition>
      sectionTitleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sectionTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
          QAfterFilterCondition>
      sectionTitleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sectionTitle',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> sectionTitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sectionTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> sectionTitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sectionTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> sortOrderEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> sortOrderGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> sortOrderLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> sortOrderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sortOrder',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> textEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> textGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> textLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> textBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'text',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> textStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> textEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
          QAfterFilterCondition>
      textContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
          QAfterFilterCondition>
      textMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'text',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> textIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'text',
        value: '',
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> textIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'text',
        value: '',
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc,
      QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ExaminationReflectionDocQueryObject on QueryBuilder<
    ExaminationReflectionDoc, ExaminationReflectionDoc, QFilterCondition> {}

extension ExaminationReflectionDocQueryLinks on QueryBuilder<
    ExaminationReflectionDoc, ExaminationReflectionDoc, QFilterCondition> {}

extension ExaminationReflectionDocQuerySortBy on QueryBuilder<
    ExaminationReflectionDoc, ExaminationReflectionDoc, QSortBy> {
  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc, QAfterSortBy>
      sortByReflectionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionId', Sort.asc);
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc, QAfterSortBy>
      sortByReflectionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionId', Sort.desc);
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc, QAfterSortBy>
      sortBySectionTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sectionTitle', Sort.asc);
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc, QAfterSortBy>
      sortBySectionTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sectionTitle', Sort.desc);
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc, QAfterSortBy>
      sortBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc, QAfterSortBy>
      sortBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc, QAfterSortBy>
      sortByText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.asc);
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc, QAfterSortBy>
      sortByTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.desc);
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ExaminationReflectionDocQuerySortThenBy on QueryBuilder<
    ExaminationReflectionDoc, ExaminationReflectionDoc, QSortThenBy> {
  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc, QAfterSortBy>
      thenByReflectionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionId', Sort.asc);
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc, QAfterSortBy>
      thenByReflectionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionId', Sort.desc);
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc, QAfterSortBy>
      thenBySectionTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sectionTitle', Sort.asc);
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc, QAfterSortBy>
      thenBySectionTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sectionTitle', Sort.desc);
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc, QAfterSortBy>
      thenBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc, QAfterSortBy>
      thenBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc, QAfterSortBy>
      thenByText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.asc);
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc, QAfterSortBy>
      thenByTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.desc);
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ExaminationReflectionDocQueryWhereDistinct on QueryBuilder<
    ExaminationReflectionDoc, ExaminationReflectionDoc, QDistinct> {
  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc, QDistinct>
      distinctByReflectionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reflectionId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc, QDistinct>
      distinctBySectionTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sectionTitle', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc, QDistinct>
      distinctBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortOrder');
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc, QDistinct>
      distinctByText({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'text', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExaminationReflectionDoc, ExaminationReflectionDoc, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension ExaminationReflectionDocQueryProperty on QueryBuilder<
    ExaminationReflectionDoc, ExaminationReflectionDoc, QQueryProperty> {
  QueryBuilder<ExaminationReflectionDoc, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ExaminationReflectionDoc, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ExaminationReflectionDoc, String, QQueryOperations>
      reflectionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reflectionId');
    });
  }

  QueryBuilder<ExaminationReflectionDoc, String, QQueryOperations>
      sectionTitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sectionTitle');
    });
  }

  QueryBuilder<ExaminationReflectionDoc, int, QQueryOperations>
      sortOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortOrder');
    });
  }

  QueryBuilder<ExaminationReflectionDoc, String, QQueryOperations>
      textProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'text');
    });
  }

  QueryBuilder<ExaminationReflectionDoc, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
