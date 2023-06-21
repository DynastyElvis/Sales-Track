import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sales_tracker/src/blocs/repository.dart';
import 'package:sales_tracker/src/models/product.dart';
import 'package:sales_tracker/src/pages/widgets/error_message.dart';

class ProductFormDialog extends StatelessWidget {
  static Future<void> display(BuildContext context, [Product? product]) {
    return Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        maintainState: false,
        fullscreenDialog: true,
        builder: (_) => ProductFormDialog(product),
      ),
    );
  }

  static final _dateFormatter = DateFormat.yMMMEd();

  final Product? product;
  late final TextEditingController dateInput;
  late final TextEditingController nameInput;
  late final TextEditingController unitPriceInput;
  late final TextEditingController quantityInput;

  bool get addMode => product == null;

  ProductFormDialog(this.product) {
    nameInput = TextEditingController(text: product?.name);
    unitPriceInput = TextEditingController(text: product?.unitCost.toString());
    quantityInput = TextEditingController(text: product?.quantity.toString());
    dateInput = TextEditingController(
      text: _dateFormatter.format(product?.date ?? DateTime.now()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Scaffold(
        appBar: AppBar(
          title: Text(addMode ? 'Add Product' : 'Edit Product'),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: Colors.black12,
                child: Icon(
                  addMode ? Icons.add : Icons.edit,
                  color: Colors.teal,
                  size: 48,
                ),
              ),
              SizedBox(height: 25),
              Builder(builder: buildDateInput),
              Builder(builder: buildNameInput),
              Builder(builder: buildUnitPriceInput),
              Builder(builder: buildQuantityInput),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _submitItem(context),
          child: Icon(Icons.save),
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

  Widget buildNameInput(BuildContext context) {
    return TextField(
      controller: nameInput,
      keyboardType: TextInputType.name,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Item Name',
      ),
      onEditingComplete: () {
        FocusScope.of(context).nextFocus();
      },
      inputFormatters: [
        LengthLimitingTextInputFormatter(127),
      ],
    );
  }

  Widget buildUnitPriceInput(BuildContext context) {
    return TextField(
      enabled: product == null || product!.unitsSold == 0,
      controller: unitPriceInput,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Cost Per Unit',
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
      enabled: product == null || product!.unitsSold == 0,
      controller: quantityInput,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Item Quantity',
      ),
      onEditingComplete: () {
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

  void _submitItem(BuildContext context) {
    // data
    DateTime date;
    String name = nameInput.text.trim();
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
    if (unitPrice == null || unitPrice < 0) {
      return _showError(context, 'Invalid Price');
    }
    if (name.isEmpty) {
      return _showError(context, 'Invalid Name');
    }

    // new product
    final newProduct = Product(
      name: name,
      date: date,
      unitCost: unitPrice,
      quantity: quantity,
    );

    // add or update
    if (addMode) {
      Repository.of(context).addProduct(newProduct);
    } else {
      Repository.of(context).updateProduct(product!.id, newProduct);
    }

    Navigator.of(context).pop();
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
}
