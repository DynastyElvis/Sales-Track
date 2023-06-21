import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:sales_tracker/src/models/sales_record.dart';
import 'package:sales_tracker/src/models/sales_report.dart';

Future<Uint8List> generateSalesReport(SalesReport report) async {
  final regularFont = await rootBundle.load('lib/res/RobotoSlab-Regular.ttf');
  final boldFont = await rootBundle.load('lib/res/RobotoSlab-Bold.ttf');

  final pdf = pw.Document(
    compress: true,
    title: 'Sales Report',
    subject: 'Sales Tracker',
    producer: 'https://github.com/dipu-bd/sales_tracker',
    theme: pw.ThemeData.withFont(
      base: pw.Font.ttf(regularFont),
      bold: pw.Font.ttf(boldFont),
      italic: pw.Font.ttf(regularFont),
      boldItalic: pw.Font.ttf(boldFont),
    ),
  );

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(50),
      build: (context) {
        return [
          buildHeader(report),
          buildSalesTable(report),
          pw.Divider(height: 20, thickness: 1, color: PdfColors.grey300),
          buildSummaryItem('Records', '${report.items.length} ps.'),
          buildSummaryItem('Total Units', '${report.totalUnits} ps.'),
          buildSummaryItem('Selling Price', report.totalPriceStr),
          buildSummaryItem('Production Cost', report.totalCostStr),
          pw.Divider(height: 20, thickness: 1, color: PdfColors.grey300),
          buildSummaryItem('Net Profit', report.profitStr),
        ];
      },
      header: (context) {
        return pw.Container();
      },
      footer: (context) {
        return pw.Container(
          alignment: pw.Alignment.center,
          padding: pw.EdgeInsets.only(top: 10),
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(
              color: PdfColors.grey600,
            ),
          ),
        );
      },
    ),
  );

  Uint8List data = await pdf.save();
  return data;
}

pw.Widget buildSalesTable(SalesReport report) {
  return pw.Table(
    children: [
      pw.TableRow(
        children: [
          buildHeadCell('Date'),
          buildHeadCell('Item Name'),
          buildHeadCell('Units'),
          buildHeadCell('Cost'),
          buildHeadCell('Price'),
          buildHeadCell('Profit'),
        ],
        decoration: pw.BoxDecoration(
          color: PdfColors.grey200,
        ),
      ),
      ...report.items.map(
        (record) => pw.TableRow(
          children: [
            buildItemCell(record.dateStr),
            buildItemCell(record.productName),
            buildItemCell(record.quantityStr),
            buildItemCell(record.totalCostStr),
            buildItemCell(record.totalPriceStr),
            buildItemCell(record.profitStr),
          ],
        ),
      ),
    ],
  );
}

pw.Widget buildHeader(SalesReport report) {
  return pw.Container(
      padding: pw.EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      margin: pw.EdgeInsets.only(bottom: 20),
      alignment: pw.Alignment.center,
      child: pw.Column(children: [
        pw.Text(
          'Sales Report',
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: 24.0,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          '${report.startTimeStr} ~ ${report.endTimeStr}',
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: 18.0,
            color: PdfColors.grey700,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ]));
}

pw.Widget buildHeadCell(String text) {
  return pw.Padding(
    padding: pw.EdgeInsets.all(5),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
      ),
    ),
  );
}

pw.Widget buildItemCell(String text) {
  return pw.Padding(
    padding: pw.EdgeInsets.all(5),
    child: pw.Text(
      text,
    ),
  );
}

pw.Widget buildSummaryItem(String label, String value) {
  return pw.Container(
    padding: pw.EdgeInsets.all(5),
    alignment: pw.Alignment.centerRight,
    child: pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(
          label,
          textAlign: pw.TextAlign.right,
        ),
        pw.Container(
          width: 100,
          child: pw.Text(
            value,
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
