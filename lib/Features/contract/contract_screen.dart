import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:safetyZone/core/localization/app_localizations.dart';
import 'package:safetyZone/core/utils/constants/colors.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class ContractScreen extends StatefulWidget {
  const ContractScreen({super.key});

  @override
  State<ContractScreen> createState() => _ContractScreenState();
}

class _ContractScreenState extends State<ContractScreen> {
  final GlobalKey _contractKey = GlobalKey();

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
          child: RepaintBoundary(
            key: _contractKey,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    t.translate("electronic_contract"),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.translate("maintenance_contract"),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Image.asset(
                    'assets/images/contract.png',
                    width: double.infinity,
                    height: 110,
                    fit: BoxFit.fill,
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    color: Colors.blue[900],
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      t.translate("party_info"),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
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
                              AppLocalizations.of(context)
                                  .translate('branch_name'),
                              'معرض الحياة لمستحضرات التجميل')),
                      Expanded(
                          child: _buildInfoRow(
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
                              AppLocalizations.of(context)
                                  .translate('branch_area'),
                              '130 م')),
                      Expanded(
                          flex: 3,
                          child: _buildInfoRow(
                              AppLocalizations.of(context)
                                  .translate('number_of_visits'),
                              '6')),
                      Expanded(
                        flex: 5,
                        child: _buildInfoRow(
                            AppLocalizations.of(context)
                                .translate('visit_value'),
                            '500'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    color: Colors.blue[900],
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      t.translate("branch_quantities"),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Expanded removed here
                        DataTable(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[100]!),
                          ),
                          border: TableBorder.all(
                            color: Colors.white,
                            width: 4,
                          ),
                          dividerThickness: 0,
                          columnSpacing: 24,
                          horizontalMargin: 10,
                          dataRowMaxHeight: 50,
                          dataRowMinHeight: 50,
                          headingRowHeight: 50,
                          columns: [
                            DataColumn(
                              label:
                                  Center(child: Text(t.translate("itemName"))),
                            ),
                            DataColumn(
                              label: Center(
                                child: Text(
                                  t.translate("quantity"),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                          rows: dataLeft
                              .map(
                                (row) => DataRow(
                                  cells: row
                                      .map((cell) => DataCell(Text(cell)))
                                      .toList(),
                                ),
                              )
                              .toList(),
                        ),
                        DataTable(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[100]!),
                          ),
                          border: TableBorder.all(
                            color: Colors.white,
                            width: 4,
                          ),
                          dividerThickness: 0,
                          columnSpacing: 24,
                          horizontalMargin: 10,
                          dataRowMaxHeight: 50,
                          dataRowMinHeight: 50,
                          headingRowHeight: 50,
                          columns: [
                            DataColumn(label: Text(t.translate("itemName"))),
                            DataColumn(label: Text(t.translate("quantity"))),
                          ],
                          rows: dataRight
                              .map(
                                (row) => DataRow(
                                  cells: row
                                      .map((cell) => DataCell(Text(cell)))
                                      .toList(),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    color: Colors.blue[900],
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      t.translate("scheduleTitle"),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Table(
                    border: TableBorder.all(color: Colors.grey, width: 0),
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
                                    cell == t.translate("thirdVisit") ||
                                    cell == t.translate("fifthVisit") ||
                                    cell == t.translate("contractValue") ||
                                    cell == t.translate("emergencyVisitValue")
                                ? const Color(0xFFEFF6F7)
                                : cell == t.translate("empty")
                                    ? const Color(0xFFF6F6F6)
                                    : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              cell,
                              textAlign: TextAlign.center,
                            ),
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    color: Colors.blue[900],
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      t.translate("terms_party_one"),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    color: Colors.blue[900],
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      t.translate("terms_party_two"),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    color: Colors.blue[900],
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      t.translate("general_terms"),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Table(
                    border: TableBorder.all(color: Colors.blue.shade900),
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(3),
                      2: FlexColumnWidth(3),
                      3: FlexColumnWidth(2),
                    },
                    children: rowsinfo.map((row) {
                      return TableRow(
                        children: List.generate(row.length, (index) {
                          final cell = row[index];
                          final isSideTitle = index == 0;
                          return Container(
                            color:
                                isSideTitle ? Colors.blue[900] : Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 8),
                            child: Text(
                              cell,
                              style: TextStyle(
                                color: isSideTitle
                                    ? Colors.white
                                    : Colors.blue[900],
                                fontWeight: isSideTitle
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _captureAndSavePDF,
        child: Icon(Icons.picture_as_pdf),
      ),
    );
  }

  Future<void> _captureAndSavePDF() async {
    try {
      // اطلب صلاحية الوصول للتخزين (Android)
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Permission denied")),
          );
          return;
        }
      }

      RenderRepaintBoundary boundary =
      _contractKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);

      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();

      final pdf = pw.Document();
      final imageProvider = pw.MemoryImage(pngBytes);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(child: pw.Image(imageProvider));
          },
        ),
      );

      // المسار إلى مجلد التنزيلات
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else {
        downloadsDir = await getApplicationDocumentsDirectory(); // iOS
      }

      final filePath = "${downloadsDir.path}/contract_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PDF saved to: $filePath")),
      );
    } catch (e) {
      print("Error saving PDF: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving PDF")),
      );
    }
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      color: Colors.blue[900],
      height: 46,
      padding: EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          title,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      color: Colors.grey[100],
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 13,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.black,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
