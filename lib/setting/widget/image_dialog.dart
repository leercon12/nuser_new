import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'dart:io';

import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

User? _user = FirebaseAuth.instance.currentUser;

class ImageViewerDialog extends StatelessWidget {
  final File? imageFile;
  final String? networkUrl;
  final String? uid;
  final List? cargo;
  final String? callType;

  const ImageViewerDialog(
      {Key? key,
      this.imageFile,
      this.networkUrl,
      this.uid,
      this.cargo,
      this.callType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dw = MediaQuery.of(context).size.width;
    final addProvider = Provider.of<AddProvider>(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 배경을 어둡게 처리
          Container(
            color: Colors.black.withOpacity(0.7),
          ),
          // 확대/축소 가능한 이미지 뷰어
          InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: networkUrl == null
                  ? Image.file(
                      imageFile!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Text(
                            '이미지를 불러올 수 없습니다',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      },
                    )
                  : Image.network(
                      cargo == null
                          ? networkUrl.toString()
                          : cargo![0].toString(),
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.grey,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Text(
                            '이미지를 불러올 수 없습니다',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      },
                    ),
            ),
          ),
          // 닫기 버튼
          Positioned(
            top: 13,
            right: 5,
            left: 5,
            child: SizedBox(
              width: dw,
              child: Row(
                children: [
                  if (callType == '기업등록' ||
                      (callType == '기사사진'
                          ? uid == _user!.uid
                          : cargo != null && cargo![1] == _user!.uid))
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (callType == '기업등록') {
                          if (callType!.contains('사업자등록증')) {
                            addProvider.companyBusinessPhotoState(null);
                          } else if (callType!.contains('로고')) {
                            addProvider.companyLogoPhotoState(null);
                          } else {
                            addProvider.companyAccountPhotoState(null);
                          }
                        } else if (callType == '기사사진') {
                          Navigator.pop(context, true);
                        } else {
                          Navigator.pop(context, cargo);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 8, top: 8, bottom: 8, right: 12),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: kRedColor.withOpacity(0.2)),
                        child: const Row(
                          children: [
                            Icon(Icons.delete_forever,
                                color: kRedColor, size: 15),
                            SizedBox(width: 5),
                            KTextWidget(
                                text: '사진 삭제',
                                size: 14,
                                fontWeight: FontWeight.bold,
                                color: kRedColor)
                          ],
                        ),
                      ),
                    ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                    },
                    child: const SizedBox(
                      width: 150,
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.close, color: Colors.white, size: 30),
                        ],
                      ),
                    ),
                  ),
                  /*   IconButton(
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.of(context).pop(),
                  ), */
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
