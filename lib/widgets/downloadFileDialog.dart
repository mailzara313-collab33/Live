import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/String.dart';

import 'package:eshop_multivendor/cubits/downloadFileCubit.dart';
import 'package:eshop_multivendor/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';

class DownloadFileDialog extends StatefulWidget {
  final String fileUrl;
  final String fileName;
  final String fileExtension;
  final bool storeInExternalStorage;
  const DownloadFileDialog(
      {super.key,
      required this.fileExtension,
      required this.fileName,
      required this.fileUrl,
      required this.storeInExternalStorage});

  @override
  State<DownloadFileDialog> createState() => _DownloadFileDialogState();
}

class _DownloadFileDialogState extends State<DownloadFileDialog> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      context.read<DownloadFileCubit>().downloadFile(
          fileUrl: widget.fileUrl,
          fileName: widget.fileName,
          fileExtension: widget.fileExtension,
          storeInExternalStorage: widget.storeInExternalStorage);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (context.read<DownloadFileCubit>().state is DownloadFileInProgress) {
          context.read<DownloadFileCubit>().cancelDownloadProcess();
        }
      },
      child: BlocConsumer<DownloadFileCubit, DownloadFileState>(
        listener: (context, state) {
          if (state is DownloadFileFailure) {
            setSnackbar(state.errorMessage, context);
            Navigator.of(context).pop();
          } else if (state is DownloadFileSuccess) {
            Navigator.of(context).pop();
            OpenFile.open(state.downloadedFileUrl);
          }
        },
        builder: (context, state) {
          Widget content =
              Text('${'PROGRESS'.translate(context: context)} : -');
          if (state is DownloadFileInProgress) {
            content = Text(
                '${'PROGRESS'.translate(context: context)} : ${state.downloadPercentage.toStringAsFixed(2)}',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.lightBlack));
          } else if (state is DownloadFileSuccess) {
            content = Text('FILE_DOWNLOAD_SUCCESS'.translate(context: context));
          }

          return AlertDialog(
              title: Text(
                'FILE_DOWNLOAD_PROGRESS'.translate(context: context),
                style:
                    TextStyle(color: Theme.of(context).colorScheme.lightBlack),
              ),
              content: content);
        },
      ),
    );
  }
}
