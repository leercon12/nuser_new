import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_widget/delayed_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/splash.dart';
import 'package:flutter_mixcall_normaluser_new/providers/hashProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/service/sms_service.dart';
import 'package:flutter_mixcall_normaluser_new/setting/loading_page.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class SmsMainPage extends StatefulWidget {
  final String callType;
  const SmsMainPage({super.key, required this.callType});

  @override
  State<SmsMainPage> createState() => _SmsMainPageState();
}

class _SmsMainPageState extends State<SmsMainPage> {
  @override
  Widget build(BuildContext context) {
    final dw = MediaQuery.of(context).size.width;
    TextEditingController _verigText = TextEditingController();
    final maprovider = Provider.of<MapProvider>(context);
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              widget.callType == '회원정보변경' ? '회원 정보 변경' : '회원 가입',
              style: TextStyle(fontSize: 20),
              //style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: SafeArea(
            child: SizedBox(
              width: dw,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Lottie.asset('asset/lottie/sms2.json', width: 150),
                    const KTextWidget(
                        text: '인증번호가 발송되었습니다.',
                        size: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    const KTextWidget(
                        text: '혼적콜에서 발송된 6자리 숫자를 입력하세요.',
                        size: 14,
                        fontWeight: null,
                        color: Colors.grey),
                    const SizedBox(height: 8),
                    CustomTextBigFormField(
                        controller: _verigText,
                        searchLoading: false,
                        onChanged: (value) {
                          // length를 직접 받음
                        },
                        context: context,
                        input: [
                          // 숫자만 입력 가능하도록
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        hint: '인증번호(6자리)를 입력하세요.',
                        maxLength: 6),
                    const Spacer(),
                    DelayedWidget(
                      animation: DelayedAnimations.SLIDE_FROM_BOTTOM,
                      animationDuration: const Duration(milliseconds: 500),
                      child: GestureDetector(
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          if (_verigText.text.length == 6) {
                            maprovider.isLoadingState(true);
                            await SMSService.verifySMS(
                                    maprovider.joinPhone.toString(),
                                    _verigText.text.trim())
                                .then((value) async {
                              switch (value) {
                                case 'pass':
                                  print('Verification successful');

                                  if (widget.callType == '회원정보변경') {
                                    Navigator.pop(context, 'pass');
                                  } else {
                                    await _joinNUser(maprovider);
                                    maprovider.isLoadingState(false);
                                  }

                                  break;
                                case 'noPass':
                                  maprovider.isLoadingState(false);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                      errorSnackBar('인증번호가 틀립니다.\n인증번호를 확인하세요.',
                                          context));
                                  break;

                                case 'noTime':
                                  maprovider.isLoadingState(false);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      errorSnackBar(
                                          '시간이 만료되었습니다.\n 다시 시도하세요.', context));
                                  break;
                                default:
                                  print('Error occurred during verification');
                              }
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                errorSnackBar('인증번호 6자리를 입력하세요.', context));
                          }
                        },
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: kGreenFontColor,
                          ),
                          child: const Center(
                            child: KTextWidget(
                                text: '혼적콜 회원 가입',
                                size: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        if (maprovider.isLoading == true) const LoadingPage()
      ],
    );
  }

  Future _joinNUser(MapProvider mapProvider) async {
    if (widget.callType == '일반') {
      await _normal(mapProvider);
    } else {}
  }

  Future _normal(MapProvider mapProvider) async {
    final hashProvider = Provider.of<HashProvider>(context, listen: false);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: mapProvider.joinPhone.toString() + '@mixcallNuser.com',
        password: mapProvider.joinPw.toString(),
      );
      // 성공적으로 계정 생성 및 로그인된 상태
      User? user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('user_normal')
          .doc(user!.uid)
          .set({
        'name': mapProvider.joinUserName!.trim().toString(),
        'joinDate': DateTime.now(),
        'email': mapProvider.joinEmail!.trim().toString(),
        'phone': mapProvider.joinPhone!.trim().toString(),
        'uid': user.uid,
      });

      await FirebaseFirestore.instance
          .collection('cargo_px')
          .doc('user_normal')
          .collection(user.uid)
          .doc('main_px')
          .set({'px': hashProvider.encryptData('0')});
      mapProvider.isLoginState(false);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const SplashPage(),
        ),
        (route) => false, // 모든 이전 라우트 제거
      );
    } catch (e) {
      // 에러 처리
      mapProvider.isLoginState(false);
      print('Error: $e');
    }
  }
}
