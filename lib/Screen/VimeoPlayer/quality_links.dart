import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class QualityLinks {
  String videoId;

  QualityLinks(this.videoId);

  dynamic getQualitiesSync() {
    return getQualitiesAsync();
  }

  // Future<SplayTreeMap?> getQualitiesAsync() async {
  //   try {
  //     var response = await http.get(
  //         Uri.parse('https://player.vimeo.multivendor/video/$videoId/config'));
  //     var jsonData =
  //         jsonDecode(response.body)['request']['files']['progressive'];
  //     SplayTreeMap videoList = SplayTreeMap.fromIterable(jsonData,
  //         key: (item) => "${item['quality']} ${item['fps']}",
  //         value: (item) => item['url']);
  //     return videoList;
  //   } catch (error) {
  //     return null;
  //   }
  // }

  Future<SplayTreeMap?> getQualitiesAsync() async {
    try {
      var response = await http.get(
        Uri.parse('https://player.vimeo.com/video/$videoId/config'),
      );

      var jsonData = jsonDecode(response.body);

      // Try progressive first
      var progressive = jsonData['request']['files']['progressive'];
      if (progressive != null) {
        SplayTreeMap videoList = SplayTreeMap.fromIterable(jsonData,
            key: (item) => "${item['quality']} ${item['fps']}",
            value: (item) => item['url']);
        return videoList;
      }

      // If progressive not available, fallback to HLS
      var hls = jsonData['request']['files']['hls']?['cdns'];
      if (hls != null) {
        SplayTreeMap videoList = SplayTreeMap();
        hls.forEach((cdn, data) {
          videoList['HLS ($cdn)'] = data['url'];
        });
        return videoList;
      }

      return null; // neither available
    } catch (error) {
      debugPrint('❌ Vimeo error: $error');
      return null;
    }
  }
}
