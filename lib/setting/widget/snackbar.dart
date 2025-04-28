import 'package:flutter/material.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';

SnackBar errorSnackBar(String label, context) {
  return SnackBar(
      margin: const EdgeInsets.all(10),
      backgroundColor: kRedColor.withOpacity(0.7),
      elevation: 1,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
      /*   action: SnackBarAction(
      label: 'Undo',
      textColor: Colors.white,
      onPressed: () {},
    ), */
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      content: Row(
        children: [
          const Icon(
            Icons.change_circle,
            color: Colors.white,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.start,
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ));
}

SnackBar currentSnackBar(String label, context) {
  return SnackBar(
      margin: const EdgeInsets.all(10),
      backgroundColor: kGreenFontColor.withOpacity(0.7),
      elevation: 1,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
      /*   action: SnackBarAction(
      label: 'Undo',
      textColor: Colors.white,
      onPressed: () {},
    ), */
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      content: Row(
        children: [
          const Icon(
            Icons.change_circle,
            color: Colors.white,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.start,
              maxLines: 2,
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ));
}
