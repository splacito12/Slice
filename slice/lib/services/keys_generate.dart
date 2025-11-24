import 'dart:math';

String generateMediaKey(){
  final random = Random.secure();
  
  return List<int>.generate(32, (_) => random.nextInt(256))
    .map((e) => e.toRadixString(16).padLeft(2, '0'))
    .join();
}