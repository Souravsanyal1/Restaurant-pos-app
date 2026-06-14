import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../constants/app_strings.dart';
import 'db_service.dart';

class AuthService extends GetxService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final isLoggedIn = false.obs;
  final currentUserRole = AppStrings.roleCashier.obs;
  final currentUserEmail = ''.obs;

  final dbService = Get.find<DbService>();

  @override
  void onInit() {
    super.onInit();
    // Monitor auth state changes
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _loadUserProfile(user.uid);
      } else {
        isLoggedIn.value = false;
        currentUserEmail.value = '';
      }
    });
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        currentUserRole.value = data?['role'] ?? AppStrings.roleCashier;
        currentUserEmail.value = _auth.currentUser?.email ?? '';
        isLoggedIn.value = true;
      }
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  Future<bool> login(String email, String password, String selectedRole) async {
    // 0. Demo Mode Fallback (Optional: remove this when Firebase is fully ready)
    if (email == 'demo@gmail.com' && password == 'demo123') {
      currentUserRole.value = selectedRole;
      currentUserEmail.value = email;
      isLoggedIn.value = true;
      return true;
    }

    try {
      // 1. Authenticate with Firebase Auth
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (credential.user != null) {
        // 2. Fetch role from Firestore
        final doc = await _firestore.collection('users').doc(credential.user!.uid).get();
        
        if (doc.exists) {
          final firestoreRole = doc.data()?['role'];
          
          if (firestoreRole == selectedRole) {
            currentUserRole.value = firestoreRole;
            currentUserEmail.value = email.trim();
            isLoggedIn.value = true;
            return true;
          } else {
            await logout();
            throw 'Role mismatch! Your account is assigned as "$firestoreRole", but you selected "$selectedRole".';
          }
        } else {
          // AUTO-FIX: If user exists in Auth but not in Firestore, create the record now
          await _firestore.collection('users').doc(credential.user!.uid).set({
            'email': email.trim(),
            'role': selectedRole,
            'createdAt': FieldValue.serverTimestamp(),
          });
          
          currentUserRole.value = selectedRole;
          currentUserEmail.value = email.trim();
          isLoggedIn.value = true;
          return true;
        }
      }
      return false;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw 'No user found for that email. Please check your Firebase Authentication list.';
        case 'wrong-password':
          throw 'Wrong password provided. Please try again.';
        case 'operation-not-allowed':
          throw 'Email/Password login is not enabled in Firebase Console. Go to Build > Authentication > Sign-in method and enable it.';
        case 'invalid-email':
          throw 'The email address is badly formatted.';
        default:
          throw e.message ?? 'Authentication error occurred.';
      }
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('pigeon') || errorStr.contains('firebaseauthhostapi')) {
        throw 'TECHNICAL ERROR: Firebase is not properly synced with your browser. \n\nFIX: Please STOP the app in Android Studio (Red button) and Run it again from scratch. \n(Hot Restart is not enough after adding new plugins).';
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    isLoggedIn.value = false;
    currentUserRole.value = AppStrings.roleCashier;
    currentUserEmail.value = '';
  }

  // Admin Tool: Create or Update staff account without logging out current Admin
  Future<void> registerOrUpdateStaff(String email, String password, String role) async {
    FirebaseApp? secondaryApp;
    try {
      // 1. Create a secondary app instance to manage other users without losing current session
      secondaryApp = await Firebase.initializeApp(
        name: 'StaffManager',
        options: Firebase.app().options,
      );

      final staffAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      
      UserCredential? credential;
      try {
        // Try creating new user
        credential = await staffAuth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          // If user exists, we might need to handle password updates via Admin SDK (Cloud Functions)
          // For client-side, we'll just update their Firestore role
          print('User exists, updating Firestore role only.');
        } else {
          rethrow;
        }
      }

      // 2. Update Firestore role
      String uid = '';
      if (credential != null && credential.user != null) {
        uid = credential.user!.uid;
      } else {
        // Try to find existing UID via Firestore
        final query = await _firestore.collection('users').where('email', isEqualTo: email.trim()).get();
        if (query.docs.isNotEmpty) {
          uid = query.docs.first.id;
        } else {
          throw 'User already exists in Auth but record not found. Please try logging in with that user first.';
        }
      }

      if (uid.isNotEmpty) {
        await _firestore.collection('users').doc(uid).set({
          'email': email.trim(),
          'role': role,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

    } finally {
      await secondaryApp?.delete();
    }
  }

  // Helper to initialize a user with a role in Firestore (useful for first-time setup)
  Future<void> createUserWithRole(String email, String password, String role) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'email': email,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error creating user: $e');
    }
  }
}
