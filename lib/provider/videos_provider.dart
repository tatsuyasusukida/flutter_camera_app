import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database_provider.dart';

final videosStreamProvider = StreamProvider((ref) {
  final db = ref.watch(databaseProvider);
  final query = db.select(db.videos)..orderBy([
    (tbl) => OrderingTerm.desc(tbl.id),
  ]);
  
  return query.watch();
});
