import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sales_tracker/src/blocs/repository.dart';
import 'package:sales_tracker/src/models/product.dart';
import 'package:sales_tracker/src/pages/product_report_page.dart';
import 'package:sales_tracker/src/pages/sales_report_page.dart';
import 'package:sales_tracker/src/pages/widgets/error_message.dart';
import 'package:sales_tracker/src/pages/widgets/home_page_drawer.dart';
import 'package:sales_tracker/src/pages/widgets/product_form_dialog.dart';
import 'package:sales_tracker/src/pages/widgets/product_list.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: buildAppBar(context),
      floatingActionButton: buildAddItemButton(context),
      drawer: Drawer(
        child: HomePageDrawer(),
      ),
      body: StreamBuilder<List<Product>>(
        stream: Repository.of(context).allProducts,
        builder: (context, snapshot) {
          print(snapshot.connectionState);
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.active:
            case ConnectionState.done:
              if (snapshot.hasError) {
                return ErrorMessage(
                  messageText: 'Could not get product list',
                  errorDetails: snapshot.error,
                  onDismiss: () => FirebaseAuth.instance.signOut(),
                );
              }
              return ProductListView(snapshot.requireData);
          }
        },
      ),
    );
  }

  FloatingActionButton buildAddItemButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => ProductFormDialog.display(context),
      child: Icon(Icons.add),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: Text("Sales Tracker"),
      actions: [
        PopupMenuButton<int>(
          icon: Icon(Icons.history),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 1,
              child: Text('Product Report'),
            ),
            PopupMenuItem(
              value: 2,
              child: Text('Sales Report'),
            ),
          ],
          onSelected: (index) {
            switch (index) {
              case 1:
                ProductReportPage.display(context);
                break;
              case 2:
                SalesReportPage.display(context);
                break;
            }
          },
        ),
      ],
    );
  }
}
