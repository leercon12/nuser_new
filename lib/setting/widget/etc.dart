import 'package:flutter/material.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';

Widget checkBox({required bool option, Color? color}) {
  return Container(
    width: 34,
    height: 34,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: option == true
            ? color == null
                ? kGreenFontColor
                : kRedColor
            : btnColor),
    child: Center(
      child: Icon(
        Icons.check,
        color: option == true ? Colors.white : Colors.grey,
      ),
    ),
  );
}
