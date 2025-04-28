import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/service/pick_image_service.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/image_dialog.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class InvoiceState extends StatefulWidget {
  final Map<String, dynamic> cargo;
  const InvoiceState({super.key, required this.cargo});

  @override
  State<InvoiceState> createState() => _InvoiceStateState();
}

class _InvoiceStateState extends State<InvoiceState> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const KTextWidget(
            text: '인수증 등록',
            size: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey),
        const KTextWidget(
            text: '필요시 인수증을 등록하면, 서류를 보관할 수 있어요.',
            size: 12,
            fontWeight: null,
            color: Colors.grey),
        const SizedBox(height: 12),
        _imgState(),
        _downState(),
      ],
    );
  }

  Widget _downState() {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        color: msgBackColor,
      ),
      child: GestureDetector(
          onTap: () async {},
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              KTextWidget(
                  text: '위 버튼을 클릭하여, 인수증을 등록하세요!',
                  size: 14,
                  fontWeight: FontWeight.bold,
                  color: kGreenFontColor),
            ],
          )),
    );
  }

  Widget _imgState() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        color: msgBackColor,
      ),
      child: Column(
        children: [
          Row(
            children: [
              _imgBox(0),
              _imgBox(1),
              _imgBox(2),
            ],
          )
        ],
      ),
    );
  }

  Widget _imgBox(
    int count,
  ) {
    final addProvider = Provider.of<AddProvider>(context);
    final mapProvider = Provider.of<MapProvider>(context);
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        addProvider.cargoImageState(null);
        if (widget.cargo['invoicePhotoURl$count'] == null) {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return PickImageBottom(
                callType: '상차보고',
                comUid: widget.cargo['comUid'].toString(),
                count: count,
              );
            },
          ).then((value) async {
            if (value == true) {
              if (addProvider.cargoImage != null) {
                mapProvider.isLoadingState(true);
                await _photoUpdate(addProvider, count);
                mapProvider.isLoadingState(false);
              }
            }
          });
        } else {
          showDialog(
            context: context,
            builder: (context) => ImageViewerDialog(
              networkUrl: widget.cargo['invoicePhotoURl$count'].toString(),
              cargo: widget.cargo['invoicePhotoURl$count'],
            ),
          ).then((value) async {
            if (value != null) {
              print(value);

              if (widget.cargo['comUid'] == null) {
                await FirebaseFirestore.instance
                    .collection('cargoInfo')
                    .doc(widget.cargo['uid'])
                    .collection(extractFour(widget.cargo['id']))
                    .doc(widget.cargo['id'])
                    .update({
                  'invoicePhotoURl$count': null,
                });
              } else {
                await FirebaseFirestore.instance
                    .collection('cargoInfo')
                    .doc(widget.cargo['uid'])
                    .collection(extractFour(widget.cargo['id']))
                    .doc(widget.cargo['id'])
                    .update({
                  'invoicePhotoURl$count': null,
                });
                await FirebaseFirestore.instanceFor(
                        app: FirebaseFirestore.instance.app,
                        databaseId: 'mixcallcompany')
                    .collection(widget.cargo['comUid'])
                    .doc('cargoInfo')
                    .collection(extractFour(widget.cargo['id']))
                    .doc(widget.cargo['id'])
                    .update({
                  'invoicePhotoURl$count': null,
                });
              }
            }
          });
        }
      },
      child: Container(
        width: 60,
        height: 60,
        margin: const EdgeInsets.only(right: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: noState,
        ),
        child: widget.cargo['invoicePhotoURl$count'] == null
            ? const Center(
                child: Icon(
                  Icons.add,
                  color: Colors.grey,
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: widget.cargo['invoicePhotoURl$count'][0],
                  fit: BoxFit.cover, // 이미지를 컨테이너에 맞춰서 보여줍니다.
                ),
              ),
      ),
    );
  }

  Future _photoUpdate(AddProvider addProvider, int count) async {
    String? downUrl = await uploadImage(addProvider.cargoImage!, 'cargo',
        widget.cargo['id'], 'invoicePhotoURl$count');
    User? _user = FirebaseAuth.instance.currentUser;
    if (widget.cargo['comUid'] == null) {
      await FirebaseFirestore.instance
          .collection('cargoInfo')
          .doc(widget.cargo['uid'])
          .collection(extractFour(widget.cargo['id']))
          .doc(widget.cargo['id'])
          .update({
        'invoicePhotoURl$count': [downUrl, _user!.uid],
      });
    } else {
      await FirebaseFirestore.instance
          .collection('cargoInfo')
          .doc(widget.cargo['uid'])
          .collection(extractFour(widget.cargo['id']))
          .doc(widget.cargo['id'])
          .update({
        'invoicePhotoURl$count': [downUrl, _user!.uid],
      });
      await FirebaseFirestore.instanceFor(
              app: FirebaseFirestore.instance.app, databaseId: 'mixcallcompany')
          .collection(widget.cargo['comUid'])
          .doc('cargoInfo')
          .collection(extractFour(widget.cargo['id']))
          .doc(widget.cargo['id'])
          .update({
        'invoicePhotoURl$count': [downUrl, _user.uid],
      });
    }
  }
}
