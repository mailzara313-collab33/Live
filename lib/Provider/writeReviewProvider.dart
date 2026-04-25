import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eshop_multivendor/Helper/curlLoggerInterceptor.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Helper/String.dart';
import '../Helper/routes.dart';
import '../widgets/networkAvailablity.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../widgets/security.dart';
import '../widgets/snackbar.dart';

class WriteReviewProvider extends ChangeNotifier {
  double curRating = 0.0;
  List<File> reviewPhotos = [];
  TextEditingController commentTextController = TextEditingController();
  setcurrentRatting(double value) {
    curRating = value;
  }

  setreviewPhotos(value) {
    reviewPhotos = value;
  }

  getReviewPhotoatindex(int index) {
    return reviewPhotos[index];
  }

  Future<void> setRating(
    var productID,
    BuildContext context,
    BuildContext screenContext,
    Function update,
  ) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        var request = http.MultipartRequest('POST', setRatingApi);
        request.headers.addAll(headers ?? {});
        request.fields[PRODUCT_ID] = productID;
        print("jkdcvfjh---${reviewPhotos.length}");
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

        if (commentTextController.text != '') {
          request.fields[COMMENT] = commentTextController.text;
        }

        // Log the request as cURL
        logHttpMultipartRequestAsCurl(request);
        if (curRating != 0) request.fields[RATING] = curRating.toString();
        var response = await request.send();
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var getdata = json.decode(responseString);
        bool error = getdata['error'];
        String? msg = getdata['message'];

        if (!error) {
          Routes.pop(context);
          setSnackbar(msg!, screenContext);
        } else {
          setSnackbar(msg!, screenContext);
        }
        commentTextController.text = '';
        reviewPhotos.clear();
      } on TimeoutException catch (_) {
        setSnackbar('somethingMSg'.translate(context: context), screenContext);
      }
    } else {
      isNetworkAvail = false;
      update();
    }
  }
}
