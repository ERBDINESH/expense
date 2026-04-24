import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection reference
  CollectionReference get _usersCollection => _db.collection('users');

  // Stream of user data - Fixed: removed 'get' keyword as it has parameters
  Stream<UserModel?> userDataStream(String userId) {
    return _usersCollection.doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // Get user data once
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

  // Update user data
  Future<void> updateUser(String userId, UserModel user) async {
    try {
      await _usersCollection.doc(userId).set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      print("Error updating user: $e");
    }
  }

  // Example: Add a new user
  Future<void> addUser(String userId, Map<String, dynamic> userData) async {
    try {
      await _usersCollection.doc(userId).set(userData);
    } catch (e) {
      print("Error adding user: $e");
    }
  }
}
