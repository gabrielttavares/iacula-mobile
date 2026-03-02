// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_phrase_doc.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCustomPhraseDocCollection on Isar {
  IsarCollection<CustomPhraseDoc> get customPhraseDocs => this.collection();
}

const CustomPhraseDocSchema = CollectionSchema(
  name: r'CustomPhraseDoc',
  id: -2163000266123931189,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'displayAsNotification': PropertySchema(
      id: 1,
      name: r'displayAsNotification',
      type: IsarType.bool,
    ),
    r'displayOnHero': PropertySchema(
      id: 2,
      name: r'displayOnHero',
      type: IsarType.bool,
    ),
    r'isActive': PropertySchema(
      id: 3,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'phraseId': PropertySchema(
      id: 4,
      name: r'phraseId',
      type: IsarType.string,
    ),
    r'scheduleJson': PropertySchema(
      id: 5,
      name: r'scheduleJson',
      type: IsarType.string,
    ),
    r'text': PropertySchema(
      id: 6,
      name: r'text',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 7,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _customPhraseDocEstimateSize,
  serialize: _customPhraseDocSerialize,
  deserialize: _customPhraseDocDeserialize,
  deserializeProp: _customPhraseDocDeserializeProp,
  idName: r'id',
  indexes: {
    r'phraseId': IndexSchema(
      id: -1936705100628921048,
      name: r'phraseId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'phraseId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _customPhraseDocGetId,
  getLinks: _customPhraseDocGetLinks,
  attach: _customPhraseDocAttach,
  version: '3.1.0+1',
);

int _customPhraseDocEstimateSize(
  CustomPhraseDoc object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.phraseId.length * 3;
  bytesCount += 3 + object.scheduleJson.length * 3;
  bytesCount += 3 + object.text.length * 3;
  return bytesCount;
}

void _customPhraseDocSerialize(
  CustomPhraseDoc object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeBool(offsets[1], object.displayAsNotification);
  writer.writeBool(offsets[2], object.displayOnHero);
  writer.writeBool(offsets[3], object.isActive);
  writer.writeString(offsets[4], object.phraseId);
  writer.writeString(offsets[5], object.scheduleJson);
  writer.writeString(offsets[6], object.text);
  writer.writeDateTime(offsets[7], object.updatedAt);
}

CustomPhraseDoc _customPhraseDocDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CustomPhraseDoc();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.displayAsNotification = reader.readBool(offsets[1]);
  object.displayOnHero = reader.readBool(offsets[2]);
  object.id = id;
  object.isActive = reader.readBool(offsets[3]);
  object.phraseId = reader.readString(offsets[4]);
  object.scheduleJson = reader.readString(offsets[5]);
  object.text = reader.readString(offsets[6]);
  object.updatedAt = reader.readDateTime(offsets[7]);
  return object;
}

P _customPhraseDocDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _customPhraseDocGetId(CustomPhraseDoc object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _customPhraseDocGetLinks(CustomPhraseDoc object) {
  return [];
}

void _customPhraseDocAttach(
    IsarCollection<dynamic> col, Id id, CustomPhraseDoc object) {
  object.id = id;
}

extension CustomPhraseDocByIndex on IsarCollection<CustomPhraseDoc> {
  Future<CustomPhraseDoc?> getByPhraseId(String phraseId) {
    return getByIndex(r'phraseId', [phraseId]);
  }

  CustomPhraseDoc? getByPhraseIdSync(String phraseId) {
    return getByIndexSync(r'phraseId', [phraseId]);
  }

  Future<bool> deleteByPhraseId(String phraseId) {
    return deleteByIndex(r'phraseId', [phraseId]);
  }

  bool deleteByPhraseIdSync(String phraseId) {
    return deleteByIndexSync(r'phraseId', [phraseId]);
  }

  Future<List<CustomPhraseDoc?>> getAllByPhraseId(List<String> phraseIdValues) {
    final values = phraseIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'phraseId', values);
  }

  List<CustomPhraseDoc?> getAllByPhraseIdSync(List<String> phraseIdValues) {
    final values = phraseIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'phraseId', values);
  }

  Future<int> deleteAllByPhraseId(List<String> phraseIdValues) {
    final values = phraseIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'phraseId', values);
  }

  int deleteAllByPhraseIdSync(List<String> phraseIdValues) {
    final values = phraseIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'phraseId', values);
  }

  Future<Id> putByPhraseId(CustomPhraseDoc object) {
    return putByIndex(r'phraseId', object);
  }

  Id putByPhraseIdSync(CustomPhraseDoc object, {bool saveLinks = true}) {
    return putByIndexSync(r'phraseId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPhraseId(List<CustomPhraseDoc> objects) {
    return putAllByIndex(r'phraseId', objects);
  }

  List<Id> putAllByPhraseIdSync(List<CustomPhraseDoc> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'phraseId', objects, saveLinks: saveLinks);
  }
}

extension CustomPhraseDocQueryWhereSort
    on QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QWhere> {
  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CustomPhraseDocQueryWhere
    on QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QWhereClause> {
  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterWhereClause>
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

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterWhereClause> idBetween(
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

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterWhereClause>
      phraseIdEqualTo(String phraseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'phraseId',
        value: [phraseId],
      ));
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterWhereClause>
      phraseIdNotEqualTo(String phraseId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'phraseId',
              lower: [],
              upper: [phraseId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'phraseId',
              lower: [phraseId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'phraseId',
              lower: [phraseId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'phraseId',
              lower: [],
              upper: [phraseId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension CustomPhraseDocQueryFilter
    on QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QFilterCondition> {
  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
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

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
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

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
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

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      displayAsNotificationEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayAsNotification',
        value: value,
      ));
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      displayOnHeroEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayOnHero',
        value: value,
      ));
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
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

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
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

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
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

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      isActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      phraseIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'phraseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      phraseIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'phraseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      phraseIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'phraseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      phraseIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'phraseId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      phraseIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'phraseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      phraseIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'phraseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      phraseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'phraseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      phraseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'phraseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      phraseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'phraseId',
        value: '',
      ));
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      phraseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'phraseId',
        value: '',
      ));
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      scheduleJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduleJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      scheduleJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scheduleJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      scheduleJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scheduleJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      scheduleJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scheduleJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      scheduleJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'scheduleJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      scheduleJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'scheduleJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      scheduleJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'scheduleJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      scheduleJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'scheduleJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      scheduleJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduleJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      scheduleJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'scheduleJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      textEqualTo(
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

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      textGreaterThan(
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

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      textLessThan(
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

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      textBetween(
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

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      textStartsWith(
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

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      textEndsWith(
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

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      textContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      textMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'text',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      textIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'text',
        value: '',
      ));
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      textIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'text',
        value: '',
      ));
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      updatedAtGreaterThan(
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

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      updatedAtLessThan(
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

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterFilterCondition>
      updatedAtBetween(
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

extension CustomPhraseDocQueryObject
    on QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QFilterCondition> {}

extension CustomPhraseDocQueryLinks
    on QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QFilterCondition> {}

extension CustomPhraseDocQuerySortBy
    on QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QSortBy> {
  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterSortBy>
      sortByDisplayAsNotification() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayAsNotification', Sort.asc);
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterSortBy>
      sortByDisplayAsNotificationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayAsNotification', Sort.desc);
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterSortBy>
      sortByDisplayOnHero() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayOnHero', Sort.asc);
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterSortBy>
      sortByDisplayOnHeroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayOnHero', Sort.desc);
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterSortBy>
      sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterSortBy>
      sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterSortBy>
      sortByPhraseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phraseId', Sort.asc);
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterSortBy>
      sortByPhraseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phraseId', Sort.desc);
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterSortBy>
      sortByScheduleJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduleJson', Sort.asc);
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterSortBy>
      sortByScheduleJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduleJson', Sort.desc);
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterSortBy> sortByText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.asc);
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterSortBy>
      sortByTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.desc);
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension CustomPhraseDocQuerySortThenBy
    on QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QSortThenBy> {
  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterSortBy>
      thenByDisplayAsNotification() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayAsNotification', Sort.asc);
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterSortBy>
      thenByDisplayAsNotificationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayAsNotification', Sort.desc);
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterSortBy>
      thenByDisplayOnHero() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayOnHero', Sort.asc);
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterSortBy>
      thenByDisplayOnHeroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayOnHero', Sort.desc);
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterSortBy>
      thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterSortBy>
      thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterSortBy>
      thenByPhraseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phraseId', Sort.asc);
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterSortBy>
      thenByPhraseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phraseId', Sort.desc);
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterSortBy>
      thenByScheduleJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduleJson', Sort.asc);
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterSortBy>
      thenByScheduleJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduleJson', Sort.desc);
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterSortBy> thenByText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.asc);
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterSortBy>
      thenByTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.desc);
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension CustomPhraseDocQueryWhereDistinct
    on QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QDistinct> {
  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QDistinct>
      distinctByDisplayAsNotification() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayAsNotification');
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QDistinct>
      distinctByDisplayOnHero() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayOnHero');
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QDistinct>
      distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QDistinct> distinctByPhraseId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'phraseId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QDistinct>
      distinctByScheduleJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scheduleJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QDistinct> distinctByText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'text', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension CustomPhraseDocQueryProperty
    on QueryBuilder<CustomPhraseDoc, CustomPhraseDoc, QQueryProperty> {
  QueryBuilder<CustomPhraseDoc, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CustomPhraseDoc, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<CustomPhraseDoc, bool, QQueryOperations>
      displayAsNotificationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayAsNotification');
    });
  }

  QueryBuilder<CustomPhraseDoc, bool, QQueryOperations>
      displayOnHeroProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayOnHero');
    });
  }

  QueryBuilder<CustomPhraseDoc, bool, QQueryOperations> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<CustomPhraseDoc, String, QQueryOperations> phraseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'phraseId');
    });
  }

  QueryBuilder<CustomPhraseDoc, String, QQueryOperations>
      scheduleJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scheduleJson');
    });
  }

  QueryBuilder<CustomPhraseDoc, String, QQueryOperations> textProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'text');
    });
  }

  QueryBuilder<CustomPhraseDoc, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
