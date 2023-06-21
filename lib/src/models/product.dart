import 'package:sales_tracker/src/models/item.dart';
import 'package:sales_tracker/src/utils/formatters.dart';

export 'package:sales_tracker/src/models/item.dart';

class Product extends Item {
  late final String name;
  late final double unitCost;
  late final int unitsSold;

  double get totalCost => quantity * unitCost;

  int get availableUnits => quantity - unitsSold;

  double get availableCost => availableUnits * unitCost;

  Product({
    required this.name,
    required this.unitCost,
    required int quantity,
    required DateTime date,
  })  : unitsSold = 0,
        super(
          date: date,
          quantity: quantity,
        );

  Product.fromJson(String id, Map<String, dynamic> data)
      : super.fromJson(id, data) {
    name = data.remove('name');
    unitCost = data.remove('unit_price');
    unitsSold = data.remove('units_sold') ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['name'] = name;
    data['unit_price'] = unitCost;
    data['units_sold'] = unitsSold;
    return data;
  }
}

extension ProductFormat on Product {
  String get unitsSoldStr => unitsSold.toString();

  String get availableUnitsStr => availableUnits.toString();

  String get unitCostStr => formatCurrency(unitCost);

  String get totalCostStr => formatCurrency(totalCost);

  String get availableCostStr => formatCurrency(availableCost);
}
