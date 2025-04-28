import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/full_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/list/inuse_list/my_list/comList.dart';
import 'package:flutter_mixcall_normaluser_new/pages/list/inuse_list/my_list/myList.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/loading_page.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class InUseCargoList extends StatefulWidget {
  final String? callType;
  const InUseCargoList({super.key, this.callType});

  @override
  State<InUseCargoList> createState() => _InUseCargoListState();
}

class _InUseCargoListState extends State<InUseCargoList> {
  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final dw = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              dataProvider.totalCargoList.length < 10
                  ? '진행중인 운송 목록(0${dataProvider.totalCargoList.length})'
                  : '진행중인 운송 목록(${dataProvider.totalCargoList.length})',
              style: const TextStyle(fontSize: 20),
            ),
          ),
          body: /*  dataProvider.cargoList.isEmpty
              ? SizedBox(
                  width: dw,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info,
                        color: Colors.grey.withOpacity(0.5),
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      KTextWidget(
                          text: '진행중인 운송이 없습니다.',
                          size: 15,
                          fontWeight: null,
                          color: Colors.grey.withOpacity(0.5))
                    ],
                  ),
                )
              : */
              ContainedTabBarView(
            initialIndex: 0,
            tabs: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '나의 화물',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    ' ${dataProvider.cargoList.length}',
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey.withOpacity(0.5)),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '소속 기업 화물',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    ' ${dataProvider.companyCargoList.length}',
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
            views: [
              ListProgressMy(
                callType: widget.callType,
              ),
              ListProgressCom(
                callType: widget.callType,
              )
            ],
          ),
        ),
        if (dataProvider.isLoading == true) const LoadingPage()
      ],
    );
  }
}
