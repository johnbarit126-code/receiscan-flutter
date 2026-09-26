import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/receipt.dart';
import 'dart:io';

class ReceiptProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Receipt> _receipts = [];
  bool _isLoading = false;
  String? _error;
  double _totalSpent = 0;

  List<Receipt> get receipts => _receipts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get totalSpent => _totalSpent;

  Future<void> loadReceipts() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final snapshot = await _firestore
          .collection('receipts')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      _receipts = snapshot.docs.map((doc) => Receipt.fromFirestore(doc)).toList();
      _calculateTotalSpent();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addReceipt(Receipt receipt, {File? imageFile}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadImage(receipt.id, imageFile);
      }

      final receiptData = receipt.toFirestore();
      if (imageUrl != null) {
        receiptData['imageUrl'] = imageUrl;
      }

      await _firestore.collection('receipts').doc(receipt.id).set(receiptData);
      _receipts.insert(0, receipt.copyWith(imageUrl: imageUrl));
      _calculateTotalSpent();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateReceipt(Receipt receipt, {File? imageFile}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      String? imageUrl = receipt.imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadImage(receipt.id, imageFile);
      }

      final receiptData = receipt.copyWith(imageUrl: imageUrl).toFirestore();
      await _firestore.collection('receipts').doc(receipt.id).update(receiptData);

      final index = _receipts.indexWhere((r) => r.id == receipt.id);
      if (index != -1) {
        _receipts[index] = receipt.copyWith(imageUrl: imageUrl);
      }
      _calculateTotalSpent();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteReceipt(String receiptId) async {
    try {
      await _firestore.collection('receipts').doc(receiptId).delete();
      _receipts.removeWhere((r) => r.id == receiptId);
      _calculateTotalSpent();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<String> _uploadImage(String receiptId, File imageFile) async {
    final ref = _storage.ref('receipts/${_auth.currentUser!.uid}/$receiptId.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  void _calculateTotalSpent() {
    _totalSpent = _receipts.fold(0, (sum, receipt) => sum + receipt.total);
  }

  List<Receipt> filterByCategory(String category) {
    return _receipts.where((r) => r.category == category).toList();
  }

  List<Receipt> filterByDateRange(DateTime start, DateTime end) {
    return _receipts
        .where((r) => r.date.isAfter(start) && r.date.isBefore(end))
        .toList();
  }
}

extension ReceiptCopy on Receipt {
  Receipt copyWith({
    String? id,
    String? userId,
    String? vendor,
    double? total,
    List<String>? items,
    DateTime? date,
    String? imageUrl,
    String? category,
    String? description,
  }) {
    return Receipt(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vendor: vendor ?? this.vendor,
      total: total ?? this.total,
      items: items ?? this.items,
      date: date ?? this.date,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
