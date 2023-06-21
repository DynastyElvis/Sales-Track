import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sales_tracker/src/blocs/global_bloc.dart';
import 'package:sales_tracker/src/models/product.dart';
import 'package:sales_tracker/src/models/product_report.dart';
import 'package:sales_tracker/src/models/sales_record.dart';
import 'package:sales_tracker/src/models/sales_report.dart';

class Repository {
  static Repository of(BuildContext context) =>
      GlobalBloc.of(context).repository;

  final User user;
  late final FirebaseFirestore firestore;
  late final CollectionReference<Product> _products;
  late final CollectionReference<SalesRecord> _sales;
  late final DocumentReference<Map<String, dynamic>> _userDoc;

  Repository({required this.user}) {
    firestore = FirebaseFirestore.instance;
    _userDoc = firestore.collection('users').doc(user.uid);
    _products = _userDoc.collection("products").withConverter<Product>(
          fromFirestore: (snap, _) => Product.fromJson(snap.id, snap.data()!),
          toFirestore: (model, _) => model.toJson(),
        );
    _sales = _userDoc.collection("sales").withConverter<SalesRecord>(
          fromFirestore: (snap, _) =>
              SalesRecord.fromJson(snap.id, snap.data()!),
          toFirestore: (model, _) => model.toJson(),
        );
    _saveUserData();
  }

  void _saveUserData() async {
    final snapshot = await _userDoc.get();
    if (!snapshot.exists) {
      await _userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'phoneNumber': user.phoneNumber,
        'photoURL': user.photoURL,
        'tenantId': user.tenantId,
        'creationTime': user.metadata.creationTime?.millisecondsSinceEpoch,
        'lastSignInTime': user.metadata.lastSignInTime?.millisecondsSinceEpoch,
        'isAnonymous': user.isAnonymous,
      });
    }
  }

  String _generatePassword() {
    return user.uid.substring(0, 6);
  }

  Future<void> registerAsVerified(String password) {
    if (_generatePassword() != password) {
      throw Exception('Password did not match');
    }
    return _userDoc.update({'password': password});
  }

  /// Get user verified status stream
  Stream<bool> get userVerified {
    return _userDoc.parent
        .where('uid', isEqualTo: user.uid)
        .where('password', isEqualTo: _generatePassword())
        .snapshots()
        .map((event) => event.size == 1 && event.docs.first.id == user.uid);
  }

  /// Get all products
  Stream<List<Product>> get allProducts {
    return _products.snapshots().asyncMap(_collectProducts);
  }

  static List<Product> _collectProducts(QuerySnapshot<Product> event) {
    var result = event.docs.fold<List<Product>>([], (list, snapshot) {
      return list..add(snapshot.data());
    });
    result.sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  /// Get list of products between start and stop dates (inclusive)
  Stream<ProductReport> getProductReport(DateTime start, DateTime stop) =>
      _products
          .where(
            'date',
            isGreaterThanOrEqualTo: start.millisecondsSinceEpoch,
            isLessThanOrEqualTo: stop.millisecondsSinceEpoch,
          )
          .snapshots()
          .map(_collectProducts)
          .map((products) => ProductReport(
                startTime: start,
                endTime: stop,
                products: products,
              ));

  /// Get list of sales between start and stop dates (inclusive)
  Stream<SalesReport> getSalesReport(DateTime start, DateTime stop) => _sales
      .where(
        'date',
        isGreaterThanOrEqualTo: start.millisecondsSinceEpoch,
        isLessThanOrEqualTo: stop.millisecondsSinceEpoch,
      )
      .snapshots()
      .map(_collectSalesRecords)
      .map((sales) => SalesReport(
            startTime: start,
            endTime: stop,
            sales: sales,
          ));

  static List<SalesRecord> _collectSalesRecords(
      QuerySnapshot<SalesRecord> event) {
    var result = event.docs.fold<List<SalesRecord>>([], (list, snapshot) {
      return list..add(snapshot.data());
    });
    return result;
  }

  Future<DocumentReference<Product>> addProduct(Product product) {
    return _products.add(product);
  }

  Future<DocumentSnapshot<Product>> getProduct(String? productId) {
    return _products.doc(productId).get();
  }

  Future<void> deleteProduct(String? productId) {
    return _products.doc(productId).delete();
  }

  Future<void> updateProduct(String? productId, Product updates) {
    return _products.doc(productId).update(updates.toJson());
  }

  Future<DocumentReference<SalesRecord>> addSalesRecord(SalesRecord sales) {
    assert(sales.quantity > 0);
    final doc = _products.doc(sales.productId);
    return doc.get().then((snapshot) {
      final product = snapshot.data()!;
      assert(product.availableUnits >= sales.quantity);
      doc.update({'units_sold': product.unitsSold + sales.quantity});
      return _sales.add(sales);
    });
  }

  Future<void> clearAllData() async {
    final sales = await _sales.get();
    final products = await _products.get();
    await Future.wait(products.docs.map((doc) => doc.reference.delete()));
    await Future.wait(sales.docs.map((doc) => doc.reference.delete()));
  }
}
