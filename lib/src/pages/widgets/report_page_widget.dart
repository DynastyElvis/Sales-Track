import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:sales_tracker/src/models/report.dart';
import 'package:sales_tracker/src/pages/widgets/error_message.dart';
import 'package:sales_tracker/src/pages/widgets/future_loading.dart';

class ReportPageWidget<T extends Report> extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final String titleText;
  final String fetchFailureText;
  final Widget Function(T report) reportViewBuilder;
  final Stream<T> Function() onGetReportStream;
  final Future<Uint8List> Function(T report) onGenerateReport;
  final String Function(T report) onGetReportFileName;

  ReportPageWidget({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.titleText,
    required this.fetchFailureText,
    required this.onGetReportFileName,
    required this.onGetReportStream,
    required this.reportViewBuilder,
    required this.onGenerateReport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(titleText),
      ),
      body: StreamBuilder<T>(
        stream: onGetReportStream(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.active:
            case ConnectionState.done:
              if (snapshot.hasError || snapshot.data == null) {
                return ErrorMessage(
                  messageText: fetchFailureText,
                  errorDetails: snapshot.error,
                  onDismiss: () => Navigator.of(context).pop(),
                );
              }
              return Column(
                children: [
                  Expanded(child: reportViewBuilder(snapshot.data!)),
                  buildSaveAsPdfButton(context, snapshot.data!),
                ],
              );
          }
        },
      ),
    );
  }

  Widget buildSaveAsPdfButton(BuildContext context, T report) {
    if (report.totalUnits == 0) {
      return Container();
    }
    return ListTile(
      tileColor: Colors.green,
      title: Text('Save as PDF'),
      trailing: Icon(Icons.save_alt),
      onTap: () => _generatePdf(context, report),
    );
  }

  void _generatePdf(BuildContext context, T report) async {
    Uint8List? result = await showFutureLoading(
      context: context,
      future: onGenerateReport(report),
      loadingText: 'Generating PDF...',
      errorText: 'Failed to generate PDF',
    );
    print(result?.lengthInBytes);
    if (result == null) return;

    final fileName = onGetReportFileName(report);
    print(fileName);

    final filePath = await FlutterFileDialog.saveFile(
      params: SaveFileDialogParams(
        data: result,
        fileName: fileName,
        mimeTypesFilter: ['application/pdf'],
      ),
    );
    print(filePath);
  }
}

Future<DateTimeRange?> selectDateRange(
  BuildContext context,
  String saveButtonText,
) async {
  DateTime now = DateTime.now();
  DateTime startOfMonth = DateTime(now.year, now.month);
  DateTimeRange? range = await showDateRangePicker(
    context: context,
    saveText: saveButtonText,
    firstDate: DateTime(now.year - 10),
    lastDate: DateTime(now.year + 10).subtract(Duration(microseconds: 1)),
    initialDateRange: DateTimeRange(
      start: startOfMonth,
      end: DateTime.now(),
    ),
  );
  if (range == null) return null;

  var start = range.start;
  start = DateTime(start.year, start.month, start.day);

  var end = range.end;
  end = DateTime(end.year, end.month, end.day)
      .add(Duration(days: 1))
      .subtract(Duration(milliseconds: 1));

  return DateTimeRange(start: start, end: end);
}
