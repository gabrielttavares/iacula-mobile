// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'premium_status_doc.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPremiumStatusDocCollection on Isar {
  IsarCollection<PremiumStatusDoc> get premiumStatusDocs => this.collection();
}

const PremiumStatusDocSchema = CollectionSchema(
  name: r'PremiumStatusDoc',
  id: -6353681057262321863,
  properties: {
    r'isPremium': PropertySchema(
      id: 0,
      name: r'isPremium',
      type: IsarType.bool,
    ),
    r'lastValidated': PropertySchema(
      id: 1,
      name: r'lastValidated',
      type: IsarType.dateTime,
    ),
    r'purchaseDate': PropertySchema(
      id: 2,
      name: r'purchaseDate',
      type: IsarType.dateTime,
    ),
    r'storeTransactionId': PropertySchema(
      id: 3,
      name: r'storeTransactionId',
      type: IsarType.string,
    ),
    r'userId': PropertySchema(
      id: 4,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _premiumStatusDocEstimateSize,
  serialize: _premiumStatusDocSerialize,
  deserialize: _premiumStatusDocDeserialize,
  deserializeProp: _premiumStatusDocDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _premiumStatusDocGetId,
  getLinks: _premiumStatusDocGetLinks,
  attach: _premiumStatusDocAttach,
  version: '3.1.0+1',
);

int _premiumStatusDocEstimateSize(
  PremiumStatusDoc object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.storeTransactionId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.userId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _premiumStatusDocSerialize(
  PremiumStatusDoc object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.isPremium);
  writer.writeDateTime(offsets[1], object.lastValidated);
  writer.writeDateTime(offsets[2], object.purchaseDate);
  writer.writeString(offsets[3], object.storeTransactionId);
  writer.writeString(offsets[4], object.userId);
}

PremiumStatusDoc _premiumStatusDocDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PremiumStatusDoc();
  object.id = id;
  object.isPremium = reader.readBool(offsets[0]);
  object.lastValidated = reader.readDateTimeOrNull(offsets[1]);
  object.purchaseDate = reader.readDateTimeOrNull(offsets[2]);
  object.storeTransactionId = reader.readStringOrNull(offsets[3]);
  object.userId = reader.readStringOrNull(offsets[4]);
  return object;
}

P _premiumStatusDocDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _premiumStatusDocGetId(PremiumStatusDoc object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _premiumStatusDocGetLinks(PremiumStatusDoc object) {
  return [];
}

void _premiumStatusDocAttach(
    IsarCollection<dynamic> col, Id id, PremiumStatusDoc object) {
  object.id = id;
}

extension PremiumStatusDocQueryWhereSort
    on QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QWhere> {
  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PremiumStatusDocQueryWhere
    on QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QWhereClause> {
  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterWhereClause>
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

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterWhereClause> idBetween(
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
}

extension PremiumStatusDocQueryFilter
    on QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QFilterCondition> {
  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
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

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
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

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
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

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      isPremiumEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPremium',
        value: value,
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      lastValidatedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastValidated',
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      lastValidatedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastValidated',
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      lastValidatedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastValidated',
        value: value,
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      lastValidatedGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastValidated',
        value: value,
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      lastValidatedLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastValidated',
        value: value,
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      lastValidatedBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastValidated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      purchaseDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'purchaseDate',
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      purchaseDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'purchaseDate',
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      purchaseDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'purchaseDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      purchaseDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'purchaseDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      purchaseDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'purchaseDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      purchaseDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'purchaseDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      storeTransactionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'storeTransactionId',
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      storeTransactionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'storeTransactionId',
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      storeTransactionIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'storeTransactionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      storeTransactionIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'storeTransactionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      storeTransactionIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'storeTransactionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      storeTransactionIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'storeTransactionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      storeTransactionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'storeTransactionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      storeTransactionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'storeTransactionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      storeTransactionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'storeTransactionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      storeTransactionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'storeTransactionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      storeTransactionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'storeTransactionId',
        value: '',
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      storeTransactionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'storeTransactionId',
        value: '',
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      userIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'userId',
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      userIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'userId',
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      userIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      userIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      userIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      userIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      userIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      userIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension PremiumStatusDocQueryObject
    on QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QFilterCondition> {}

extension PremiumStatusDocQueryLinks
    on QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QFilterCondition> {}

extension PremiumStatusDocQuerySortBy
    on QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QSortBy> {
  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterSortBy>
      sortByIsPremium() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPremium', Sort.asc);
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterSortBy>
      sortByIsPremiumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPremium', Sort.desc);
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterSortBy>
      sortByLastValidated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastValidated', Sort.asc);
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterSortBy>
      sortByLastValidatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastValidated', Sort.desc);
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterSortBy>
      sortByPurchaseDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseDate', Sort.asc);
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterSortBy>
      sortByPurchaseDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseDate', Sort.desc);
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterSortBy>
      sortByStoreTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storeTransactionId', Sort.asc);
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterSortBy>
      sortByStoreTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storeTransactionId', Sort.desc);
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension PremiumStatusDocQuerySortThenBy
    on QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QSortThenBy> {
  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterSortBy>
      thenByIsPremium() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPremium', Sort.asc);
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterSortBy>
      thenByIsPremiumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPremium', Sort.desc);
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterSortBy>
      thenByLastValidated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastValidated', Sort.asc);
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterSortBy>
      thenByLastValidatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastValidated', Sort.desc);
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterSortBy>
      thenByPurchaseDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseDate', Sort.asc);
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterSortBy>
      thenByPurchaseDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseDate', Sort.desc);
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterSortBy>
      thenByStoreTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storeTransactionId', Sort.asc);
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterSortBy>
      thenByStoreTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storeTransactionId', Sort.desc);
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension PremiumStatusDocQueryWhereDistinct
    on QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QDistinct> {
  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QDistinct>
      distinctByIsPremium() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPremium');
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QDistinct>
      distinctByLastValidated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastValidated');
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QDistinct>
      distinctByPurchaseDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'purchaseDate');
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QDistinct>
      distinctByStoreTransactionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'storeTransactionId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension PremiumStatusDocQueryProperty
    on QueryBuilder<PremiumStatusDoc, PremiumStatusDoc, QQueryProperty> {
  QueryBuilder<PremiumStatusDoc, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PremiumStatusDoc, bool, QQueryOperations> isPremiumProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPremium');
    });
  }

  QueryBuilder<PremiumStatusDoc, DateTime?, QQueryOperations>
      lastValidatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastValidated');
    });
  }

  QueryBuilder<PremiumStatusDoc, DateTime?, QQueryOperations>
      purchaseDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'purchaseDate');
    });
  }

  QueryBuilder<PremiumStatusDoc, String?, QQueryOperations>
      storeTransactionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'storeTransactionId');
    });
  }

  QueryBuilder<PremiumStatusDoc, String?, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
