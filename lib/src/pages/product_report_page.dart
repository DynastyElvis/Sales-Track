import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sales_tracker/src/blocs/repository.dart';
import 'package:sales_tracker/src/models/product_report.dart';
import 'package:sales_tracker/src/pages/widgets/product_report_view.dart';
import 'package:sales_tracker/src/pages/widgets/report_page_widget.dart';
import 'package:sales_tracker/src/utils/generate_product_report.dart';

class ProductReportPage extends StatelessWidget {
  static Future<void> display(BuildContext context) async {
    final navigator = Navigator.of(context, rootNavigator: true);

    DateTimeRange? range = await selectDateRange(
      context,
      'Generate Product Report',
    );
    if (range == null) return;

    await navigator.push(
      MaterialPageRoute(
        maintainState: true,
        fullscreenDialog: false,
        builder: (context) => ProductReportPage(range.start, range.end),
      ),
    );
  }

  final DateTime start;
  final DateTime end;

  ProductReportPage(this.start, this.end);

  @override
  Widget build(BuildContext context) {
    return ReportPageWidget<ProductReport>(
      startDate: start,
      endDate: end,
      titleText: 'Product Report',
      fetchFailureText: 'Could not fetch products',
      onGenerateReport: generateProductReport,
      onGetReportStream: () =>
          Repository.of(context).getProductReport(start, end),
      reportViewBuilder: (report) => ProductReportView(report),
      onGetReportFileName: (report) {
        final formatter = DateFormat('yyyy-MM-dd');
        final startStr = formatter.format(start);
        final endStr = formatter.format(end);
        return 'Products_${startStr}_$endStr.pdf';
      },
    );
  }
}
