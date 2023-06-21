import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sales_tracker/src/blocs/repository.dart';
import 'package:sales_tracker/src/pages/product_report_page.dart';
import 'package:sales_tracker/src/pages/sales_report_page.dart';
import 'package:sales_tracker/src/pages/widgets/product_form_dialog.dart';

class HomePageDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('lib/res/pattern_back.jpg'),
          alignment: Alignment.center,
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              buildHeader(),
              Divider(),
              SizedBox(height: 10),
              buildUserAvatar(),
              SizedBox(height: 5),
              buildUserName(),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 5),
              Builder(builder: buildAddButton),
              SizedBox(height: 5),
              Builder(builder: buildProductReportButton),
              SizedBox(height: 5),
              Builder(builder: buildSalesReportButton),
              Divider(),
              Builder(builder: buildResetButton),
              Spacer(),
              Divider(),
              buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Text(
      'Sales Tracker',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.deepOrange,
        fontSize: 30,
        fontWeight: FontWeight.w300,
      ),
    );
  }

  Widget buildUserAvatar() {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.photoURL == null) return Container();
    return Container(
      width: 80,
      height: 80,
      alignment: Alignment.center,
      child: ClipOval(
        child: Image.network(
          user!.photoURL!,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget buildUserName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.displayName == null) {
      return Container();
    }
    return Text(
      user!.displayName!,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.blueGrey,
        fontFamily: 'sans',
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget buildLogoutButton() {
    return ElevatedButton(
      onPressed: () {
        FirebaseAuth.instance.signOut();
      },
      child: Container(
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            Text('Sign Out'),
            Spacer(),
            Icon(Icons.logout),
          ],
        ),
      ),
    );
  }

  Widget buildProductReportButton(BuildContext context) {
    return ListTile(
      tileColor: Colors.grey[100],
      title: Text('Product Report'),
      leading: Icon(Icons.history),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      onTap: () async {
        await ProductReportPage.display(context);
        Navigator.of(context).pop();
      },
    );
  }

  Widget buildSalesReportButton(BuildContext context) {
    return ListTile(
      tileColor: Colors.grey[100],
      title: Text('Sales Report'),
      leading: Icon(Icons.history_edu),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      onTap: () async {
        await SalesReportPage.display(context);
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
  }

  Widget buildAddButton(BuildContext context) {
    return ListTile(
      tileColor: Colors.grey[100],
      title: Text('Add Product'),
      leading: Icon(Icons.add),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      onTap: () async {
        await ProductFormDialog.display(context);
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
  }

  Widget buildResetButton(BuildContext context) {
    return ListTile(
      tileColor: Colors.grey[100],
      title: Text('Reset Data'),
      leading: Icon(Icons.cleaning_services),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      onTap: () {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Confirm Reset'),
            content:
                Text('Resetting will clear all data you have entered so far!'),
            actions: [
              TextButton(
                child: Text('Continue'),
                onPressed: () {
                  Repository.of(context).clearAllData();
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
