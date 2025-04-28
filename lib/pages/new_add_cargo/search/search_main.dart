import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/search/widget/search_address.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/search/widget/search_cargo.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class SearchMainPage extends StatefulWidget {
  final String callType;
  final String type;
  const SearchMainPage({super.key, required this.callType, required this.type});

  @override
  State<SearchMainPage> createState() => _SearchMainPageState();
}

class _SearchMainPageState extends State<SearchMainPage> {
  List<dynamic> locations = [];
  List<dynamic> cargos = [];

  List<dynamic> comLocations = [];
  List<dynamic> comCargos = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchData2();
  }

  Future<void> _fetchData() async {
    try {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      final docSnap = await FirebaseFirestore.instance
          .collection('user_normal')
          .doc(dataProvider.userData!.uid)
          .collection('recList')
          .doc('rec')
          .get();

      if (docSnap.exists) {
        final data = docSnap.data();
        setState(() {
          locations = (data?['locations'] ?? []) as List<dynamic>;
          cargos = (data?['cargos'] ?? []) as List<dynamic>;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _fetchData2() async {
    try {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);

      if (dataProvider.userData!.company.isNotEmpty) {
        final docSnap = await FirebaseFirestore.instance
            .collection('normalCom')
            .doc(dataProvider.userData!.company[0])
            .collection('recList')
            .doc('rec')
            .get();

        if (docSnap.exists) {
          final data = docSnap.data();
          setState(() {
            comLocations = (data?['locations'] ?? []) as List<dynamic>;
            comCargos = (data?['cargos'] ?? []) as List<dynamic>;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('운송 정보 내역', style: TextStyle(fontSize: 20)),
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(child: Text('오류가 발생했습니다: $error'));
    }

    if (locations.isEmpty && cargos.isEmpty) {
      return const Center(child: Text('데이터가 없습니다'));
    }

    return Column(
      children: [
        Expanded(
          child: ContainedTabBarView(
            initialIndex: widget.callType.contains('화물') ? 1 : 0,
            tabs: const [
              Text('운송 지역', style: TextStyle(fontSize: 18)),
              Text('운송 화물', style: TextStyle(fontSize: 18)),
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
              SearchAddress(
                locations: locations,
                comLocations: comLocations,
                callType: widget.type,
                type: widget.type,
              ),
              SearchCargoPage(
                cargos: cargos,
                comCargos: comCargos,
                callType: widget.callType,
                type: widget.type,
              )
            ],
          ),
        ),
      ],
    );
  }
}
