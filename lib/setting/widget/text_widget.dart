import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';

class KTextWidget extends StatelessWidget {
  final String text;
  final double size;
  final FontWeight? fontWeight;
  final Color? color;
  final double? lineHeight;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  const KTextWidget(
      {super.key,
      required this.text,
      required this.size,
      required this.fontWeight,
      required this.color,
      this.lineHeight,
      this.overflow,
      this.textAlign});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      overflow: overflow == null ? null : overflow,
      style: TextStyle(
          fontFamily: 'Suit',
          fontSize: size,
          color: color,
          fontWeight: fontWeight,
          height: lineHeight),
    );
  }
}

/* ===================================
하단 박스 
=================================== */

Widget bottomBox(
    {required String? text, required bool? change, bool? isLoading}) {
  return Container(
    // width: 328,
    height: 56,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: change == null
          ? kGreenFontColor
          : change == true
              ? kGreenFontColor
              : noState,
    ),
    child: Center(
      child: isLoading == true || change == false
          ? KTextWidget(
              text: text.toString(),
              size: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey)
          : KTextWidget(
              text: text.toString(),
              size: 16,
              fontWeight: FontWeight.bold,
              color: null),
    ),
  );
}

/////////////////////////////
//// 밑줄 위젯
////////////////////////////

class UnderLineWidget extends StatelessWidget {
  final String text;
  final Color color;
  final double? size;
  final double? width;
  const UnderLineWidget(
      {super.key,
      required this.text,
      required this.color,
      this.size,
      this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: color, // 밑줄 색상
            width: width == null ? 2 : width!, // 밑줄 두께
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            text,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: size == null ? 13 : size,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/////////////////////////////
///
///

class CustomTextBigFormField extends StatefulWidget {
  final TextEditingController controller;
  final bool? searchLoading;
  final void Function(dynamic)? onChanged;
  final BuildContext context;
  final int maxLength;
  final double? contentsSize;
  final double? hintSize;
  final String? Function(String?)? validator;
  final String hint;
  final bool? obs;
  final bool? isDigt;
  final List<TextInputFormatter>? input;

  const CustomTextBigFormField({
    Key? key,
    required this.controller,
    required this.searchLoading,
    required this.onChanged,
    required this.context,
    required this.hint,
    required this.maxLength,
    this.contentsSize,
    this.hintSize,
    this.validator,
    this.input,
    this.obs,
    this.isDigt,
  }) : super(key: key);

  @override
  State<CustomTextBigFormField> createState() => _CustomTextBigFormFieldState();
}

class _CustomTextBigFormFieldState extends State<CustomTextBigFormField> {
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 56,
          child: TextFormField(
            controller: widget.controller,
            autocorrect: false,
            maxLength: widget.maxLength,
            keyboardType: widget.isDigt == null || widget.isDigt == false
                ? TextInputType.number
                : TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            obscureText: widget.obs == null ? false : widget.obs as bool,
            minLines: 1,
            maxLines: 1,
            textAlign: TextAlign.start,
            style: TextStyle(
              color: widget.searchLoading == true ? Colors.grey : null,
              fontSize: widget.contentsSize == null ? 18 : widget.contentsSize,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterStyle: const TextStyle(fontSize: 0),
              errorStyle:
                  const TextStyle(fontSize: 0, height: 0), // 기본 에러 스타일 완전히 숨기기
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
              hintText: widget.hint,
              hintStyle: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: widget.hintSize == null ? 16 : widget.hintSize,
                color: Colors.grey,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: kGreenFontColor, width: 1.0),
                borderRadius: BorderRadius.circular(10),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: widget.onChanged,
            validator: (value) {
              final error = widget.validator?.call(value);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _errorText = error;
                });
              });
              return error; // null 대신 error를 반환
            },
            inputFormatters: widget.input,
          ),
        ),
        if (_errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 1, left: 8),
            child: Text(
              _errorText!,
              style: TextStyle(
                color: kRedColor,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

///박스

class KRoundedContainer extends StatelessWidget {
  final Color? color;
  final Widget? child;
  final BoxBorder? border;
  const KRoundedContainer(
      {super.key, required this.color, this.border, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 5, right: 5, top: 2, bottom: 2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: color!.withOpacity(0.25),
          border: border),
      child: child,
    );
  }
}
