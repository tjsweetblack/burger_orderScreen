import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore
// For Authentication


part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthCubit() : super(AuthInitial());

  User? get currentUser => _auth.currentUser;
  
  Future<void> createAccountAndLinkItWithGoogleAccount(
      String email,
      String password,
      GoogleSignInAccount googleUser,
      OAuthCredential credential) async {
    emit(AuthLoading());

    try {
      await _auth.createUserWithEmailAndPassword(
        email: googleUser.email,
        password: password,
      );
      await _auth.currentUser!.linkWithCredential(credential);
      await _auth.currentUser!.updateDisplayName(googleUser.displayName);
      await _auth.currentUser!.updatePhotoURL(googleUser.photoUrl);
      emit(UserSingupAndLinkedWithGoogle());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> resetPassword(String email) async {
    emit(AuthLoading());
    try {
      await _auth.sendPasswordResetEmail(email: email);
      emit(ResetPasswordSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    emit(AuthLoading());
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user!.emailVerified) {
        // Update Firestore lastLogin field
        await _firestore.collection('users').doc(userCredential.user!.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });

        emit(UserSignIn());
      } else {
        await _auth.signOut();
        emit(AuthError('Email not verified. Please check your email.'));
        emit(UserNotVerified());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        emit(AuthError('Google Sign In Failed'));
        return;
      }
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential authResult =
          await _auth.signInWithCredential(credential);
      if (authResult.additionalUserInfo!.isNewUser) {
        // Delete the user account if it is a new user to Create it automatically in Next Screen
        await _auth.currentUser!.delete();

        emit(IsNewUser(googleUser: googleUser, credential: credential));
      } else {
        emit(UserSignIn());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    await _auth.signOut();
    emit(UserSignedOut());
  }

  Future<void> signUpWithEmail(
      String name, String email, String password, String phoneNumber) async {
    emit(AuthLoading());
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _auth.currentUser!.updateDisplayName(name);
      await _auth.currentUser!.sendEmailVerification();

      User? user = userCredential.user;
      if (user != null) {
        // Create a new cart document
        DocumentReference cartDocRef = _firestore.collection('cart').doc();
        await cartDocRef.set({
          'items': [], // Initialize with an empty items array
          'userId': user.uid, // Add user ID to cart for reference
          'cartTotalPrice': 0.0, // Initialize cart total price
          'dateCreated': FieldValue.serverTimestamp(), // Add timestamp
        });

        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': user.email,
          'phoneNumber': phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': 0,
          'role': 'user', // Default role
          'cart': cartDocRef.id,
          'favorites': [], // Initialize with an empty favorites array
          // Add cart ID to user document
        });
      }
      emit(UserSingupButNotVerified());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
   // Initiates phone number sign-up
  Future<void> signUpWithPhoneNumber(String phoneNumber) async {
  try {
    emit(AuthLoading());

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        emit(UserSignIn());
      },
      verificationFailed: (FirebaseAuthException e) {
        emit(AuthError(e.message ?? "Verification failed"));
      },
      codeSent: (String verificationId, int? resendToken) async {
        // Emit the PhoneVerificationSent state with the verificationId
        emit(PhoneVerificationSent(verificationId));
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        emit(AuthError("Code retrieval timeout"));
      },
    );
  } catch (e) {
    emit(AuthError("Error during phone sign-up: ${e.toString()}"));
  }
}


  // Verifies the OTP sent to the phone number
  Future<void> verifyPhoneOTP(String verificationId, String otp) async {
    try {
      emit(AuthLoading());
      
      // Create a PhoneAuthCredential with the verification ID and OTP
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      // Sign in using the credential
      await _auth.signInWithCredential(credential);
      emit(UserSignIn());
    } catch (e) {
      emit(AuthError("Verification failed: ${e.toString()}"));
    }
  }
}