import 'package:abacam/database/database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database_provider.dart';

final videoFutureProvider = Provider.family<Future<Video>, int>((ref, id) {
  final db = ref.watch(databaseProvider);
  final query = db.select(db.videos)
    ..where((tbl) => tbl.id.equals(id));
  
  return query.getSingle();
});
