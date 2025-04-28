import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mixcall_normaluser_new/pages/mainMenu/notificaton/msg_type/msg.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class MsgMainPage extends StatefulWidget {
  final Box messageBox;

  const MsgMainPage({
    super.key,
    required this.messageBox,
  });

  @override
  State<MsgMainPage> createState() => _MsgMainPageState();
}

class _MsgMainPageState extends State<MsgMainPage> {
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> messages = [];
  bool isLoading = false;
  bool hasMore = true;
  final int limit = 6;
  DocumentSnapshot? lastDocument;
  StreamSubscription<QuerySnapshot>? _subscription;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _scrollController.addListener(_onScroll);
    _setupMessageStream();
  }

  void _setupMessageStream() {
    if (!mounted) return;
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final stream = FirebaseFirestore.instance
        .collection('msg')
        .doc('user')
        .collection(dataProvider.userData!.uid)
        .orderBy('date', descending: true)
        .limit(1)
        .snapshots();

    _subscription = stream.listen((snapshot) {
      if (snapshot.docs.isNotEmpty && mounted) {
        _checkForNewMessages(snapshot.docs.first);
      }
    });
  }

  Future<void> _initializeData() async {
    if (!mounted) return;
    final cachedMessages = widget.messageBox.get('cached_messages');
    if (cachedMessages != null) {
      setState(() {
        messages = (cachedMessages as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      });
    }
    await _fetchMessages();
  }

  Future<void> _checkForNewMessages(DocumentSnapshot latestMessage) async {
    if (!mounted || messages.isEmpty) return;

    final latestServerDate = latestMessage.get('date') as Timestamp;
    final latestLocalDate = messages.first['date'] as Timestamp;

    if (latestServerDate.compareTo(latestLocalDate) > 0) {
      setState(() {
        messages.clear();
        lastDocument = null;
        hasMore = true;
      });
      await _fetchMessages();
    }
  }

  Future<void> _fetchMessages() async {
    if (!mounted || isLoading || !hasMore) return;
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    setState(() {
      isLoading = true;
    });

    try {
      Query query = FirebaseFirestore.instance
          .collection('msg')
          .doc('user')
          .collection(dataProvider.userData!.uid)
          .orderBy('date', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }

      final querySnapshot = await query.get();

      if (querySnapshot.docs.length < limit) {
        hasMore = false;
      }

      if (querySnapshot.docs.isNotEmpty) {
        lastDocument = querySnapshot.docs.last;

        final newMessages = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();

        // 가격제안 메시지 카운팅을 위한 맵
        final Map<String, int> cargoCount = {};
        final allMessages =
            lastDocument == null ? newMessages : [...messages, ...newMessages];

        // 모든 메시지를 순회하면서 각 cargoId별 가격제안 개수를 카운트
        for (var message in allMessages) {
          if (message['callType'] == '가격제안') {
            final cargoId = message['cargoId'];
            cargoCount[cargoId] = 1; // 각 cargoId당 1개로 카운트
          }
        }

        final Map<String, Map<String, dynamic>> messageMap = {};

        // 메시지 처리 및 카운트 정보 추가
        for (var message in allMessages) {
          if (message['callType'] == '가격제안') {
            final cargoId = message['cargoId'];
            if (!messageMap.containsKey(cargoId) ||
                (messageMap[cargoId]!['date'] as Timestamp)
                        .compareTo(message['date'] as Timestamp) <
                    0) {
              messageMap[cargoId] = {
                ...message,
                'priceOfferCount': cargoCount[cargoId],
              };
            }
          } else {
            messageMap[message['id']] = message;
          }
        }

        if (mounted) {
          setState(() {
            messages = messageMap.values.toList()
              ..sort((a, b) =>
                  (b['date'] as Timestamp).compareTo(a['date'] as Timestamp));
          });
          await widget.messageBox.put('cached_messages', messages);
        }
      }
    } catch (e) {
      print('Error fetching messages: $e');
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.95) {
      _fetchMessages();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: messages.isEmpty && !isLoading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info,
                      color: Colors.grey.withOpacity(0.7),
                      size: 50,
                    ),
                    const SizedBox(height: 8),
                    KTextWidget(
                      text: '메세지가 없습니다.',
                      size: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.withOpacity(0.7),
                    )
                  ],
                )
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length + (isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final message = messages[index];
                    if (message['callType'] == '가격제안') {
                      return Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: PriceInput(messageData: message),
                      );
                    }
                    return const SizedBox.shrink(); // 다른 타입의 메시지는 일단 숨김
                  },
                ),
        ),
      ],
    );
  }
}
