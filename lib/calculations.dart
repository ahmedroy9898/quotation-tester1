// Mirror of src/lib/calculations.ts — DO NOT change formulas.
import 'package:intl/intl.dart';

enum ConstructionType { grey, finishing }
enum StoreyType { single, double, triple }
enum YesNo { yes, no }
enum BasementKind { partial, full }
enum PlotLocation { bahria, dha, sialkot, islamabad, other }

const double plinthBeamRate = 150;

const Map<PlotLocation, String> locationLabels = {
  PlotLocation.bahria: 'Bahria Town, Lahore',
  PlotLocation.dha: 'DHA, Lahore',
  PlotLocation.sialkot: 'Sialkot',
  PlotLocation.islamabad: 'Islamabad',
  PlotLocation.other: 'Other',
};

class QuotationInput {
  final ConstructionType type;
  final double basicRate;
  final double plotArea;
  final double coveredArea;
  final double depth;
  final StoreyType storey;
  final YesNo basement;
  final BasementKind basementKind;
  final double basementArea;
  final YesNo plinthBeam;
  final PlotLocation plotLocation;
  final String? plotLocationCustom;

  QuotationInput({
    required this.type,
    required this.basicRate,
    required this.plotArea,
    required this.coveredArea,
    required this.depth,
    required this.storey,
    required this.basement,
    required this.basementKind,
    required this.basementArea,
    required this.plinthBeam,
    required this.plotLocation,
    this.plotLocationCustom,
  });
}

class QuotationResult {
  final ConstructionType type;
  final double basicRate;
  final double depthEffect;
  final double storeyEffect;
  final double adjustedRate;
  final double coveredArea;
  final double plotArea;
  final StoreyType storey;
  final YesNo basement;
  final BasementKind basementKind;
  final double depth;
  final double? basementRate;
  final double? basementArea;
  final double? basementCost;
  final YesNo plinthBeam;
  final double? plinthBeamRate;
  final double? plinthBeamCost;
  final double normalCost;
  final double totalCost;
  final String timestamp;
  final PlotLocation plotLocation;
  final String? plotLocationCustom;
  final String locationLabel;
  final double basicCost;

  QuotationResult({
    required this.type,
    required this.basicRate,
    required this.depthEffect,
    required this.storeyEffect,
    required this.adjustedRate,
    required this.coveredArea,
    required this.plotArea,
    required this.storey,
    required this.basement,
    required this.basementKind,
    required this.depth,
    required this.basementRate,
    required this.basementArea,
    required this.basementCost,
    required this.plinthBeam,
    required this.plinthBeamRate,
    required this.plinthBeamCost,
    required this.normalCost,
    required this.totalCost,
    required this.timestamp,
    required this.plotLocation,
    required this.plotLocationCustom,
    required this.locationLabel,
    required this.basicCost,
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'basicRate': basicRate,
        'depthEffect': depthEffect,
        'storeyEffect': storeyEffect,
        'adjustedRate': adjustedRate,
        'coveredArea': coveredArea,
        'plotArea': plotArea,
        'storey': storey.name,
        'basement': basement.name,
        'basementKind': basementKind.name,
        'depth': depth,
        'basementRate': basementRate,
        'basementArea': basementArea,
        'basementCost': basementCost,
        'plinthBeam': plinthBeam.name,
        'plinthBeamRate': plinthBeamRate,
        'plinthBeamCost': plinthBeamCost,
        'normalCost': normalCost,
        'totalCost': totalCost,
        'timestamp': timestamp,
        'plotLocation': plotLocation.name,
        'plotLocationCustom': plotLocationCustom,
        'locationLabel': locationLabel,
        'basicCost': basicCost,
      };

  static QuotationResult fromJson(Map<String, dynamic> j) => QuotationResult(
        type: ConstructionType.values.byName(j['type']),
        basicRate: (j['basicRate'] as num).toDouble(),
        depthEffect: (j['depthEffect'] as num).toDouble(),
        storeyEffect: (j['storeyEffect'] as num).toDouble(),
        adjustedRate: (j['adjustedRate'] as num).toDouble(),
        coveredArea: (j['coveredArea'] as num).toDouble(),
        plotArea: (j['plotArea'] as num).toDouble(),
        storey: StoreyType.values.byName(j['storey']),
        basement: YesNo.values.byName(j['basement']),
        basementKind: BasementKind.values.byName(j['basementKind']),
        depth: (j['depth'] as num).toDouble(),
        basementRate: (j['basementRate'] as num?)?.toDouble(),
        basementArea: (j['basementArea'] as num?)?.toDouble(),
        basementCost: (j['basementCost'] as num?)?.toDouble(),
        plinthBeam: YesNo.values.byName(j['plinthBeam']),
        plinthBeamRate: (j['plinthBeamRate'] as num?)?.toDouble(),
        plinthBeamCost: (j['plinthBeamCost'] as num?)?.toDouble(),
        normalCost: (j['normalCost'] as num).toDouble(),
        totalCost: (j['totalCost'] as num).toDouble(),
        timestamp: j['timestamp'],
        plotLocation: PlotLocation.values.byName(j['plotLocation']),
        plotLocationCustom: j['plotLocationCustom'],
        locationLabel: j['locationLabel'],
        basicCost: (j['basicCost'] as num).toDouble(),
      );
}

QuotationResult calculateQuotation(QuotationInput input) {
  final locationLabel = input.plotLocation == PlotLocation.other
      ? ((input.plotLocationCustom?.trim().isNotEmpty ?? false)
          ? input.plotLocationCustom!.trim()
          : 'Other')
      : locationLabels[input.plotLocation]!;

  double storeyEffect = 0;
  double depthEffect = 0;
  double adjustedRate = input.basicRate;

  if (input.storey == StoreyType.single) {
    storeyEffect = 600;
    depthEffect = 150 * input.depth;
  } else {
    depthEffect = 75 * input.depth;
  }

  if (input.basement == YesNo.yes && input.basementKind == BasementKind.full) {
    depthEffect = (depthEffect / 3).round().toDouble();
  }

  if (input.storey == StoreyType.single) {
    adjustedRate = input.basicRate + storeyEffect + depthEffect;
  } else {
    adjustedRate = input.basicRate + depthEffect;
  }

  double? basementRateVal;
  double? basementAreaVal;
  double? basementCostVal;
  final normalCost = adjustedRate * input.coveredArea;
  double totalCost = normalCost;

  if (input.basement == YesNo.yes && input.basementArea > 0) {
    basementRateVal = input.basicRate + 1200;
    basementAreaVal = input.basementArea;
    basementCostVal = basementRateVal * input.basementArea;
    totalCost += basementCostVal;
  }

  double? plinthBeamRateVal;
  double? plinthBeamCostVal;
  if (input.plinthBeam == YesNo.yes) {
    plinthBeamRateVal = plinthBeamRate;
    plinthBeamCostVal = plinthBeamRate * input.coveredArea;
    totalCost += plinthBeamCostVal;
  }

  final ts = DateFormat('d/M/y, h:mm:ss a').format(DateTime.now());

  return QuotationResult(
    type: input.type,
    basicRate: input.basicRate,
    depthEffect: depthEffect,
    storeyEffect: storeyEffect,
    adjustedRate: adjustedRate,
    coveredArea: input.coveredArea,
    plotArea: input.plotArea,
    storey: input.storey,
    basement: input.basement,
    basementKind: input.basementKind,
    depth: input.depth,
    basementRate: basementRateVal,
    basementArea: basementAreaVal,
    basementCost: basementCostVal,
    plinthBeam: input.plinthBeam,
    plinthBeamRate: plinthBeamRateVal,
    plinthBeamCost: plinthBeamCostVal,
    normalCost: normalCost,
    totalCost: totalCost,
    timestamp: ts,
    plotLocation: input.plotLocation,
    plotLocationCustom: input.plotLocationCustom,
    locationLabel: locationLabel,
    basicCost: input.basicRate * input.coveredArea,
  );
}

final NumberFormat _intFmt = NumberFormat('#,##0', 'en_PK');

String formatCurrency(num amount) => 'Rs. ${_intFmt.format(amount)}';
String formatArea(num area) => '${_intFmt.format(area)} Sqft';
String _trimNum(double v) {
  if (v == v.roundToDouble()) return v.toStringAsFixed(0);
  return v.toString();
}

String quotationToText(QuotationResult r) {
  final title =
      r.type == ConstructionType.grey ? 'Grey Structure Quotation' : 'Finishing Quotation';
  final typeLabel = r.type == ConstructionType.grey ? 'Grey Structure' : 'Finishing';
  final buf = StringBuffer();
  buf.writeln(title);
  buf.writeln('─' * 32);
  buf.writeln();
  buf.writeln('Plot Location: ${r.locationLabel}');
  buf.writeln();
  buf.writeln('Construction Type: $typeLabel');
  buf.writeln();
  buf.writeln('Plot Area: ${_trimNum(r.plotArea)} Marla');
  buf.writeln();
  buf.writeln('Depth from Road Level (NSL): ${_trimNum(r.depth)} ft');
  buf.writeln();
  buf.writeln('Covered Area: ${formatArea(r.coveredArea)}');
  buf.writeln();
  buf.writeln('─' * 34);
  buf.writeln();
  final basicRateLabel = r.plotLocation == PlotLocation.other
      ? 'Basic Rate (Per Sqft)'
      : 'Basic Rate in ${r.locationLabel} (Per Sqft)';
  buf.writeln('$basicRateLabel: ${formatCurrency(r.basicRate)}');
  buf.writeln();
  buf.writeln('Basic Cost:  ${formatCurrency(r.basicCost)}');
  buf.writeln();

  final hasDepth = r.depthEffect > 0;
  final isSingle = r.storey == StoreyType.single;
  final hasBasement = r.basementCost != null && r.basementCost! > 0;
  final hasPlinth = r.plinthBeamCost != null && r.plinthBeamCost! > 0;

  if (hasDepth || isSingle || hasBasement || hasPlinth) {
    buf.writeln('Additional Cost — Special Conditions');
    buf.writeln();
    if (hasDepth) {
      final mult = isSingle ? 150 : 75;
      buf.writeln(
          'Depth Effect (${_trimNum(r.depth)} × $mult = ${formatCurrency(r.depthEffect)}/Sqft): ${formatCurrency(r.depthEffect * r.coveredArea)}');
      buf.writeln();
    }
    if (isSingle) {
      buf.writeln(
          'Single Storey Effect (${formatCurrency(r.storeyEffect)}/Sqft): ${formatCurrency(r.storeyEffect * r.coveredArea)}');
      buf.writeln();
    }
    if (hasBasement) {
      buf.writeln(
          'Basement Effect (${formatArea(r.basementArea ?? 0)} @ ${formatCurrency(r.basementRate ?? 0)}): ${formatCurrency(r.basementCost ?? 0)}');
      buf.writeln();
    }
    if (hasPlinth) {
      buf.writeln(
          'Plinth Beam Effect (@ ${formatCurrency(r.plinthBeamRate ?? 150)}): ${formatCurrency(r.plinthBeamCost ?? 0)}');
      buf.writeln();
    }
  }

  buf.writeln('_' * 34);
  buf.writeln();
  buf.write('Total Cost (Tentative): ${formatCurrency(r.totalCost)}');
  return buf.toString();
}
