import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/login_join/join/join_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/login_join/pw_reset/pw_reset.dart';
import 'package:flutter_mixcall_normaluser_new/pages/splash.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/service/future_service.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/loading_page.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/bottomSheet.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _phoneText = TextEditingController();
  TextEditingController _pwText = TextEditingController();
  bool _searchLoading = false;
  bool _isSnackBarVisible = false;
  num? _inputNum = 0;
  num? _inputNum2 = 0;

  @override
  void dispose() {
    super.dispose();
    _phoneText.dispose();
    _pwText.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maprovider = Provider.of<MapProvider>(context);
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 56),
              Image.asset(
                'asset/img/logo.png',
                width: 65,
                height: 65,
              ),
              const SizedBox(height: 25),
              const KTextWidget(
                  text: '휴대폰 번호', size: 14, fontWeight: null, color: null),
              const SizedBox(height: 8),
              SizedBox(
                height: 52,
                child: TextFormField(
                  // focusNode: _focusNodes[1],
                  controller: _phoneText,
                  autocorrect: false,
                  maxLength: 12,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  minLines: 1,
                  maxLines: 1,
                  textAlign: TextAlign.start,

                  style: TextStyle(
                      color: _searchLoading == true ? Colors.grey : null,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    counterStyle: const TextStyle(fontSize: 0),
                    filled: true, // 배경을 채우도록 설정
                    fillColor: btnColor, // 배경색 설정
                    /*   contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 10), // 텍스트 중앙 정렬을 위한 패딩 */
                    hintText: "'-'없이 가입된 핸드폰번호를 입력하세요.",

                    hintStyle: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                        color: Colors.grey),

                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 0.0),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    focusedBorder: OutlineInputBorder(
                      // 선택되었을 때 보덕색으로 표시됨
                      borderSide:
                          const BorderSide(color: kGreenFontColor, width: 1.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    enabled: !_searchLoading,
                  ),
                  onChanged: (value) {
                    if (!RegExp(r'^[0-9]*$').hasMatch(value)) {
                      if (!_isSnackBarVisible) {
                        _isSnackBarVisible = true;
                        ScaffoldMessenger.of(context)
                            .showSnackBar(errorSnackBar('숫자만 입력하세요!', context))
                            .closed
                            .then((_) {
                          _isSnackBarVisible =
                              false; // 스낵바가 닫히면 플래그를 다시 false로 설정
                        });
                      }
                      _phoneText.text = value.replaceAll(
                          RegExp(r'[^0-9]'), ''); // 숫자 이외의 문자 제거
                      _phoneText.selection = TextSelection.fromPosition(
                        TextPosition(offset: _phoneText.text.length),
                      ); // 커서 위치 유지
                    }
                    setState(() {
                      _inputNum = value.length;
                      print(value.length);
                    });
                  },
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 52,
                child: TextFormField(
                  // focusNode: _focusNodes[1],
                  controller: _pwText,
                  autocorrect: false,
                  maxLength: 30,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  minLines: 1,
                  maxLines: 1,
                  textAlign: TextAlign.start,
                  obscureText: true,
                  style: TextStyle(
                      color: _searchLoading == true ? Colors.grey : null,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    counterStyle: const TextStyle(fontSize: 0),
                    filled: true, // 배경을 채우도록 설정
                    fillColor: btnColor, // 배경색 설정
                    /* contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 10), // 텍스트 중앙 정렬을 위한 패딩 */
                    hintText: "6자 이상 비밀번호를 입력하세요.",

                    hintStyle: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                        color: Colors.grey),

                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 0.0),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    focusedBorder: OutlineInputBorder(
                      // 선택되었을 때 보덕색으로 표시됨
                      borderSide:
                          const BorderSide(color: kGreenFontColor, width: 1.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    enabled: !_searchLoading,
                  ),
                  onChanged: (value) {
                    /*   if (!RegExp(r'^[0-9]*$').hasMatch(value)) {
                      if (!_isSnackBarVisible) {
                        _isSnackBarVisible = true;
                        ScaffoldMessenger.of(context)
                            .showSnackBar(errorSnackBar('숫자만 입력하세요!', context))
                            .closed
                            .then((_) {
                          _isSnackBarVisible =
                              false; // 스낵바가 닫히면 플래그를 다시 false로 설정
                        });
                      }
                      _phoneText.text = value.replaceAll(
                          RegExp(r'[^0-9]'), ''); // 숫자 이외의 문자 제거
                      _phoneText.selection = TextSelection.fromPosition(
                        TextPosition(offset: _phoneText.text.length),
                      ); // 커서 위치 유지
                    } */
                    setState(() {
                      _inputNum2 = value.length;
                      print(value.length);
                    });
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (BuildContext context) {
                          return BottomSheetWidget(
                              contents: Column(
                            children: [
                              const Icon(
                                Icons.info,
                                size: 60,
                                color: kGreenFontColor,
                              ),
                              const SizedBox(height: 28),
                              const KTextWidget(
                                  text: '로그인 후 전화변경이 가능합니다.',
                                  size: 18,
                                  fontWeight: FontWeight.bold,
                                  color: null),
                              const KTextWidget(
                                  text: '로그인 후, 메뉴>>내정보에서 전화번호를 변경하세요.',
                                  size: 14,
                                  fontWeight: null,
                                  color: Colors.grey),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const KTextWidget(
                                      text: '문의 전화 : ',
                                      size: 14,
                                      fontWeight: null,
                                      color: Colors.grey),
                                  GestureDetector(
                                      onTap: () {
                                        makePhoneCall('0322271107');
                                      },
                                      child: const UnderLineWidget(
                                          text: '032-227-1107',
                                          color: kGreenFontColor))
                                ],
                              ),
                              const SizedBox(
                                height: 32,
                              )
                            ],
                          ));
                        },
                      );
                    },
                    child: const KTextWidget(
                        text: '휴대번호가 변경되셨나요?',
                        size: 14,
                        fontWeight: null,
                        color: Colors.grey),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PwResetMainPage()),
                      );
                    },
                    child: KTextWidget(
                        text: '비밀번호 재설정',
                        size: 14,
                        fontWeight: null,
                        color: Colors.grey),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    //AuthProvider.loginPhoneState(_phoneText.text.trim());
                    hideKeyboard(context);
                    await _login(maprovider);
                  },
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: _inputNum! < 3 || _inputNum2! < 6
                          ? noState
                          : kGreenFontColor,
                    ),
                    child: Center(
                      child: KTextWidget(
                          text: '로그인',
                          size: 16,
                          fontWeight: FontWeight.bold,
                          color: _inputNum! < 3 || _inputNum2! < 6
                              ? Colors.grey
                              : Colors.white),
                    ),
                  )),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      hideKeyboard(context);
                      final maprovider =
                          Provider.of<MapProvider>(context, listen: false);
                      maprovider.joinTypeState(null);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const JoinMainPage()),
                      );
                    },
                    child: const KTextWidget(
                        text: '혼적콜 회원 가입하기',
                        size: 16,
                        fontWeight: null,
                        color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
        if (maprovider.isLoading == true) const LoadingPage(),
      ],
    );
  }

  Future<Map<String, dynamic>> _login(MapProvider mapProvider) async {
    try {
      mapProvider.isLoadingState(true);
      String? id = _phoneText.text.trim() + '@mixcallnuser.com';
      String? password = _pwText.text.trim();

      // Firebase 로그인 시도
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: id,
        password: password,
      );

      if (userCredential.user != null) {
        mapProvider.isLoadingState(false);

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SplashPage()));

        return {
          'success': true,
          'message': '로그인 성공',
          'user': userCredential.user
        };
      } else {
        mapProvider.isLoadingState(false);
        ScaffoldMessenger.of(context).showSnackBar(
            errorSnackBar('사용자 정보가 없습니다\n신규회원으로 가입하세요.', context));
        return {'success': false, 'message': '로그인 실패: 사용자 정보가 없습니다'};
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = '로그인 실패';
      mapProvider.isLoadingState(false);
      switch (e.code) {
        case 'user-not-found':
          errorMessage = '존재하지 않는 계정입니다';
          break;
        case 'wrong-password':
          errorMessage = '비밀번호가 올바르지 않습니다';
          break;
        case 'invalid-email':
          errorMessage = '유효하지 않은 이메일 형식입니다';
          break;
        case 'user-disabled':
          errorMessage = '비활성화된 계정입니다';
          break;
        default:
          errorMessage = '로그인 중 오류가 발생했습니다';
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(errorSnackBar(errorMessage, context));
      print(e);
      return {'success': false, 'message': errorMessage, 'error': e.code};
    } catch (e) {
      print(e);
      mapProvider.isLoadingState(false);

      ScaffoldMessenger.of(context).showSnackBar(
          errorSnackBar('알 수 없는 오류가 발생했습니다.\n잠시 후 다시 시도하세요.', context));
      return {
        'success': false,
        'message': '알 수 없는 오류가 발생했습니다',
        'error': e.toString()
      };
    }
  }
}
