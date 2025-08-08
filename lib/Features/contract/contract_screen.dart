import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:safetyZone/core/localization/app_localizations.dart';
import 'package:safetyZone/core/utils/constants/colors.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

class ContractScreen extends StatefulWidget {
  const ContractScreen({super.key});

  @override
  State<ContractScreen> createState() => _ContractScreenState();
}

class _ContractScreenState extends State<ContractScreen> {
  final GlobalKey contractFirstKey = GlobalKey();
  final GlobalKey contractSecondKey = GlobalKey();
  bool _isFirstVisit = true;
  late pw.ImageProvider imageProvider1;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final List<List<String>> dataRight = [
      [t.translate("emergencyExit"), '5'],
      [t.translate("backupLight"), '5'],
      [t.translate("fireExtinguisher"), '5'],
      [t.translate("fireBox"), '5'],
      [t.translate("zoneControlPanel"), '5'],
    ];
    final List<List<String>> dataLeft = [
      [t.translate("zoneControlPanel"), '5'],
      [t.translate("smokeDetector"), '5'],
      [t.translate("heatDetector"), '5'],
      [t.translate("alarmBell"), '5'],
      [t.translate("glassBreaker"), '5'],
    ];
    final List<List<String>> rows = [
      [
        t.translate("firstVisit"),
        '22-12-2024',
        t.translate("secondVisit"),
        '22-12-2024'
      ],
      [
        t.translate("thirdVisit"),
        '13-12-2024',
        t.translate("fourthVisit"),
        '22-12-2024'
      ],
      [
        t.translate("fifthVisit"),
        '22-12-2024',
        t.translate("sixthVisit"),
        '22-12-2024'
      ],
      [
        t.translate("contractValue"),
        '500 ${t.translate("currency")}',
        t.translate("emergencyVisitValue"),
        '200 ${t.translate("currency")}'
      ],
    ];
    final List<List<String>> rowsinfo = [
      [
        t.translate("party1"),
        "أحمد خالد صالح الصالح",
        "12345678901234",
        t.translate("signature")
      ],
      [
        t.translate("party2"),
        "أحمد خالد صالح الصالح",
        "12345678901234",
        t.translate("signature")
      ],
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RepaintBoundary(
                  key: contractFirstKey,
                  child: Visibility(
                    visible: _isFirstVisit,
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            t.translate("electronic_contract"),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: CColors.secondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t.translate("maintenance_contract"),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Image.asset(
                            'assets/images/contract.png',
                            width: double.infinity,
                            height: 90,
                            fit: BoxFit.fill,
                          ),
                          SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            color: CColors.secondary,
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              t.translate("party_info"),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                  child: _buildSectionHeader(
                                      AppLocalizations.of(context)
                                          .translate('first_party'))),
                              Expanded(
                                  child: _buildSectionHeader(
                                      AppLocalizations.of(context)
                                          .translate('second_party'))),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: _buildInfoRow(
                                      AppLocalizations.of(context)
                                          .translate('company_name'),
                                      'معرض الحياة لمستحضرات التجميل')),
                              Expanded(
                                  child: _buildInfoRow(
                                      AppLocalizations.of(context)
                                          .translate('service_provider'),
                                      'شركة احمد خالد صالح')),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: _buildInfoRow(
                                      isColor: false,
                                      AppLocalizations.of(context)
                                          .translate('branch_name'),
                                      'معرض الحياة لمستحضرات التجميل')),
                              Expanded(
                                  child: _buildInfoRow(
                                      isColor: false,
                                      AppLocalizations.of(context)
                                          .translate('license_number'),
                                      '24')),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: _buildInfoRow(
                                      AppLocalizations.of(context)
                                          .translate('commercial_registration'),
                                      '23')),
                              Expanded(
                                  child: _buildInfoRow(
                                      AppLocalizations.of(context)
                                          .translate('commercial_registration'),
                                      '23')),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  flex: 4,
                                  child: _buildInfoRow(
                                      isColor: false,
                                      AppLocalizations.of(context)
                                          .translate('branch_area'),
                                      '130 م')),
                              Expanded(
                                  flex: 3,
                                  child: _buildInfoRow(
                                      isColor: false,
                                      AppLocalizations.of(context)
                                          .translate('number_of_visits'),
                                      '6')),
                              Expanded(
                                flex: 5,
                                child: _buildInfoRow(
                                    isColor: false,
                                    AppLocalizations.of(context)
                                        .translate('visit_value'),
                                    '500'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            color: CColors.secondary,
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              t.translate("branch_quantities"),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left Table
                                _buildCustomTable(dataLeft, t),
                                const SizedBox(width: 8),
                                // Right Table
                                _buildCustomTable(dataRight, t),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_isFirstVisit) ...[
                  const SizedBox(height: 32),
                  InkWell(
                    onTap: () async {
                      // _generatePDF(contractFirstKey,isSave: false);

                      // Capture first part
                      RenderRepaintBoundary boundary1 =
                          contractFirstKey.currentContext!.findRenderObject()
                              as RenderRepaintBoundary;
                      if (boundary1 == null) {
                        throw Exception("First boundary not rendered");
                      }
                      if (boundary1.size.isEmpty) {
                        throw Exception("First image has empty dimensions");
                      }

                      ui.Image image1 =
                          await boundary1.toImage(pixelRatio: 3.0);
                      ByteData? byteData1 = await image1.toByteData(
                          format: ui.ImageByteFormat.png);
                      if (byteData1 == null) {
                        throw Exception("First image ByteData is null");
                      }

                      Uint8List pngBytes1 = byteData1.buffer.asUint8List();
                      imageProvider1 = pw.MemoryImage(pngBytes1);
                      await Future.delayed(const Duration(milliseconds: 300));
                      setState(() {
                        _isFirstVisit = false;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: CColors.secondary,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Text(
                        t.translate("next"),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 32),
                RepaintBoundary(
                  key: contractSecondKey,
                  child: Visibility(
                    visible: !_isFirstVisit,
                    child: Center(
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            color: CColors.secondary,
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              t.translate("scheduleTitle"),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Table(
                            border:
                                TableBorder.all(color: Colors.grey, width: 0),
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(2),
                              2: FlexColumnWidth(2),
                              3: FlexColumnWidth(2),
                            },
                            children: rows.map((row) {
                              return TableRow(
                                children: row.map((cell) {
                                  return Container(
                                    color: cell == t.translate("firstVisit") ||
                                            cell ==
                                                t.translate("fourthVisit") ||
                                            cell == t.translate("sixthVisit") ||
                                            cell ==
                                                t.translate("secondVisit") ||
                                            cell == t.translate("thirdVisit") ||
                                            cell == t.translate("fifthVisit") ||
                                            cell ==
                                                t.translate("contractValue") ||
                                            cell ==
                                                t.translate(
                                                    "emergencyVisitValue")
                                        ? const Color(0xFFEFF6F7)
                                        : cell == t.translate("empty")
                                            ? const Color(0xFFF6F6F6)
                                            : Colors.white,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      cell,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: cell ==
                                                    t.translate("firstVisit") ||
                                                cell ==
                                                    t.translate(
                                                        "secondVisit") ||
                                                cell ==
                                                    t.translate("thirdVisit") ||
                                                cell ==
                                                    t.translate(
                                                        "fourthVisit") ||
                                                cell ==
                                                    t.translate("fifthVisit") ||
                                                cell ==
                                                    t.translate("sixthVisit") ||
                                                cell ==
                                                    t.translate(
                                                        "contractValue") ||
                                                cell ==
                                                    t.translate(
                                                        "emergencyVisitValue")
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            color: CColors.secondary,
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              t.translate("terms_party_one"),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "The parties agree to the following terms and conditions: "
                            "The parties agree to the following terms and conditions: "
                            "The parties agree to the following terms and conditions: ",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            color: CColors.secondary,
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              t.translate("terms_party_two"),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "The parties agree to the following terms and conditions: "
                            "The parties agree to the following terms and conditions: "
                            "The parties agree to the following terms and conditions: ",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            color: CColors.secondary,
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              t.translate("general_terms"),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "The parties agree to the following terms and conditions: "
                            "The parties agree to the following terms and conditions: "
                            "The parties agree to the following terms and conditions: ",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Table(
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            border: TableBorder.all(color: Colors.transparent),
                            columnWidths: const {
                              0: FlexColumnWidth(3),
                              1: FlexColumnWidth(3),
                              2: FlexColumnWidth(3),
                              3: FlexColumnWidth(3),
                            },
                            children: rowsinfo.map((row) {
                              return TableRow(
                                children: List.generate(
                                  row.length,
                                  (index) {
                                    final cell = row[index];
                                    final isSideTitle = index == 0;
                                    return Center(
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: isSideTitle
                                              ? CColors.secondary
                                              : Colors.white,
                                          border: Border.all(
                                            color: CColors.secondary,
                                            width: 1,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 8,
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 4,
                                          horizontal: 4,
                                        ),
                                        child: Text(
                                          cell,
                                          style: TextStyle(
                                            color: isSideTitle
                                                ? Colors.white
                                                : CColors.black,
                                            fontWeight: isSideTitle
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _isFirstVisit
          ? null
          : FloatingActionButton(
              onPressed: () => _generatePDF(context: context),
              child: Icon(Icons.picture_as_pdf),
            ),
    );
  }

  Widget _buildCustomTable(List<List<String>> data, t) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              _buildCell(
                t.translate("itemName"),
                isHeader: true,
                width: 110,
              ),
              _buildCell(
                t.translate("quantity"),
                isHeader: true,
                width: 60,
              ),
            ],
          ),
          // Data Rows with alternating colors
          ...List.generate(data.length, (rowIndex) {
            final row = data[rowIndex];
            final isColored = rowIndex % 2 == 0;

            return Row(
              children: List.generate(
                row.length,
                (cellIndex) {
                  final cell = row[cellIndex];
                  return _buildCell(
                    cell,
                    width: cellIndex == 0 ? 100 : 60,
                    isColor: isColored,
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCell(
    String text, {
    bool isHeader = false,
    double width = 100,
    bool isColor = false,
  }) {
    final bool isNumber =
        double.tryParse(text) != null; // للتحقق إذا كان قيمة رقمية

    return Container(
      width: width,
      height: 25,
      alignment: isNumber ? Alignment.center : null,
      margin: isHeader
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent, width: 2),
        color: isColor ? const Color(0xFFF5F5F5) : null,
      ),
      child: Text(
        text,
        textAlign: isNumber ? TextAlign.center : TextAlign.start,
        style: TextStyle(
          fontSize: isHeader ? 13 : 11,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      color: CColors.secondary,
      height: 38,
      padding: EdgeInsets.all(6),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isColor = true}) {
    return Container(
      color: isColor ? Colors.grey[100] : null,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 11,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.black,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePDF({
    required BuildContext context,
  }) async {
    try {
      // Wait for rendering to complete
      await Future.delayed(Duration(milliseconds: 300));
      // Capture second part
      RenderRepaintBoundary boundary2 = contractSecondKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      if (boundary2 == null) throw Exception("Second boundary not rendered");
      if (boundary2.size.isEmpty) {
        throw Exception("Second image has empty dimensions");
      }

      ui.Image image2 = await boundary2.toImage(pixelRatio: 3.0);
      ByteData? byteData2 =
          await image2.toByteData(format: ui.ImageByteFormat.png);
      if (byteData2 == null) throw Exception("Second image ByteData is null");

      Uint8List pngBytes2 = byteData2.buffer.asUint8List();
      final imageProvider2 = pw.MemoryImage(pngBytes2);

      // Create PDF
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (_) => pw.Center(
              child: pw.Image(imageProvider1, fit: pw.BoxFit.contain)),
        ),
      );
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (_) => pw.Center(
              child: pw.Image(imageProvider2, fit: pw.BoxFit.contain)),
        ),
      );

      // Save
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/contract.pdf');
      await file.writeAsBytes(await pdf.save());
      await OpenFile.open(file.path);
    } catch (e) {
      debugPrint("PDF Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في إنشاء PDF: $e')),
      );
    }
  }
}
