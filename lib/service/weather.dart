import 'dart:convert';
import 'package:http/http.dart' as http;

/* class WeatherService {
  // Cloud Functions URL
  final String baseUrl =
      'https://us-central1-mixcall.cloudfunctions.net/update_weather';

  Future<Map<String, dynamic>> updateWeather({String action = 'all'}) async {
    try {
      final Uri uri = Uri.parse('$baseUrl/update_weather').replace(
        queryParameters: {'action': action},
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          return {
            'success': true,
            'result': data['result'],
          };
        } else {
          return {
            'success': false,
            'error': data['error'] ?? '알 수 없는 오류가 발생했습니다.',
          };
        }
      } else {
        return {
          'success': false,
          'error': '서버 오류: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '네트워크 오류: $e',
      };
    }
  }
} */

Future<void> updateWeather() async {
  final url = Uri.parse(
      'https://us-central1-mixcall.cloudfunctions.net/update_weather');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('날씨 업데이트 응답: ${data['result']}');
      if (data.containsKey('logs')) {
        for (var log in data['logs']) {
          print('Server Log: $log');
        }
      }
    } else {
      print('요청 실패: ${response.statusCode}');
    }
  } catch (e) {
    print('에러 발생: $e');
  }
}
