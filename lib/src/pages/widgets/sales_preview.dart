import 'package:flutter/material.dart';
import 'package:sales_tracker/src/models/product.dart';
import 'package:sales_tracker/src/models/sales_record.dart';

class SalesPreview extends StatelessWidget {
  final Product product;
  final SalesRecord record;

  SalesPreview({
    Key? key,
    required this.record,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildLabelRow('Date', record.dateStr),
          SizedBox(height: 5),
          buildLabelRow('Product', record.productName),
          SizedBox(height: 5),
          buildLabelRow('Product Cost', record.unitCostStr),
          SizedBox(height: 5),
          buildLabelRow('Available', '${product.availableUnits} ps.'),
          SizedBox(height: 5),
          buildLabelRow('Selling Price', record.unitPriceStr),
          SizedBox(height: 5),
          buildLabelRow('Sell Quantity', '${record.quantity} ps.'),
          Divider(),
          buildLabelRow('Total Cost', record.totalCostStr),
          SizedBox(height: 5),
          buildLabelRow('Total Price', record.totalPriceStr),
          SizedBox(height: 5),
          buildLabelRow('Profit per Unit', record.profitPerUnitStr),
          Divider(),
          buildLabelRow('Net Profit', record.profitStr),
        ],
      ),
    );
  }

  Widget buildLabelRow(String labelText, String valueText) {
    return Row(
      children: [
        Container(
          width: 100,
          child: Text(
            labelText,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              color: Colors.blueGrey[700],
            ),
          ),
        ),
        Text(' : '),
        Expanded(
          child: Text(
            valueText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
