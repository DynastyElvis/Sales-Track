import 'package:intl/intl.dart';

class Item {
  final String? id;
  late final int quantity;
  late final DateTime date;

  Item({
    required this.date,
    required this.quantity,
  }) : id = null;

  Item.fromJson(String id, Map<String, dynamic> data) : id = id {
    quantity = data.remove('quantity');
    date = DateTime.fromMillisecondsSinceEpoch(data.remove('date') ?? 0);
  }

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['quantity'] = quantity;
    data['date'] = date.millisecondsSinceEpoch;
    return data;
  }

  @override
  bool operator ==(Object other) {
    return other is Item && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

extension ItemFormat on Item {
  String get dateStr => DateFormat.yMMMd().format(date);

  String get quantityStr => quantity.toString();
}
