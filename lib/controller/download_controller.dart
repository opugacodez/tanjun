import 'dart:async';
import 'dart:io';
// import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
// import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';

class DownloadController {
  final BuildContext context;
  final StreamController<DownloadProgress> _progressController =
  StreamController<DownloadProgress>();
  Completer<void>? _downloadCompleter;
  List<String> downloadedVideos = [];

  DownloadController(this.context);

  Stream<DownloadProgress> get progressStream => _progressController.stream;

  String cleanFileName(String input) {
    var cleaned = input.characters
        .where((c) => RegExp(r'[a-zA-Z0-9 ]').hasMatch(c))
        .join();
    cleaned = cleaned
        .replaceAll(r'\', '')
        .replaceAll('/', '')
        .replaceAll('*', '')
        .replaceAll('?', '')
        .replaceAll('"', '')
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('|', '')
        .trim();
    return cleaned;
  }

  Future<void> downloadPlaylist(String playlistUrl, String directory) async {
    _downloadCompleter = Completer<void>();
    var yt = YoutubeExplode();

    try {
      var playlist = await yt.playlists.get(playlistUrl);
      var videos = await yt.playlists.getVideos(playlist.id).toList();
      var totalVideos = videos.length;
      var completedVideos = 0;

      for (var video in videos) {
        if (_downloadCompleter!.isCompleted) break;
        await _downloadVideo(video, directory, totalVideos, completedVideos);
        completedVideos++;
      }
    } catch (e) {
      debugPrint('Error downloading playlist: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading playlist: $e')),
      );
    } finally {
      yt.close();
    }
  }

  Future<void> _downloadVideo(Video video, String directory, int totalVideos, int completedVideos) async {
    var yt = YoutubeExplode();
    try {
      var manifest = await yt.videos.streamsClient.getManifest(video.id);
      var music = manifest.muxed.withHighestBitrate();
      var musicStream = yt.videos.streamsClient.get(music);
      var fileName = '${cleanFileName(video.title)}.${music.container.name}';

      final dirPath = '$directory/${video.author}';
      final filePath = '$dirPath/$fileName';

      final dir = Directory(dirPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      final output = file.openWrite(mode: FileMode.writeOnlyAppend);
      var len = music.size.totalBytes;
      var count = 0;
      var msg = 'Downloading ${video.title}.${music.container.name}';
      stdout.writeln(msg);
      await for (final data in musicStream) {
        count += data.length;
        var videoProgress = ((count / len) * 100).ceil();
        _progressController.add(DownloadProgress(
            video.title, videoProgress, completedVideos / totalVideos * 100));
        output.add(data);
      }
      await output.flush();
      await output.close();
      _progressController.add(DownloadProgress(
          video.title, 100, completedVideos / totalVideos * 100));
      downloadedVideos.add(video.title);

      // Uncomment and refactor this block if you want to convert to MP3
      // await _convertToMp3(filePath, dirPath, video.title);

    } catch (e) {
      debugPrint('Error downloading video: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading video: $e')),
      );
    } finally {
      yt.close();
    }
  }

  // Uncomment and refactor this method if you want to convert to MP3
  // Future<void> _convertToMp3(String filePath, String dirPath, String title) async {
  //   var mp3FilePath = '$dirPath/${cleanFileName(title)}.mp3';
  //
  //   if (await File(filePath).exists()) {
  //     FFmpegKit.execute('-i "$filePath" -vn -ab 256k -ar 44100 "$mp3FilePath"').then((session) async {
  //       final returnCode = await session.getReturnCode();
  //
  //       if (ReturnCode.isSuccess(returnCode)) {
  //         debugPrint("FFMEG: SUCCESS");
  //       } else if (ReturnCode.isCancel(returnCode)) {
  //         debugPrint("FFMEG: CANCEL");
  //       } else {
  //         debugPrint("FFMEG: ERROR");
  //         final state = await session.getState();
  //         final errorLogs = await session.getAllLogsAsString();
  //
  //         debugPrint("FFMEG State: $state");
  //         debugPrint("FFMEG Error Logs: $errorLogs");
  //       }
  //     });
  //   }
  // }

  void dispose() {
    _progressController.close();
  }

  void cancelDownload() {
    _downloadCompleter?.complete();
  }
}

class DownloadProgress {
  final String videoTitle;
  final int videoProgress;
  final double playlistProgress;

  DownloadProgress(this.videoTitle, this.videoProgress, this.playlistProgress);
}
