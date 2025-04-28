import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class PointMainPage extends StatefulWidget {
  const PointMainPage({super.key});

  @override
  State<PointMainPage> createState() => _PointMainPageState();
}

class _PointMainPageState extends State<PointMainPage> {
  final ScrollController _scrollController = ScrollController();
  final int _pageSize = 20;
  List<DocumentSnapshot> _documents = [];
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoading = false;
  StreamSubscription<QuerySnapshot>? _streamSubscription;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialData2();
    if (mounted) {
      _loadInitialData();
      _setupRealtimeUpdates();
    }
  }

  bool _initialLoading = true;
  Future<void> _loadInitialData2() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _initialLoading = false;
      });
    }
  }

  Future<void> _loadInitialData() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final querySnapshot = await _getQuery().limit(_pageSize).get();
      setState(() {
        _documents = querySnapshot.docs;
        _lastDocument = _documents.isNotEmpty ? _documents.last : null;
        _hasMore = querySnapshot.docs.length == _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading initial data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _setupRealtimeUpdates() {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final latestDocument = _documents.isNotEmpty ? _documents.first : null;

    _streamSubscription = _getQuery().limit(1).snapshots().listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final newDoc = snapshot.docs.first;
        if (latestDocument == null ||
            newDoc.get('fixDate').compareTo(latestDocument.get('fixDate')) >
                0) {
          setState(() {
            _documents.insert(0, newDoc);
          });
        }
      }
    });
  }

  Query _getQuery() {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    return FirebaseFirestore.instance
        .collection('cargo_px')
        .doc('user_normal')
        .collection(dataProvider.userData!.uid)
        .doc('main_px')
        .collection('history')
        .orderBy('fixDate', descending: true);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading &&
        _hasMore &&
        mounted) {
      _loadMoreData();
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    try {
      final querySnapshot = await _getQuery()
          .startAfterDocument(_lastDocument!)
          .limit(_pageSize)
          .get();

      setState(() {
        _documents.addAll(querySnapshot.docs);
        _lastDocument = querySnapshot.docs.isNotEmpty
            ? querySnapshot.docs.last
            : _lastDocument;
        _hasMore = querySnapshot.docs.length == _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading more data: $e');
      setState(() => _isLoading = false);
    }
  }

  DateTime? dateTime;

  Future<void> _isPre() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    if (dataProvider.userData!.preDday != null) {
      String dateString =
          extractDate(dataProvider.userData!.preDday.toString());
      DateTime preDateTime = parseDateString(dateString);

      // 현재 날짜와 preDday의 차이를 계산
      Duration difference = DateTime.now().difference(preDateTime);

      // 6일 이상 지났는지 확인
      if (difference.inDays >= 6) {
        await _updateFirestore(dataProvider.userData!.uid);
      }
    }
  }

  Future<void> _updateFirestore(String uid) async {
    try {
      await FirebaseFirestore.instance
          .collection('user_normal')
          .doc(uid)
          .update({
        'preAcNum': null,
        'preBank': null,
        'preDday': null,
        'preOnewr': null,
        'preOrderId': null,
        'prePrice': null
      });
      print('Firestore updated successfully');
    } catch (e) {
      print('Error updating Firestore: $e');
      // 여기에 에러 처리 로직을 추가할 수 있습니다.
    }
  }

// 이전에 정의한 함수들
  String extractDate(String dateTimeString) {
    return dateTimeString.substring(0, 10);
  }

  DateTime parseDateString(String dateString) {
    return DateTime.parse(dateString);
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '포인트 내역',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _newTop(dataProvider),
          ],
        ),
      )),
    );
  }

  Widget _newTop(DataProvider dataProvider) {
    return Container(
      padding: const EdgeInsets.all(13),
      // height: 173,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: msgBackColor,
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              KTextWidget(
                  text: '보유 포인트',
                  size: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Expanded(child: SizedBox()),
              KTextWidget(
                  text: formatCurrency(dataProvider.pxNum as int) + 'P',
                  size: 28,
                  fontWeight: FontWeight.bold,
                  color: null),
              /*  const SizedBox(width: 5),
              const KTextWidget(
                  text: '포인트', size: 14, fontWeight: null, color: Colors.grey), */
            ],
          ),
          Divider(
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    /* HapticFeedback.lightImpact();

                    if (authProvider.userDriver!.isExport == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          errorSnackBar('현재 출금 신청중입니다.', context));
                    } else {
                      /*  showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (BuildContext context) {
                          return const ExportPointPage();
                        }, */
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: dialogColor,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(30)),
                        ),
                        builder: (BuildContext context) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: const ExportPointPage(),
                          );
                        },
                      ).then((value) async {
                        if (value != null && value['confirmed'] == true) {
                          int exportAmount = value['amount'];
                          print(exportAmount);
                          if (exportAmount > 0) {
                            mapProvider.isLoadingState(true);
                            String mngNum = await _taxMagNum(authProvider);

                            final exportRequest = ExportRequest();
                            bool success =
                                await ExportRequest()
                                    .callExportFunction(
                                        userUid: authProvider.userDriver!.uid
                                            .toString(),
                                        exportMoney: hashProvider.encryptData(
                                            exportAmount.toString()),
                                        bankName: authProvider
                                            .userDriver!.bankName
                                            .toString(),
                                        acName: authProvider
                                            .userDriver!.acountName
                                            .toString(),
                                        anNum: authProvider
                                            .userDriver!.acountNum
                                            .toString(),
                                        userType: 'driver');

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  currentSnackBar('출금요청이 완료되었습니다.', context));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  errorSnackBar(
                                      '출금 요청이 실패했습니다. 다시 시도하세요.', context));
                            }
                            /*  num? a = exportAmount - 250;
                            DocumentReference ourcomDocRef =
                                FirebaseFirestore.instanceFor(
                                        app: FirebaseFirestore.instance.app,
                                        databaseId: 'ourcom')
                                    .collection('export')
                                    .doc(yyyymmdd + userUid);

                            ourcomDocRef.set({
                              'userType': 'driver',
                              'userUid': authProvider.userDriver!.uid,
                              'reqDate': DateTime.now(),
                              'isComplete': false,
                              'tid': null,
                              'comDate': null,
                              'exportPoint': hashProvider.encryptData(
                                  exportAmount.toString()), // 여기에 출금 금액을 저장
                              'exportMoney':
                                  hashProvider.encryptData(a.toString()),
                              'susu': 250,
                              'bankName': null,
                              'acName': null,
                              'anNum': null,
                            });

                            await FirebaseFirestore.instance
                                .collection('user_driver')
                                .doc(authProvider.userDriver!.uid)
                                .update({
                              'exportDate': DateTime.now(),
                              'isExport': true,
                              'exportId': ourcomDocRef.id,
                              'exportMoney':
                                  hashProvider.encryptData(a.toString()),
                                  'bankInfo' : 
                            }); */
                            mapProvider.isLoadingState(false);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                errorSnackBar('출금 금액이 0원입니다.', context));
                          }
                        }
                      });
                    } */
                  },
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: noState),
                    child: const Center(
                      child: KTextWidget(
                          text: '출금',
                          size: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    /*  HapticFeedback.lightImpact();

                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return const ChargeBottonSheet();
                      },
                    ).then((value) {
                      if (value != null && value is Map<String, dynamic>) {
                        // int chargeMoney = value['amount'] as int;
                        String paymentType = value['type'] as String;
                        int chargeMoney = 500;
                        if (paymentType == 'card') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NicePaymentPage(
                                amount: chargeMoney,
                                type: paymentType,
                                userUid:
                                    authProvider.userDriver!.uid.toString(),
                                // userUid: authProvider.userDriver!.uid.toString(),
                              ),
                            ),
                          );
                        } else if (paymentType == 'vbank') {
                          if (dateTime != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                errorSnackBar('이미 배정받은 가상계좌가 있습니다.', context));
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NicePaymentVbankPage(
                                  amount: chargeMoney,

                                  userUid:
                                      authProvider.userDriver!.uid.toString(),
                                  // userUid: authProvider.userDriver!.uid.toString(),
                                ),
                              ),
                            );
                          }
                        } else if (paymentType == 'bank') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NicePaymentBankPage(
                                amount: chargeMoney,

                                userUid:
                                    authProvider.userDriver!.uid.toString(),
                                // userUid: authProvider.userDriver!.uid.toString(),
                              ),
                            ),
                          );
                        }
                      }
                    }); */
                  },
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: kBlueBssetColor),
                    child: const Center(
                      child: KTextWidget(
                          text: '충전',
                          size: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
