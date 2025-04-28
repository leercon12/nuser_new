import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:delayed_widget/delayed_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/login_join/sms/sms_page.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/service/future_service.dart';
import 'package:flutter_mixcall_normaluser_new/service/myinfo_service.dart';
import 'package:flutter_mixcall_normaluser_new/service/sms_service.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/bottomSheet.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class MyInfoPage extends StatefulWidget {
  const MyInfoPage({super.key});

  @override
  State<MyInfoPage> createState() => _MyInfoPageState();
}

class _MyInfoPageState extends State<MyInfoPage> {
  @override
  void initState() {
    super.initState();
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    _phoneText.text = dataProvider.userData!.phone.toString();
    _emailText.text = dataProvider.userData!.email.toString();
    _nameText.text = dataProvider.userData!.name.toString();
  }

  TextEditingController _phoneText = TextEditingController();
  TextEditingController _nameText = TextEditingController();
  TextEditingController _emailText = TextEditingController();
  TextEditingController _pwText = TextEditingController();
  TextEditingController _pwText2 = TextEditingController();
  TextEditingController _pw2Text = TextEditingController();
  TextEditingController _pwRe2Text = TextEditingController();

  bool _isLoading = false;
  bool _isOk = false;

  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final maprovider = Provider.of<MapProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '나의 정보',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                  onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                  child: ContainedTabBarView(
                    initialIndex: 0,
                    tabs: [
                      const Text('회원 정보', style: TextStyle(fontSize: 18)),
                      const Text('비밀번호 변경', style: TextStyle(fontSize: 18)),
                    ],
                    tabBarProperties: TabBarProperties(
                      height: 50.0,
                      indicatorColor: Colors.transparent,
                      background: Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      indicatorWeight: 6.0,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      unselectedLabelStyle: const TextStyle(fontWeight: null),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kGreenFontColor,
                      ),
                    ),
                    views: [
                      _myInfo(maprovider),
                      _pw(),
                    ],
                  )))),
    );
  }

  Widget _myInfo(MapProvider maprovider) {
    final dataProvider = Provider.of<DataProvider>(context);
    final mapProvider = Provider.of<MapProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Form(
          key: _formKey,
          child: Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: KTextWidget(
                        text: 'ID(핸드폰 번호)',
                        size: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  CustomTextBigFormField(
                      maxLength: 12,
                      hintSize: 16,
                      contentsSize: 16,
                      controller: _phoneText,
                      searchLoading: _isLoading,
                      onChanged: (value) {},
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '전화번호를 입력해주세요';
                        }
                        if (value.length != 11) {
                          return '11자리 번호를 입력해주세요';
                        }
                        return null;
                      },
                      context: context,
                      input: [
                        FilteringTextInputFormatter.digitsOnly, // 숫자만 허용
                      ],
                      hint: '스마트폰 번호 입력 후, 인증을 완료하세요.'),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        KTextWidget(
                            text: '비밀번호 재입력',
                            size: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        KTextWidget(
                            text: '회원정보 변경을 위해서는 비밀번호가 필요합니다.',
                            size: 14,
                            fontWeight: null,
                            color: Colors.grey),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextBigFormField(
                      maxLength: 12,
                      hintSize: 16,
                      obs: true,
                      contentsSize: 16,
                      controller: _pwText,
                      searchLoading: _isLoading,
                      onChanged: (value) {},
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호를 입력하세요.';
                        }
                        if (value.length < 6) {
                          return '비밀번호는 6자 이상입니다.';
                        }
                        return null;
                      },
                      context: context,
                      input: null,
                      hint: '6자리 이상 비밀번호를 입력하세요.'),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: KTextWidget(
                        text: '회원 이름',
                        size: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  CustomTextBigFormField(
                      maxLength: 20,
                      hintSize: 16,
                      contentsSize: 16,
                      controller: _nameText,
                      searchLoading: _isLoading,
                      onChanged: (value) {},
                      validator: (value) {
                        // 빈값 체크
                        if (value == null || value.isEmpty) {
                          return '이름을 입력해주세요.';
                        }

                        // 공백 체크 (맨 앞/뒤 공백, 연속 공백)
                        if (value.startsWith(' ') ||
                            value.endsWith(' ') ||
                            value.contains('  ')) {
                          return '올바른 이름 형식이 아닙니다.';
                        }

                        // 한글과 영문만 허용 체크 (공백 제외하고)
                        String valueWithoutSpaces = value.replaceAll(' ', '');
                        if (!RegExp(r'^[가-힣a-zA-Z]+$')
                            .hasMatch(valueWithoutSpaces)) {
                          return '한글과 영문만 입력 가능합니다.';
                        }

                        // 최소 길이 체크 (공백 제외하고)
                        if (valueWithoutSpaces.length < 2) {
                          return '이름은 2자 이상이어야 합니다.';
                        }

                        return null; // 유효성 검사 통과
                      },
                      context: context,
                      hint: '이용자 실명을 입력하세요.'),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        KTextWidget(
                            text: '이메일 주소',
                            size: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        KTextWidget(
                            text: '비밀번호 변경 및 보고서 수취에 이둉됩니다.',
                            size: 14,
                            fontWeight: null,
                            color: Colors.grey),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextBigFormField(
                      maxLength: 50,
                      hintSize: 16,
                      contentsSize: 16,
                      controller: _emailText,
                      searchLoading: _isLoading,
                      onChanged: (value) {},
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '이메일을 입력해주세요';
                        }

                        // 이메일 정규식 패턴
                        final emailRegex = RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                        );

                        if (!emailRegex.hasMatch(value)) {
                          return '올바른 이메일 형식이 아닙니다';
                        }

                        return null; // 유효성 검사 통과
                      },
                      context: context,
                      hint: '이메일 주소를 입력하세요.'),
                ],
              ),
            ),
          ),
        ),
        //const Spacer(),
        GestureDetector(
            onTap: () async {
              HapticFeedback.lightImpact();
              await _newUpdate(dataProvider, maprovider);
            },
            child: DelayedWidget(
              animation: DelayedAnimations.SLIDE_FROM_BOTTOM,
              animationDuration: const Duration(milliseconds: 500),
              child: Container(
                margin: const EdgeInsets.only(left: 4, right: 4),
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: kGreenFontColor,
                ),
                child: const Center(
                  child: KTextWidget(
                      text: '회원 정보 변경',
                      size: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            )),
      ],
    );
  }

  Widget _pw() {
    final dataProvider = Provider.of<DataProvider>(context);
    return Form(
      key: _formKey2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KTextWidget(
                    text: '현재 비밀번호',
                    size: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                KTextWidget(
                    text: '현재 이용중이신 비밀번호를 입력하세요.',
                    size: 14,
                    fontWeight: null,
                    color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 8),
          CustomTextBigFormField(
              maxLength: 12,
              hintSize: 16,
              contentsSize: 16,
              obs: true,
              controller: _pwText2,
              searchLoading: _isLoading,
              onChanged: (value) {},
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '비밀번호를 입력하세요.';
                }
                if (value.length < 6) {
                  return '비밀번호는 6자 이상입니다.';
                }
                return null;
              },
              context: context,
              hint: '6자리 이상 비밀번호를 입력하세요.'),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: Divider(color: Colors.grey.withOpacity(0.5)),
          ),

          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KTextWidget(
                    text: '변경 비밀번호',
                    size: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                KTextWidget(
                    text: '변경하실 비밀번호를 입력하세요.',
                    size: 14,
                    fontWeight: null,
                    color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 8),
          CustomTextBigFormField(
              maxLength: 12,
              hintSize: 16,
              contentsSize: 16,
              controller: _pw2Text,
              obs: true,
              searchLoading: _isLoading,
              onChanged: (value) {},
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '비밀번호를 입력하세요.';
                }
                if (value.length < 6) {
                  return '비밀번호는 6자 이상입니다.';
                }
                return null;
              },
              context: context,
              hint: '6자리 이상 비밀번호를 입력하세요.'),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KTextWidget(
                    text: '변경 비밀번호 재입력',
                    size: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                KTextWidget(
                    text: '변경하실 비밀번호를 재입력하세요.',
                    size: 14,
                    fontWeight: null,
                    color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 8),
          CustomTextBigFormField(
              maxLength: 12,
              hintSize: 16,
              contentsSize: 16,
              obs: true,
              controller: _pwRe2Text,
              searchLoading: _isLoading,
              onChanged: (value) {},
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '비밀번호를 입력하세요.';
                }
                if (value.length < 6) {
                  return '비밀번호는 6자 이상입니다.';
                }
                return null;
              },
              context: context,
              hint: '6자리 이상 비밀번호를 입력하세요.'),
          const Spacer(),
          GestureDetector(
              onTap: () async {
                HapticFeedback.lightImpact();
                await _updatePw(dataProvider);
              },
              child: DelayedWidget(
                animation: DelayedAnimations.SLIDE_FROM_BOTTOM,
                animationDuration: const Duration(milliseconds: 500),
                child: Container(
                  margin: const EdgeInsets.only(left: 4, right: 4),
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: kGreenFontColor,
                  ),
                  child: const Center(
                    child: KTextWidget(
                        text: '비밀 번호 변경',
                        size: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Future _updatePw(DataProvider dataProvider) async {
    if (_formKey2.currentState!.validate()) {
      final isReauthenticated = await reauthenticate(_pwText2.text.trim());
      final _auth = FirebaseAuth.instance;
      final user = _auth.currentUser;
      if (_pwRe2Text.text.trim() == _pw2Text.text.trim()) {
        if (isReauthenticated == true) {
          // 비밀번호 변경
          if (_pwRe2Text.text.isNotEmpty) {
            await user!.updatePassword(_pwRe2Text.text.trim());

            ScaffoldMessenger.of(context)
                .showSnackBar(currentSnackBar('비밀번호가 정상적으로 변경되었습니다.', context));
          }
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(errorSnackBar('비밀번호가 틀립니다.', context));
        }
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(errorSnackBar('변경 비밀번호가 일치하지 않습니다.', context));
      }
    }
  }

  Future _newUpdate(DataProvider dataProvider, MapProvider mapProvider) async {
    HapticFeedback.lightImpact();
    hideKeyboard(context);
    final _auth = FirebaseAuth.instance;
    if (_formKey.currentState!.validate()) {
      final isReauthenticated = await reauthenticate(_pwText.text.trim());

      if (isReauthenticated == true) {
        if (dataProvider.userData!.phone == _phoneText.text.trim()) {
          await FirebaseFirestore.instance
              .collection('user_normal')
              .doc(dataProvider.userData!.uid.toString())
              .update({
            'email': _emailText.text.trim(),
            'name': _nameText.text.trim(),
            'phone': _phoneText.text.trim(),
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(currentSnackBar('회원정보가 정상적으로 변경되었습니다.', context));
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(errorSnackBar('비밀번호가 틀렸습니다.', context));
        }
      } else {
        if (isReauthenticated == true) {
          final _isEmail = await isEmailAlreadyRegistered(
              _phoneText.text.trim() + '@mixcallNuser.com');
          if (_isEmail == false) {
            final user = _auth.currentUser;
            // 이메일 변경
            if (_phoneText.text.isNotEmpty &&
                _phoneText.text != dataProvider.userData!.phone) {
              mapProvider.isLoadingState(true);
              await SMSService.sendSMS(_phoneText.text.trim())
                  .then((value) async {
                if (value == true) {
                  mapProvider.isLoadingState(false);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const SmsMainPage(callType: '회원정보변경')),
                  ).then((vlaue) async {
                    if (value == 'pass') {
                      await user!.updateEmail(
                          _phoneText.text.trim() + '@mixcallNuser.com');
                      await FirebaseFirestore.instance
                          .collection('user_normal')
                          .doc(dataProvider.userData!.uid.toString())
                          .update({
                        'email': _emailText.text.trim(),
                        'name': _nameText.text.trim(),
                        'phone': _phoneText.text.trim(),
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                          currentSnackBar('회원정보가 정상적으로 변경되었습니다.', context));
                    }
                  });
                } else {
                  mapProvider.isLoadingState(false);
                  ScaffoldMessenger.of(context).showSnackBar(errorSnackBar(
                      '인증문자 발송에 실패했습니다.\n잠시후 다시 시도하세요.', context));
                }
              });
            }
          } else {
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
                      color: kRedColor,
                    ),
                    const SizedBox(height: 28),
                    const KTextWidget(
                        text: '이미 사용중인 전화번호입니다.',
                        size: 18,
                        fontWeight: FontWeight.bold,
                        color: null),
                    const KTextWidget(
                        text: '이미 사용중인 전화번호로 가입할 수 없습니다.',
                        size: 14,
                        fontWeight: null,
                        color: Colors.grey),
                    const KTextWidget(
                        text: '자세한 안내는 아래 문의번호로 문의해 주세요.',
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
                              HapticFeedback.lightImpact();
                              makePhoneCall('0322271107');
                            },
                            child: const UnderLineWidget(
                                text: '032-227-1107', color: kGreenFontColor))
                      ],
                    ),
                    const SizedBox(
                      height: 32,
                    )
                  ],
                ));
              },
            );
          }
        } else {}
      }
    }
  }
}








/* */