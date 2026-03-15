// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_highlight_doc.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetReadingHighlightDocCollection on Isar {
  IsarCollection<ReadingHighlightDoc> get readingHighlightDocs =>
      this.collection();
}

const ReadingHighlightDocSchema = CollectionSchema(
  name: r'ReadingHighlightDoc',
  id: -8290763065724614623,
  properties: {
    r'blockId': PropertySchema(
      id: 0,
      name: r'blockId',
      type: IsarType.string,
    ),
    r'colorKey': PropertySchema(
      id: 1,
      name: r'colorKey',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'documentId': PropertySchema(
      id: 3,
      name: r'documentId',
      type: IsarType.string,
    ),
    r'endOffset': PropertySchema(
      id: 4,
      name: r'endOffset',
      type: IsarType.long,
    ),
    r'highlightId': PropertySchema(
      id: 5,
      name: r'highlightId',
      type: IsarType.string,
    ),
    r'startOffset': PropertySchema(
      id: 6,
      name: r'startOffset',
      type: IsarType.long,
    )
  },
  estimateSize: _readingHighlightDocEstimateSize,
  serialize: _readingHighlightDocSerialize,
  deserialize: _readingHighlightDocDeserialize,
  deserializeProp: _readingHighlightDocDeserializeProp,
  idName: r'id',
  indexes: {
    r'highlightId': IndexSchema(
      id: -6411662984405488768,
      name: r'highlightId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'highlightId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'documentId': IndexSchema(
      id: 4187168439921340405,
      name: r'documentId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'documentId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _readingHighlightDocGetId,
  getLinks: _readingHighlightDocGetLinks,
  attach: _readingHighlightDocAttach,
  version: '3.1.0+1',
);

int _readingHighlightDocEstimateSize(
  ReadingHighlightDoc object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.blockId.length * 3;
  bytesCount += 3 + object.colorKey.length * 3;
  bytesCount += 3 + object.documentId.length * 3;
  bytesCount += 3 + object.highlightId.length * 3;
  return bytesCount;
}

void _readingHighlightDocSerialize(
  ReadingHighlightDoc object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.blockId);
  writer.writeString(offsets[1], object.colorKey);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.documentId);
  writer.writeLong(offsets[4], object.endOffset);
  writer.writeString(offsets[5], object.highlightId);
  writer.writeLong(offsets[6], object.startOffset);
}

ReadingHighlightDoc _readingHighlightDocDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ReadingHighlightDoc();
  object.blockId = reader.readString(offsets[0]);
  object.colorKey = reader.readString(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.documentId = reader.readString(offsets[3]);
  object.endOffset = reader.readLong(offsets[4]);
  object.highlightId = reader.readString(offsets[5]);
  object.id = id;
  object.startOffset = reader.readLong(offsets[6]);
  return object;
}

P _readingHighlightDocDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _readingHighlightDocGetId(ReadingHighlightDoc object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _readingHighlightDocGetLinks(
    ReadingHighlightDoc object) {
  return [];
}

void _readingHighlightDocAttach(
    IsarCollection<dynamic> col, Id id, ReadingHighlightDoc object) {
  object.id = id;
}

extension ReadingHighlightDocByIndex on IsarCollection<ReadingHighlightDoc> {
  Future<ReadingHighlightDoc?> getByHighlightId(String highlightId) {
    return getByIndex(r'highlightId', [highlightId]);
  }

  ReadingHighlightDoc? getByHighlightIdSync(String highlightId) {
    return getByIndexSync(r'highlightId', [highlightId]);
  }

  Future<bool> deleteByHighlightId(String highlightId) {
    return deleteByIndex(r'highlightId', [highlightId]);
  }

  bool deleteByHighlightIdSync(String highlightId) {
    return deleteByIndexSync(r'highlightId', [highlightId]);
  }

  Future<List<ReadingHighlightDoc?>> getAllByHighlightId(
      List<String> highlightIdValues) {
    final values = highlightIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'highlightId', values);
  }

  List<ReadingHighlightDoc?> getAllByHighlightIdSync(
      List<String> highlightIdValues) {
    final values = highlightIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'highlightId', values);
  }

  Future<int> deleteAllByHighlightId(List<String> highlightIdValues) {
    final values = highlightIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'highlightId', values);
  }

  int deleteAllByHighlightIdSync(List<String> highlightIdValues) {
    final values = highlightIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'highlightId', values);
  }

  Future<Id> putByHighlightId(ReadingHighlightDoc object) {
    return putByIndex(r'highlightId', object);
  }

  Id putByHighlightIdSync(ReadingHighlightDoc object, {bool saveLinks = true}) {
    return putByIndexSync(r'highlightId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByHighlightId(List<ReadingHighlightDoc> objects) {
    return putAllByIndex(r'highlightId', objects);
  }

  List<Id> putAllByHighlightIdSync(List<ReadingHighlightDoc> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'highlightId', objects, saveLinks: saveLinks);
  }
}

extension ReadingHighlightDocQueryWhereSort
    on QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QWhere> {
  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ReadingHighlightDocQueryWhere
    on QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QWhereClause> {
  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterWhereClause>
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

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterWhereClause>
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

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterWhereClause>
      highlightIdEqualTo(String highlightId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'highlightId',
        value: [highlightId],
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterWhereClause>
      highlightIdNotEqualTo(String highlightId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'highlightId',
              lower: [],
              upper: [highlightId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'highlightId',
              lower: [highlightId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'highlightId',
              lower: [highlightId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'highlightId',
              lower: [],
              upper: [highlightId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterWhereClause>
      documentIdEqualTo(String documentId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'documentId',
        value: [documentId],
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterWhereClause>
      documentIdNotEqualTo(String documentId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [],
              upper: [documentId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [documentId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [documentId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [],
              upper: [documentId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ReadingHighlightDocQueryFilter on QueryBuilder<ReadingHighlightDoc,
    ReadingHighlightDoc, QFilterCondition> {
  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      blockIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blockId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      blockIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'blockId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      blockIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'blockId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      blockIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'blockId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      blockIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'blockId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      blockIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'blockId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      blockIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'blockId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      blockIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'blockId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      blockIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blockId',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      blockIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'blockId',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      colorKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'colorKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      colorKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'colorKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      colorKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'colorKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      colorKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'colorKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      colorKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'colorKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      colorKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'colorKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      colorKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'colorKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      colorKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'colorKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      colorKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'colorKey',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      colorKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'colorKey',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
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

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
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

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
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

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      documentIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      documentIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      documentIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      documentIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'documentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      documentIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      documentIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      documentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      documentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'documentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      documentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentId',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      documentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'documentId',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      endOffsetEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endOffset',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      endOffsetGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endOffset',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      endOffsetLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endOffset',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      endOffsetBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endOffset',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      highlightIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'highlightId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      highlightIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'highlightId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      highlightIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'highlightId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      highlightIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'highlightId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      highlightIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'highlightId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      highlightIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'highlightId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      highlightIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'highlightId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      highlightIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'highlightId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      highlightIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'highlightId',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      highlightIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'highlightId',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
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

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
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

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
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

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      startOffsetEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startOffset',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      startOffsetGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startOffset',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      startOffsetLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startOffset',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterFilterCondition>
      startOffsetBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startOffset',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ReadingHighlightDocQueryObject on QueryBuilder<ReadingHighlightDoc,
    ReadingHighlightDoc, QFilterCondition> {}

extension ReadingHighlightDocQueryLinks on QueryBuilder<ReadingHighlightDoc,
    ReadingHighlightDoc, QFilterCondition> {}

extension ReadingHighlightDocQuerySortBy
    on QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QSortBy> {
  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterSortBy>
      sortByBlockId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockId', Sort.asc);
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterSortBy>
      sortByBlockIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockId', Sort.desc);
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterSortBy>
      sortByColorKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorKey', Sort.asc);
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterSortBy>
      sortByColorKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorKey', Sort.desc);
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterSortBy>
      sortByDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.asc);
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterSortBy>
      sortByDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.desc);
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterSortBy>
      sortByEndOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endOffset', Sort.asc);
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterSortBy>
      sortByEndOffsetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endOffset', Sort.desc);
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterSortBy>
      sortByHighlightId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highlightId', Sort.asc);
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterSortBy>
      sortByHighlightIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highlightId', Sort.desc);
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterSortBy>
      sortByStartOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startOffset', Sort.asc);
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterSortBy>
      sortByStartOffsetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startOffset', Sort.desc);
    });
  }
}

extension ReadingHighlightDocQuerySortThenBy
    on QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QSortThenBy> {
  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterSortBy>
      thenByBlockId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockId', Sort.asc);
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterSortBy>
      thenByBlockIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockId', Sort.desc);
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterSortBy>
      thenByColorKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorKey', Sort.asc);
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterSortBy>
      thenByColorKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorKey', Sort.desc);
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterSortBy>
      thenByDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.asc);
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterSortBy>
      thenByDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.desc);
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterSortBy>
      thenByEndOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endOffset', Sort.asc);
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterSortBy>
      thenByEndOffsetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endOffset', Sort.desc);
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterSortBy>
      thenByHighlightId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highlightId', Sort.asc);
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterSortBy>
      thenByHighlightIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highlightId', Sort.desc);
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterSortBy>
      thenByStartOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startOffset', Sort.asc);
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QAfterSortBy>
      thenByStartOffsetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startOffset', Sort.desc);
    });
  }
}

extension ReadingHighlightDocQueryWhereDistinct
    on QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QDistinct> {
  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QDistinct>
      distinctByBlockId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'blockId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QDistinct>
      distinctByColorKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'colorKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QDistinct>
      distinctByDocumentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'documentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QDistinct>
      distinctByEndOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endOffset');
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QDistinct>
      distinctByHighlightId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'highlightId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QDistinct>
      distinctByStartOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startOffset');
    });
  }
}

extension ReadingHighlightDocQueryProperty
    on QueryBuilder<ReadingHighlightDoc, ReadingHighlightDoc, QQueryProperty> {
  QueryBuilder<ReadingHighlightDoc, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ReadingHighlightDoc, String, QQueryOperations>
      blockIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'blockId');
    });
  }

  QueryBuilder<ReadingHighlightDoc, String, QQueryOperations>
      colorKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'colorKey');
    });
  }

  QueryBuilder<ReadingHighlightDoc, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ReadingHighlightDoc, String, QQueryOperations>
      documentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'documentId');
    });
  }

  QueryBuilder<ReadingHighlightDoc, int, QQueryOperations> endOffsetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endOffset');
    });
  }

  QueryBuilder<ReadingHighlightDoc, String, QQueryOperations>
      highlightIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'highlightId');
    });
  }

  QueryBuilder<ReadingHighlightDoc, int, QQueryOperations>
      startOffsetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startOffset');
    });
  }
}
