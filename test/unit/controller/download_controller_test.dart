import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:yt_downloader/controller/download_controller.dart';

class MockContext extends Mock implements BuildContext {}

void main() {
  group('DownloadController', () {
    late DownloadController downloadController;
    late MockContext mockContext;

    setUp(() {
      mockContext = MockContext();
      downloadController = DownloadController(mockContext);
    });

    test('cleanFileName removes special characters', () {
      expect(downloadController.cleanFileName('video@123'), equals('video123'));

      expect(downloadController.cleanFileName('video@ 123'), equals('video 123'));

      expect(downloadController.cleanFileName('video@ 123'), equals('video 123'));

      expect(downloadController.cleanFileName('19-2000'), equals('19-2000'));
    });

  });
}
