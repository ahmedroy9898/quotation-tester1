import 'package:flutter/material.dart';
import 'calculations.dart';
import 'result_card.dart';
import 'storage.dart';

const _green = Color(0xFF0B5D3B);
const _gold = Color(0xFFFFD700);

class QuotationScreen extends StatefulWidget {
  const QuotationScreen({super.key});
  @override
  State<QuotationScreen> createState() => _QuotationScreenState();
}

class _QuotationScreenState extends State<QuotationScreen> {
  ConstructionType type = ConstructionType.grey;
  final basicRate = TextEditingController();
  final plotArea = TextEditingController();
  final coveredArea = TextEditingController();
  final depth = TextEditingController(text: '0');
  StoreyType storey = StoreyType.single;
  YesNo basement = YesNo.no;
  YesNo plinth = YesNo.no;
  BasementKind basementKind = BasementKind.partial;
  final basementArea = TextEditingController();
  PlotLocation plotLocation = PlotLocation.bahria;
  final plotLocationCustom = TextEditingController();
  QuotationResult? result;
  final _resultKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final saved = await loadLastQuotation();
    if (saved == null || !mounted) return;
    setState(() {
      result = saved;
      type = saved.type;
      basicRate.text = _n(saved.basicRate);
      plotArea.text = _n(saved.plotArea);
      coveredArea.text = _n(saved.coveredArea);
      depth.text = _n(saved.depth);
      storey = saved.storey;
      basement = saved.basement;
      basementKind = saved.basementKind;
      if (saved.basementArea != null) basementArea.text = _n(saved.basementArea!);
      plinth = saved.plinthBeam;
      plotLocation = saved.plotLocation;
      if (saved.plotLocationCustom != null) plotLocationCustom.text = saved.plotLocationCustom!;
    });
  }

  String _n(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  void _generate() async {
    final br = double.tryParse(basicRate.text);
    final pa = double.tryParse(plotArea.text);
    final ca = double.tryParse(coveredArea.text);
    if (br == null || br <= 0 || pa == null || pa <= 0 || ca == null || ca <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill rate, plot area and covered area')));
      return;
    }
    if (basement == YesNo.yes) {
      final ba = double.tryParse(basementArea.text);
      if (ba == null || ba <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter basement covered area')));
        return;
      }
    }
    final res = calculateQuotation(QuotationInput(
      type: type,
      basicRate: br,
      plotArea: pa,
      coveredArea: ca,
      depth: double.tryParse(depth.text) ?? 0,
      storey: storey,
      basement: basement,
      basementKind: basementKind,
      basementArea: double.tryParse(basementArea.text) ?? 0,
      plinthBeam: plinth,
      plotLocation: plotLocation,
      plotLocationCustom: plotLocationCustom.text.trim().isEmpty ? null : plotLocationCustom.text.trim(),
    ));
    setState(() => result = res);
    await saveLastQuotation(res);
    Future.delayed(const Duration(milliseconds: 200), () {
      final ctx = _resultKey.currentContext;
      if (ctx != null) Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 350));
    });
  }

  void _reset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Reset?'),
        content: const Text('Clear all fields and results?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Reset')),
        ],
      ),
    );
    if (ok != true) return;
    setState(() {
      type = ConstructionType.grey;
      basicRate.clear();
      plotArea.clear();
      coveredArea.clear();
      depth.text = '0';
      storey = StoreyType.single;
      basement = YesNo.no;
      plinth = YesNo.no;
      basementKind = BasementKind.partial;
      basementArea.clear();
      plotLocation = PlotLocation.bahria;
      plotLocationCustom.clear();
      result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _header(),
            const SizedBox(height: 16),
            _formCard(),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _generate,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.description, color: _gold),
              label: const Text('Generate Quotation',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset Form'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
            if (result != null) ...[
              const SizedBox(height: 24),
              KeyedSubtree(key: _resultKey, child: QuotationResultCard(result: result!)),
            ],
            const SizedBox(height: 20),
            const Center(
              child: Text('© Al Mubarak Engineering (Pvt.) Limited',
                  style: TextStyle(fontSize: 11, color: Colors.black45)),
            ),
            const SizedBox(height: 12),
          ]),
        ),
      ),
    );
  }

  Widget _header() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(20)),
        child: Column(children: [
          Container(height: 2, color: _gold),
          const SizedBox(height: 14),
          Row(children: [
            Image.asset('assets/logo.png', width: 56, height: 56),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('AL MUBARAK ENGINEERING',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.4)),
                Text('(PVT.) LIMITED', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 12)),
                SizedBox(height: 3),
                Text('Construction Quotation Calculator', style: TextStyle(color: _gold, fontSize: 11)),
              ]),
            ),
          ]),
          const SizedBox(height: 14),
          Container(height: 2, color: _gold),
        ]),
      );

  Widget _formCard() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _heading('Project Information'),
          const SizedBox(height: 12),
          _label('Plot Location'),
          DropdownButtonFormField<PlotLocation>(
            value: plotLocation,
            isExpanded: true,
            decoration: _decoration(),
            items: PlotLocation.values
                .map((l) => DropdownMenuItem(value: l, child: Text(locationLabels[l]!)))
                .toList(),
            onChanged: (v) => setState(() => plotLocation = v!),
          ),
          if (plotLocation == PlotLocation.other) ...[
            const SizedBox(height: 8),
            TextField(
              controller: plotLocationCustom,
              decoration: _decoration(hint: 'Location'),
            ),
          ],
          const SizedBox(height: 16),
          _pill<ConstructionType>('Construction Type', ConstructionType.values,
              {ConstructionType.grey: 'Grey Structure', ConstructionType.finishing: 'Finishing'},
              type, (v) => setState(() => type = v)),
          const SizedBox(height: 16),
          _numField('Basic Rate per Sqft (Rs.)', basicRate, hint: 'e.g. 5000'),
          const SizedBox(height: 12),
          _numField('Plot Area (Marla)', plotArea, hint: 'e.g. 10'),
          const SizedBox(height: 12),
          _numField('Covered Area (Sqft)', coveredArea, hint: 'e.g. 2500'),
          const SizedBox(height: 12),
          _numField('Depth from Road Level (Feet)', depth),
          const Divider(height: 32),
          _heading('Structure Details'),
          const SizedBox(height: 12),
          _pill<StoreyType>('Number of Storeys', StoreyType.values,
              {StoreyType.single: 'Single', StoreyType.double: 'Double', StoreyType.triple: 'Triple'},
              storey, (v) => setState(() => storey = v)),
          const SizedBox(height: 12),
          _pill<YesNo>('Plinth Beam', YesNo.values,
              {YesNo.no: 'No', YesNo.yes: 'Yes'}, plinth, (v) => setState(() => plinth = v)),
          const SizedBox(height: 12),
          _pill<YesNo>('Basement', YesNo.values,
              {YesNo.no: 'No', YesNo.yes: 'Yes'}, basement, (v) => setState(() => basement = v)),
          if (basement == YesNo.yes) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                _pill<BasementKind>('Basement Type', BasementKind.values,
                    {BasementKind.partial: 'Partial', BasementKind.full: 'Full'},
                    basementKind, (v) => setState(() => basementKind = v)),
                const SizedBox(height: 12),
                _numField('Basement Covered Area (Sqft)', basementArea, hint: 'e.g. 1000'),
              ]),
            ),
          ],
        ]),
      );

  Widget _heading(String t) => Text(t.toUpperCase(),
      style: const TextStyle(
          color: _green, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.8));

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      );

  InputDecoration _decoration({String? hint}) => InputDecoration(
        hintText: hint,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      );

  Widget _numField(String label, TextEditingController c, {String? hint}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _label(label),
        TextField(
          controller: c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: _decoration(hint: hint ?? '0'),
        ),
      ]);

  Widget _pill<T>(String label, List<T> options, Map<T, String> labels, T value,
          ValueChanged<T> onChange) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _label(label),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((o) {
            final active = o == value;
            return GestureDetector(
              onTap: () => onChange(o),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: active ? _green : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: active ? _green : const Color(0xFFD1D5DB)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active ? _gold : Colors.transparent,
                      border: Border.all(color: active ? _gold : Colors.black26),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(labels[o]!,
                      style: TextStyle(
                          color: active ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                ]),
              ),
            );
          }).toList(),
        ),
      ]);
}
