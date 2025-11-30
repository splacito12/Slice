import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'encryption _service.dart';

class MediaService {
  final ImagePicker _imagePicker;
  final FirebaseStorage _firebaseStorage;
  final EncryptService _encryptService;

  //allows us to use mockito
  MediaService({
    required EncryptService encryptService,
    ImagePicker? picker, 
    FirebaseStorage? storage,
  }) : _imagePicker = picker ?? ImagePicker(),
  _firebaseStorage = storage ?? FirebaseStorage.instance,
  _encryptService = encryptService;

  //Pick media function
  Future<File?> _pickMedia({required bool isImage}) async{
    final pickedMedia = await (isImage ? 
    _imagePicker.pickImage(source: ImageSource.gallery) 
    : _imagePicker.pickVideo(source: ImageSource.gallery));

    if(pickedMedia == null){
      return null;
    }

    return File(pickedMedia.path);
  }

  Future<File?> pickMedia(bool isImage) async{
    return await _pickMedia(isImage: isImage);
  }

  //upload media and get URL
  Future<String> uploadMedia({
    required File file,
    required String convoId,
  }) async{
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final ref = _firebaseStorage
      .ref()
      .child('chat_media/$convoId/$fileName');

    final bytes = await file.readAsBytes();
    final encrypted = _encryptService.encryptBytes(bytes);

    await ref.putData(encrypted);
    return await ref.getDownloadURL();
  }

  //decript and download
  Future<Uint8List> decrypt(String storagePath) async{
    final ref = _firebaseStorage
      .ref()
      .child(storagePath);
    final encryptedBytes = await ref.getData(50*1024*1024);

    if(encryptedBytes == null){
      throw Exception("Couldn't download encrypted media");
    }

    return _encryptService.decryptBytes(encryptedBytes);
  }
}