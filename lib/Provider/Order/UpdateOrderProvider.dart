import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eshop_multivendor/Helper/curlLoggerInterceptor.dart';
import 'package:eshop_multivendor/repository/Order/UpdateOrderRepository.dart';
import 'package:flutter/material.dart';
import '../../Helper/String.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import '../../widgets/security.dart';
import '../../widgets/snackbar.dart';

enum UpdateOrdStatus { initial, inProgress, isSuccsess, isFailure }

class UpdateOrdProvider extends ChangeNotifier {
  Future<List<Directory>?>? externalStorageDirectories;
  UpdateOrdStatus _UpdateOrdStatus = UpdateOrdStatus.initial;
  String errorMessage = '';
  bool isReturnClick = true;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  ScrollController controller = ScrollController();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  late TabController tabController;
  List<File> files = [];
  String updatedComment = '';
  List<File> reviewPhotos = [];
  double curRating = 0.0;
  TextEditingController commentTextController = TextEditingController();
  GlobalKey<FormState> commentTextFieldKey = GlobalKey<FormState>();
  String currentLinkForDownload = '';
  String selectedReason = '';
  List<File> imageVideoFiles = [];
  late final TextEditingController otherReasonTextEditingController =
      TextEditingController();

  get getCurrentStatus => _UpdateOrdStatus;

  // meesage of cancelation
  String? msg;

  changeStatus(UpdateOrdStatus status) {
    _UpdateOrdStatus = status;
    notifyListeners();
  }

  Future<String?> cancelOrder(
    String ordId,
    Uri api,
    String status, {
    String? returnReason,
    List<File>? returnItemMedia,
    String? otherReason,
  }) async {
    try {
      print("Media files------>${returnItemMedia}");
      var request = http.MultipartRequest('POST', api);
      request.headers.addAll(headers ?? {});

      request.fields[ORDERID] = ordId;
      request.fields[STATUS] = status;
      if (returnReason != null) request.fields[RETURN_REASON] = returnReason;
      if (otherReason != null) request.fields[OTHER_REASON] = otherReason;

      // Attach media files (images and videos)
      if (returnItemMedia != null) {
        for (var file in returnItemMedia) {
          final mimeType = lookupMimeType(file.path);
          if (mimeType != null) {
            var extension = mimeType.split('/');
            var fileType = extension[0] == 'image' ? 'image' : 'video';
            var mediaFile = await http.MultipartFile.fromPath(
              fileType == 'image' ? 'image_document' : 'video_document',
              file.path,
              contentType: MediaType(fileType, extension[1]),
            );
            request.files.add(mediaFile);
          }
        }
      }
      // Log the request as cURL
      logHttpMultipartRequestAsCurl(request);
      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);

      print('Raw Response: $responseString');
      var getdata = json.decode(responseString);

      bool error = getdata['error'];
      if (!error) {
        changeStatus(UpdateOrdStatus.isSuccsess);
        returnItemMedia?.clear();
        return getdata['message']; // Return success message
      } else {
        changeStatus(UpdateOrdStatus.isFailure);
        return getdata['message']; // Return error message
      }
    } catch (e) {
      errorMessage = e.toString();
      print("Error Message---->${errorMessage}");
      changeStatus(UpdateOrdStatus.isFailure);
      return errorMessage; // Return error message
    }
  }

  /* Future<String?> cancelOrder(String ordId, Uri api, String status,
      {String? returnReason,
      List<File>? returnItemImage,
      String? otherReason}) async {
    try {
      print("images------>${returnItemImage}");
      var request = http.MultipartRequest('POST', api);
      request.headers.addAll(headers ?? {});

      request.fields[ORDERID] = ordId;
      request.fields[STATUS] = status;
      if (returnReason != null) request.fields[RETURN_REASON] = returnReason;
      if (otherReason != null) request.fields[OTHER_REASON] = otherReason;

      // Attach images
      if (returnItemImage != null) {
        for (var file in returnItemImage) {
          final mimeType = lookupMimeType(file.path);
          if (mimeType != null) {
            var extension = mimeType.split('/');
            var pic = await http.MultipartFile.fromPath(
              DOCUMENT,
              file.path,
              contentType: MediaType('image', extension[1]),
            );
            request.files.add(pic);
          }
        }
      }

      var response = await request.send();
      print('response:---->${response.toString()}');

      var responseData = await response.stream.toBytes();
      print('responsedata:---->${responseData.toString()}');

      var responseString = String.fromCharCodes(responseData);

      print('Raw Response: $responseString');

      var getdata = json.decode(responseString);
      print('getdata response place order****$getdata');

      bool error = getdata['error'];
      if (!error) {
        changeStatus(UpdateOrdStatus.isSuccsess);
        returnItemImage?.clear();
        return getdata['message']; // Return success message
      } else {
        changeStatus(UpdateOrdStatus.isFailure);
        return getdata['message']; // Return error message
      }
    } catch (e) {
      errorMessage = e.toString();
      print("errormeassge---->${errorMessage}");
      changeStatus(UpdateOrdStatus.isFailure);
      return errorMessage; // Return error message
    }
  }
*/

  Future<bool> getDownloadLink(
    BuildContext context,
    String orderIteamId,
  ) async {
    try {
      changeStatus(UpdateOrdStatus.inProgress);
      var parameter = {'order_item_id': orderIteamId};

      var result = await UpdateOrderRepository.cancelOrder(
        parameter: parameter,
        api: downloadLinkHashApi,
      );

      bool error = result['error'];
      setSnackbar(result['message'], context);
      print('error downloading order**$error');
      if (!error) {
        currentLinkForDownload = result['data'];
      }
      //isReturnClick = true;
      changeStatus(UpdateOrdStatus.isSuccsess);
      return error;
    } catch (e) {
      errorMessage = e.toString();
      changeStatus(UpdateOrdStatus.isFailure);
      return true;
    }
  }

  Future<void> sendBankProof(String id, BuildContext context) async {
    try {
      changeStatus(UpdateOrdStatus.inProgress);
      var request = await UpdateOrderRepository.sendBankProof();
      request.headers.addAll(headers);
      request.fields[ORDER_ID] = id;
      for (var i = 0; i < files.length; i++) {
        final mimeType = lookupMimeType(files[i].path);
        var extension = mimeType!.split('/');
        var pic = await http.MultipartFile.fromPath(
          ATTACH,
          files[i].path,
          contentType: MediaType('image', extension[1]),
        );
        request.files.add(pic);
      }
      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      var getdata = json.decode(responseString);
      String msg = getdata['message'];
      changeStatus(UpdateOrdStatus.isSuccsess);
      files.clear();

      print("msg***$msg");
      setSnackbar(msg, context);
    } on TimeoutException catch (_) {
      setSnackbar('somethingMSg'.translate(context: context), context);
    }
  }

  Future<void> setRating(
    double rating,
    var productID,
    BuildContext context1,
  ) async {
    try {
      changeStatus(UpdateOrdStatus.inProgress);
      var request = await UpdateOrderRepository.setRating();
      request.headers.addAll(headers);
      request.fields[PRODUCT_ID] = productID;

      if (reviewPhotos.isNotEmpty) {
        for (var i = 0; i < reviewPhotos.length; i++) {
          final mimeType = lookupMimeType(reviewPhotos[i].path);
          var extension = mimeType!.split('/');
          var pic = await http.MultipartFile.fromPath(
            IMGS,
            reviewPhotos[i].path,
            contentType: MediaType('image', extension[1]),
          );

          request.files.add(pic);
        }
      }

      if (updatedComment != '') request.fields[COMMENT] = updatedComment;
      if (rating != 0) request.fields[RATING] = rating.toString();
      print(
        "request----$setRatingApi------param----${request.fields}--header----$headers",
      );

      var response = await request.send();

      var responseData = await response.stream.toBytes();

      var responseString = String.fromCharCodes(responseData);

      var getdata = json.decode(responseString);

      bool error = getdata['error'];
      msg = getdata['message'];

      setSnackbar(msg!.translate(context: context1), context1);
      if (error != true) {}
      changeStatus(UpdateOrdStatus.isSuccsess);
    } on TimeoutException catch (_) {
      changeStatus(UpdateOrdStatus.isSuccsess);
      setSnackbar('somethingMSg'.translate(context: context1), context1);
    }
  }
}
