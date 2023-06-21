import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sales_tracker/src/blocs/repository.dart';
import 'package:sales_tracker/src/models/sales_report.dart';
import 'package:sales_tracker/src/pages/widgets/report_page_widget.dart';
import 'package:sales_tracker/src/pages/widgets/sales_report_view.dart';
import 'package:sales_tracker/src/utils/generate_sales_report.dart';

class SalesReportPage extends StatelessWidget {
  static Future<void> display(BuildContext context) async {
    final navigator = Navigator.of(context, rootNavigator: true);

    DateTimeRange? range = await selectDateRange(
      context,
      'Generate Sales Report',
    );
    if (range == null) return;

    await navigator.push(
      MaterialPageRoute(
        maintainState: true,
        fullscreenDialog: false,
        builder: (context) => SalesReportPage(range.start, range.end),
      ),
    );
  }

  final DateTime start;
  final DateTime end;

  SalesReportPage(this.start, this.end);

  @override
  Widget build(BuildContext context) {
    return ReportPageWidget<SalesReport>(
      startDate: start,
      endDate: end,
      titleText: 'Sales Report',
      fetchFailureText: 'Could not fetch sales records',
      onGenerateReport: generateSalesReport,
      onGetReportStream: () =>
          Repository.of(context).getSalesReport(start, end),
      reportViewBuilder: (report) => SalesReportView(report),
      onGetReportFileName: (report) {
        final formatter = DateFormat('yyyy-MM-dd');
        final startStr = formatter.format(start);
        final endStr = formatter.format(end);
        return 'Sales_${startStr}_$endStr.pdf';
      },
    );
  }
}
