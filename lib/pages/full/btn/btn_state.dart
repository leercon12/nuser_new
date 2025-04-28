import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/normal/bottomSheet/cancel.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/normal/bottomSheet/new_cancel.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/service/future_service.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class FullBtnState extends StatefulWidget {
  final Map<String, dynamic> cargo;
  final String callType;
  const FullBtnState({super.key, required this.cargo, required this.callType});

  @override
  State<FullBtnState> createState() => _FullBtnStateState();
}

class _FullBtnStateState extends State<FullBtnState> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.cargo['pickUserUid'] != null &&
            (widget.cargo['cargoStat'] == '운송완료' ||
                widget.cargo['cargoStat'] == '하차완료' ||
                widget.cargo['cargoStat'] == '취소'))
          _comState()
        else
          _btnState()
      ],
    );
  }

  Widget _btnState() {
    return Column(
      children: [
        /* if (widget.cargo['pickUserUid'] == null)
          _userNullState()
        else if (widget.cargo['cargoStat'] == '운송완료' ||
            widget.cargo['cargoStat'] == '하차완료' ||
            widget.cargo['cargoStat'] == '취소')
          _completeState()
        else
          widget.cargo['comUid'] == null ? _driverState() : _comState() */

        if (widget.cargo['comUid'] == null &&
            widget.cargo['pickUserUid'] == null)
          _readyState()
        else
          _noReadyState()
      ],
    );
  }

  Widget _readyState() {
    final mapProvider = Provider.of<MapProvider>(context);
    return Column(
      children: [
        if (isPassedDate(widget.cargo['aloneType'] == '왕복' ||
                    widget.cargo['aloneType'] == '다구간'
                ? widget.cargo['locations'][0]['date'].toDate()
                : widget.cargo['upTime'].toDate()) ==
            true)
          GestureDetector(
            onTap: () async {
              HapticFeedback.lightImpact();
              cargoReCon(context, widget.cargo['id'], widget.cargo['uid'],
                  widget.cargo, widget.callType);
            },
            child: Container(
              height: 52,
              margin: const EdgeInsets.only(left: 8, right: 8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: kGreenFontColor),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  KTextWidget(
                      text: '운송 정보 재등록',
                      size: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)
                ],
              ),
            ),
          )
        else
          GestureDetector(
            onTap: () async {
              HapticFeedback.lightImpact();
              cargoReset(context, widget.cargo['id'], widget.cargo['uid'],
                  widget.cargo);
            },
            child: Container(
              height: 52,
              margin: const EdgeInsets.only(left: 8, right: 8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: kOrangeAssetColor),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  KTextWidget(
                      text: '운송 정보 수정',
                      size: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)
                ],
              ),
            ),
          ),
        GestureDetector(
          onTap: () async {
            HapticFeedback.lightImpact();
            cargoDelete(context, widget.cargo['id'], widget.cargo['uid'])
                .then((value) async {
              if (value == true) {
                Navigator.pop(context);
                // Navigator.pop(context);
                mapProvider.isLoadingState(true);

                await FirebaseFirestore.instance
                    .collection('cargoLive')
                    .doc(widget.cargo['id'])
                    .delete();

                await deleteCargoWithSubcollections(
                    widget.cargo['uid'], widget.cargo['id']);

                mapProvider.isLoadingState(false);

                ScaffoldMessenger.of(context).showSnackBar(
                    currentSnackBar('운송 요청이 정상적으로 취소되었습니다.', context));
              }
            });
          },
          child: Container(
            height: 52,
            margin: const EdgeInsets.only(top: 8, left: 8, right: 8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12), color: kRedColor),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                KTextWidget(
                    text: '운송 요청 삭제',
                    size: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _noReadyState() {
    return Column(
      children: [
        if (widget.cargo['comUid'] == null) _driverState() else _comState(),
      ],
    );
  }

  Widget _driverState() {
    return widget.cargo['cargoStat'] == '하차완료' ||
            widget.cargo['cargoStat'] == '운송완료' ||
            widget.cargo['cargoStat'] == '취소'
        ? _completeState()
        : Column(
            children: [
              GestureDetector(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  if (widget.cargo['comUid'] == null) {
                    makePhoneCall(widget.cargo['driverPhone'].toString());
                  } else {
                    makePhoneCall(widget.cargo['comPhone'].toString());
                  }
                },
                child: Container(
                  height: 52,
                  margin: const EdgeInsets.only(left: 8, right: 8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12), color: noState),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.phone, color: Colors.grey, size: 16),
                      const SizedBox(width: 10),
                      KTextWidget(
                          text: widget.cargo['comUid'] == null
                              ? '배차 기사 문의'
                              : '주선사 문의',
                          size: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  cargoDriverSet(context, widget.cargo['id'],
                      widget.cargo['uid'], widget.cargo);
                },
                child: Container(
                  height: 52,
                  margin: const EdgeInsets.only(top: 8, left: 8, right: 8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: kOrangeAssetColor),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      KTextWidget(
                          text: '운송 정보 수정',
                          size: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  driverOut(context, widget.cargo['id'], widget.cargo['uid'],
                      widget.cargo, widget.callType);
                },
                child: Container(
                  height: 52,
                  margin: const EdgeInsets.only(top: 8, left: 8, right: 8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: kRedColor),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      KTextWidget(
                          text: '운송 취소',
                          size: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          );
  }

  Widget _comState() {
    return widget.cargo['cargoStat'] == '하차완료' ||
            widget.cargo['cargoStat'] == '운송완료' ||
            widget.cargo['cargoStat'] == '취소'
        ? _completeState()
        : Column(
            children: [],
          );
  }

  Widget _completeState() {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            HapticFeedback.lightImpact();
            cargoReCon(context, widget.cargo['id'], widget.cargo['uid'],
                widget.cargo, widget.callType);
          },
          child: Container(
            height: 52,
            margin: const EdgeInsets.only(left: 8, right: 8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: kGreenFontColor),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                KTextWidget(
                    text: '운송 정보 재등록',
                    size: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)
              ],
            ),
          ),
        )
      ],
    );
  }
}
