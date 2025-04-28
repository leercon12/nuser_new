import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/login_join/login/login_main.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/loading_page.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class LoginMainPage extends StatefulWidget {
  const LoginMainPage({super.key});

  @override
  State<LoginMainPage> createState() => _LoginMainPageState();
}

class _LoginMainPageState extends State<LoginMainPage> {
  Timer? _timer; // 타이머 변수 추가
  @override
  void initState() {
    super.initState();
    // Start a timer to change the image every 2 seconds
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % imagePaths.length;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    // 타이머 취소
    _timer?.cancel();
  }

  int _currentIndex = 0;
  List<String> imagePaths = [
    'asset/img/pack_con.png',
    'asset/img/pack.png',
    'asset/img/pack_de.png',
    // Add more image paths here
  ];

  List<String> _captions = [
    '어떤 사이즈의 화물이라도',
    '혼적이든 독차이든',
    '혼적콜에 등록하고 가격제안 받으세요!',

    // Add captions corresponding to the images
  ];

  bool _isClick = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: _isClick == true
              ? const LoginPage()
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 56),
                      Image.asset(
                        'asset/img/logo.gif',
                        width: 110,
                        height: 110,
                      ),
                      const SizedBox(height: 16),
                      const FittedBox(
                        child: KTextWidget(
                            text: '용달을 이용하는 새로운 방법,\n혼적부터 독차까지 혼적콜을 경험하세요!',
                            size: 22,
                            fontWeight: FontWeight.bold,
                            color: null),
                      ),
                      KTextWidget(
                          text: _captions[_currentIndex],
                          size: 16,
                          fontWeight: null,
                          color: Colors.grey),
                      const Expanded(child: SizedBox()),
                      GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            hideKeyboard(context);

                            setState(() {
                              _isClick = true;
                            });
                            //  AuthProvider.isLoginState(true);
                          },
                          child: bottomBox(text: '시작하기', change: null))
                    ],
                  ),
                )),
    );
  }
}
