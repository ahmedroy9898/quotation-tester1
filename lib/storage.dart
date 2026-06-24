import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'calculations.dart';

const _key = 'last_quotation_v1';

Future<void> saveLastQuotation(QuotationResult r) async {
  final p = await SharedPreferences.getInstance();
  await p.setString(_key, jsonEncode(r.toJson()));
}

Future<QuotationResult?> loadLastQuotation() async {
  final p = await SharedPreferences.getInstance();
  final s = p.getString(_key);
  if (s == null) return null;
  try {
    return QuotationResult.fromJson(jsonDecode(s));
  } catch (_) {
    return null;
  }
}
