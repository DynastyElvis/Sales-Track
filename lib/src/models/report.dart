import 'package:intl/intl.dart';
import 'package:sales_tracker/src/models/item.dart';

class Report<T extends Item> {
  final DateTime startTime;
  final DateTime endTime;
  final List<T> items;
  final Map<DateTime, List<T>> groups = {};
  late final int totalUnits;

  Report({
    required this.items,
    required this.endTime,
    required this.startTime,
  }) {
    items.sort(
      (a, b) => a.date.compareTo(b.date),
    );

    int total = 0;
    for (T item in items) {
      total += item.quantity;
      DateTime group = DateTime(
        item.date.year,
        item.date.month,
        item.date.day,
      );
      groups.putIfAbsent(group, () => []);
      groups[group]!.add(item);
    }
    totalUnits = total;
  }
}

extension ReportFormat on Report {
  String get startTimeStr => DateFormat.yMMMd().format(startTime);

  String get endTimeStr => DateFormat.yMMMd().format(endTime);
}
