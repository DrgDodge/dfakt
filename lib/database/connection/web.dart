import 'package:drift/drift.dart';

LazyDatabase connect() {
  // If you want to support Web, you would use WasmDatabase here.
  // For now, we throw an error to prevent the "JS Interop" crash 
  // and inform the user.
  return LazyDatabase(() async {
      throw UnsupportedError('Web is not currently supported. Please run on Android or Windows.');
  });
}
