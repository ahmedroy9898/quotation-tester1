import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'calculations.dart';
import 'pdf_generator.dart';

const _green = Color(0xFF0B5D3B);
const _gold = Color(0xFFFFD700);

class QuotationResultCard extends StatelessWidget {
  final QuotationResult result;
  const QuotationResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final r = result;
    final title = r.type == ConstructionType.grey
        ? 'Grey Structure Quotation'
        : 'Finishing Quotation';

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          color: _green,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(children: [
            Container(height: 2, color: _gold),
            const SizedBox(height: 10),
            const Text('AL MUBARAK ENGINEERING (PVT.) LIMITED',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Construction Quotation Calculator',
                style: TextStyle(color: _gold, fontSize: 11)),
            const SizedBox(height: 10),
            Container(height: 2, color: _gold),
            const SizedBox(height: 12),
            Text(title.toUpperCase(),
                style: const TextStyle(
                    color: _gold,
                    fontSize: 13,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(r.timestamp, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _heading('Cost Estimation'),
            _row('Plot Location', r.locationLabel),
            _row('Construction Type', r.type == ConstructionType.grey ? 'Grey Structure' : 'Finishing'),
            _row('Plot Area', '${_n(r.plotArea)} Marla'),
            _row('Depth from Road Level (NSL)', '${_n(r.depth)} ft'),
            _row('Covered Area', formatArea(r.coveredArea)),
            const Divider(thickness: 1.5, height: 24),
            _row(
              r.plotLocation == PlotLocation.other
                  ? 'Basic Rate (Per Sqft)'
                  : 'Basic Rate in ${r.locationLabel} (Per Sqft)',
              formatCurrency(r.basicRate),
            ),
            _row('Basic Cost', formatCurrency(r.basicCost), bold: true),
            if (_hasSpecial(r)) ...[
              const SizedBox(height: 10),
              _heading('Additional Cost — Special Conditions'),
              if (r.depthEffect > 0)
                _row(
                    'Depth Effect (${_n(r.depth)} × ${r.storey == StoreyType.single ? 150 : 75} = ${formatCurrency(r.depthEffect)}/Sqft)',
                    formatCurrency(r.depthEffect * r.coveredArea)),
              if (r.storey == StoreyType.single)
                _row('Single Storey Effect (${formatCurrency(r.storeyEffect)}/Sqft)',
                    formatCurrency(r.storeyEffect * r.coveredArea)),
              if (r.basementCost != null && r.basementCost! > 0)
                _row(
                    'Basement Effect (${formatArea(r.basementArea ?? 0)} @ ${formatCurrency(r.basementRate ?? 0)})',
                    formatCurrency(r.basementCost!)),
              if (r.plinthBeamCost != null && r.plinthBeamCost! > 0)
                _row('Plinth Beam Effect (@ ${formatCurrency(r.plinthBeamRate ?? 150)})',
                    formatCurrency(r.plinthBeamCost!)),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(12)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('TOTAL COST (TENTATIVE)',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.8)),
                Text(formatCurrency(r.totalCost),
                    style: const TextStyle(color: _gold, fontWeight: FontWeight.bold, fontSize: 17)),
              ]),
            ),
            const SizedBox(height: 10),
            const Text(
              '* This is a tentative quotation. Final cost may vary based on actual site conditions and material costs.',
              style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.black54),
            ),
          ]),
        ),
        Container(
          color: const Color(0xFFF3F4F6),
          padding: const EdgeInsets.all(10),
          child: Row(children: [
            Expanded(
              child: _actionBtn(
                icon: Icons.copy,
                label: 'Copy',
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: quotationToText(r)));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Quotation copied to clipboard')));
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _actionBtn(
                icon: Icons.share,
                label: 'Share',
                onTap: () => Share.share(quotationToText(r)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _actionBtn(
                icon: Icons.picture_as_pdf,
                label: 'PDF',
                filled: true,
                onTap: () => printOrSharePdf(r),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  static String _n(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  static bool _hasSpecial(QuotationResult r) =>
      r.depthEffect > 0 ||
      r.storey == StoreyType.single ||
      (r.basementCost != null && r.basementCost! > 0) ||
      (r.plinthBeamCost != null && r.plinthBeamCost! > 0);

  static Widget _heading(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t.toUpperCase(),
            style: const TextStyle(
                color: _green, fontWeight: FontWeight.bold, letterSpacing: 0.8, fontSize: 12)),
      );

  static Widget _row(String label, String value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
            child: Text(label,
                style: TextStyle(
                    color: bold ? Colors.black : Colors.black54,
                    fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13)),
          ),
          const SizedBox(width: 10),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: bold ? Colors.black : const Color(0xFF111827))),
        ]),
      );

  static Widget _actionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    return Material(
      color: filled ? _green : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: filled ? _green : const Color(0xFFE5E7EB)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 16, color: filled ? _gold : Colors.black87),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: filled ? _gold : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ]),
        ),
      ),
    );
  }
}
