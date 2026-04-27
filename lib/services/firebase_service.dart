import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/app_category.dart';
import '../models/expense_transaction.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _usersCollection => _db.collection('users');
  CollectionReference get _globalCategoriesCollection => _db.collection('categories');

  // User related
  Stream<UserModel?> userDataStream(String userId) {
    return _usersCollection.doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error fetching user: $e");
    }
    return null;
  }

  Future<void> updateUser(String userId, UserModel user) async {
    try {
      await _usersCollection.doc(userId).set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      print("Error updating user: $e");
    }
  }

  Future<void> updateDailyLimit(String userId, double limit) async {
    try {
      await _usersCollection.doc(userId).update({'dailyLimit': limit});
    } catch (e) {
      print("Error updating daily limit: $e");
    }
  }

  Future<void> updateTotalLoans(String userId, double loans) async {
    try {
      await _usersCollection.doc(userId).update({'totalLoans': loans});
    } catch (e) {
      print("Error updating total loans: $e");
    }
  }

  // Categories related
  Stream<List<AppCategory>> getDefaultCategoriesStream() {
    return _globalCategoriesCollection
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppCategory.fromFirestore(doc, CategoryType.defaultType))
            .toList());
  }

  Stream<List<AppCategory>> getUserCategoriesStream(String userId) {
    return _usersCollection
        .doc(userId)
        .collection('categories')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppCategory.fromFirestore(doc, CategoryType.custom))
            .toList());
  }

  Future<void> addCustomCategory(String userId, String name) async {
    try {
      final docRef = _usersCollection.doc(userId).collection('categories').doc();
      await docRef.set({
        'id': docRef.id,
        'categoryId': docRef.id,
        'name': name,
        'type': 'custom',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding custom category: $e");
    }
  }

  Future<void> deleteCustomCategory(String userId, String categoryId) async {
    try {
      final snapshot = await _usersCollection
          .doc(userId)
          .collection('categories')
          .where('categoryId', isEqualTo: categoryId)
          .get();
      
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print("Error deleting custom category: $e");
    }
  }

  // Transactions related
  Stream<List<ExpenseTransaction>> getTransactionsStream(String userId) {
    return _usersCollection
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExpenseTransaction.fromFirestore(doc))
            .toList());
  }

  Future<void> addTransaction(String userId, ExpenseTransaction tx) async {
    try {
      await _usersCollection.doc(userId).collection('transactions').add(tx.toMap());
    } catch (e) {
      print("Error adding transaction to Firestore: $e");
    }
  }

  Future<void> updateTransaction(String userId, ExpenseTransaction tx) async {
    try {
      if (tx.id != null) {
        final updateData = tx.toMap();
        updateData.remove('createdAt'); // Don't overwrite creation time
        await _usersCollection
            .doc(userId)
            .collection('transactions')
            .doc(tx.id)
            .update(updateData);
      }
    } catch (e) {
      print("Error updating transaction in Firestore: $e");
    }
  }

  Future<void> deleteTransaction(String userId, String transactionId) async {
    try {
      await _usersCollection
          .doc(userId)
          .collection('transactions')
          .doc(transactionId)
          .delete();
    } catch (e) {
      print("Error deleting transaction from Firestore: $e");
    }
  }

  // Fixed Costs related
  Stream<List<Map<String, dynamic>>> getFixedCostsStream(String userId) {
    return _usersCollection
        .doc(userId)
        .collection('fixed_costs')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList());
  }

  Future<void> addFixedCost(String userId, String name, double amount, int day) async {
    try {
      await _usersCollection.doc(userId).collection('fixed_costs').add({
        'name': name,
        'amount': amount,
        'dayOfMonth': day,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding fixed cost: $e");
    }
  }

  Future<void> deleteFixedCost(String userId, String id) async {
    try {
      await _usersCollection
          .doc(userId)
          .collection('fixed_costs')
          .doc(id)
          .delete();
    } catch (e) {
      print("Error deleting fixed cost: $e");
    }
  }
}
