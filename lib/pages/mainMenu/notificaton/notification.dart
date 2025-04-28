import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/mainMenu/notificaton/msg_page.dart';
import 'package:flutter_mixcall_normaluser_new/pages/mainMenu/notificaton/news_page.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class NotificationMainPage extends StatefulWidget {
  const NotificationMainPage({super.key});

  @override
  State<NotificationMainPage> createState() => _NotificationMainPageState();
}

class _NotificationMainPageState extends State<NotificationMainPage> {
  Box? messageBox;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    messageBox = await Hive.openBox('msg_${dataProvider.userData!.uid}');
    setState(() {});
  }

  @override
  void dispose() {
    messageBox?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final mapProvider = Provider.of<MapProvider>(context);

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text(
            '메세지',
            style: TextStyle(fontSize: 20),
          ),
          actions: [
            if (messageBox != null)
              GestureDetector(
                onTap: () async {
                  HapticFeedback.lightImpact();

                  await FirebaseFirestore.instance
                      .collection('msg')
                      .doc('user')
                      .collection(dataProvider.userData!.uid)
                      .get()
                      .then((querySnapshot) {
                    querySnapshot.docs.forEach((doc) {
                      doc.reference.delete();
                    });
                  });

                  await messageBox?.clear();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                      currentSnackBar('메시지 삭제가 완료되었습니다.', context));
                },
                child: const KTextWidget(
                    text: '모두 삭제',
                    size: 16,
                    fontWeight: null,
                    color: kRedColor),
              ),
            const SizedBox(width: 10),
          ]),
      body: messageBox == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ContainedTabBarView(
                initialIndex: 0,
                tabs: const [
                  Text('메세지', style: TextStyle(fontSize: 18)),
                  Text('공지 사항', style: TextStyle(fontSize: 18)),
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
                    fontWeight: FontWeight.bold,
                    color: kGreenFontColor,
                  ),
                ),
                views: [
                  MsgMainPage(messageBox: messageBox!), // messageBox 전달
                  const NotiCationPage()
                ],
              ),
            ),
    );
  }
}
