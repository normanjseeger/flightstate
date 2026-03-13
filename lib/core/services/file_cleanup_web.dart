/// No-op file cleanup for web (files are handled by browser)
Future<void> deleteFileIfExists(String path) async {
  // Web platform - no file cleanup needed, browser manages blob URLs
}
