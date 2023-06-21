import 'package:sales_tracker/src/models/product.dart';
import 'package:sales_tracker/src/models/report.dart';
import 'package:sales_tracker/src/utils/formatters.dart';

export 'package:sales_tracker/src/models/report.dart';

class ProductReport extends Report<Product> {
  late final int totalSold;
  late final double totalCost;

  int get remainingUnits => totalUnits - totalSold;

  ProductReport({
    required DateTime startTime,
    required DateTime endTime,
    required List<Product> products,
  }) : super(
          startTime: startTime,
          endTime: endTime,
          items: products,
        ) {
    int sold = 0;
    double cost = 0;
    for (final item in products) {
      sold += item.unitsSold;
      cost += item.totalCost;
    }
    totalCost = cost;
    totalSold = sold;
  }
}

extension ProductReportFormat on ProductReport {
  String get totalCostStr => formatCurrency(totalCost);
}
