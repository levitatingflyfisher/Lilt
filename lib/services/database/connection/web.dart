import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

// Loads sqlite3.wasm + drift_worker.js (both shipped in web/) and runs the
// database off the main thread in the browser.
QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'lilt',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    return result.resolvedExecutor;
  });
}
