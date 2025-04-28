import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mixcall_normaluser_new/pages/list/history_list/widget/multi.dart';
import 'package:flutter_mixcall_normaluser_new/pages/list/history_list/widget/normal.dart';
import 'package:flutter_mixcall_normaluser_new/pages/list/history_list/widget/return.dart';
import 'package:flutter_mixcall_normaluser_new/pages/list/inuse_list/list_widget/new_multi.dart';
import 'package:flutter_mixcall_normaluser_new/pages/list/inuse_list/list_widget/new_normal.dart';
import 'package:flutter_mixcall_normaluser_new/pages/list/inuse_list/list_widget/new_retrun.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:provider/provider.dart';

class HistoryComList extends StatefulWidget {
  const HistoryComList({super.key});

  @override
  State<HistoryComList> createState() => _HistoryComListState();
}

class _HistoryComListState extends State<HistoryComList> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final int limit = 5;
  List<DocumentSnapshot> documents = [];
  bool isLoading = false;
  bool isSearching = false;
  bool hasMore = true;
  DocumentSnapshot? lastDocument;

  // 검색 관련 변수
  String searchText = '';
  String selectedYear = DateTime.now().year.toString(); // 기본값: 현재 연도
  int? selectedMonth; // 선택된 월 (null이면 전체 월)
  int? selectedDay; // 선택된 일 (null이면 전체 일)

  // 연도, 월, 일 옵션
  List<String> yearOptions = [];
  List<int> monthOptions = List.generate(12, (index) => index + 1); // 1-12월
  List<int> dayOptions = []; // 선택된 월에 따라 동적 생성

  @override
  void initState() {
    super.initState();
    _initializeYearOptions();
    _fetchData();
    _scrollController.addListener(_scrollListener);
  }

  // 연도 옵션 초기화
  void _initializeYearOptions() {
    final currentYear = DateTime.now().year;
    // 2024년부터 현재 연도까지의 옵션 추가
    for (int year = 2024; year <= currentYear; year++) {
      yearOptions.add(year.toString());
    }
    // 최신 연도가 먼저 나오도록 역순 정렬
    yearOptions = yearOptions.reversed.toList();

    // 기본값 설정
    selectedYear = yearOptions.first;

    print('연도 옵션: $yearOptions');
    print('선택된 연도: $selectedYear');
  }

  // 월 선택에 따라 일 옵션 업데이트
  void _updateDayOptions() {
    if (selectedMonth == null) {
      dayOptions = [];
      selectedDay = null;
      return;
    }

    // 각 월의 일수 계산 (2월은 윤년 고려)
    int daysInMonth;
    final year = int.parse(selectedYear);
    bool isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);

    switch (selectedMonth) {
      case 2: // 2월
        daysInMonth = isLeapYear ? 29 : 28;
        break;
      case 4:
      case 6:
      case 9:
      case 11: // 30일인 달
        daysInMonth = 30;
        break;
      default: // 31일인 달
        daysInMonth = 31;
        break;
    }

    dayOptions = List.generate(daysInMonth, (index) => index + 1);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (!isSearching) {
        _fetchData(); // 일반 스크롤 로딩
      } else {
        _fetchSearchResults(loadMore: true); // 검색 결과 추가 로딩
      }
    }
  }

  // 일반 데이터 로드
  Future<void> _fetchData() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    try {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);

      print(
          '데이터 로드 - 연도: $selectedYear, 회사: ${dataProvider.userData!.company[0]}');

      Query query = FirebaseFirestore.instance
          .collection('cargoInfo')
          .doc(dataProvider.userData!.company[0])
          .collection(selectedYear)
          .orderBy('createdDate', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }

      final snapshot = await query.get();
      print('로드된 문서 수: ${snapshot.docs.length}');

      if (snapshot.docs.isEmpty) {
        setState(() {
          hasMore = false;
          isLoading = false;
        });
        return;
      }

      setState(() {
        documents.addAll(snapshot.docs);
        lastDocument = snapshot.docs.last;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // 검색 실행
  void _executeSearch() {
    final searchTerm = _searchController.text.trim();

    setState(() {
      documents.clear();
      lastDocument = null;
      hasMore = true;
      searchText = searchTerm;
      isSearching = true;
    });

    _fetchSearchResults();
  }

  // 검색 취소
  void _cancelSearch() {
    setState(() {
      documents.clear();
      lastDocument = null;
      hasMore = true;
      searchText = '';
      isSearching = false;
      _searchController.clear();
      selectedMonth = null;
      selectedDay = null;
      dayOptions = [];
    });

    _fetchData();
  }

  // 연도 변경 처리
  void _handleYearChange(String newYear) {
    print('연도 변경: $selectedYear -> $newYear');
    setState(() {
      selectedYear = newYear;
      selectedMonth = null;
      selectedDay = null;
      dayOptions = [];
    });

    // 검색 중이었던 경우에만 검색 상태 초기화
    if (isSearching) {
      setState(() {
        isSearching = false;
        searchText = '';
        _searchController.clear();

        // 검색 취소 시 데이터 초기화
        documents.clear();
        lastDocument = null;
        hasMore = true;
      });

      // 기본 데이터 로드
      _fetchData();
    }
  }

  // 월 변경 처리
  void _handleMonthChange(int? newMonth) {
    setState(() {
      selectedMonth = newMonth;
      selectedDay = null; // 월이 변경되면 일 초기화
      _updateDayOptions();
    });
  }

  // 일 변경 처리
  void _handleDayChange(int? newDay) {
    setState(() {
      selectedDay = newDay;
    });
  }

  // 서버 측 검색 결과 가져오기 (날짜 기반 검색 추가)
  Future<void> _fetchSearchResults({bool loadMore = false}) async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    try {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);

      // 검색 접두사 생성 (날짜 기반)
      String prefix = '';
      if (selectedMonth != null) {
        prefix = selectedYear;

        // 월 추가 (01, 02, ... 형식)
        prefix += selectedMonth!.toString().padLeft(2, '0');

        if (selectedDay != null) {
          // 일 추가 (01, 02, ... 형식)
          prefix += selectedDay!.toString().padLeft(2, '0');
        }
      }

      print('검색 실행 - 연도: $selectedYear, 월: $selectedMonth, 일: $selectedDay');
      print('검색어: $searchText, 날짜 접두사: $prefix');

      // 기본 쿼리 설정
      Query query = FirebaseFirestore.instance
          .collection('cargoInfo')
          .doc(dataProvider.userData!.company[0])
          .collection(selectedYear);

      // 기본적으로 최신순 정렬
      query = query.orderBy('createdDate', descending: true);

      // 날짜 접두사가 있는 경우, 클라이언트 측에서 필터링
      final snapshot = await query.limit(50).get(); // 더 많은 데이터 로드

      List<DocumentSnapshot> filteredDocs = snapshot.docs;

      // 날짜 접두사 기반 필터링
      if (prefix.isNotEmpty) {
        filteredDocs = filteredDocs.where((doc) {
          return doc.id.startsWith(prefix);
        }).toList();
      }

      // 검색어가 있는 경우 모든 필드에서 검색
      if (searchText.isNotEmpty) {
        final searchTermLower = searchText.toLowerCase();
        filteredDocs = filteredDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;

          // 검색 대상 필드 목록 (실제 데이터 구조에 맞게 조정)
          final fieldsToSearch = [
            'upAddress', 'downAddress',
            'upName', 'downName',
            'upPhone', 'downPhone',
            'driverName', 'driverPhone',
            'comName', 'comPhone',
            'cargoName', 'cargoDetail',
            'cargoId', 'cargoStat',
            'detail', 'memo'
            // 필요한 경우 추가 필드
          ];

          // 모든 검색 대상 필드에서 검색어 포함 여부 확인
          for (final field in fieldsToSearch) {
            if (data[field] != null) {
              final fieldValue = data[field].toString().toLowerCase();
              if (fieldValue.contains(searchTermLower)) {
                return true; // 하나라도 일치하면 true 반환
              }
            }
          }
          return false; // 어떤 필드도 일치하지 않으면 false
        }).toList();
      }

      print('필터링 후 결과 수: ${filteredDocs.length}');

      if (filteredDocs.isEmpty) {
        setState(() {
          hasMore = false;
          isLoading = false;
        });
        return;
      }

      setState(() {
        if (!loadMore) {
          documents = filteredDocs;
        } else {
          documents.addAll(filteredDocs);
        }

        // 페이지네이션을 위한 마지막 문서 설정
        if (snapshot.docs.isNotEmpty) {
          lastDocument = snapshot.docs.last;
        }
        hasMore = snapshot.docs.length >= 50;
        isLoading = false;
      });
    } catch (e) {
      print('Error executing search: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dw = MediaQuery.of(context).size.width;

    return Column(
      children: [
        // 검색 UI
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // 첫 번째 줄: 연/월/일 선택 드롭다운
              Row(
                children: [
                  // 연도 선택 드롭다운
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: msgBackColor),
                      ),
                      child: yearOptions.isEmpty
                          ? Center(
                              child: Text(
                                '연도 로딩 중...',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color),
                              ),
                            )
                          : DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedYear,
                                isExpanded: true,
                                icon: Icon(Icons.keyboard_arrow_down,
                                    color: Theme.of(context).iconTheme.color),
                                dropdownColor: Theme.of(context).cardColor,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color),
                                hint: Text('연도',
                                    style: TextStyle(
                                        color: Theme.of(context).hintColor)),
                                items: yearOptions.map((String year) {
                                  return DropdownMenuItem<String>(
                                    value: year,
                                    child: Text(year),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  if (newValue != null) {
                                    _handleYearChange(newValue);
                                  }
                                },
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 월 선택 드롭다운
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: msgBackColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          value: selectedMonth,
                          isExpanded: true,
                          icon: Icon(Icons.keyboard_arrow_down,
                              color: Theme.of(context).iconTheme.color),
                          dropdownColor: Theme.of(context).cardColor,
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color),
                          hint: Text('월',
                              style: TextStyle(
                                  color: Theme.of(context).hintColor)),
                          items: [
                            DropdownMenuItem<int?>(
                              value: null,
                              child: Text('전체'),
                            ),
                            ...monthOptions.map((int month) {
                              return DropdownMenuItem<int?>(
                                value: month,
                                child: Text('$month월'),
                              );
                            }).toList(),
                          ],
                          onChanged: _handleMonthChange,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 일 선택 드롭다운 (월이 선택된 경우에만 활성화)
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: msgBackColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          value: selectedDay,
                          isExpanded: true,
                          icon: Icon(Icons.keyboard_arrow_down,
                              color: Theme.of(context).iconTheme.color),
                          dropdownColor: Theme.of(context).cardColor,
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color),
                          hint: Text('일',
                              style: TextStyle(
                                  color: Theme.of(context).hintColor)),
                          items: [
                            if (selectedMonth != null)
                              DropdownMenuItem<int?>(
                                value: null,
                                child: Text('전체'),
                              ),
                            ...dayOptions.map((int day) {
                              return DropdownMenuItem<int?>(
                                value: day,
                                child: Text('$day일'),
                              );
                            }).toList(),
                          ],
                          onChanged:
                              selectedMonth == null ? null : _handleDayChange,
                          disabledHint: Text('월 선택',
                              style: TextStyle(
                                  color: Theme.of(context).disabledColor)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 두 번째 줄: 검색 입력창
              SizedBox(
                width: dw,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: msgBackColor),
                        ),
                        child: Row(
                          children: [
                            // 검색어 입력 텍스트 필드
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color),
                                decoration: InputDecoration(
                                  hintText: '검색어를 입력하세요',
                                  hintStyle: TextStyle(
                                      color: Theme.of(context).hintColor),
                                  prefixIcon: Icon(Icons.search,
                                      color: Theme.of(context).iconTheme.color),
                                  suffixIcon: isSearching
                                      ? IconButton(
                                          icon: Icon(Icons.clear,
                                              color: Theme.of(context)
                                                  .iconTheme
                                                  .color),
                                          onPressed: _cancelSearch,
                                        )
                                      : null,
                                  border: InputBorder.none,
                                  fillColor: msgBackColor,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                ),
                                onSubmitted: (_) => _executeSearch(),
                              ),
                            ),
                            // 검색 버튼 (텍스트필드 내부에 위치)
                            GestureDetector(
                              onTap: _executeSearch,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  '검색',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 검색 결과 또는 빈 데이터 메시지
        isLoading && documents.isEmpty
            ? const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : isSearching && documents.isEmpty && !isLoading
                ? const Expanded(
                    child: Center(
                      child: Text('검색 결과가 없습니다.'),
                    ),
                  )
                : documents.isEmpty && !isLoading
                    ? const Expanded(
                        child: Center(
                          child: Text('데이터가 없습니다.'),
                        ),
                      )
                    : Expanded(
                        child: _buildListView(),
                      ),
      ],
    );
  }

  Widget _buildListView() {
    // 날짜별로 데이터 그룹화
    Map<String, List<DocumentSnapshot>> groupedDocs = {};
    for (var doc in documents) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = data['createdDate'] as Timestamp;
      final date = timestamp.toDate().toString().split(' ')[0];

      if (!groupedDocs.containsKey(date)) {
        groupedDocs[date] = [];
      }
      groupedDocs[date]!.add(doc);
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: groupedDocs.length + 1, // +1 for loading/end message
      itemBuilder: (context, index) {
        if (index == groupedDocs.length) {
          if (isLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (!hasMore) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('마지막 항목입니다', style: TextStyle(color: Colors.grey)),
              ),
            );
          }
          return const SizedBox();
        }

        final date = groupedDocs.keys.elementAt(index);
        final docs = groupedDocs[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              child: Text(
                date,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: null,
                ),
              ),
            ),
            ...docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              switch (data['aloneType']) {
                case '다구간':
                  return Padding(
                    padding: EdgeInsets.all(8),
                    child: NewMultiListCard(data: data),
                  );
                case '왕복':
                  return Padding(
                    padding: EdgeInsets.all(8),
                    child: NewRetrunListCard(data: data),
                  );
                default:
                  return Padding(
                    padding: EdgeInsets.all(8),
                    child: NewNormalListCard(data: data),
                  );
              }
            }).toList(),
          ],
        );
      },
    );
  }
}
