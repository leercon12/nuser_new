import 'dart:convert';

import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/list/history_list/history.dart';

import 'package:flutter_mixcall_normaluser_new/pages/mainMenu/agree_term.dart';
import 'package:flutter_mixcall_normaluser_new/pages/mainMenu/bottom/main_bottom.dart';
import 'package:flutter_mixcall_normaluser_new/pages/mainMenu/company/comapny_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/mainMenu/myinfo/my_info.dart';
import 'package:flutter_mixcall_normaluser_new/pages/mainMenu/notificaton/notification.dart';

import 'package:flutter_mixcall_normaluser_new/pages/mainMenu/point/point_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/new_add_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/splash.dart';

import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/hashProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/service/ar_service/ar_main.dart';
import 'package:flutter_mixcall_normaluser_new/service/future_service.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/loading_page.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';

import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  int _msg = 0;
  int _my = 0;

  Future<void> _initializeData() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    try {
      // userProvider 완료 대기
      dataProvider.userProvider();

      // uid가 있는지 확인
      if (dataProvider.uid.isNotEmpty) {
        // 병렬로 두 카운트 실행
        await Future.wait([
          _msgCount(dataProvider),
          _myCount(dataProvider),
        ]);
      } else {
        print('User ID is not available');
      }
    } catch (e) {
      print('Error in initialization: $e');
    }
  }

  Future<void> _msgCount(DataProvider dataProvider) async {
    try {
      print('Fetching msg count for uid: ${dataProvider.uid}'); // 디버깅용
      final AggregateQuerySnapshot query = await FirebaseFirestore.instance
          .collection('msg')
          .doc('user')
          .collection(dataProvider.uid)
          .count()
          .get();

      setState(() {
        _msg = query.count!;
      });
    } catch (e) {
      print('Error getting msg count: $e');
    }
  }

  Future<void> _myCount(DataProvider dataProvider) async {
    try {
      print('Fetching cargo count for uid: ${dataProvider.uid}'); // 디버깅용
      final AggregateQuerySnapshot query = await FirebaseFirestore.instance
          .collection('cargoInfo')
          .doc(dataProvider.uid)
          .collection(DateTime.now().year.toString())
          .count()
          .get();

      setState(() {
        _my = query.count!;
      });
    } catch (e) {
      print('Error getting cargo count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text(
              '메인 메뉴',
              style: TextStyle(fontSize: 20),
            ),
          ),
          body: SafeArea(
              child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //  const SizedBox(height: 14),
                  const KTextWidget(
                      text: '나의 정보',
                      size: 18,
                      fontWeight: FontWeight.bold,
                      color: null),
                  const KTextWidget(
                      text: '나의 정보 또는 화물 운송 정보를 확인할 수 있어요.',
                      size: 12,
                      fontWeight: null,
                      color: Colors.grey),
                  const SizedBox(height: 24),
                  _myInfo(),
                  const SizedBox(height: 24),
                  _company(),
                  const SizedBox(height: 24),
                  _noti(),
                  const SizedBox(height: 24),
                  _point(),
                  const SizedBox(height: 24),
                  _cargoRec(),

                  const SizedBox(height: 24),
                  const Divider(height: 1, color: noState),
                  const SizedBox(height: 24),
                  const KTextWidget(
                      text: '신규 운송 등록',
                      size: 18,
                      fontWeight: FontWeight.bold,
                      color: null),
                  const KTextWidget(
                      text: '새로운 운송을 등록하고 운송료를 제안받으세요!.',
                      size: 12,
                      fontWeight: null,
                      color: Colors.grey),
                  const SizedBox(height: 24),
                  _addCargo(),
                  const SizedBox(height: 24),
                  _arWe(),
                  const SizedBox(height: 24),
                  const Divider(height: 1, color: noState),
                  const SizedBox(height: 24),
                  const KTextWidget(
                      text: '기타 메뉴',
                      size: 18,
                      fontWeight: FontWeight.bold,
                      color: null),
                  const KTextWidget(
                      text: '원하시는 메뉴를 선택하세요.',
                      size: 12,
                      fontWeight: null,
                      color: Colors.grey),
                  const SizedBox(height: 24),
                  _contactUs(),
                  const SizedBox(height: 24),
                  _set1(),
                  const SizedBox(height: 24),
                  _lic1(),
                  const SizedBox(height: 24),
                  _agree(),
                  const SizedBox(height: 24),
                  _logOut(),
                  const SizedBox(height: 24),
                  _outTeam(),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          )),
        ),
        if (mapProvider.isLoading == true) LoadingPage()
      ],
    );
  }

  Widget _myInfo() {
    return InkWell(
      onTap: () async {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyInfoPage()),
        );
      },
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100), color: noState),
            child: Image.asset(
              'asset/img/ic_my.png',
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(width: 12),
          const KTextWidget(
              text: '나의 정보', size: 16, fontWeight: null, color: null),
          const Expanded(child: SizedBox()),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.grey,
          ),
          //const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _company() {
    final dataProvider = Provider.of<DataProvider>(context);
    return InkWell(
      onTap: () async {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ComapnyMainPage()),
        );
      },
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: noState,
            ),
            child: Padding(
              padding: const EdgeInsets.all(4), // 적절한 패딩값 조정
              child: Image.asset('asset/img/company.png'),
            ),
          ),
          const SizedBox(width: 12),
          const KTextWidget(
              text: '소속 기업(단체) 설정', size: 16, fontWeight: null, color: null),
          const Expanded(child: SizedBox()),
          if (dataProvider.userData != null)
            KTextWidget(
                text: dataProvider.userData!.company.isEmpty &&
                        dataProvider.userData!.masterCompany.isEmpty
                    ? '소속 없음'
                    : '소속 있음',
                size: 14,
                fontWeight: FontWeight.bold,
                color: dataProvider.userData!.company.isEmpty &&
                        dataProvider.userData!.masterCompany.isEmpty
                    ? Colors.grey.withOpacity(0.5)
                    : kGreenFontColor),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.grey,
          ),
          //const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _noti() {
    return InkWell(
      onTap: () async {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotificationMainPage()),
        );
      },
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100), color: noState),
            child: Image.asset(
              'asset/img/ic_notification.png',
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(width: 12),
          const KTextWidget(
              text: '메세지 / 공지사항', size: 16, fontWeight: null, color: null),
          const Expanded(child: SizedBox()),
          KTextWidget(
              text: _msg.toString(), //'${hiveBox.length}',
              size: 15,
              fontWeight: FontWeight.bold,
              color: kGreenFontColor),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.grey,
          ),
          //const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _point() {
    final dataProvider = Provider.of<DataProvider>(context);
    return InkWell(
      onTap: () async {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PointMainPage()),
        );
      },
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100), color: noState),
            child: Image.asset(
              'asset/img/ic_coin.png',
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(width: 12),
          const KTextWidget(
              text: '나의 포인트', size: 16, fontWeight: null, color: null),
          const Expanded(child: SizedBox()),
          KTextWidget(
              text: formatCurrency(dataProvider
                  .pxNum), //'${formatCurrency2(pointProvider.pxNum as int)}',
              size: 15,
              fontWeight: FontWeight.bold,
              color: kGreenFontColor),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.grey,
          ),
          //const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _cargoRec() {
    return InkWell(
      onTap: () async {
        HapticFeedback.lightImpact();
        //addProvider.addReset();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HistoryListMain()),
        );
      },
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100), color: noState),
            child: Image.asset(
              'asset/img/ic_delivery.png',
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(width: 12),
          const KTextWidget(
              text: '전체 운송 내역', size: 16, fontWeight: null, color: null),
          const Expanded(child: SizedBox()),
          KTextWidget(
              text: _my.toString(),
              size: 15,
              fontWeight: FontWeight.bold,
              color: kGreenFontColor),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.grey,
          ),
          //const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _cargoSend() {
    return InkWell(
      onTap: () async {
        HapticFeedback.lightImpact();
        /*  Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const DriverAddCargoListMain()),
        ); */
      },
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100), color: noState),
            child: Image.asset(
              'asset/img/ic_list.png',
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(width: 12),
          const KTextWidget(
              text: '운송 등록 내역', size: 16, fontWeight: null, color: null),
          const Expanded(child: SizedBox()),
          KTextWidget(
              text: '00', //'$_my2',
              size: 15,
              fontWeight: FontWeight.bold,
              color: kGreenFontColor),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.grey,
          ),
          //const SizedBox(width: 12),
        ],
      ),
    );
  }

  /////////////
  ///
  ///

  Widget _addCargo() {
    //final authProvider = Provider.of<AuthProvider>(context);
    return InkWell(
      onTap: () async {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const NewAddMainPage(
                    callType: '',
                  )),
        );
      },
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100), color: noState),
            child: Image.asset(
              'asset/img/ic_add.png',
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(width: 12),
          const KTextWidget(
              text: '화물 운송 등록하기', size: 16, fontWeight: null, color: null),
          const Expanded(child: SizedBox()),

          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.grey,
          ),
          //const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _arWe() {
    return InkWell(
      onTap: () async {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ARServiceMainPage()),
        );
      },
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100), color: noState),
            child: Image.asset(
              'asset/img/ar1.png',
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(width: 12),
          const KTextWidget(
              text: 'AR 화물 사이즈 측정', size: 16, fontWeight: null, color: null),
          const Expanded(child: SizedBox()),

          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.grey,
          ),
          //const SizedBox(width: 12),
        ],
      ),
    );
  }

  /////////////
  ///
  ///

  Widget _contactUs() {
    return InkWell(
      onTap: () async {
        HapticFeedback.lightImpact();
        makePhoneCall('0322271107');
      },
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100), color: noState),
            child: Image.asset(
              'asset/img/ic_customer.png',
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(width: 12),
          const KTextWidget(
              text: '고객센터 문의', size: 16, fontWeight: null, color: null),
          const Expanded(child: SizedBox()),

          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.grey,
          ),
          //const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _set1() {
    return InkWell(
      onTap: () async {
        HapticFeedback.lightImpact();
        AppSettings.openAppSettings();
      },
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100), color: noState),
            child: Image.asset(
              'asset/img/settings.png',
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(width: 12),
          const KTextWidget(
              text: '알람&위치권한 설정', size: 16, fontWeight: null, color: null),
          const Expanded(child: SizedBox()),

          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.grey,
          ),
          //const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _gforce() {
    return InkWell(
      onTap: () async {
        HapticFeedback.lightImpact();
        /* Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GForcePage()),
        ); */
      },
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100), color: noState),
            child: Image.asset(
              'asset/img/gforce.png',
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(width: 12),
          const KTextWidget(
              text: '운전 보조(중력계)', size: 16, fontWeight: null, color: null),
          const Expanded(child: SizedBox()),

          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.grey,
          ),
          //const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _lic1() {
    return InkWell(
      onTap: () async {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LicensePage()),
        );
      },
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100), color: noState),
            child: Image.asset(
              'asset/img/certificate.png',
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(width: 12),
          const KTextWidget(
              text: '라이센스', size: 16, fontWeight: null, color: null),
          const Expanded(child: SizedBox()),

          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.grey,
          ),
          //const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _agree() {
    return InkWell(
      onTap: () async {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AgreeMainPage()),
        );
      },
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100), color: noState),
            child: Image.asset(
              'asset/img/ic_terms.png',
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(width: 12),
          const KTextWidget(
              text: '약관보기', size: 16, fontWeight: null, color: null),
          const Expanded(child: SizedBox()),

          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.grey,
          ),
          //const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _logOut() {
    // final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context);
    return InkWell(
      onTap: () async {
        try {
          HapticFeedback.lightImpact();

          // Sign out from Firebase
          await FirebaseAuth.instance.signOut();

          // Clear local user data
          dataProvider.disposeUserData();

          // Navigate to splash screen
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const SplashPage()),
              (route) => false,
            );
          }
        } catch (e) {
          print('Error during sign out: $e');
          // Handle sign-out errors (e.g., show an error message to the user)
        }
      },
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100), color: noState),
            child: Image.asset(
              'asset/img/ic_logout.png',
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(width: 12),
          const KTextWidget(
              text: '로그 아웃', size: 16, fontWeight: null, color: null),
          const Expanded(child: SizedBox()),

          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.grey,
          ),
          //const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _outTeam() {
    final mapProvider = Provider.of<MapProvider>(context);
    // final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    return InkWell(
      onTap: () async {
        HapticFeedback.lightImpact();
        // 이거 탈퇴 법칙 필요하네.
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return const OutTmeBottomSheet();
          },
        ).then((value) async {
          if (value == 'exit') {
            mapProvider.isLoadingState(true);

            final result = await deleteAccount(
                dataProvider.userData!.phone.toString() + '@mixcallnuser.com',
                'normal');

            if (result == true) {
              await FirebaseAuth.instance.signOut();
              dataProvider.disposeUserData();
              mapProvider.isLoadingState(false);

              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SplashPage()),
                  (route) => false);
            } else {
              mapProvider.isLoadingState(false);

              ScaffoldMessenger.of(context).showSnackBar(
                  errorSnackBar('탈퇴에 실패하였습니다.\n잠시 후 다시 시도하세요.', context));
            }
          }
        });
      },
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100), color: noState),
            child: Image.asset(
              'asset/img/ic_exit.png',
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(width: 12),
          const KTextWidget(
              text: '회원 탈퇴', size: 16, fontWeight: null, color: null),
          const Expanded(child: SizedBox()),

          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.grey,
          ),
          //const SizedBox(width: 12),
        ],
      ),
    );
  }

  Future<bool> deleteAccount(String email, String userType) async {
    final url =
        'https://us-central1-mixcall.cloudfunctions.net/delete_account'; // 실제 함수 URL로 변경 필요

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'userType': userType, // 'normal' 또는 'driver'
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['success'];
      } else {
        print('Failed to delete account. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error deleting account: $e');
      return false;
    }
  }
}


/* 
      String maskedPh = ph.length > 4
          ? ph.substring(0, ph.length - 4) + "****"
          : "*" * ph.length;

      String maskedCar = car.length > 2
          ? car.substring(0, car.length - 2) + "**"
          : "*" * car.length;

      String maskedName = name.length > 1
          ? name.substring(0, name.length - 1) + "*"
          : "*" * name.length; */