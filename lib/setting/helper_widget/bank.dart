import 'package:flutter/material.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:multi_dropdown/models/value_item.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

class BankDropdownHelper extends StatelessWidget {
  final Function(String bankName, String bankCode) onBankSelected;
  final String? selectedValue;

  const BankDropdownHelper({
    Key? key,
    required this.onBankSelected,
    this.selectedValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<ValueItem> bankItems = [
      // 주요 시중은행
      ValueItem(label: '국민은행', value: 'KB'),
      ValueItem(label: '신한은행', value: 'SH'),
      ValueItem(label: '우리은행', value: 'WR'),
      ValueItem(label: '하나은행', value: 'HN'),
      ValueItem(label: 'NH농협은행', value: 'NH'),
      ValueItem(label: 'IBK기업은행', value: 'IBK'),

      // 인터넷전문은행
      ValueItem(label: '카카오뱅크', value: 'KK'),
      ValueItem(label: '토스뱅크', value: 'TS'),
      ValueItem(label: '케이뱅크', value: 'KBK'),

      // 지방은행
      ValueItem(label: '부산은행', value: 'BNK'),
      ValueItem(label: '대구은행', value: 'DGB'),
      ValueItem(label: '경남은행', value: 'KNB'),
      ValueItem(label: '광주은행', value: 'KJB'),
      ValueItem(label: '전북은행', value: 'JBB'),
      ValueItem(label: '제주은행', value: 'JJB'),

      // 특수은행 및 기타
      ValueItem(label: 'SC제일은행', value: 'SC'),
      ValueItem(label: '산업은행', value: 'KDB'),
      ValueItem(label: '수협은행', value: 'SH'),
      ValueItem(label: '씨티은행', value: 'CITI'),
      ValueItem(label: '새마을금고', value: 'MG'),
      ValueItem(label: '신협', value: 'CU'),
      ValueItem(label: '우체국은행', value: 'POST'),
      ValueItem(label: '저축은행', value: 'SB'),
    ];

    // 초기 선택값 설정
    List<ValueItem> selectedOptions = [];
    if (selectedValue != null) {
      selectedOptions =
          bankItems.where((item) => item.value == selectedValue).toList();
    }

    return SizedBox(
      height: 56,
      child: MultiSelectDropDown(
        onOptionSelected: (List<ValueItem> selectedOptions) {
          if (selectedOptions.isNotEmpty) {
            final selectedBank = selectedOptions.first;
            onBankSelected(selectedBank.label, selectedBank.value);
          }
        },
        options: bankItems,
        selectedOptions:
            selectedOptions, // initiallySelectedItems 대신 selectedOptions 사용
        selectionType: SelectionType.single,
        chipConfig: const ChipConfig(wrapType: WrapType.wrap),
        dropdownHeight: 300,
        fieldBackgroundColor: msgBackColor,
        optionTextStyle: const TextStyle(fontSize: 16),
        selectedOptionIcon:
            const Icon(Icons.check_circle, color: kGreenFontColor),
        selectedOptionTextColor: kGreenFontColor,
        selectedOptionBackgroundColor: msgBackColor,
        singleSelectItemStyle: TextStyle(
            fontSize: 16, color: kGreenFontColor, fontWeight: FontWeight.bold),
        padding: EdgeInsets.only(right: 8),
        borderRadius: 8,
        hint: '은행을 선택하세요',
        hintPadding: EdgeInsets.only(left: 8),
        hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
        optionsBackgroundColor: msgBackColor,
        dropdownBackgroundColor: msgBackColor,
        focusedBorderColor: kGreenFontColor,
        focusedBorderWidth: 2,
        dropdownMargin: 12,
      ),
    );
  }
}
