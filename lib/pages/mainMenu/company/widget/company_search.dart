import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/mainMenu/company/widget/comany_add.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/loading_page.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class ComapnySearchPage extends StatefulWidget {
  const ComapnySearchPage({super.key});

  @override
  State<ComapnySearchPage> createState() => _ComapnySearchPageState();
}

class _ComapnySearchPageState extends State<ComapnySearchPage> {
  TextEditingController _searchText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    return GestureDetector(
      onTap: () => hideKeyboard(context),
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text(
                '기업(단체) 검색',
                style: TextStyle(fontSize: 20),
              ),
            ),
            body: SafeArea(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 56,
                          child: TextFormField(
                            controller: _searchText,
                            autocorrect: false,
                            maxLength: 30,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            minLines: 1,
                            maxLines: 1,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              color: null,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              suffix: GestureDetector(
                                onTap: () async {
                                  HapticFeedback.lightImpact();

                                  if (dataProvider
                                      .userData!.masterCompany.isNotEmpty) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        errorSnackBar(
                                            '마스터로 등록된 기업이 있습니다.\n마스터는 회사를 검색할 수 없습니다.',
                                            context));
                                  } else {
                                    print('@@');
                                    await searchBusinessDocuments(
                                      searchText: _searchText.text
                                          .trim(), // 사업자명 또는 사업자번호
                                    ).then((value) {
                                      print(value);

                                      setState(() {});
                                      if (value.isEmpty) {
                                        print('!!');
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(errorSnackBar(
                                                '검색 결과가 없습니다.\n기업(단체)를 등록하세요!',
                                                context));
                                      }
                                    });
                                  }
                                },
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    KTextWidget(
                                        text: '검색',
                                        size: 16,
                                        fontWeight: FontWeight.bold,
                                        color: kGreenFontColor)
                                  ],
                                ),
                              ),
                              counterStyle: const TextStyle(fontSize: 0),
                              errorStyle: const TextStyle(
                                  fontSize: 0, height: 0), // 기본 에러 스타일 완전히 숨기기
                              errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: kRedColor)),
                              errorText: null, // 기본 에러 텍스트 비활성화
                              filled: true,
                              fillColor: btnColor,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 10,
                              ),
                              hintText: '회사명 또는 사업자번호를 입력하세요.',
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: kGreenFontColor, width: 1.0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (vlaue) {},
                            validator: (value) {},
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: resultList.isEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info,
                                size: 60,
                                color: Colors.grey.withOpacity(0.3),
                              ),
                              const SizedBox(height: 12),
                              KTextWidget(
                                text: '검색 결과가 없습니다.',
                                size: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              KTextWidget(
                                text: '기업(단체)를 등록하려면 아래 버튼을 클릭하세요.',
                                size: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const CompanyAddPage()),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                          left: 12,
                                          right: 12,
                                          top: 8,
                                          bottom: 8),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: noState),
                                      child: const Row(
                                        children: [
                                          KTextWidget(
                                              text: '신규 기업(단체) 등록',
                                              size: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey)
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          )
                        : ListView.builder(
                            itemCount: resultList.length,
                            itemBuilder: (context, index) {
                              final company = resultList[index];
                              return _searchCard(company, mapProvider);
                            },
                          ),
                  ),
                ],
              ),
            )),
          ),
          if (mapProvider.isLoading == true) const LoadingPage()
        ],
      ),
    );
  }

  Widget _searchCard(Map<String, dynamic> company, MapProvider mapProvider) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: () async {
          mapProvider.isLoadingState(true);
          await FirebaseFirestore.instance
              .collection('normalCom')
              .doc(company['id'])
              .update({
            'waitList': FieldValue.arrayUnion([dataProvider.userData!.uid])
          });

          await FirebaseFirestore.instance
              .collection('user_normal')
              .doc(dataProvider.userData!.uid)
              .update({'wait': company['id'], 'waitName': company['comName']});
          dataProvider.userProvider();
          mapProvider.isLoadingState(false);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(currentSnackBar(
              '소속 요청이 완료되었습니다.\n담당자가 승인하면, 소속설정이 완료됩니다.', context));
        },
        title: KTextWidget(
          text: company['comName'] ?? '회사명 없음',
          size: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KTextWidget(
              text: '사업자번호: ${company['busNum'] ?? '없음'}',
              size: 14,
              fontWeight: FontWeight.normal,
              color: Colors.grey,
            ),
            if (company['comAddress1'] != null)
              KTextWidget(
                text: '주소: ${company['comAddress1']}',
                size: 14,
                fontWeight: FontWeight.normal,
                color: Colors.grey,
              ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  List<Map<String, dynamic>> resultList = [];
  Future<List<Map<String, dynamic>>> searchBusinessDocuments({
    required String searchText,
  }) async {
    try {
      // 하나의 쿼리로 name 또는 bNumber가 일치하는 문서 검색
      final query = await FirebaseFirestore.instance
          .collection('normalCom')
          .where(Filter.or(
            Filter('comName', isEqualTo: searchText),
            Filter('busNum', isEqualTo: searchText),
          ))
          .get();

      // 검색된 문서들을 리스트로 변환
      for (var doc in query.docs) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        resultList.add(data);
      }

      return resultList;
    } catch (e) {
      print('검색 중 오류 발생: $e');

      return [];
    }
  }
}
