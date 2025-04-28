import 'dart:convert';

import 'package:http/http.dart' as http;

class SMSService {
  static Future<bool> sendSMS(String phoneNumber) async {
    final url = 'https://send-sms-y3iac4yzjq-uc.a.run.app';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'receiver': phoneNumber,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('JSON Response: $jsonResponse');
        return jsonResponse['success'] == true;
      } else {
        print('Failed to send SMS. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error sending SMS: $e');
      return false;
    }
  }

  static Future<String> verifySMS(String phoneNumber, String code) async {
    final url = 'https://verify-sms-y3iac4yzjq-uc.a.run.app';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'phone': phoneNumber,
          'code': code,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['message'];
      } else {
        print('Failed to verify SMS. Status code: ${response.statusCode}');
        return 'error';
      }
    } catch (e) {
      print('Error verifying SMS: $e');
      return 'error';
    }
  }
}
