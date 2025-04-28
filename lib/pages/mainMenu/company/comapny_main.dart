import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/mainMenu/company/widget/comany_add.dart';
import 'package:flutter_mixcall_normaluser_new/pages/mainMenu/company/widget/company_search.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/hashProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/bottomSheet.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class ComapnyMainPage extends StatefulWidget {
  const ComapnyMainPage({super.key});

  @override
  State<ComapnyMainPage> createState() => _ComapnyMainPageState();
}

class _ComapnyMainPageState extends State<ComapnyMainPage> {
  @override
  void initState() {
    super.initState();
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    dataProvider.userProvider();
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '소속 정보 설정',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: dataProvider.userData!.masterCompany.isEmpty
              ? dataProvider.userData!.wait == ''
                  ? _addBox(dataProvider)
                  : _waitState(dataProvider)
              : ListView.builder(
                  itemCount: dataProvider.userData!.masterCompany == []
                      ? dataProvider.userData!.company.length
                      : dataProvider.userData!.masterCompany.length,
                  itemBuilder: (context, index) {
                    final company = dataProvider.userData!.masterCompany == []
                        ? dataProvider.userData!.company[index]
                        : dataProvider.userData!.masterCompany[0];
                    return Column(
                      children: [
                        _comWidget(dataProvider, company),
                      ],
                    );
                  },
                ),
          /* dataProvider.userData!.masterCompany == [] ||
                  dataProvider.userData!.company.length == 0
              ? dataProvider.userData!.wait == null
                  ? _addBox(dataProvider)
                  : _waitState(dataProvider)
              : ListView.builder(
                  itemCount: dataProvider.userData!.company.length,
                  itemBuilder: (context, index) {
                    final company = dataProvider.userData!.company[index];
                    return Column(
                      children: [
                        _comWidget(dataProvider, company),
                      ],
                    );
                  },
                ), */
        ),
      ),
    );
  }

  Widget _waitState(DataProvider dataProvider) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();

        if (dataProvider.userData!.wait != '') {
          print('@@@');
          await FirebaseFirestore.instance
              .collection('normalCom')
              .doc(dataProvider.userData!.wait)
              .update({
            'waitList': FieldValue.arrayRemove([dataProvider.uid])
          });
          await FirebaseFirestore.instance
              .collection('user_normal')
              .doc(dataProvider.uid)
              .update({
            'wait': null,
            'waitName': null,
          });
          dataProvider.userProvider();
          ScaffoldMessenger.of(context)
              .showSnackBar(errorSnackBar('소속 등록 요청이 취소되었습니다.', context));
          setState(() {});
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ComapnySearchPage()),
          );
        }
      },
      child: Container(
        height: 67,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: msgBackColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 10,
                  width: 10,
                  child: CircularProgressIndicator(
                    color: Colors.grey,
                    strokeWidth: 1.5,
                  ),
                ),
                const SizedBox(width: 10),
                KTextWidget(
                    text: '${dataProvider.userData!.waitName}의 승인을 대기중입니다.',
                    size: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ],
            ),
            KTextWidget(
                text: '요청을 취소하려면, 다시 한번 클릭하세요.',
                size: 12,
                fontWeight: null,
                color: kRedColor)
          ],
        ),
      ),
    );
  }

  Widget _comWidget(DataProvider dataProvider, dynamic company) {
    return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('normalCom')
            .doc(company)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('데이터가 없습니다'));
          }

          // Firestore 데이터를 Map으로 변환
          final data = snapshot.data!.data() as Map<String, dynamic>;

          return Column(
            children: [
              Container(
                //height: 150,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: msgBackColor,
                ),
                child: Column(
                  children: [
                    _top(data, dataProvider),
                  ],
                ),
              ),
              _master(data, dataProvider),
              _busInfo(data, dataProvider),
              _member(data, dataProvider),
            ],
          );
        });
  }

  Widget _top(Map<String, dynamic> data, DataProvider dataProvider) {
    final hashProvider = Provider.of<HashProvider>(context, listen: false);
    return Column(
      children: [
        Row(
          children: [
            if (data['state'] == '미승인')
              const KTextWidget(
                  text: '승인 대기중...',
                  size: 14,
                  fontWeight: FontWeight.bold,
                  color: kOrangeAssetColor)
            else if (data['state'] == '승인')
              const KTextWidget(
                  text: '정상 등록',
                  size: 14,
                  fontWeight: FontWeight.bold,
                  color: kGreenFontColor),
            const Spacer(),
            if (dataProvider.userData!.uid == data['masterUid'])
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CompanyAddPage(
                              comName: data['comName'],
                              comNum: data['busNum'],
                              ceoName: data['ceoName'],
                              busImg: data['busnienssUrl'],
                              accImg: data['accountUrl'],
                              accName: data['accountName'],
                              accNum: data['accountNum'],
                              bankName: data['accountName'],
                              address: data['comAddress1'],
                              comZone: data['comZone'],
                              email: data['email'],
                              comUid: data['id'],
                            )),
                  );
                },
                child: const KTextWidget(
                    text: '정보 수정',
                    size: 14,
                    fontWeight: null,
                    color: Colors.grey),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: 100,
          height: 100,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: noState.withOpacity(0.2),
          ),
          child: data['logoUrl'] == null
              ? ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                  child: Image.asset(
                    'asset/img/company.png',
                    errorBuilder: (context, error, stackTrace) {
                      print('이미지 로드 에러: $error');
                      return const Center(
                        child: Text('이미지를 불러올 수 없습니다'),
                      );
                    },
                  ),
                )
              : ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                  child: Image.network(
                    data['logoUrl'].toString(),
                    errorBuilder: (context, error, stackTrace) {
                      print('이미지 로드 에러: $error');
                      return const Center(
                        child: Text('이미지를 불러올 수 없습니다'),
                      );
                    },
                  ),
                ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const SizedBox(
              width: 90,
              child: KTextWidget(
                  text: '기업(단체)명',
                  size: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(width: 15),
            KTextWidget(
                text: data['comName'],
                size: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: 90,
              child: KTextWidget(
                  text: '우편물 주소',
                  size: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KTextWidget(
                    text: data['comAddress1'],
                    size: 14,
                    fontWeight: null,
                    color: Colors.grey),
                if (data['comAddress2'] != '')
                  KTextWidget(
                      text: data['comAddress2'],
                      size: 14,
                      fontWeight: null,
                      color: Colors.grey),
                KTextWidget(
                    text: data['comZone'],
                    size: 14,
                    fontWeight: null,
                    color: Colors.grey),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const SizedBox(
              width: 90,
              child: KTextWidget(
                  text: '사업자등록번호',
                  size: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(width: 15),
            KTextWidget(
                text: data['busNum'],
                size: 14,
                fontWeight: null,
                color: Colors.grey),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: 90,
              child: KTextWidget(
                  text: '환불계좌정보',
                  size: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KTextWidget(
                    text: '${data['bankName']}, ${data['accountName']}',
                    size: 14,
                    fontWeight: null,
                    color: Colors.grey),
                KTextWidget(
                    text: '${hashProvider.decryptData(data['accountNum'])}',
                    size: 14,
                    fontWeight: null,
                    color: Colors.grey),
              ],
            ),
          ],
        ),
        const SizedBox(
          height: 8,
        )
      ],
    );
  }

  Widget _master(Map<String, dynamic> data2, DataProvider dataProvider) {
    final hashProvider = Provider.of<HashProvider>(context, listen: false);
    return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('user_normal')
            .doc(data2['masterUid'])
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('데이터가 없습니다'));
          }

          // Firestore 데이터를 Map으로 변환
          final data = snapshot.data!.data() as Map<String, dynamic>;
          return GestureDetector(
            onTap: () {
              print(data2['masterUid']);
              print(dataProvider.userData!.uid);
              if (data2['masterUid'] == dataProvider.userData!.uid) {
                print('@@');

                setState(() {
                  isChangeMaster = !isChangeMaster;
                });
              }
            },
            child: Container(
              //height: 150,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: msgBackColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const KTextWidget(
                      text: '관리자',
                      size: 14,
                      fontWeight: null,
                      color: Colors.grey),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      KTextWidget(
                          text: hashProvider.decryptData(data['name']),
                          size: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      KTextWidget(
                          text: ', ${maskText(data['phone'])}',
                          size: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ],
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      KTextWidget(
                          text: '관리자를 변경하려면, 관리자 계정으로 이곳을 클릭하세요.',
                          size: 14,
                          fontWeight: null,
                          color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        });
  }

  Widget _busInfo(Map<String, dynamic> data2, DataProvider dataProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: msgBackColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const KTextWidget(
                  text: '승인 대기',
                  size: 14,
                  fontWeight: null,
                  color: Colors.grey),
              const Spacer(),
              if (data2['waitList'].isEmpty)
                const KTextWidget(
                    text: '승인요청없음',
                    size: 14,
                    fontWeight: null,
                    color: Colors.grey),
            ],
          ),
          if (data2['waitList'].isNotEmpty) const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true, // Column 내부에서 ListView를 사용하기 위해 필요
            physics: const NeverScrollableScrollPhysics(), // 스크롤 비활성화
            itemCount: data2['waitList'].length,
            itemBuilder: (context, index) {
              return StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('user_normal')
                      .doc(data2['waitList'][index])
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Center(child: Text('데이터가 없습니다'));
                    }

                    // Firestore 데이터를 Map으로 변환
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          KTextWidget(
                              text: data['name'],
                              size: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          KTextWidget(
                              text: ' (${maskText(data['phone'])})',
                              size: 14,
                              fontWeight: null,
                              color: Colors.grey),
                          const Spacer(),
                          if (data2['masterUid'] == dataProvider.userData!.uid)
                            GestureDetector(
                              onTap: () async {
                                HapticFeedback.lightImpact();
                                await FirebaseFirestore.instance
                                    .collection('normalCom')
                                    .doc(data2['id'])
                                    .update({
                                  'member':
                                      FieldValue.arrayUnion([data['uid']]),
                                  'waitList':
                                      FieldValue.arrayRemove([data['uid']]),
                                  'comName': data['comName']
                                });

                                setState(() {});
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.only(left: 8, right: 8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: kGreenFontColor),
                                child: const Center(
                                  child: KTextWidget(
                                      text: '소속 승인',
                                      size: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            )
                          else
                            const KTextWidget(
                                text: '승인 대기중',
                                size: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)
                        ],
                      ),
                    );
                  });
            },
          ),
        ],
      ),
    );
  }

  bool isChangeMaster = false;
  Widget _member(Map<String, dynamic> data2, DataProvider dataProvider) {
    final hashProvider = Provider.of<HashProvider>(context, listen: false);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: msgBackColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const KTextWidget(
                  text: '승인 유저',
                  size: 14,
                  fontWeight: null,
                  color: Colors.grey),
              const Spacer(),
              if (data2['member'].isEmpty)
                const KTextWidget(
                    text: '승인유저없음',
                    size: 14,
                    fontWeight: null,
                    color: Colors.grey),
            ],
          ),
          if (data2['member'].isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ListView.builder(
                shrinkWrap: true, // Column 내부에서 ListView를 사용하기 위해 필요
                physics: const NeverScrollableScrollPhysics(), // 스크롤 비활성화
                itemCount: data2['member'].length,
                itemBuilder: (context, index) {
                  return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('user_normal')
                          .doc(data2['member'][index])
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }

                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return const Center(child: Text('데이터가 없습니다'));
                        }

                        // Firestore 데이터를 Map으로 변환
                        final data =
                            snapshot.data!.data() as Map<String, dynamic>;
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              KTextWidget(
                                  text: hashProvider.decryptData(data['name']),
                                  size: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              KTextWidget(
                                  text: ' (${maskText(data['phone'])})',
                                  size: 14,
                                  fontWeight: null,
                                  color: Colors.grey),
                              const Spacer(),
                              if (isChangeMaster == true)
                                GestureDetector(
                                  onTap: () async {
                                    HapticFeedback.lightImpact();
                                    await _btm1().then((value) async {
                                      if (value == true) {
                                        await FirebaseFirestore.instance
                                            .collection('normalCom')
                                            .doc(data2['id'])
                                            .update({'masterUid': data['uid']});

                                        await FirebaseFirestore.instance
                                            .collection('user_normal')
                                            .doc(data['uid'])
                                            .update({
                                          'masterCompany':
                                              FieldValue.arrayRemove(
                                                  [data2['masterUid']])
                                        });
                                        setState(() {
                                          isChangeMaster = false;
                                        });
                                        dataProvider.userProvider();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(currentSnackBar(
                                                '소속 관리자가 변경되었습니다.', context));
                                      }
                                    });
                                    /*  */
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        border:
                                            Border.all(color: kBlueBssetColor)
                                        //color: kRedColor,
                                        ),
                                    child: const Center(
                                      child: KTextWidget(
                                          text: '관리자 변경',
                                          size: 14,
                                          fontWeight: null,
                                          color: kBlueBssetColor),
                                    ),
                                  ),
                                )
                              else if (data2['masterUid'] ==
                                      dataProvider.userData!.uid ||
                                  data2['member'][index] ==
                                      dataProvider.userData!.uid)
                                GestureDetector(
                                  onTap: () async {
                                    HapticFeedback.lightImpact();
                                    await _btm1().then((value) async {
                                      if (value == true) {
                                        await FirebaseFirestore.instance
                                            .collection('normalCom')
                                            .doc(data2['id'])
                                            .update({
                                          'member': FieldValue.arrayRemove(
                                              [data['uid']]),
                                          'waitList': FieldValue.arrayRemove(
                                              [data['uid']])
                                        });

                                        await FirebaseFirestore.instance
                                            .collection('user_normal')
                                            .doc(data['uid'])
                                            .update({
                                          'company': FieldValue.arrayRemove(
                                              [data2['id']]),
                                          'comName': null
                                        });
                                        setState(() {});
                                      }
                                    });
                                    /*  */
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(color: kRedColor)
                                        //color: kRedColor,
                                        ),
                                    child: const Center(
                                      child: KTextWidget(
                                          text: '소속 해제',
                                          size: 14,
                                          fontWeight: null,
                                          color: kRedColor),
                                    ),
                                  ),
                                )
                              else
                                const KTextWidget(
                                    text: '승인 대기중',
                                    size: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)
                            ],
                          ),
                        );
                      });
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<bool?> _btm1() async {
    final dw = MediaQuery.of(context).size.width;

    return await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return BottomSheetWidget(
              contents: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),
                const Icon(Icons.info, size: 70, color: kRedColor),
                const SizedBox(height: 32),
                const KTextWidget(
                    text: '해당 유저의 소속을 해제합니다.',
                    size: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                const SizedBox(height: 12),
                const KTextWidget(
                    text:
                        '해당 유저의 소속을 해제하면, 소속 운송건을 확인하거나 요청할 수 없습니다. 소속을 해제하시려면 아래 버튼을 클릭하세요.',
                    size: 14,
                    textAlign: TextAlign.center,
                    fontWeight: null,
                    color: Colors.grey),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context, true); // true 값을 반환
                  },
                  child: Container(
                    height: 52,
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    width: dw,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: kRedColor),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        KTextWidget(
                            text: '확인',
                            size: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ));
        });
      },
    );
  }

  Widget _addBox(DataProvider dataProvider) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ComapnySearchPage()),
        );
      },
      child: Container(
        height: 67,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: msgBackColor,
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  size: 18,
                  color: Colors.grey,
                ),
                SizedBox(width: 5),
                KTextWidget(
                    text: '소속 기업(단체)를 설정하려면 이곳을 클릭하세요.',
                    size: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
