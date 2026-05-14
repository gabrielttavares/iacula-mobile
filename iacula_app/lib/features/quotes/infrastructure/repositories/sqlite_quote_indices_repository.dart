import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import '../../../../core/storage/sqlite/app_database.dart';
import '../../domain/entities/quote_indices.dart';
import '../../domain/repositories/quote_indices_repository.dart';

final class SqliteQuoteIndicesRepository implements QuoteIndicesRepository {
  SqliteQuoteIndicesRepository(this._database);

  final AppDatabase _database;

  @override
  Future<QuoteIndices> load({required int dayOfWeek}) async {
    final db = await _database.database;
    final rows = await db.query('quote_indices');
    final quoteIndices = <int, int>{};
    final imageIndices = <int, int>{};
    final quoteOrders = <int, List<int>>{};
    final imageOrders = <int, List<int>>{};
    final quotePoolKeys = <int, String>{};
    final imagePoolKeys = <int, String>{};

    for (final row in rows) {
      final day = row['day_of_week'] as int;
      quoteIndices[day] = row['quote_index'] as int;
      imageIndices[day] = row['image_index'] as int;
      final quoteOrder = _decodeIntList(row['quote_order'] as String?);
      if (quoteOrder != null) {
        quoteOrders[day] = quoteOrder;
      }
      final imageOrder = _decodeIntList(row['image_order'] as String?);
      if (imageOrder != null) {
        imageOrders[day] = imageOrder;
      }
      final quotePoolKey = row['quote_pool_key'] as String?;
      if (quotePoolKey != null) {
        quotePoolKeys[day] = quotePoolKey;
      }
      final imagePoolKey = row['image_pool_key'] as String?;
      if (imagePoolKey != null) {
        imagePoolKeys[day] = imagePoolKey;
      }
    }

    return QuoteIndices(
      quoteIndices: quoteIndices,
      imageIndices: imageIndices,
      quoteOrders: quoteOrders,
      imageOrders: imageOrders,
      quotePoolKeys: quotePoolKeys,
      imagePoolKeys: imagePoolKeys,
    );
  }

  @override
  Future<void> save(QuoteIndices indices) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      await txn.delete('quote_indices');

      final days = <int>{}
        ..addAll(indices.quoteIndices.keys)
        ..addAll(indices.imageIndices.keys)
        ..addAll(indices.quoteOrders.keys)
        ..addAll(indices.imageOrders.keys)
        ..addAll(indices.quotePoolKeys.keys)
        ..addAll(indices.imagePoolKeys.keys);

      for (final day in days) {
        await txn.insert('quote_indices', {
          'day_of_week': day,
          'quote_index': indices.quoteIndices[day] ?? 0,
          'image_index': indices.imageIndices[day] ?? 0,
          'quote_order': _encodeIntList(indices.quoteOrders[day]),
          'image_order': _encodeIntList(indices.imageOrders[day]),
          'quote_pool_key': indices.quotePoolKeys[day],
          'image_pool_key': indices.imagePoolKeys[day],
        });
      }
    });
  }

  String? _encodeIntList(List<int>? values) {
    if (values == null) {
      return null;
    }
    return jsonEncode(values);
  }

  List<int>? _decodeIntList(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return null;
    }

    return decoded.map((value) => value as int).toList(growable: false);
  }
}
