import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_widget/delayed_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/normal_state/up_down/set_page/address.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/hashProvider.dart';
import 'package:flutter_mixcall_normaluser_new/service/pick_image_service.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/address_dialog.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/bank.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/loading_page.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/bottomSheet.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/image_dialog.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CompanyAddPage extends StatefulWidget {
  final String? busImg;
  final String? accImg;
  final String? logoImg;
  final String? comName;
  final String? comNum;
  final String? address;
  final String? addressDis;
  final String? email;
  final String? ceoName;
  final String? accName;
  final String? accNum;
  final String? bankName;
  final String? comZone;
  final String? comUid;

  const CompanyAddPage(
      {super.key,
      this.accImg,
      this.busImg,
      this.logoImg,
      this.accName,
      this.accNum,
      this.address,
      this.addressDis,
      this.ceoName,
      this.comName,
      this.comNum,
      this.bankName,
      this.comZone,
      this.comUid,
      this.email});

  @override
  State<CompanyAddPage> createState() => _CompanyAddPageState();
}

class _CompanyAddPageState extends State<CompanyAddPage> {
  @override
  void initState() {
    super.initState();
    final hashProvider = Provider.of<HashProvider>(context, listen: false);
    if (widget.accImg != null) {
      _comNameText.text = widget.comName.toString();
      _bNumText.text = widget.comNum.toString();
      _addressText.text = widget.address.toString();

      _emailText.text = widget.email.toString();
      _nameText.text = widget.ceoName.toString();
      _aNameText.text = widget.accName.toString();
      _aNumText.text = hashProvider.decryptData(widget.accNum.toString());
      selectedBankName = widget.bankName.toString();

      if (widget.addressDis == null) {
        _addressDisText.text;
      } else {
        _addressDisText.text = widget.addressDis.toString();
      }

      _zone = widget.comZone;

      _input1 = _comNameText.text.length;
      _input2 = _emailText.text.length;
      _input3 = _nameText.text.length;
      _input4 = _bNumText.text.length;
      _input5 = _aNameText.text.length;
      _input6 = _aNumText.text.length;

      setState(() {});
    }
  }

  @override
  void dispose() {
    _comNameText.dispose();
    _bNumText.dispose();
    _addressDisText.dispose();
    _addressText.dispose();
    _emailText.dispose();
    _nameText.dispose();
    _aNameText.dispose();
    _aNumText.dispose();

    super.dispose();
  }

  TextEditingController _comNameText = TextEditingController();
  TextEditingController _bNumText = TextEditingController();

  TextEditingController _addressText = TextEditingController();
  TextEditingController _addressDisText = TextEditingController();

  TextEditingController _emailText = TextEditingController();
  TextEditingController _nameText = TextEditingController();

  TextEditingController _aNameText = TextEditingController();
  TextEditingController _aNumText = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final addProvider = Provider.of<AddProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    return GestureDetector(
      onTap: () => hideKeyboard(context),
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text(
                '기업(단체) 등록',
                style: TextStyle(fontSize: 20),
              ),
            ),
            body: SafeArea(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _mainContents(addProvider),
                  const SizedBox(height: 10),
                  if (_is01 == true &&
                      _is02 == true &&
                      _is03 == true &&
                      _is04 == true &&
                      _is06 == true)
                    _btn(dataProvider, addProvider),
                ],
              ),
            )),
          ),
          if (addProvider.addLoading == true) const LoadingPage()
        ],
      ),
    );
  }

  //원미로 13번길 43

  Widget _mainContents(AddProvider addProvider) {
    return Expanded(
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _step01(),
              const SizedBox(height: 24),
              _emailState(),
              const SizedBox(height: 24),
              _nameState(),
              const SizedBox(height: 24),
              _step02(addProvider),
              const SizedBox(height: 24),
              _step03(addProvider),
              const SizedBox(height: 24),
              _step04(addProvider),
              const SizedBox(height: 24),
              _logo(addProvider),
              const SizedBox(height: 150),
            ],
          ),
        ),
      ),
    );
  }

  Widget _btn(DataProvider dataProvider, AddProvider addProvider) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();

        if (_formKey.currentState!.validate()) {
          if (widget.comUid != null) {
            await _updateNoramlCom(
                    addProvider, dataProvider, widget.comUid.toString())
                .then((value) {
              if (value == true) {
                dataProvider.userProvider();

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    currentSnackBar('소속정보 변경이 완료되었습니다.', context));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(errorSnackBar(
                    '알 수 없는 문제가 발생했습니다.\n잠시 후 다시 시도하세요.', context));
              }
            });
          } else {
            bool _isSame = await _searchBN();

            if (_isSame == true) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(errorSnackBar('이미 등록된 사업자 번호입니다.', context));
            } else {
              _btm1().then((vlaue) async {
                if (vlaue == true) {
                  await _addNoramlCom(addProvider, dataProvider).then((value) {
                    if (value == true) {
                      dataProvider.userProvider();

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                          currentSnackBar(
                              '등록이 완료되었습니다.\n승인까지 최대 2영업일이 소요됩니다.', context));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(errorSnackBar(
                          '알 수 없는 문제가 발생했습니다.\n잠시 후 다시 시도하세요.', context));
                    }
                  });
                }
              });
            }
          }
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(errorSnackBar('모든 정보가 입력되어야 합니다!', context));
        }

        //
      },
      child: DelayedWidget(
        animationDuration: const Duration(milliseconds: 400),
        animation: DelayedAnimations.SLIDE_FROM_BOTTOM,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12), color: kGreenFontColor),
          child: Center(
            child: KTextWidget(
                text: widget.accImg != null ? '기업(단체)정보 수정' : '기업(단체) 신규 등록',
                size: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
        ),
      ),
    );
  }

  Future<bool> _searchBN() async {
    try {
      // busNum 필드가 _bNumText.text와 일치하는 문서 검색
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('normalCom')
          .where('busNum', isEqualTo: _bNumText.text)
          .get();

      // 검색 결과가 있으면 true, 없으면 false 반환
      if (querySnapshot.docs.isNotEmpty) {
        print('사업자등록번호가 이미 등록되어 있습니다.');
        return true;
      } else {
        print('등록 가능한 사업자등록번호입니다.');
        return false;
      }
    } catch (e) {
      print('사업자등록번호 검색 중 오류 발생: $e');
      // 오류 발생 시 false 반환 또는 예외를 다시 throw할 수 있음
      return false;
    }
  }

  Future<bool?> _btm1() async {
    final dw = MediaQuery.of(context).size.width;
    final addProvider = Provider.of<AddProvider>(context, listen: false);

    return await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return BottomSheetWidget(
              contents: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),
                const Icon(Icons.info, size: 70, color: kGreenFontColor),
                const SizedBox(height: 32),
                const KTextWidget(
                    text: '등록까지 1~3영업일이 소요됩니다.',
                    size: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                const SizedBox(height: 12),
                const KTextWidget(
                    text:
                        '기업 또는 단체를 가입할 경우, 제출서류 확인 및 사업자\n조회를 위해 최소 1~3영업일이 소요됩니다. 정식 승인 전에는\n기업(단체)명의 운송 등록은 불가합니다.',
                    size: 14,
                    textAlign: TextAlign.center,
                    fontWeight: null,
                    color: Colors.grey),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context, true); // true 값을 반환
                  },
                  child: Container(
                    height: 52,
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    width: dw,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: kGreenFontColor),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        KTextWidget(
                            text: '확인',
                            size: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ));
        });
      },
    );
  }

  bool _is01 = false;
  bool _is02 = false;
  bool _is03 = false;
  bool _is04 = false;

  bool _is06 = false;

  int _input1 = 0;
  int _input2 = 0;
  int _input3 = 0;
  int _input4 = 0;
  int _input5 = 0;
  int _input6 = 0;
  Widget _step01() {
    _is01 = _input1 > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KTextWidget(
            text: '기업 또는 단체명 입력',
            size: 16,
            fontWeight: _is01 ? null : FontWeight.bold,
            color: _is01 ? Colors.grey.withOpacity(0.5) : Colors.white),
        const SizedBox(height: 8),
        Container(
          height: 56,
          child: TextFormField(
            controller: _comNameText,
            autocorrect: false,
            maxLength: 30,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            minLines: 1,
            maxLines: 1,
            textAlign: TextAlign.start,
            style: const TextStyle(
              color: null,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterStyle: const TextStyle(fontSize: 0),
              errorStyle:
                  const TextStyle(fontSize: 0, height: 0), // 기본 에러 스타일 완전히 숨기기
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: kRedColor)),
              errorText: null, // 기본 에러 텍스트 비활성화
              filled: true,
              fillColor: btnColor,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 10,
              ),
              hintText: '기업 또는 단체명을 입력하세요.',
              hintStyle: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
                color: Colors.grey,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: kGreenFontColor, width: 1.0),
                borderRadius: BorderRadius.circular(10),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _input1 = value.length;
              });
            },
            validator: (value) {},
          ),
        ),
      ],
    );
  }

  Widget _emailState() {
    _is02 = _input2 > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KTextWidget(
            text: '기업(단체) 이메일',
            size: 16,
            fontWeight: _is02 ? null : FontWeight.bold,
            color: _is02 ? Colors.grey.withOpacity(0.5) : Colors.white),
        KTextWidget(
            text: '기업 또는 단체의 대표 이메일주소를 입력하세요.',
            size: 14,
            fontWeight: null,
            color: _is02 ? Colors.grey.withOpacity(0.5) : Colors.grey),
        const SizedBox(height: 8),
        Container(
          height: 56,
          child: TextFormField(
            controller: _emailText,
            autocorrect: false,
            maxLength: 30,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            minLines: 1,
            maxLines: 1,
            textAlign: TextAlign.start,
            style: const TextStyle(
              color: null,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterStyle: const TextStyle(fontSize: 0),
              errorStyle:
                  const TextStyle(fontSize: 0, height: 0), // 기본 에러 스타일 완전히 숨기기
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: kRedColor)),
              errorText: null, // 기본 에러 텍스트 비활성화
              filled: true,
              fillColor: btnColor,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 10,
              ),
              hintText: '기업 또는 단체의 대표메일 주소를 입력하세요.',
              hintStyle: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
                color: Colors.grey,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: kGreenFontColor, width: 1.0),
                borderRadius: BorderRadius.circular(10),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (vlaue) {
              setState(() {
                _input2 = vlaue.length;
              });
            },
            validator: (value) {},
          ),
        ),
      ],
    );
  }

  Widget _nameState() {
    _is03 = _input3 > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KTextWidget(
            text: '대표자 성명',
            size: 16,
            fontWeight: _is03 ? null : FontWeight.bold,
            color: _is03 ? Colors.grey.withOpacity(0.5) : Colors.white),
        KTextWidget(
            text: '기업 또는 단체의 대표자 성명을 입력하세요.',
            size: 14,
            fontWeight: null,
            color: _is03 ? Colors.grey.withOpacity(0.5) : Colors.grey),
        const SizedBox(height: 8),
        Container(
          height: 56,
          child: TextFormField(
            controller: _nameText,
            autocorrect: false,
            maxLength: 30,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            minLines: 1,
            maxLines: 1,
            textAlign: TextAlign.start,
            style: const TextStyle(
              color: null,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterStyle: const TextStyle(fontSize: 0),
              errorStyle:
                  const TextStyle(fontSize: 0, height: 0), // 기본 에러 스타일 완전히 숨기기
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: kRedColor)),
              errorText: null, // 기본 에러 텍스트 비활성화
              filled: true,
              fillColor: btnColor,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 10,
              ),
              hintText: '대표자 성명을 입력하세요.',
              hintStyle: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
                color: Colors.grey,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: kGreenFontColor, width: 1.0),
                borderRadius: BorderRadius.circular(10),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (vlaue) {
              setState(() {
                _input3 = vlaue.length;
              });
            },
            validator: (value) {},
          ),
        ),
      ],
    );
  }

  Widget _step02(AddProvider addProvider) {
    _is04 = _input4 > 0 &&
        (addProvider.companyBusinessPhoto != null || widget.busImg != null);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KTextWidget(
            text: '사업자 등록 번호',
            size: 16,
            fontWeight: _is04 ? null : FontWeight.bold,
            color: _is04 ? Colors.grey.withOpacity(0.5) : Colors.white),
        KTextWidget(
            text: '사업자 번호 및 사업자 등록증 사본을 등록하세요.',
            size: 14,
            fontWeight: null,
            color: _is04 ? Colors.grey.withOpacity(0.5) : Colors.grey),
        const SizedBox(height: 8),
        Container(
          height: 56,
          child: TextFormField(
            controller: _bNumText,
            autocorrect: false,
            maxLength: 30,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            minLines: 1,
            maxLines: 1,
            textAlign: TextAlign.start,
            style: const TextStyle(
              color: null,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterStyle: const TextStyle(fontSize: 0),
              errorStyle:
                  const TextStyle(fontSize: 0, height: 0), // 기본 에러 스타일 완전히 숨기기
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: kRedColor)),
              errorText: null, // 기본 에러 텍스트 비활성화
              filled: true,
              fillColor: btnColor,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 10,
              ),
              hintText: '사업자등록번호를 숫자만 입력하세요.',
              hintStyle: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
                color: Colors.grey,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: kGreenFontColor, width: 1.0),
                borderRadius: BorderRadius.circular(10),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // 숫자만 허용
            ],
            onChanged: (vlaue) {
              setState(() {
                _input4 = vlaue.length;
              });
            },
            validator: (value) {},
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (BuildContext context) {
                return const PickImageBottom(
                  callType: '기업_사업자등록증',
                  comUid: 'null',
                );
              },
            );
          },
          child: Container(
            height: 56,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12), color: msgBackColor),
            child: Center(
                child: addProvider.companyBusinessPhoto == null &&
                        widget.busImg == null
                    ? const Row(
                        children: [
                          KTextWidget(
                              text: '사업자등록증(사본) 등록하기',
                              size: 16,
                              fontWeight: null,
                              color: Colors.grey),
                          Spacer(),
                          Icon(
                            Icons.add,
                            color: Colors.grey,
                          )
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const KTextWidget(
                              text: '사업자등록증 등록 완료!',
                              size: 16,
                              fontWeight: FontWeight.bold,
                              color: kGreenFontColor),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              if (addProvider.companyBusinessPhoto == null) {
                                showDialog(
                                  context: context,
                                  builder: (context) => ImageViewerDialog(
                                    networkUrl: widget.busImg,
                                    callType: '기업등록_사업자등록증',
                                  ),
                                );
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) => ImageViewerDialog(
                                    imageFile:
                                        addProvider.companyBusinessPhoto!,
                                    callType: '기업등록_사업자등록증',
                                  ),
                                );
                              }
                            },
                            child: const KTextWidget(
                                text: '사진 보기',
                                size: 14,
                                fontWeight: null,
                                color: kGreenFontColor),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.check_circle,
                              size: 16, color: kGreenFontColor),
                        ],
                      )),
          ),
        )
      ],
    );
  }

  String? _zone;

  Widget _step03(AddProvider addProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KTextWidget(
            text: '사업장 또는 우편물 주소',
            size: 16,
            fontWeight: _zone == null ? FontWeight.bold : null,
            color: _zone == null ? Colors.white : Colors.grey.withOpacity(0.5)),
        KTextWidget(
            text: '사업장 주소 또는 우편물 취급 주소를 등록하세요.',
            size: 14,
            fontWeight: null,
            color: _zone == null ? Colors.grey : Colors.grey.withOpacity(0.5)),
        const SizedBox(height: 8),
        Container(
          height: 56,
          child: TextFormField(
            controller: _addressText,
            autocorrect: false,
            maxLength: 30,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            minLines: 1,
            maxLines: 1,
            textAlign: TextAlign.start,
            style: const TextStyle(
              color: null,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              suffix: GestureDetector(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  print('222');
                  if (_addressText.text.isEmpty) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(errorSnackBar('검색어가 없습니다.', context));
                  }
                  //소사역   원미로13번길 43
                  addProvider.search(searchData: _addressText.text.trim()).then(
                    (value) {
                      print(_addressText.text);
                      print(value);
                      if (value.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            errorSnackBar(
                                '검색결과가 없습니다.\n검색하실 주소를 확인하세요.', context));
                      } else {
                        showDialog(
                          context: context,
                          barrierDismissible:
                              true, // Enable outside tap to dismiss the dialog
                          builder: (BuildContext context) {
                            return Material(
                              color: Colors.transparent,
                              child: Stack(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      Navigator.of(context)
                                          .pop(); // Close the dialog when the outside area is tapped
                                    },
                                    child: Container(
                                      color: Colors
                                          .transparent, // Make the outside area transparent
                                    ),
                                  ),
                                  Center(
                                    child: GestureDetector(
                                      onTap:
                                          () {}, // Prevent closing the dialog when the dialog itself is tapped
                                      child: Container(
                                          width: 600,
                                          height: 654,
                                          padding: const EdgeInsets.all(16),
                                          margin: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: dialogColor,
                                          ),
                                          child: Address2Dialog(
                                            callType: '사업자',
                                          )),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ).then((value) {
                          if (value != null) {
                            _addressText.text = '${value['address_name']}';
                            _zone = '(${value['zone_no']})';
                            print(_zone);
                            setState(() {});
                          }
                        });
                      }

                      print(addProvider.dataA);
//소사역 원미로 13번길 43
                    },
                  );
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    KTextWidget(
                        text: '검색',
                        size: 16,
                        fontWeight: FontWeight.bold,
                        color: kGreenFontColor)
                  ],
                ),
              ),
              counterStyle: const TextStyle(fontSize: 0),
              errorStyle:
                  const TextStyle(fontSize: 0, height: 0), // 기본 에러 스타일 완전히 숨기기
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: kRedColor)),
              errorText: null, // 기본 에러 텍스트 비활성화
              filled: true,
              fillColor: btnColor,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 10,
              ),
              hintText: '검색하실 주소를 입력하세요.',
              hintStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
                color: Colors.grey,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: kGreenFontColor, width: 1.0),
                borderRadius: BorderRadius.circular(10),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (vlaue) {},
            validator: (value) {},
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          child: TextFormField(
            controller: _addressDisText,
            autocorrect: false,
            maxLength: 30,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            minLines: 1,
            maxLines: 2,
            textAlign: TextAlign.start,
            style: const TextStyle(
              color: null,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterStyle: const TextStyle(fontSize: 0),
              errorStyle:
                  const TextStyle(fontSize: 0, height: 0), // 기본 에러 스타일 완전히 숨기기
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: kRedColor)),
              errorText: null, // 기본 에러 텍스트 비활성화
              filled: true,
              fillColor: btnColor,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 10,
              ),
              hintText: '상세주소를 입력하세요.',
              hintStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
                color: Colors.grey,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: kGreenFontColor, width: 1.0),
                borderRadius: BorderRadius.circular(10),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (vlaue) {},
            validator: (value) {},
          ),
        ),
        const SizedBox(height: 5),
        if (_zone != null)
          KTextWidget(
              text: _zone.toString(),
              size: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white)
      ],
    );
  }

  String? selectedBankName;
  String? selectedBankCode;
  Widget _step04(AddProvider addProvider) {
    _is06 = _input5 > 0 &&
        _input6 > 0 &&
        (addProvider.companyAccountPhoto != null || widget.accImg != null) &&
        selectedBankName != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KTextWidget(
            text: '사업자 계좌 정보',
            size: 16,
            fontWeight: _is06 ? null : FontWeight.bold,
            color: _is06 ? Colors.grey.withOpacity(0.5) : Colors.white),
        KTextWidget(
            text: '운송료 환불을 위해 사업장 계좌정보를 등록하세요.',
            size: 14,
            fontWeight: null,
            color: _is06 ? Colors.grey.withOpacity(0.5) : Colors.grey),
        const SizedBox(height: 8),
        BankDropdownHelper(
          onBankSelected: (bankName, bankCode) {
            setState(() {
              selectedBankName = bankName;
              selectedBankCode = bankCode;
            });
          },
          selectedValue: selectedBankCode,
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          child: TextFormField(
            controller: _aNameText,
            autocorrect: false,
            maxLength: 30,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            minLines: 1,
            maxLines: 2,
            textAlign: TextAlign.start,
            style: const TextStyle(
              color: null,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterStyle: const TextStyle(fontSize: 0),
              errorStyle:
                  const TextStyle(fontSize: 0, height: 0), // 기본 에러 스타일 완전히 숨기기
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: kRedColor)),
              errorText: null, // 기본 에러 텍스트 비활성화
              filled: true,
              fillColor: btnColor,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 10,
              ),
              hintText: '계좌명을 입력하세요.',
              hintStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
                color: Colors.grey,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: kGreenFontColor, width: 1.0),
                borderRadius: BorderRadius.circular(10),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (vlaue) {
              setState(() {
                _input5 = vlaue.length;
              });
            },
            validator: (value) {},
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          child: TextFormField(
            controller: _aNumText,
            autocorrect: false,
            maxLength: 30,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            minLines: 1,
            maxLines: 2,
            textAlign: TextAlign.start,
            style: const TextStyle(
              color: null,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterStyle: const TextStyle(fontSize: 0),
              errorStyle:
                  const TextStyle(fontSize: 0, height: 0), // 기본 에러 스타일 완전히 숨기기
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: kRedColor)),
              errorText: null, // 기본 에러 텍스트 비활성화
              filled: true,
              fillColor: btnColor,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 10,
              ),
              hintText: '계좌번호를 입력하세요.',
              hintStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
                color: Colors.grey,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: kGreenFontColor, width: 1.0),
                borderRadius: BorderRadius.circular(10),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (vlaue) {
              setState(() {
                _input6 = vlaue.length;
              });
            },
            validator: (value) {},
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // 숫자만 허용
            ],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (BuildContext context) {
                return PickImageBottom(
                  callType: '기업_통장사본',
                  comUid: 'null',
                );
              },
            );
          },
          child: Container(
            height: 56,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12), color: msgBackColor),
            child: Center(
                child: addProvider.companyAccountPhoto == null &&
                        widget.accImg == null
                    ? const Row(
                        children: [
                          KTextWidget(
                              text: '계좌사본 등록하기',
                              size: 16,
                              fontWeight: null,
                              color: Colors.grey),
                          Spacer(),
                          Icon(
                            Icons.add,
                            color: Colors.grey,
                          )
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const KTextWidget(
                              text: '계좌사본 등록 완료!',
                              size: 16,
                              fontWeight: FontWeight.bold,
                              color: kGreenFontColor),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              if (addProvider.companyAccountPhoto == null) {
                                showDialog(
                                  context: context,
                                  builder: (context) => ImageViewerDialog(
                                    networkUrl: widget.accImg.toString(),
                                    callType: '기업등록_통장사본',
                                  ),
                                );
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) => ImageViewerDialog(
                                    imageFile: addProvider.companyAccountPhoto!,
                                    callType: '기업등록_통장사본',
                                  ),
                                );
                              }
                            },
                            child: const KTextWidget(
                                text: '사진보기',
                                size: 14,
                                fontWeight: null,
                                color: kGreenFontColor),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.check_circle,
                              size: 16, color: kGreenFontColor),
                        ],
                      )),
          ),
        )
      ],
    );
  }

  Widget _logo(AddProvider addProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KTextWidget(
            text: '기업(단체) 로고 이미지(필요시)',
            size: 16,
            fontWeight: _is06 ? null : FontWeight.bold,
            color: _is06 ? Colors.grey.withOpacity(0.5) : Colors.white),
        KTextWidget(
            text: '기업 또는 단체의 로고 이미지를 등록하세요!',
            size: 14,
            fontWeight: null,
            color: _is06 ? Colors.grey.withOpacity(0.5) : Colors.grey),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (BuildContext context) {
                return PickImageBottom(
                  callType: '기업_로고',
                  comUid: 'null',
                );
              },
            );
          },
          child: Container(
            height: 56,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12), color: msgBackColor),
            child: Center(
                child: addProvider.companyLogoPhoto == null &&
                        widget.logoImg == null
                    ? const Row(
                        children: [
                          KTextWidget(
                              text: '기업(단체)로고 등록하기',
                              size: 16,
                              fontWeight: null,
                              color: Colors.grey),
                          Spacer(),
                          Icon(
                            Icons.add,
                            color: Colors.grey,
                          )
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const KTextWidget(
                              text: '기업(단체)로고 등록 완료!',
                              size: 16,
                              fontWeight: FontWeight.bold,
                              color: kGreenFontColor),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              if (addProvider.companyLogoPhoto == null) {
                                showDialog(
                                  context: context,
                                  builder: (context) => ImageViewerDialog(
                                    networkUrl: widget.logoImg.toString(),
                                    callType: '기업등록_로고',
                                  ),
                                );
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) => ImageViewerDialog(
                                    imageFile: addProvider.companyLogoPhoto,
                                    callType: '기업등록_로고',
                                  ),
                                );
                              }
                            },
                            child: const KTextWidget(
                                text: '사진보기',
                                size: 14,
                                fontWeight: null,
                                color: kGreenFontColor),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.check_circle,
                              size: 16, color: kGreenFontColor),
                        ],
                      )),
          ),
        )
      ],
    );
  }

  List<Map<String, dynamic>> resultList = [];
  Future<List<Map<String, dynamic>>> searchBusinessDocuments({
    required String searchText,
  }) async {
    try {
      // 하나의 쿼리로 name 또는 bNumber가 일치하는 문서 검색
      final query = await FirebaseFirestore.instance
          .collection('normalComInfo')
          .where(Filter.or(
            Filter('name', isEqualTo: searchText),
            Filter('bNumber', isEqualTo: searchText),
          ))
          .get();

      // 검색된 문서들을 리스트로 변환
      for (var doc in query.docs) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        resultList.add(data);
      }

      return resultList;
    } catch (e) {
      print('검색 중 오류 발생: $e');

      return [];
    }
  }

  Future<bool> _addNoramlCom(
      AddProvider addProvider, DataProvider dataProvider) async {
    final hashProvider = Provider.of<HashProvider>(context, listen: false);
    try {
      addProvider.addLoadingState(true);
      // 1. 문서 생성하여 ID 얻기
      final docRef =
          await FirebaseFirestore.instance.collection('normalCom').add({
        'createdAt': Timestamp.now(),
        // 기본 필드들 추가
      });

      // 생성된 문서의 ID 얻기
      final String docId = docRef.id;

      final url1 = await uploadImage(
          addProvider.companyBusinessPhoto as File, 'business', docId);
      final url2 = await uploadImage(
          addProvider.companyAccountPhoto as File, 'account', docId);
      final url3;
      if (addProvider.companyLogoPhoto != null) {
        url3 = await uploadImage(
            addProvider.companyLogoPhoto as File, 'logo', docId);
      } else {
        url3 = null;
      }

      String aNum = hashProvider.encryptData(_aNumText.text.trim());

      // 2. 생성된 문서 업데이트
      await docRef.update({
        'id': docId,
        'busnienssUrl': url1,
        'accountUrl': url2,
        'comName': _comNameText.text.trim(),
        'email': _emailText.text.trim(),
        'ceoName': _nameText.text.trim(),
        'busNum': _bNumText.text.trim(),
        'comAddress1': _addressText.text.trim(),
        'comAddress2': _addressDisText.text.trim(),
        'comZone': _zone,
        'bankName': selectedBankName,
        'accountName': _aNameText.text.trim(),
        'accountNum': aNum,
        'masterUid': dataProvider.userData!.uid,
        'waitList': [],
        'member': FieldValue.arrayUnion([
          dataProvider.userData!.uid,
        ]),
        'logoUrl': url3,
        'state': '미승인'

        // 필요한 추가 필드들 업데이트
      });

      await FirebaseFirestore.instance
          .collection('user_normal')
          .doc(dataProvider.userData!.uid)
          .update({
        'company': FieldValue.arrayUnion([docId.toString()]),
        'masterCompany': FieldValue.arrayUnion([docId.toString()]),
        'comName': _comNameText.text.trim(),
      });

      addProvider.companyBusinessPhotoState(null);

      addProvider.companyLogoPhotoState(null);

      addProvider.companyAccountPhotoState(null);

      addProvider.addLoadingState(false);
      return true;
    } catch (e) {
      addProvider.addLoadingState(false);
      print('기업 등록 중 에러 : $e');
      // 에러 처리 로직 추가
      return false;
    }
  }

  Future<bool> _updateNoramlCom(
      AddProvider addProvider, DataProvider dataProvider, String id) async {
    final hashProvider = Provider.of<HashProvider>(context, listen: false);
    try {
      addProvider.addLoadingState(true);
      // 1. 문서 생성하여 ID 얻기

      // 생성된 문서의 ID 얻기
      final String docId = id;

      final url1;

      if (addProvider.companyBusinessPhoto != null) {
        url1 = await uploadImage(
            addProvider.companyBusinessPhoto as File, 'logo', docId);
      } else {
        url1 = widget.busImg == null ? null : widget.busImg;
      }
      final url2;

      if (addProvider.companyLogoPhoto != null) {
        url2 = await uploadImage(
            addProvider.companyAccountPhoto as File, 'logo', docId);
      } else {
        url2 = widget.accImg == null ? null : widget.accImg;
      }
      final url3;
      if (addProvider.companyLogoPhoto != null) {
        url3 = await uploadImage(
            addProvider.companyLogoPhoto as File, 'logo', docId);
      } else {
        url3 = widget.logoImg == null ? null : widget.logoImg;
      }

      String aNum = hashProvider.encryptData(_aNumText.text.trim());

      FirebaseFirestore.instance.collection('normalCom').doc(id).update({
        'comName': _comNameText.text.trim(),
        'email': _emailText.text.trim(),
        'ceoName': _nameText.text.trim(),
        'busNum': _bNumText.text.trim(),
        'comAddress1': _addressText.text.trim(),
        'comAddress2': _addressDisText.text.trim(),
        'comZone': _zone,
        'bankName': selectedBankName,
        'accountName': _aNameText.text.trim(),
        'accountNum': aNum,
        'masterUid': dataProvider.userData!.uid,
        'busnienssUrl': url1,
        'accountUrl': url2,
        'logoUrl': url3,
      });
      // 2. 생성된 문서 업데이트

      addProvider.companyBusinessPhotoState(null);

      addProvider.companyLogoPhotoState(null);

      addProvider.companyAccountPhotoState(null);

      addProvider.addLoadingState(false);
      return true;
    } catch (e) {
      addProvider.addLoadingState(false);
      print('기업 등록 중 에러 : $e');
      // 에러 처리 로직 추가
      return false;
    }
  }

  Future<String?> uploadImage(
      File imageFile, String filename, String id) async {
    try {
      // Firebase 초기화
      await Firebase.initializeApp();

      DateTime now = DateTime.now();

// Format the date and time as yyyy/mm/dd/hh/mm
      String formattedDate = DateFormat('yyyy-MM-dd-HH-mm').format(now);

      // Storage에 대한 참조 생성

      String uniqueId = '${filename}_${formattedDate}';
      Reference ref = FirebaseStorage.instance
          .ref()
          .child("normalCom/${id}/${uniqueId}.jpg");

      // 이미지 업로드
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      // 업로드된 이미지의 URL 가져오기
      String downloadURL = await snapshot.ref.getDownloadURL();

      return downloadURL;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }
}
