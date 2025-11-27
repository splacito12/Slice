import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class MediaService {
  final ImagePicker _imagePicker;
  final FirebaseStorage _firebaseStorage;

  //allows us to use mockito
  MediaService({ImagePicker? picker, FirebaseStorage? storage})
    : _imagePicker = picker ?? ImagePicker(),
      _firebaseStorage = storage ?? FirebaseStorage.instance;

  //Pick media function
  Future<File?> _pickMedia({required bool isImage}) async {
    final pickedMedia = await (isImage
        ? _imagePicker.pickImage(source: ImageSource.gallery)
        : _imagePicker.pickVideo(source: ImageSource.gallery));

    if (pickedMedia == null) {
      return null;
    }

    return File(pickedMedia.path);
  }

  Future<File?> pickMedia(bool isImage) async {
    return await _pickMedia(isImage: isImage);
  }

  //upload medial and get URL
  Future<String> uploadMedia({
    required File file,
    required String convoId,
  }) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final ref = _firebaseStorage.ref().child('chat_media/$convoId/$fileName');

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<String> uploadProfilePic(File file, String uid) async {
    final fileName = 'profile_$uid.jpg';

    final ref = _firebaseStorage
        .ref()
        .child('profile_pictures')
        .child(fileName);

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}
