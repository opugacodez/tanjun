import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yt_downloader/controller/download_controller.dart';
import '../widgets/custom_card.dart';
import '../utils/app_bar_builder.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _urlController = TextEditingController();
  String _downloadDirectory = "/storage/emulated/0/Download/Tanjun";
  DownloadController? _downloadController;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _loadDownloadDirectory();
  }

  Future<void> _loadDownloadDirectory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _downloadDirectory =
          prefs.getString('downloadDirectory') ?? "/storage/emulated/0/Download/Tanjun";
    });
  }

  // Future<void> _saveDownloadDirectory(String directory) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('downloadDirectory', directory);
  //   setState(() {
  //     _downloadDirectory = directory;
  //   });
  // }

  @override
  void dispose() {
    _downloadController?.dispose();
    super.dispose();
  }

  // Future<void> _pickDownloadDirectory() async {
  //   String? downloadDirectory = await FilePicker.platform.getDirectoryPath();
  //
  //   if (downloadDirectory != null) {
  //     await _saveDownloadDirectory(downloadDirectory);
  //   }
  // }

  void _startDownload() async {
    final String url = _urlController.text;
    if (url.isNotEmpty) {
      setState(() {
        _isDownloading = true;
      });

      _downloadController = DownloadController(context);
      await _downloadController!.downloadPlaylist(url, _downloadDirectory);

      setState(() {
        _isDownloading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide a valid URL and directory.')),
      );
    }
  }

  void _cancelDownload() {
    _downloadController?.cancelDownload();
    setState(() {
      _isDownloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomCard(
                icon: Icons.folder_outlined,
                title: 'Set your download location',
                content: _buildDownloadDirectoryContent(),
              ),
              CustomCard(
                icon: Icons.download_outlined,
                title: 'Paste your playlist URL',
                content: _buildDownloadUrlContent(),
              ),
              CustomCard(
                icon: Icons.list_outlined,
                title: 'Your latest download list',
                content: _buildDownloadListContent(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadDirectoryContent() {
    return Row(
      children: [
        Expanded(
          child: Text(
            _downloadDirectory,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Info"),
                      content: const Text("At the moment, downloads can only be stored in:\n/storage/emulated/0/Download/Tanjun"),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  });
            },
            icon: Icon(Icons.info_outline)
        )
        // IconButton(
        //   onPressed: _pickDownloadDirectory,
        //   icon: Icon(Icons.folder_open),
        // ),
      ],
    );
  }

  Widget _buildDownloadUrlContent() {
    return Column(
      children: [
        TextField(
          controller: _urlController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          enabled: !_isDownloading,
        ),
        Container(
          margin: EdgeInsets.only(top: 10),
          alignment: Alignment.bottomRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_isDownloading)
                IconButton(
                  onPressed: _cancelDownload,
                  icon: Icon(Icons.close),
                ),
              FilledButton(
                onPressed: _isDownloading ? null : _startDownload,
                child: _isDownloading ? Text('Downloading...') : Text('Download'),
              ),
            ],
          ),
        ),
        if (_isDownloading)
          Container(
            margin: EdgeInsets.only(top: 10),
            child: StreamBuilder<DownloadProgress>(
              stream: _downloadController!.progressStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final progress = snapshot.data!;
                  return Column(
                    children: [
                      Text('Downloading: ${progress.videoTitle}'),
                      LinearProgressIndicator(
                        value: progress.videoProgress / 100,
                      ),
                      Text('${progress.videoProgress}%'),
                      SizedBox(height: 20),
                      Text('Playlist Progress:'),
                      LinearProgressIndicator(
                        value: progress.playlistProgress / 100,
                      ),
                      Text('${progress.playlistProgress.toStringAsFixed(2)}%'),
                    ],
                  );
                } else {
                  return Text('Starting download...');
                }
              },
            ),
          ),
      ],
    );
  }

  Widget _buildDownloadListContent() {
    return _downloadController != null && _downloadController!.downloadedVideos.isNotEmpty
        ? Container(
      height: 200,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _downloadController!.downloadedVideos.length,
        itemBuilder: (context, index) {
          final videoTitle = _downloadController!.downloadedVideos[index];
          return ListTile(
            title: Text(videoTitle),
            leading: Icon(Icons.download_done),
            dense: true,
          );
        },
      ),
    )
        : Container(
      child: Text('No latest downloads to show'),
    );
  }
}