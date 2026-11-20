import 'dart:io';

Future<void> send(Uri uri) async {
  final client = HttpClient();
  try {
    await _request(client, uri).timeout(const Duration(seconds: 3));
  } finally {
    client.close(force: true);
  }
}

Future<void> _request(HttpClient client, Uri uri) async {
  final request = await client.getUrl(uri);
  request.followRedirects = false;
  request.headers.set(HttpHeaders.cacheControlHeader, 'no-store');
  final response = await request.close();
  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw HttpException('ESP32 respondió HTTP ${response.statusCode}');
  }
  await response.drain<void>();
}
