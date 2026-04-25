import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HasUnreadChatRepository {
  static const String hasUnreadChatKey = 'has-unread-chats';
  static ValueNotifier<bool> hasUnreadChats = ValueNotifier(false);

  static Future<void> initialCheckForUnreadChats() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    hasUnreadChats.value = prefs.getBool(hasUnreadChatKey) ?? false;
  }

  static Future<void> setChatUnread(bool value) async {
    hasUnreadChats.value = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    await prefs.setBool(hasUnreadChatKey, value);
  }
}
