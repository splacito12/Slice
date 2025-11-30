import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProfileService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadProfilePic() async {
    final imagePicker = ImagePicker();
    final selectedImage = await imagePicker.pickImage(source: ImageSource.gallery);

    if (selectedImage == null) return null;

    final myUid = _auth.currentUser!.uid;
    final storageRef = _storage.ref().child('profilePics/$myUid.png');
    await storageRef.putFile(File(selectedImage.path));
    final imageURL = await storageRef.getDownloadURL();

    await _firestore.collection('users').doc(myUid).update({'profilePic': imageURL});

    return imageURL;
  }
}