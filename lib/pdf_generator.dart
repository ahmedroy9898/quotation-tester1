import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'calculations.dart';

const _green = PdfColor.fromInt(0xFF0B5D3B);
const _gold = PdfColor.fromInt(0xFFFFD700);
const _greenLight = PdfColor.fromInt(0xFFE8F0EC);
const _border = PdfColor.fromInt(0xFFC8D5CD);
const _text = PdfColor.fromInt(0xFF111827);
const _muted = PdfColor.fromInt(0xFF374151);
const _amber = PdfColor.fromInt(0xFF92400E);
const _amberBg = PdfColor.fromInt(0xFFFFFBEB);

Future<Uint8List> buildQuotationPdf(QuotationResult r) async {
  final doc = pw.Document();
  final logoBytes = await rootBundle.load('assets/logo.png');
  final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());

  final hasDepth = r.depthEffect > 0;
  final isSingle = r.storey == StoreyType.single;
  final hasPlinth = r.plinthBeamCost != null && r.plinthBeamCost! > 0;
  final hasBasement = r.basementCost != null && r.basementCost! > 0;
  final hasSpecial = hasDepth || isSingle || hasPlinth || hasBasement;
  final title = r.type == ConstructionType.grey
      ? 'GREY STRUCTURE QUOTATION'
      : 'FINISHING QUOTATION';

  final basicRateLabel = r.plotLocation == PlotLocation.other
      ? 'Basic Rate'
      : 'Basic Rate in ${r.locationLabel}';
  final depthMul = isSingle ? 150 : 75;

  final baseCost = r.basicRate * r.coveredArea +
      (r.basementArea != null ? (r.basicRate + 1200) * r.basementArea! : 0);
  final plinthCost = r.plinthBeamCost ?? 0;
  final extraCost = r.totalCost - baseCost - plinthCost;

  String factorLabel;
  if (hasDepth && isSingle) {
    factorLabel = 'Plot Depth & Single Storey';
  } else if (hasDepth) {
    factorLabel = 'Plot Depth';
  } else {
    factorLabel = 'Single Storey';
  }

  final stages = isSingle
      ? const [
          {'n': 'Foundation Excavation', 'p': 15},
          {'n': 'Foundation Lean/PCC (1:4:8)', 'p': 15},
          {'n': 'Bricks Work up to DPC', 'p': 18},
          {'n': 'Ground Floor Bricks Work', 'p': 20},
          {'n': 'Ground Floor Slab Pouring (Lanter)', 'p': 17},
          {'n': 'Floor PCC/Kacha', 'p': 6},
          {'n': 'Inner Plaster', 'p': 4},
          {'n': 'Outer Plaster', 'p': 4},
          {'n': 'Completion', 'p': 1},
        ]
      : const [
          {'n': 'Foundation Excavation', 'p': 8},
          {'n': 'Foundation Lean/PCC (1:4:8)', 'p': 7},
          {'n': 'Bricks Work up to DPC', 'p': 15},
          {'n': 'Ground Floor Bricks Work', 'p': 15},
          {'n': 'Ground Floor Slab Pouring (Lanter)', 'p': 11},
          {'n': 'First Floor Bricks Work', 'p': 15},
          {'n': 'First Floor Slab Pouring (Lanter)', 'p': 11},
          {'n': 'Inner Plaster – Ground Floor', 'p': 4},
          {'n': 'Inner Plaster – First Floor', 'p': 3},
          {'n': 'Floor PCC/Kacha', 'p': 4},
          {'n': 'Outer Plaster (2 sides)', 'p': 3},
          {'n': 'Outer Plaster (2 sides)', 'p': 3},
          {'n': 'Completion', 'p': 1},
        ];

  pw.Widget kv(String k, String v, {bool bold = false}) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Text(k,
                  style: pw.TextStyle(
                      fontSize: 9,
                      color: bold ? _green : _muted,
                      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
            ),
            pw.Text(v,
                style: pw.TextStyle(
                    fontSize: 9,
                    color: bold ? _green : _text,
                    fontWeight: pw.FontWeight.bold)),
          ],
        ),
      );

  pw.Widget boxHead(String t) => pw.Container(
        width: double.infinity,
        color: _green,
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: pw.Text(t,
            style: pw.TextStyle(
                color: _gold,
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                letterSpacing: 0.8)),
      );

  doc.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4.landscape,
    margin: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    build: (ctx) {
      return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
        // Header
        pw.Container(
          color: _green,
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: pw.Row(children: [
            pw.Container(width: 44, height: 44, child: pw.Image(logo)),
            pw.SizedBox(width: 10),
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('AL MUBARAK ENGINEERING (PVT.) LIMITED',
                  style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold)),
              pw.Text('Construction Quotation Calculator',
                  style: pw.TextStyle(color: PdfColors.white, fontSize: 9)),
            ]),
          ]),
        ),
        pw.Container(height: 2, color: _gold),
        pw.Container(
          color: _text,
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Text(title,
                style: pw.TextStyle(
                    color: _gold,
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 0.8)),
            pw.Text('Date & Time: ${r.timestamp}',
                style: pw.TextStyle(color: PdfColors.white, fontSize: 9)),
          ]),
        ),
        pw.SizedBox(height: 8),
        // Two columns
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          // Left stack
          pw.Expanded(
            child: pw.Column(children: [
              pw.Container(
                decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: _border, width: 1),
                    borderRadius: pw.BorderRadius.circular(6)),
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
                  boxHead('COST ESTIMATION'),
                  kv('Plot Location', r.locationLabel),
                  kv('Construction Type', r.type == ConstructionType.grey ? 'Grey Structure' : 'Finishing'),
                  kv('Plot Area', '${r.plotArea} Marla'),
                  kv('Depth from Road Level (NSL)', '${r.depth} ft'),
                  kv('Covered Area', formatArea(r.coveredArea)),
                  pw.Container(height: 2, color: _green, margin: const pw.EdgeInsets.symmetric(vertical: 2)),
                  kv(basicRateLabel, '${formatCurrency(r.basicRate)} / Sqft'),
                  kv('Basic Cost', formatCurrency(r.basicCost), bold: true),
                  if (hasDepth)
                    kv('Depth Effect (${r.depth} × $depthMul)', '${formatCurrency(r.depthEffect)} / Sqft'),
                  if (isSingle)
                    kv('Single Storey Effect', '${formatCurrency(r.storeyEffect)} / Sqft'),
                  if (hasSpecial) ...[
                    pw.Container(
                      width: double.infinity,
                      color: _greenLight,
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      child: pw.Text('ADDITIONAL COST — SPECIAL CONDITIONS',
                          style: pw.TextStyle(
                              color: _green, fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    ),
                    if (hasDepth)
                      kv('Depth Effect (${r.depth} × $depthMul = ${formatCurrency(r.depthEffect)}/Sqft)',
                          formatCurrency(r.depthEffect * r.coveredArea)),
                    if (isSingle)
                      kv('Single Storey Effect', formatCurrency(r.storeyEffect * r.coveredArea)),
                    if (hasBasement)
                      kv('Basement Effect (${formatArea(r.basementArea ?? 0)})',
                          formatCurrency(r.basementCost ?? 0)),
                    if (hasPlinth)
                      kv('Plinth Beam Effect', formatCurrency(plinthCost)),
                  ],
                  pw.Container(
                    color: _green,
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('TOTAL COST (TENTATIVE)',
                            style: pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold)),
                        pw.Text(formatCurrency(r.totalCost),
                            style: pw.TextStyle(
                                color: _gold,
                                fontSize: 11,
                                fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ),
                ]),
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: _border, width: 1),
                    borderRadius: pw.BorderRadius.circular(6)),
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
                  boxHead('MATERIAL BRANDS'),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                      pw.Expanded(
                        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                          for (final b in const [
                            'Awwal Brick',
                            'Best Way / Lucky / Flying Cement',
                            'Mughal Steel (60 grade)',
                            'Sargodha Plant Crush'
                          ])
                            pw.Text('• $b',
                                style: pw.TextStyle(
                                    fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: _text)),
                        ]),
                      ),
                      pw.Expanded(
                        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                          for (final b in const [
                            'Popular Pipe',
                            'Ravi Sand',
                            'Jisti 16 guage Door Frame',
                          ])
                            pw.Text('• $b',
                                style: pw.TextStyle(
                                    fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: _text)),
                        ]),
                      ),
                    ]),
                  ),
                ]),
              ),
            ]),
          ),
          pw.SizedBox(width: 12),
          // Right column — payment schedule
          pw.Expanded(
            child: pw.Container(
              decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: _border, width: 1),
                  borderRadius: pw.BorderRadius.circular(6)),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
                boxHead('PAYMENT SCHEDULE'),
                pw.Container(
                  color: _greenLight,
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: pw.Row(children: [
                    pw.Expanded(flex: 5, child: pw.Text('STAGE', style: pw.TextStyle(fontSize: 9, color: _green, fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(flex: 1, child: pw.Text('%', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 9, color: _green, fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(flex: 3, child: pw.Text('AMOUNT', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9, color: _green, fontWeight: pw.FontWeight.bold))),
                  ]),
                ),
                for (int i = 0; i < stages.length; i++) ...[
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
                    child: pw.Row(children: [
                      pw.Expanded(flex: 5, child: pw.Text(stages[i]['n'] as String, style: pw.TextStyle(fontSize: 9, color: _text))),
                      pw.Expanded(flex: 1, child: pw.Text('${stages[i]['p']}%', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 9, color: _muted))),
                      pw.Expanded(flex: 3, child: pw.Text(formatCurrency(((baseCost * (stages[i]['p'] as int)) / 100).round()), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
                    ]),
                  ),
                  if (stages[i]['n'] == 'Bricks Work up to DPC' && (hasDepth || isSingle))
                    pw.Container(
                      color: _amberBg,
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
                      child: pw.Row(children: [
                        pw.Expanded(flex: 5, child: pw.Text('$factorLabel Cost Effect', style: pw.TextStyle(fontSize: 9, color: _amber, fontWeight: pw.FontWeight.bold))),
                        pw.Expanded(flex: 1, child: pw.Text('—', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 9, color: _amber))),
                        pw.Expanded(flex: 3, child: pw.Text(formatCurrency(extraCost), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9, color: _amber, fontWeight: pw.FontWeight.bold))),
                      ]),
                    ),
                  if (stages[i]['n'] == 'Bricks Work up to DPC' && hasPlinth)
                    pw.Container(
                      color: _amberBg,
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
                      child: pw.Row(children: [
                        pw.Expanded(flex: 5, child: pw.Text('Plinth Beam Effect', style: pw.TextStyle(fontSize: 9, color: _amber, fontWeight: pw.FontWeight.bold))),
                        pw.Expanded(flex: 1, child: pw.Text('—', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 9, color: _amber))),
                        pw.Expanded(flex: 3, child: pw.Text(formatCurrency(plinthCost), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9, color: _amber, fontWeight: pw.FontWeight.bold))),
                      ]),
                    ),
                ],
                pw.Container(
                  color: _green,
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: pw.Row(children: [
                    pw.Expanded(flex: 5, child: pw.Text('Total', style: pw.TextStyle(color: PdfColors.white, fontSize: 10, fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(flex: 1, child: pw.Text('100%', textAlign: pw.TextAlign.center, style: pw.TextStyle(color: PdfColors.white, fontSize: 10, fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(flex: 3, child: pw.Text(formatCurrency(r.totalCost), textAlign: pw.TextAlign.right, style: pw.TextStyle(color: _gold, fontSize: 11, fontWeight: pw.FontWeight.bold))),
                  ]),
                ),
              ]),
            ),
          ),
        ]),
        pw.SizedBox(height: 8),
        // Terms & Conditions
        pw.Container(
          decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _border, width: 1),
              borderRadius: pw.BorderRadius.circular(6)),
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
            boxHead('TERMS & CONDITIONS'),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Expanded(
                  child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    _term('1. The work will start WITHOUT ADVANCE PAYMENT.', bold: true),
                    _term('2. The drawing/plan will be made FREE OF COST after the contract is signed.', bold: true),
                    _term('3. The owner will arrange the gate and safety grills, and the contractor will install them.'),
                    _term('4. The owner will be responsible for the termite spray.'),
                    _term('5. Plaster under the roof/ceiling is not included in this rate.'),
                    _term('6. The grey structure work of the covered area will take about five months, provided all stage payments are made on time.'),
                  ]),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    _term('7. Non-covered areas such as the boundary wall, street, and ramp are included in the contract and will not be charged separately.'),
                    _term('8. All water tanks will be counted twice in the covered area measurement.'),
                    _term('9. Plaster under the roofs/ceilings is not included in the contract.'),
                    _term('10. Double-height areas will be counted in the covered area measurement on both floors/slabs.'),
                    _term('11. Molding work is not included in the grey structure work.'),
                  ]),
                ),
              ]),
            ),
          ]),
        ),
        pw.SizedBox(height: 6),
        pw.Center(
          child: pw.Text(
            'Note: This is a tentative quotation. Final cost may vary based on actual site conditions and material costs.  |  Al Mubarak Engineering (Pvt.) Limited',
            style: pw.TextStyle(fontSize: 7, color: PdfColors.grey, fontStyle: pw.FontStyle.italic),
          ),
        ),
      ]);
    },
  ));

  return doc.save();
}

pw.Widget _term(String t, {bool bold = false}) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Text(t,
          style: pw.TextStyle(
              fontSize: 8.5,
              color: _text,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              lineSpacing: 1.2)),
    );

Future<void> printOrSharePdf(QuotationResult r) async {
  final bytes = await buildQuotationPdf(r);
  await Printing.layoutPdf(onLayout: (_) async => bytes);
}
