import 'dart:convert';

import 'package:delayed_widget/delayed_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/providers/hashProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ReSetPart extends StatefulWidget {
  const ReSetPart({
    super.key,
  });

  @override
  State<ReSetPart> createState() => _ReSetPartState();
}

class _ReSetPartState extends State<ReSetPart> {
  TextEditingController _pwText = TextEditingController();
  TextEditingController _pwReText = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    super.dispose();

    _pwText.dispose();
    _pwReText.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: KTextWidget(
                    text: '비밀번호 재설정',
                    size: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 8),
              CustomTextBigFormField(
                  maxLength: 30,
                  hintSize: 16,
                  contentsSize: 16,
                  obs: true,
                  controller: _pwText,
                  searchLoading: false,
                  onChanged: (value) {},
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력하세요.';
                    }
                    if (value.length <= 6) {
                      return '6자리 이상 비밀번호를 입력하세요.';
                    }
                    return null;
                  },
                  context: context,
                  input: [],
                  hint: '비밀번호 6자리 이상을 입력하세요.'),
              const SizedBox(height: 8),
              CustomTextBigFormField(
                  maxLength: 30,
                  hintSize: 16,
                  contentsSize: 16,
                  obs: true,
                  controller: _pwReText,
                  searchLoading: false,
                  onChanged: (value) {},
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력하세요.';
                    }
                    if (value.length <= 6) {
                      return '6자리 이상 비밀번호를 입력하세요.';
                    }

                    if (_pwText.text.trim() != _pwReText.text.trim()) {
                      return '비밀번호가 일치하지 않습니다';
                    }

                    return null;
                  },
                  context: context,
                  input: [],
                  hint: '비밀번호를 다시 한번 입력하세요.'),
            ],
          ),
        ),
        const Spacer(),
        DelayedWidget(
          animation: DelayedAnimations.SLIDE_FROM_BOTTOM,
          animationDuration: const Duration(milliseconds: 500),
          child: GestureDetector(
            onTap: () async {
              if (_formKey.currentState!.validate()) {
                mapProvider.isLoadingState(true);
                await _reset(mapProvider);
                mapProvider.isLoadingState(false);
              }
            },
            child: Container(
              margin: EdgeInsets.only(left: 8, right: 8),
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: kGreenFontColor,
              ),
              child: const Center(
                child: KTextWidget(
                    text: '비밀번호 재설정',
                    size: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        )
      ],
    );
  }

  Future _reset(MapProvider mapProvider) async {
    final hashProvider = Provider.of<HashProvider>(context, listen: false);
    String phone = hashProvider
        .encryptData(mapProvider.resetPhone.toString() + '@mixcallnuser.com');
    String pw = hashProvider.encryptData(_pwReText.text.trim());

    try {
      final response = await http.post(
        Uri.parse(
            'https://us-central1-mixcall.cloudfunctions.net/update_pw_http'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'encrypted_email': phone, // encrypted_phone -> encrypted_email로 변경
          'encrypted_password': pw,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.headers['content-type']?.contains('application/json') ==
          true) {
        final data = jsonDecode(response.body);

        if (response.statusCode == 200 && data['success'] == true) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context)
              .showSnackBar(currentSnackBar('비밀번호가 성공적으로 변경되었습니다.', context));
        } else if (response.statusCode == 404) {
          ScaffoldMessenger.of(context)
              .showSnackBar(errorSnackBar('등록되지 않은 전화번호입니다.', context));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              errorSnackBar(data['error'] ?? '비밀번호 변경에 실패했습니다.', context));
        }
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(errorSnackBar('서버 응답 형식이 잘못되었습니다.', context));
      }
    } catch (e) {
      print('Error details: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('오류'),
          content: Text('네트워크 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('확인'),
            ),
          ],
        ),
      );
    }
  }
}
