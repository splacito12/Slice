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
])

void main() {
  late FakeFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late AuthService authService;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockFirestore = FakeFirebaseFirestore();

    authService = AuthService(auth: mockAuth, firestore: mockFirestore);
  });

  group('signUp tests', () {
    test('New user passing case', () async {
      final cred = await authService.signUpWithEmailPassword(
        'test@gmail.com',
        'mypassword',
        'tester'
      );

      expect(cred.user, isNotNull);
      expect(cred.user!.email, 'test@gmail.com');
      expect(cred.user!.displayName, 'tester');

      final doc = await mockFirestore.collection('users').doc(cred.user!.uid).get();
      expect(doc.exists, true);
      expect(doc.data()!['email'], 'test@gmail.com');
      expect(doc.data()!['username'], 'tester');
    });

    // test('An account with this email already exists', () async {
    //   await authService.signUpWithEmailPassword(
    //     'test@gmail.com',
    //     'mypassword',
    //     'tester'
    //   );

    //   expect(
    //     authService.signUpWithEmailPassword(
    //       'test@gmail.com',
    //       'myotherpassword',
    //       'tester2'
    //     ), throwsA(isA<Exception>()),
    //   );
    // });
  });

group('signIn tests', () {
    test('Sign in successful case', () async {
      final mockUser = MockUser(
        email: 'test@gmail.com',
        uid: 'uid12345',
        displayName: 'tester'
      );

      mockAuth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
      authService = AuthService(auth: mockAuth, firestore: mockFirestore);

      final credential = await authService.signInWithEmailPassword(
      'test@gmail.com',
      'mypassword',
      );

      expect(credential.user, isNotNull);
      expect(credential.user!.uid, 'uid12345');
      expect(credential.user!.email, 'test@gmail.com');
      expect(credential.user!.displayName, 'tester');
    });
  });

  group('signOut tests', () {
    test('Sign in successful case', () async {
      final mockUser = MockUser(
        email: 'test@gmail.com',
        uid: 'uid12345',
        displayName: 'tester'
      );

      mockAuth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
      authService = AuthService(auth: mockAuth, firestore: mockFirestore);

      expect(mockAuth.currentUser, isNotNull);
      await authService.signOut();
      expect(mockAuth.currentUser, isNull);
    });
  });
}