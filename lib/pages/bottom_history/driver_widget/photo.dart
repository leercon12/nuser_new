import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/image_dialog.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';

class BottomPhoto extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final List photo;
  final String callType;

  const BottomPhoto(
      {super.key,
      required this.photo,
      required this.userData,
      required this.callType});

  @override
  State<BottomPhoto> createState() => _BottomPhotoState();
}

class _BottomPhotoState extends State<BottomPhoto> {
  @override
  void initState() {
    super.initState();
    _sortPhotos();
  }

  late List sortedPhotos;
  void _sortPhotos() {
    sortedPhotos = List.from(widget.photo)
      ..sort((a, b) {
        final aTimestamp = a['timestamp'] as Timestamp;
        final bTimestamp = b['timestamp'] as Timestamp;
        return bTimestamp.compareTo(aTimestamp);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.photo.isEmpty
            ? Expanded(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info,
                    size: 60,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                  const SizedBox(height: 8),
                  KTextWidget(
                      text: '표시할 수 있는 사진이 없습니다.',
                      size: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.withOpacity(0.5))
                ],
              ))
            : Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: sortedPhotos.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        if (widget.callType == '기사') {
                          await showDialog(
                            context: context,
                            builder: (context) => ImageViewerDialog(
                              networkUrl: sortedPhotos[index]['url'],
                              uid: widget.userData!['uid'],
                              callType: '기사사진',
                            ),
                          ).then((value) async {
                            if (value == true) {
                              await FirebaseFirestore.instance
                                  .collection('user_driver')
                                  .doc(widget.userData!['uid'])
                                  .collection('upDownHistory')
                                  .doc('photo')
                                  .update({
                                'historyPhoto': FieldValue.arrayRemove(
                                    [sortedPhotos[index]])
                              });
                            }
                          });
                        } else {}
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                sortedPhotos[index]['url'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(Icons.error),
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                              ),
                              Positioned(
                                bottom: 5,
                                right: 5,
                                child: Container(
                                  padding: EdgeInsets.only(left: 5, right: 5),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: msgBackColor.withOpacity(0.5)),
                                  child: Center(
                                    child: KTextWidget(
                                        text: formatDate(
                                          sortedPhotos[index]['timestamp']
                                              .toDate(),
                                        ),
                                        size: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }
}
