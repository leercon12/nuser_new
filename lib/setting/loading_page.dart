import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dw = MediaQuery.of(context).size.width;
    final dh = MediaQuery.of(context).size.height;
    return Container(
        width: dw,
        height: dh,
        color: Colors.grey[900]!.withOpacity(0.4),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('asset/lottie/logo.json', width: 150),
              //  Image.asset('asset/img/logo.gif')
            ],
          ),
        ));
  }
}
