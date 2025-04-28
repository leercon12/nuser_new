import 'package:delayed_widget/delayed_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/service/sms_service.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class PhoneVerif extends StatefulWidget {
  const PhoneVerif({super.key});

  @override
  State<PhoneVerif> createState() => _PhoneVerifState();
}

class _PhoneVerifState extends State<PhoneVerif> {
  TextEditingController _phoneText = TextEditingController();
  TextEditingController _verifText = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    super.dispose();
    _phoneText.dispose();
    _verifText.dispose();
  }

  bool _isVerif = false;

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: KTextWidget(
                text: '등록된 휴대폰 번호',
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
              searchLoading: false,
              onChanged: (value) {},
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '가입된 전화번호를 입력해주세요';
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
              hint: '가입된 전화번호를 입력해주세요'),
          const SizedBox(height: 8),
          if (_isVerif == false)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    if (_formKey.currentState!.validate() == false) {
                      print('22');
                    } else {
                      mapProvider.isLoadingState(true);
                      print('33');
                      bool _send =
                          await SMSService.sendSMS(_phoneText.text.trim());

                      if (_send == true) {
                        setState(() {
                          _isVerif = true;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            errorSnackBar(
                                '네트워크 문제가 발생했습니다.\n잠시 후 다시 시도하세요.', context));
                      }
                      mapProvider.isLoadingState(false);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: kGreenFontColor,
                    ),
                    child: const Center(
                      child: KTextWidget(
                          text: '인증받기',
                          size: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            )
          else
            CustomTextBigFormField(
                maxLength: 12,
                hintSize: 16,
                contentsSize: 16,
                controller: _verifText,
                searchLoading: false,
                onChanged: (value) {},
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '문자로 발송된 인증번호를 입력하세요.';
                  }
                  if (value.length != 6) {
                    return '6자리 인증 번호를 입력해주세요';
                  }
                  return null;
                },
                context: context,
                input: [
                  FilteringTextInputFormatter.digitsOnly, // 숫자만 허용
                ],
                hint: '인증번호 6자리를 입력하세요.'),
          const SizedBox(height: 12),
          const Spacer(),
          if (_isVerif == true)
            DelayedWidget(
              animation: DelayedAnimations.SLIDE_FROM_BOTTOM,
              animationDuration: const Duration(milliseconds: 500),
              child: GestureDetector(
                onTap: () async {
                  if (_formKey.currentState!.validate() == false) {
                    print('@@');
                  } else {
                    mapProvider.isLoadingState(true);
                    final result = await SMSService.verifySMS(
                        _phoneText.text.trim(), _verifText.text.trim());

                    if (result == 'pass') {
                      mapProvider.resetPhoneState(_phoneText.text.trim());
                      mapProvider.isResetVerifState(true);
                    } else {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(errorSnackBar('인증번호가 틀립니다.', context));
                    }
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
                        text: '전화번호 인증받기',
                        size: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
