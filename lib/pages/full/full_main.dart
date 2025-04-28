import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/multi/multi_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/retrun/return_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/sidePage/biding/biding_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/sidePage/state_page/state_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/normal/cargo_info.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/return_state/return_main.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/loading_page.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:provider/provider.dart';

class FullMainPage extends StatefulWidget {
  final Map<String, dynamic>? cargo;
  final String? normalId;
  final String? id;
  final String? callType;
  const FullMainPage(
      {super.key, required this.cargo, this.callType, this.id, this.normalId});

  @override
  State<FullMainPage> createState() => _FullMainPageState();
}

class _FullMainPageState extends State<FullMainPage> {
  @override
  void initState() {
    super.initState();
    // 스트림 시작

    if (widget.cargo == null) {
      context.read<DataProvider>().initStream(
            widget.normalId.toString(),
            widget.id.toString(),
          );
    } else {
      context.read<DataProvider>().initStream(
            widget.cargo!['uid'],
            widget.cargo!['id'],
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);
    final dataProvider = context.watch<DataProvider>();

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text(
              '운송 정보 상세 보기',
              style: TextStyle(fontSize: 20),
            ),
          ),
          body: SafeArea(
              child: dataProvider.selectedCargo == null
                  ? const Center(child: CircularProgressIndicator())
                  : ContainedTabBarView(
                      initialIndex: widget.callType == '보고' ? 1 : 0,
                      tabs: [
                        const Text('운송 정보', style: TextStyle(fontSize: 18)),
                        dataProvider.selectedCargo!['pickUserUid'] == null
                            ? const Text('운송료 제안',
                                style: TextStyle(fontSize: 18))
                            : const Text('상태 관리',
                                style: TextStyle(fontSize: 18))
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
                        _fullState(dataProvider),
                        if (dataProvider.selectedCargo!['pickUserUid'] == null)
                          BidingMainPage(
                            cargo: dataProvider.selectedCargo!,
                          )
                        else
                          // 여기 풀어야 제안됨.
                          _subPage(dataProvider),
                      ],
                    )),
        ),
        if (mapProvider.isLoading == true) const LoadingPage()
      ],
    );
  }

  Widget _fullState(DataProvider dataProvider) {
    return Column(children: [
      if (dataProvider.selectedCargo!['aloneType'] == '다구간')
        Expanded(
            child: FullMultiMainPage(
          cargo: dataProvider.selectedCargo!,
        ))
      else if (dataProvider.selectedCargo!['aloneType'] == '왕복')
        Expanded(child: FullReturnMainPage(cargo: dataProvider.selectedCargo!))
      else
        Expanded(
            child: CargoInfoDetailPage(cargo: dataProvider.selectedCargo!)),
    ]);
  }

  Widget _subPage(DataProvider dataProvider) {
    return Column(
      children: [
        Expanded(
          child: SideStateMainPage(
            cargo: dataProvider.selectedCargo!,
            callType: dataProvider.selectedCargo!['aloneType'],
          ),
        ),
      ],
    );
  }
}
