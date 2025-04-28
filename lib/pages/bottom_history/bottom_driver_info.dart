import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mixcall_normaluser_new/pages/bottom_history/driver_widget/info.dart';
import 'package:flutter_mixcall_normaluser_new/pages/bottom_history/driver_widget/photo.dart';
import 'package:flutter_mixcall_normaluser_new/pages/bottom_history/driver_widget/review.dart';
import 'package:flutter_mixcall_normaluser_new/pages/bottom_history/driver_widget/review_new.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/bottomSheet.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';

class BottomDriverInfoPage extends StatefulWidget {
  final String pickUserUid;
  final bool isReview;
  final Map<String, dynamic>? cargo;

  const BottomDriverInfoPage(
      {super.key,
      required this.pickUserUid,
      required this.isReview,
      required this.cargo});

  @override
  State<BottomDriverInfoPage> createState() => _BottomDriverInfoPageState();
}

class _BottomDriverInfoPageState extends State<BottomDriverInfoPage> {
  int _currentIndex = 0;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadgCount();
  }

  Future<void> _loadUserData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('user_driver')
          .doc(widget.pickUserUid)
          .get();

      if (!snapshot.exists) {
        setState(() {
          error = '데이터를 찾을 수 없습니다';
          isLoading = false;
        });
        return;
      }

      setState(() {
        userData = snapshot.data() as Map<String, dynamic>;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = '오류가 발생했습니다: $e';
        isLoading = false;
      });
    }
  }

  List _photoList = [];
  List _reviewList = [];

  Future _loadgCount() async {
    final DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('user_driver')
        .doc(widget.pickUserUid)
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
        .collection('user_driver')
        .doc(widget.pickUserUid)
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
  }

  @override
  Widget build(BuildContext context) {
    final dh = MediaQuery.of(context).size.height;

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      return Center(
        child: Text(error!),
      );
    }

    if (userData == null) {
      return const Center(
        child: Text('데이터를 찾을 수 없습니다'),
      );
    }

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
                    const Text('기사님 정보', style: TextStyle(fontSize: 15)),
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
                    BottomDriverInfo(userData: userData!),
                    BottomPhoto(
                      photo: _photoList,
                      userData: userData,
                      callType: '기사',
                    ),
                    BottomInfoNewReview(
                        userData: userData!,
                        isReview: widget.isReview,
                        cargo: widget.cargo!,
                        review: _reviewList,
                        photo: _photoList,
                        callType: '기사')
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
