import 'dart:io';

/// Delete a file if it exists (native platforms only)
Future<void> deleteFileIfExists(String path) async {
  try {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  } catch (e) {
    // Ignore cleanup errors
  }
}
