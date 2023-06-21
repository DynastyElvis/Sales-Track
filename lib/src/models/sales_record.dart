import 'package:sales_tracker/src/models/item.dart';
import 'package:sales_tracker/src/models/product.dart';
import 'package:sales_tracker/src/utils/formatters.dart';

export 'package:sales_tracker/src/models/item.dart';

class SalesRecord extends Item {
  late final String productId;
  late final String productName;
  late final double unitCost;
  late final double unitPrice;

  double get totalCost => quantity * unitCost;

  double get totalPrice => quantity * unitPrice;

  double get profit => totalPrice - totalCost;

  double get profitPerUnit => (totalPrice - totalCost) / quantity;

  SalesRecord({
    required Product product,
    required this.unitPrice,
    required int quantity,
    required DateTime date,
  })  : assert(product.id != null),
        productId = product.id!,
        productName = product.name,
        unitCost = product.unitCost,
        super(
          date: date,
          quantity: quantity,
        );

  SalesRecord.fromJson(String id, Map<String, dynamic> data)
      : super.fromJson(id, data) {
    productId = data.remove('product_id');
    productName = data.remove('product_name');
    unitCost = data.remove('buy_price') ?? 0;
    unitPrice = data.remove('sell_price') ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['product_id'] = productId;
    data['product_name'] = productName;
    data['buy_price'] = unitCost;
    data['sell_price'] = unitPrice;
    return data;
  }
}

extension SalesRecordFormat on SalesRecord {
  String get unitCostStr => formatCurrency(unitCost);

  String get unitPriceStr => formatCurrency(unitPrice);

  String get totalCostStr => formatCurrency(totalCost);

  String get totalPriceStr => formatCurrency(totalPrice);

  String get profitStr => formatCurrency(profit);

  String get profitPerUnitStr => formatCurrency(profitPerUnit);
}
