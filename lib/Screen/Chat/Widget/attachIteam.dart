import 'dart:io';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Helper/assetsConstant.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../../Helper/Constant.dart';
import '../../../Model/Model.dart';
import '../../../Provider/chatProvider.dart';
import '../../../widgets/desing.dart';
import '../../../widgets/snackbar.dart';

// ignore: must_be_immutable
class AttachIteam extends StatefulWidget {
  List<attachment> attach;
  Model message;
  int index;
  AttachIteam({
    super.key,
    required this.attach,
    required this.message,
    required this.index,
  });

  @override
  State<AttachIteam> createState() => _AttachIteamState();
}

class _AttachIteamState extends State<AttachIteam> {
  void _requestDownload(
    String? url,
    String? mid,
    AsyncSnapshot snapshot,
  ) async {
    if (url == null || mid == null) return;

    bool hasPermission = await checkPermission(snapshot);
    if (!hasPermission) return;

    final chatProvider = context.read<ChatProvider>();

    // Set target download path
    if (Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      chatProvider.filePath = directory.path;
    } else {
      if (snapshot.hasData) {
        final paths =
            snapshot.data!.map((Directory d) => d.path).toList().join(', ');
        chatProvider.filePath = paths;
      }
    }

    final fileName = url.substring(url.lastIndexOf('/') + 1);
    final file = File('${chatProvider.filePath}/$fileName');

    final fileExists = await file.exists();

    final existingTaskId = chatProvider.downloadlist[mid];

    // Check task status if it exists
    if (existingTaskId != null) {
      final tasks = await FlutterDownloader.loadTasksWithRawQuery(
        query: 'SELECT status FROM task WHERE task_id="$existingTaskId"',
      );

      final status = tasks?.first.status;

      // Remove task if it's complete (4) or failed (5)
      if (status == DownloadTaskStatus.complete ||
          status == DownloadTaskStatus.failed) {
        chatProvider.downloadlist.remove(mid);
      }
    }

    // Skip if file already exists
    if (fileExists) {
      return;
    }

    // Prevent duplicate downloads
    if (chatProvider.downloadlist.containsKey(mid)) {
      setSnackbar('Downloading'.translate(context: context), context);
      return;
    }

    // Enqueue download
    setSnackbar('Downloading'.translate(context: context), context);

    final taskId = await FlutterDownloader.enqueue(
      url: url,
      savedDir: chatProvider.filePath,
      headers: {'auth': 'test_for_sql_encoding'},
      showNotification: true,
      openFileFromNotification: true,
    );

    setState(() {
      chatProvider.downloadlist[mid] = taskId!;
    });
  }

  Future<bool> checkPermission(AsyncSnapshot snapshot) async {
    var status = await Permission.storage.status;

    if (status != PermissionStatus.granted) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();

      if (statuses[Permission.storage] == PermissionStatus.granted) {
        fileDirectoryPrepare(snapshot);
        return true;
      }
    } else {
      fileDirectoryPrepare(snapshot);
      return true;
    }
    return false;
  }

  Future<void> fileDirectoryPrepare(AsyncSnapshot snapshot) async {
    if (Platform.isIOS) {
      Directory target = await getApplicationDocumentsDirectory();
      context.read<ChatProvider>().filePath = target.path.toString();
    } else {
      if (snapshot.hasData) {
        context.read<ChatProvider>().filePath =
            snapshot.data!.map((Directory d) => d.path).join(', ');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String? file = widget.attach[widget.index].media;
    String? type = widget.attach[widget.index].type;
    String icon;
    if (type == 'video') {
      icon = Assets.video;
    } else if (type == 'document') {
      icon = Assets.doc;
    } else if (type == 'spreadsheet') {
      icon = Assets.sheet;
    } else {
      icon = Assets.zip;
    }
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    return FutureBuilder<List<Directory>?>(
      future: context.read<ChatProvider>().externalStorageDirectories,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return file == null
            ? const SizedBox()
            : Stack(
                alignment: Alignment.bottomRight,
                children: <Widget>[
                  Card(
                    elevation: 0.0,
                    color: widget.message.uid == userProvider.userId
                        ? Theme.of(context)
                            .colorScheme
                            .fontColor
                            .withValues(alpha: 0.1)
                        : Theme.of(context).colorScheme.white,
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        crossAxisAlignment:
                            widget.message.uid == userProvider.userId
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              _requestDownload(
                                  widget.attach[widget.index].media,
                                  widget.message.id,
                                  snapshot);
                            },
                            child: type == 'image'
                                ? Image.network(file,
                                    width: 250,
                                    height: 150,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            DesignConfiguration.erroWidget(150))
                                : SvgPicture.asset(
                                    DesignConfiguration.setSvgPath(icon),
                                    width: 100,
                                    height: 100,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        widget.message.date!,
                        style: TextStyle(
                          fontFamily: 'ubuntu',
                          color: Theme.of(context).colorScheme.lightBlack,
                          fontSize: textFontSize9,
                        ),
                      ),
                    ),
                  ),
                ],
              );
      },
    );
  }
}
