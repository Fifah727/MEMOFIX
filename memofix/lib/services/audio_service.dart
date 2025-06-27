// import 'package:record/record.dart';

// class AudioService {
//   final Record _recorder =
//       Record(); // Si Record() est bien concret dans ta version

//   Future<void> startRecording(String path) async {
//     final hasPermission = await _recorder.hasPermission();
//     if (hasPermission) {
//       await _recorder.start(
//         path: path,
//         encoder: AudioEncoder.aacLc, // par exemple
//         bitRate: 128000,
//         samplingRate: 44100,
//       );
//     }
//   }

//   Future<void> stopRecording() async {
//     await _recorder.stop();
//   }

//   Future<bool> isRecording() => _recorder.isRecording();
// }
