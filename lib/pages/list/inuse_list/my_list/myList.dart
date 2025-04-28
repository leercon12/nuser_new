import 'package:flutter/material.dart';
import 'package:flutter_mixcall_normaluser_new/pages/list/inuse_list/list_widget/new_multi.dart';
import 'package:flutter_mixcall_normaluser_new/pages/list/inuse_list/list_widget/new_normal.dart';
import 'package:flutter_mixcall_normaluser_new/pages/list/inuse_list/list_widget/new_retrun.dart';
import 'package:flutter_mixcall_normaluser_new/pages/list/inuse_list/list_widget/normalList.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:provider/provider.dart';

class ListProgressMy extends StatelessWidget {
  final String? callType;
  const ListProgressMy({super.key, this.callType});

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    return ListView.builder(
      itemCount: dataProvider.cargoList.length,
      itemBuilder: (context, index) {
        final cargo = dataProvider.cargoList[index];
        return Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              if (cargo['aloneType'] == '다구간')
                NewMultiListCard(
                  data: cargo,
                  callType: callType,
                )
              else if (cargo['aloneType'] == '왕복')
                NewRetrunListCard(
                  data: cargo,
                  callType: callType,
                )
              else
                NewNormalListCard(data: cargo, callType: callType)
            ],
          ),
        );
      },
    );
  }
}
