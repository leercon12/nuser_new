import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mixcall_normaluser_new/pages/list/history_list/list_state/com_list.dart';
import 'package:flutter_mixcall_normaluser_new/pages/list/history_list/list_state/my_list.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/loading_page.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:provider/provider.dart';

class HistoryListMain extends StatefulWidget {
  const HistoryListMain({super.key});

  @override
  State<HistoryListMain> createState() => _HistoryListMainState();
}

class _HistoryListMainState extends State<HistoryListMain> {
// 클래스 멤버 변수
  num personalCargoCount = 0;
  num companyCargoCount = 0;

  @override
  void initState() {
    super.initState();
    // initState에서 카운트 메서드 호출
    _fetchCargoCounts();
  }

// 화물 수 집계를 위한 메서드
  Future<void> _fetchCargoCounts() async {
    try {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);

      // 조회할 연도 목록 (예: 2024년부터 현재 연도까지)
      final int currentYear = DateTime.now().year;
      final List<String> years = [];

      // 시작 연도부터 현재 연도까지의 모든 연도 추가
      // 앱의 운영 시작 연도를 기준으로 설정 (예: 2024부터 시작)
      final int startYear = 2024;
      for (int year = startYear; year <= currentYear; year++) {
        years.add(year.toString());
      }

      // 개인 화물 수 집계 (모든 연도)
      num totalPersonalCount = 0;
      for (String year in years) {
        final personalCountQuery = await FirebaseFirestore.instance
            .collection('cargoInfo')
            .doc(dataProvider.uid)
            .collection(year)
            .count()
            .get();

        totalPersonalCount += personalCountQuery.count ?? 0;
      }

      // 회사 화물 수 집계 (회사 ID가 있을 경우, 모든 연도)
      num totalCompanyCount = 0;
      if (dataProvider.company != null && dataProvider.company.isNotEmpty) {
        for (String year in years) {
          final companyCountQuery = await FirebaseFirestore.instance
              .collection('cargoInfo')
              .doc(dataProvider.company[0])
              .collection(year)
              .count()
              .get();

          totalCompanyCount += companyCountQuery.count ?? 0;
        }
      }

      // 상태 업데이트 (UI 갱신을 위해)
      setState(() {
        personalCargoCount = totalPersonalCount;
        companyCargoCount = totalCompanyCount;
      });

      print('개인 화물 수: $personalCargoCount, 회사 화물 수: $companyCargoCount');
    } catch (e) {
      print('화물 수 집계 중 오류 발생: $e');
    }
  }

// 특정 컬렉션이 존재하는지 확인하는 헬퍼 메서드 (선택적)
  Future<bool> _collectionExists(
      DocumentReference docRef, String collectionPath) async {
    try {
      final collection = docRef.collection(collectionPath);
      final query = await collection.limit(1).get();
      return query.docs.isNotEmpty;
    } catch (e) {
      print('컬렉션 확인 중 오류: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              '지난 운송 내역',
              style: const TextStyle(fontSize: 20),
            ),
          ),
          body: ContainedTabBarView(
            initialIndex: 0,
            tabs: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '나의 화물',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    ' ${personalCargoCount}',
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey.withOpacity(0.5)),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '소속 기업 화물',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    ' ${companyCargoCount}',
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey.withOpacity(0.5)),
                  ),
                ],
              ),
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
                    fontWeight: FontWeight.bold, color: kGreenFontColor)
                //unselectedLabelColor: Colors.grey[400],
                ),
            views: const [
              HistoryMyList(),
              HistoryComList(),
            ],
          ),
        ),
        if (dataProvider.isLoading == true) const LoadingPage()
      ],
    );
  }
}
