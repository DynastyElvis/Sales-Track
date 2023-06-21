import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sales_tracker/src/blocs/repository.dart';
import 'package:sales_tracker/src/models/product.dart';
import 'package:sales_tracker/src/models/sales_record.dart';
import 'package:sales_tracker/src/pages/widgets/error_message.dart';
import 'package:sales_tracker/src/pages/widgets/sales_preview.dart';

class SaleFormDialog extends StatelessWidget {
  static void display(BuildContext context, Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        maintainState: true,
        fullscreenDialog: true,
        builder: (_) => SaleFormDialog(product),
      ),
    );
  }

  static final _dateFormatter = DateFormat.yMMMEd();

  final Product product;
  late final TextEditingController dateInput;
  late final TextEditingController unitPriceInput;
  late final TextEditingController quantityInput;

  SaleFormDialog(this.product) {
    final now = DateTime.now();
    unitPriceInput = TextEditingController();
    quantityInput = TextEditingController();
    dateInput = TextEditingController(text: _dateFormatter.format(now));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Sell Product'),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: Colors.black12,
                child: Icon(
                  Icons.shopping_cart,
                  color: Colors.teal,
                  size: 48,
                ),
              ),
              SizedBox(height: 25),
              Builder(builder: buildDateInput),
              Builder(builder: buildUnitPriceInput),
              Builder(builder: buildQuantityInput),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _submitItem(context),
          child: Icon(Icons.send),
        ),
      ),
    );
  }

  Widget buildDateInput(BuildContext context) {
    final year = DateTime.now().year;
    return TextField(
      controller: dateInput,
      keyboardType: TextInputType.datetime,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Date',
        suffixIcon: Icon(Icons.calendar_today),
      ),
      inputFormatters: [
        TextInputFormatter.withFunction((old, _) => old),
      ],
      onTap: () {
        showDatePicker(
          context: context,
          fieldLabelText: 'Date',
          firstDate: DateTime(year - 10),
          lastDate: DateTime(year + 10).subtract(Duration(microseconds: 1)),
          initialDate: DateTime.now(),
        ).then((DateTime? value) {
          if (value != null) {
            dateInput.text = _dateFormatter.format(value);
          }
        });
      },
    );
  }

  Widget buildUnitPriceInput(BuildContext context) {
    return TextField(
      controller: unitPriceInput,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Selling Price Per Unit',
        helperText: 'Cost per unit is ${product.unitCostStr}',
      ),
      onEditingComplete: () {
        FocusScope.of(context).nextFocus();
      },
      inputFormatters: [
        LengthLimitingTextInputFormatter(20),
        TextInputFormatter.withFunction(
          (oldVal, newVal) =>
              newVal.text.isEmpty || double.tryParse(newVal.text) != null
                  ? newVal
                  : oldVal,
        ),
      ],
    );
  }

  Widget buildQuantityInput(BuildContext context) {
    return TextField(
      controller: quantityInput,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Item Quantity',
        helperText: '${product.availableUnits} items available',
      ),
      onSubmitted: (_) {
        FocusScope.of(context).nextFocus();
      },
      inputFormatters: [
        LengthLimitingTextInputFormatter(10),
        TextInputFormatter.withFunction(
          (oldVal, newVal) =>
              newVal.text.isEmpty || int.tryParse(newVal.text) != null
                  ? newVal
                  : oldVal,
        ),
      ],
    );
  }

  void _submitItem(BuildContext context) async {
    // data
    DateTime date;
    double? unitPrice = double.tryParse(unitPriceInput.text);
    int? quantity = int.tryParse(quantityInput.text);
    try {
      date = _dateFormatter.parse(dateInput.text);
    } catch (err) {
      return _showError(context, 'Invalid Date');
    }

    // validations
    if (quantity == null || quantity < 0) {
      return _showError(context, 'Invalid Quantity');
    }
    if (quantity > product.availableUnits) {
      return _showError(context,
          'Insufficient Quantity. Maximum ${product.availableUnits} available.');
    }
    if (unitPrice == null || unitPrice < 0) {
      return _showError(context, 'Invalid Price');
    }

    // new sales record
    final record = SalesRecord(
      product: product,
      date: date,
      quantity: quantity,
      unitPrice: unitPrice,
    );

    _confirmSale(context, record);
  }

  void _showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => ErrorMessage(
        messageText: message,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _confirmSale(BuildContext context, SalesRecord record) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.shopping_cart),
            SizedBox(width: 5),
            Text('Please Confirm'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Repository.of(context).addSalesRecord(record);
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('ADD'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('CANCEL'),
          ),
        ],
        content: SalesPreview(
          record: record,
          product: product,
        ),
      ),
    );
  }
}
