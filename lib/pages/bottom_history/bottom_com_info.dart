import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mixcall_normaluser_new/pages/bottom_history/com_widget/com_info.dart';
import 'package:flutter_mixcall_normaluser_new/pages/bottom_history/driver_widget/photo.dart';
import 'package:flutter_mixcall_normaluser_new/pages/bottom_history/driver_widget/review_new.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';

class BottomComInfoPage extends StatefulWidget {
  final String comUid;
  final bool isReview;
  final Map<String, dynamic> cargo;
  final Map<String, dynamic> userData;
  const BottomComInfoPage(
      {super.key,
      required this.comUid,
      required this.isReview,
      required this.cargo,
      required this.userData});

  @override
  State<BottomComInfoPage> createState() => _BottomComInfoPageState();
}

class _BottomComInfoPageState extends State<BottomComInfoPage> {
  int _currentIndex = 0;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();

    _loadgCount();
  }

  List _photoList = [];
  List _reviewList = [];
  Map<String, dynamic>? _dataList;

  Future _loadgCount() async {
    final DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('cargoComInfo')
        .doc(widget.cargo!['comUid'])
        .collection('upDownHistory')
        .doc('review')
        .get();

    if (snapshot.exists) {
      final reviewList = snapshot.get('reviews');
      // 또는
      // final historyPhoto = (snapshot.data() as Map<String, dynamic>)['historyPhoto'];

      setState(() {
        _reviewList = reviewList;
      });
    }

    final DocumentSnapshot snapshot2 = await FirebaseFirestore.instance
        .collection('cargoComInfo')
        .doc(widget.cargo!['comUid'])
        .collection('upDownHistory')
        .doc('photo')
        .get();

    if (snapshot2.exists) {
      final historyPhoto = snapshot2.get('historyPhoto');
      // 또는
      // final historyPhoto = (snapshot.data() as Map<String, dynamic>)['historyPhoto'];

      setState(() {
        _photoList = historyPhoto;
      });
    }

    try {
      final DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('cargoComInfo')
          .doc(widget.comUid)
          .get();

      if (snapshot.exists) {
        // 문서가 존재하는 경우 데이터 처리
        Map<String, dynamic> documentData =
            snapshot.data() as Map<String, dynamic>;

        // 기존 리스트 초기화
        _dataList = null;

        // 데이터를 리스트에 추가
        _dataList = documentData;

        // 상태 업데이트 (필요한 경우)
        setState(() {
          // 여기서 다른 상태 변수 업데이트 가능
        });

        //print('데이터가 성공적으로 리스트에 추가되었습니다. 리스트 크기: ${_dataList.length}');
      } else {
        print('문서가 존재하지 않습니다.');
      }
    } catch (e) {
      print('데이터 가져오기 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dh = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          color: msgBackColor,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 68,
                    height: 5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: kGreenFontColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: dh * 0.80,
                child: ContainedTabBarView(
                  initialIndex: 0,
                  onChange: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  tabs: [
                    const Text('주선사 정보', style: TextStyle(fontSize: 15)),
                    Text('상, 하차 사진(${_photoList.length})',
                        style: TextStyle(fontSize: 15)),
                    Text('운송 후기(${_reviewList.length})',
                        style: TextStyle(fontSize: 15)),
                  ],
                  tabBarProperties: TabBarProperties(
                    height: 50.0,
                    indicatorColor: Colors.transparent,
                    background: Container(
                      color: msgBackColor,
                    ),
                    indicatorWeight: 6.0,
                    labelColor: kGreenFontColor,
                    unselectedLabelColor: Colors.grey,
                    unselectedLabelStyle: const TextStyle(fontWeight: null),
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kGreenFontColor,
                    ),
                  ),
                  views: [
                    if (_dataList == null)
                      Container()
                    else
                      ComInfoBottom(
                        cargoData: widget.cargo,
                        comInfo: _dataList!,
                      ),
                    BottomPhoto(
                      photo: _photoList,
                      userData: widget.userData,
                      callType: '주선사',
                    ),
                    BottomInfoNewReview(
                        userData: widget.userData,
                        isReview: widget.isReview,
                        cargo: widget.cargo,
                        review: _reviewList,
                        callType: '주선사',
                        photo: _photoList)
                    /*   BottomDriverInfo(userData: userData!),
                    BottomPhoto(photo: _photoList, userData: userData),
                    BottomReview(
                      userData: userData,
                      isReview: widget.isReview,
                      cargo: widget.isReview == true ? widget.cargo : null,
                      photo: _photoList,
                    ) */
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
