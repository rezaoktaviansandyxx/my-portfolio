import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_config.dart';

void main() {
  setUpAll(
    () => dotenv.loadFromString(
      envString: 'API_BASE_URL=https://api.example.com/api/v1',
    ),
  );

  test('path /static/ dijadikan absolut terhadap origin, bukan base path', () {
    expect(
      ApiConfig.resolveFileUrl('/static/uploads/resumes/cv.pdf'),
      'https://api.example.com/static/uploads/resumes/cv.pdf',
    );
  });

  test('URL absolut dilewatkan apa adanya', () {
    expect(
      ApiConfig.resolveFileUrl('https://cdn.example.com/a.png'),
      'https://cdn.example.com/a.png',
    );
  });

  test('null / kosong menghasilkan string kosong', () {
    expect(ApiConfig.resolveFileUrl(null), '');
    expect(ApiConfig.resolveFileUrl('  '), '');
  });
}
