import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:slice/services/auth/auth_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  FirebaseFirestore,
  MockFirebaseAuth,
  AuthService,
])

void main() {
  late FakeFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late AuthService authService;

  TestWidgetsFlutterBinding.ensureInitialized();

  test('Login test', () async {
    final cred = await authService.signInWithEmailPassword(
      'test@gmail.com',
      'password123'
    );

    // firebase auth should create the user
    expect(cred.user, isNotNull);
    expect(cred.user!.email, 'test@gmail.com');

    // firestore should have a users document
    final doc = await mockFirestore.collection('users').doc(cred.user!.uid).get();
    expect(doc.exists, true);
    expect(doc.data()!['username'], 'hooman');
  });

  });
}