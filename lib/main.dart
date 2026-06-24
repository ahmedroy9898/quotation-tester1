import 'package:flutter/material.dart';
import 'quotation_screen.dart';

void main() => runApp(const AlMubarakApp());

class AlMubarakApp extends StatelessWidget {
  const AlMubarakApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Al Mubarak Quotation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B5D3B),
          primary: const Color(0xFF0B5D3B),
        ),
        fontFamily: 'Roboto',
      ),
      home: const QuotationScreen(),
    );
  }
}
