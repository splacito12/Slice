import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slice/services/media_service.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'dart:io';
import 'package:mockito/annotations.dart';
import 'media_test.mocks.dart';




//declare the class's for the mocks
// class MockImagePicker extends Mock implements ImagePicker{}
// class MockXFile extends Mock implements XFile{}


//main
@GenerateMocks([
  ImagePicker,
  XFile,
])
void main(){
  late MediaService mediaService;
  late MockImagePicker mockImagePicker;
  late MockFirebaseStorage mockFirebaseStorage;




  TestWidgetsFlutterBinding.ensureInitialized();


  setUp(() {
    mockImagePicker = MockImagePicker();
    mockFirebaseStorage = MockFirebaseStorage();


     mediaService = MediaService(
      picker: mockImagePicker,
      storage: mockFirebaseStorage,
  );
  });


  //test whether null is returned when the user cancels picking a media
  test("Image Picker returns NULL when when user cancels", ()async{
    when(mockImagePicker.pickImage( source: ImageSource.gallery,))
    .thenAnswer((_) async => null);


    File? result = await mediaService.pickMedia(true);


    expect(result, isNull);
  });


  //test to check if file is returned when an image is picked
  test("pickMedia returns a file when an image is selected", () async{
    final file = File("test_resources/test.png");


    when(mockImagePicker.pickImage(source: ImageSource.gallery))
        .thenAnswer((_) async => XFile(file.path));


    final result = await mediaService.pickMedia(true);


    expect(result, isA<File>());
    expect(result!.path, file.path);
  });


  //test to check if pickMedia returns a file when a video is picked
  test("pickMedia returns a file when a video is selected", () async{
    final file = File("test_resources/test.mp4");


    when(mockImagePicker.pickVideo(source: ImageSource.gallery,))
    .thenAnswer((_) async => XFile(file.path));


    final result = await mediaService.pickMedia(false);


    expect(result, isA<File>());
    expect(result!.path, file.path);
  });


  //test to check if an upload returns a URL
  test("uploadMedia returns a URL", () async{
    final file = File("test_resources/test.png");


    final url = await mediaService.uploadMedia(file: file, convoId: "123");


    expect(url, contains("123"));
    expect(url, contains("test.png"));
  });
}
