import 'package:delayed_widget/delayed_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/login_join/sms/sms_page.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/service/future_service.dart';
import 'package:flutter_mixcall_normaluser_new/service/sms_service.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/bottomSheet.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class NormalUserJoin extends StatefulWidget {
  const NormalUserJoin({super.key});

  @override
  State<NormalUserJoin> createState() => _NormalUserJoinState();
}

class _NormalUserJoinState extends State<NormalUserJoin> {
  TextEditingController _phoneText = TextEditingController();
  TextEditingController _nameText = TextEditingController();
  TextEditingController _emailText = TextEditingController();
  TextEditingController _pwText = TextEditingController();
  TextEditingController _pwReText = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isOk = false;

  @override
  void dispose() {
    super.dispose();
    _phoneText.dispose();
    _nameText.dispose();
    _emailText.dispose();
    _pwText.dispose();
    _pwReText.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maprovider = Provider.of<MapProvider>(context);
    return _isOk == true
        ? SmsMainPage(callType: '일반')
        : GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Column(
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
                                FilteringTextInputFormatter
                                    .digitsOnly, // 숫자만 허용
                              ],
                              hint: '스마트폰 번호 입력 후, 인증을 완료하세요.'),
                          const SizedBox(height: 12),
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: KTextWidget(
                                text: '비밀번호',
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
                              searchLoading: _isLoading,
                              onChanged: (value) {},
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '비밀번호를 입력하세요.';
                                }
                                if (value.length < 6) {
                                  return '6자리 이상 비밀번호를 입력하세요.';
                                }
                                return null;
                              },
                              context: context,
                              input: [],
                              isDigt: true,
                              hint: '비밀번호 6자리 이상을 입력하세요.'),
                          const SizedBox(height: 8),
                          CustomTextBigFormField(
                              maxLength: 30,
                              hintSize: 16,
                              contentsSize: 16,
                              obs: true,
                              controller: _pwReText,
                              searchLoading: _isLoading,
                              onChanged: (value) {},
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '비밀번호를 입력하세요.';
                                }
                                if (value.length < 6) {
                                  return '6자리 이상 비밀번호를 입력하세요.';
                                }

                                if (_pwText.text.trim() !=
                                    _pwReText.text.trim()) {
                                  return '비밀번호가 일치하지 않습니다';
                                }

                                return null;
                              },
                              context: context,
                              isDigt: true,
                              input: [],
                              hint: '비밀번호를 다시 한번 입력하세요.'),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(left: 12, right: 12),
                            child: Divider(
                              color: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          const SizedBox(height: 8),
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
                                String valueWithoutSpaces =
                                    value.replaceAll(' ', '');
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
                          const SizedBox(height: 12),
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

                      print(_pwText.text.length);

                      hideKeyboard(context);
                      if (_formKey.currentState!.validate()) {
                        print('!!!!');
                        maprovider.joinEmailState(_emailText.text.trim());
                        maprovider.joinPhoneState(_phoneText.text.trim());
                        maprovider.joinUserNameState(_nameText.text.trim());
                        maprovider.joinPwState(_pwReText.text.trim());

                        if (maprovider.joinEmail != null &&
                            maprovider.joinPhone != null &&
                            maprovider.joinUserName != null) {
                          final _isEmail = await isEmailAlreadyRegistered(
                              _phoneText.text.trim() + '@mixcallNuser.com');

                          if (_isEmail == false) {
                            try {
                              maprovider.isLoadingState(true);
                              await SMSService.sendSMS(_phoneText.text.trim())
                                  .then((value) {
                                if (value == true) {
                                  maprovider.isLoadingState(false);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SmsMainPage(callType: '일반')),
                                  );
                                } else {
                                  maprovider.isLoadingState(false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      errorSnackBar(
                                          '인증문자 발송에 실패했습니다.\n잠시후 다시 시도하세요.',
                                          context));
                                }
                              });
                            } catch (e) {
                              maprovider.isLoadingState(false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  errorSnackBar(
                                      '죄송합니다. 오류가 발생했습니다.\n잠시후 다시 시도하세요.',
                                      context));
                            }
                          } else {
                            maprovider.isLoadingState(false);
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                          }
                        }
                      } else {
                        print('!!');
                      }
                    },
                    child: DelayedWidget(
                      animation: DelayedAnimations.SLIDE_FROM_BOTTOM,
                      animationDuration: const Duration(milliseconds: 500),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: kGreenFontColor,
                        ),
                        child: const Center(
                          child: KTextWidget(
                              text: '스마트폰 인증 받기',
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
}

/*     
          
          
          
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
                  const SizedBox(height: 12),
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
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      hint: '스마트폰 번호를 입력하세요.'), */
