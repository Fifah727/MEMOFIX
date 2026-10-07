import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:dio/dio.dart';

typedef ProgressCallback = void Function(double progress);

class FastDownloader {
  final Dio dio;
  final ProgressCallback? onProgress;

  FastDownloader({Dio? dioInstance, this.onProgress})
    : dio = dioInstance ?? Dio();

  Future<void> downloadFile(
    String url,
    String savePath, {
    int parts = 4,
    CancelToken? cancelToken,
  }) async {
    List<File> tempFiles = [];

    try {
      // 1️⃣ Taille du fichier
      final response = await dio.head(url);
      final contentLength = int.parse(
        response.headers.value('content-length') ?? '0',
      );
      if (contentLength == 0)
        throw Exception("Impossible d'obtenir la taille du fichier");

      final sizeInMB = contentLength / (1024 * 1024);
      debugPrint("Taille du fichier : ${sizeInMB.toStringAsFixed(2)} Mo");

      // 2️⃣ Calcul des plages
      int partSize = (contentLength / parts).ceil();
      List<Future<File>> futures = [];

      for (int i = 0; i < parts; i++) {
        int start = i * partSize;
        int end = (i + 1) * partSize - 1;
        if (end >= contentLength) end = contentLength - 1;

        String tempPath = "$savePath.part$i";
        tempFiles.add(File(tempPath));

        futures.add(
          _downloadPart(
            url,
            tempPath,
            start,
            end,
            i,
            cancelToken,
            contentLength,
          ),
        );
      }

      // 3️⃣ Attendre toutes les parties
      final files = await Future.wait(futures);

      // 4️⃣ Fusionner les fichiers
      final file = File(savePath);
      final raf = file.openSync(mode: FileMode.write);
      for (var f in files) {
        raf.writeFromSync(f.readAsBytesSync());
        await f.delete();
      }
      await raf.close();

      debugPrint("Téléchargement terminé : $savePath");
    } catch (e) {
      // Nettoyer les fichiers partiels
      for (var f in tempFiles) {
        if (await f.exists()) await f.delete();
      }
      debugPrint("Erreur : $e");
      rethrow; // pour que le screen attrape l’erreur
    }
  }

  Future<File> _downloadPart(
    String url,
    String savePath,
    int start,
    int end,
    int partIndex,
    CancelToken? cancelToken,
    int totalBytes,
  ) async {
    final file = File(savePath);
    final raf = file.openSync(mode: FileMode.write);

    int receivedBytes = 0;

    try {
      final response = await dio.get<ResponseBody>(
        url,
        options: Options(
          responseType: ResponseType.stream,
          headers: {"Range": "bytes=$start-$end"},
        ),
        cancelToken: cancelToken,
      );

      await response.data!.stream
          .listen(
            (chunk) {
              raf.writeFromSync(chunk);
              receivedBytes += chunk.length;

              // ⚡ Mise à jour progression globale
              if (onProgress != null) {
                onProgress!(receivedBytes / totalBytes); // approximation
              }
            },
            onDone: () async {
              await raf.close();
            },
            onError: (e) async {
              await raf.close();
            },
          )
          .asFuture();
    } catch (e) {
      await raf.close();
      debugPrint("Exception partie $partIndex : $e");
      rethrow;
    }

    return file;
  }
}
