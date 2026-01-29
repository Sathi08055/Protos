import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:testing/pages/result_page.dart';

class LoadingPage extends StatelessWidget {
  final String searchQuery;
  const LoadingPage({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    // Start navigation to ResultPage after a short delay
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ResultPage(searchQuery: searchQuery),
        ),
      );
    });
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset(
          'assets/Searchanimation.json',
          width: 400,
          height: 400,
          repeat: true,
        ),
      ),
    );
  }
}
