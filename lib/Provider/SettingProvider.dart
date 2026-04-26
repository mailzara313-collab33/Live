import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Helper/String.dart';

// Keys stored in encrypted secure storage (Android Keystore / iOS Keychain)
const _secureKeys = [TOKEN, FCMTOKEN, EMAIL, MOBILE, ID, LATITUDE, LONGITUDE, IMAGE];

class SettingProvider {
  late SharedPreferences _sharedPreferences;

  // Secure storage for sensitive PII and auth tokens
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // In-memory cache for secure values so getters remain synchronous
  final Map<String, String?> _secureCache = {};

  SettingProvider(SharedPreferences sharedPreferences) {
    _sharedPreferences = sharedPreferences;
  }

  /// Call once at app startup (after SettingProvider is created) to
  /// populate the in-memory cache from secure storage.
  Future<void> initSecureCache() async {
    for (final key in _secureKeys) {
      _secureCache[key] = await _secureStorage.read(key: key);
    }
  }

  // ----------------------------------------------------------------
  // Sensitive getters — served from in-memory cache (loaded at init)
  // ----------------------------------------------------------------
  String? get token    => _secureCache[TOKEN];
  String? get fcmId   => _secureCache[FCMTOKEN];
  String? get userId  => _secureCache[ID];
  String  get email   => _secureCache[EMAIL] ?? '';
  String  get mobile  => _secureCache[MOBILE] ?? '';
  String  get profileUrl => _secureCache[IMAGE] ?? '';

  // ----------------------------------------------------------------
  // Non-sensitive getters — remain in SharedPreferences
  // ----------------------------------------------------------------
  String get userName    => _sharedPreferences.getString(USERNAME) ?? '';
  String get loginType   => _sharedPreferences.getString(TYPE) ?? '';
  String get countryCode => _sharedPreferences.getString(COUNTRY_CODE) ?? '';

  // ----------------------------------------------------------------
  // Write helpers
  // ----------------------------------------------------------------
  Future<void> _writeSecure(String key, String value) async {
    _secureCache[key] = value;
    await _secureStorage.write(key: key, value: value);
  }

  Future<void> _deleteSecure(String key) async {
    _secureCache[key] = null;
    await _secureStorage.delete(key: key);
  }

  void setPrefrence(String key, String value) {
    _sharedPreferences.setString(key, value);
  }

  Future<String?> getPrefrence(String key) async {
    if (_secureKeys.contains(key)) {
      return _secureCache[key];
    }
    return _sharedPreferences.getString(key);
  }

  Future<String?> getSessionValue(String key) async {
    return getPrefrence(key);
  }

  void setPrefrenceBool(String key, bool value) {
    _sharedPreferences.setBool(key, value);
  }

  Future<void> setPrefrenceList(String key, String query) async {
    List<String> valueList = await getPrefrenceList(key);
    if (!valueList.contains(query)) {
      if (valueList.length > 4) valueList.removeAt(0);
      valueList.add(query);
      _sharedPreferences.setStringList(key, valueList);
    }
  }

  Future<void> removeValuePrefrenceList(String key, String query) async {
    List<String> valueList = await getPrefrenceList(key);
    valueList.removeWhere((item) => item == query);
    _sharedPreferences.setStringList(key, valueList);
  }

  Future<List<String>> getPrefrenceList(String key) async {
    return _sharedPreferences.getStringList(key) ?? [];
  }

  Future<bool> getPrefrenceBool(String key) async {
    return _sharedPreferences.getBool(key) ?? false;
  }

  // ----------------------------------------------------------------
  // Session management
  // ----------------------------------------------------------------
  Future<void> saveUserDetail(
      String userId,
      String? name,
      String? email,
      String? mobile,
      String? city,
      String? area,
      String? address,
      String? pincode,
      String? latitude,
      String? longitude,
      String? image,
      String? type,
      String? referCode,
      String? token,
      String? countryCode,
      BuildContext context) async {
    // Write sensitive fields to secure storage
    await Future.wait([
      _writeSecure(ID, userId),
      _writeSecure(EMAIL, email ?? ''),
      _writeSecure(MOBILE, mobile ?? ''),
      _writeSecure(LATITUDE, latitude ?? ''),
      _writeSecure(LONGITUDE, longitude ?? ''),
      _writeSecure(IMAGE, image ?? ''),
      if (token != null) _writeSecure(TOKEN, token),
    ]);

    // Write non-sensitive fields to SharedPreferences
    await Future.wait([
      _sharedPreferences.setString(USERNAME, name ?? ''),
      _sharedPreferences.setString(CITY, city ?? ''),
      _sharedPreferences.setString(AREA, area ?? ''),
      _sharedPreferences.setString(ADDRESS, address ?? ''),
      _sharedPreferences.setString(PINCODE, pincode ?? ''),
      _sharedPreferences.setString(TYPE, type ?? ''),
      _sharedPreferences.setString(REFERCODE, referCode ?? ''),
      _sharedPreferences.setString(COUNTRY_CODE, countryCode ?? ''),
    ]);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.setUserId(userId);
    userProvider.setName(name ?? '');
    userProvider.setBalance('');
    userProvider.setCartCount('');
    userProvider.setProfilePic(image ?? '');
    userProvider.setMobile(mobile ?? '');
    userProvider.setEmail(email ?? '');
    userProvider.setLoginType(type ?? '');
    userProvider.setReferCode(referCode ?? '');
    userProvider.setCountrycode(countryCode ?? '');
  }

  Future<void> clearUserSession(BuildContext context) async {
    final getTheme    = _sharedPreferences.getString(APP_THEME);
    final getLanguage = _sharedPreferences.getString(LAGUAGE_CODE);

    // Wipe secure storage entries
    await Future.wait(_secureKeys.map((k) => _deleteSecure(k)));

    // Wipe SharedPreferences
    await _sharedPreferences.clear();

    // Restore non-sensitive UI preferences
    if (getTheme != null)    setPrefrence(APP_THEME, getTheme);
    if (getLanguage != null) setPrefrence(LAGUAGE_CODE, getLanguage);
    setPrefrenceBool(ISFIRSTTIME, true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    context.read<UserProvider>().setPincode('');
    userProvider.setUserId('');
    userProvider.setName('');
    userProvider.setBalance('');
    userProvider.setCartCount('');
    userProvider.setProfilePic('');
    userProvider.setMobile('');
    userProvider.setCartCount('');
    userProvider.setEmail('');
    userProvider.setLoginType('');
    userProvider.setReferCode('');
    userProvider.setCountrycode('');
  }

  Future<void> setCurrentSellerID(String value) async {
    setPrefrence('CurrentSellerID', value);
  }

  Future<String?> getCurrentSellerID(String value) async {
    return _sharedPreferences.getString('CurrentSellerID');
  }

  /// Write FCM token to secure storage and update cache.
  Future<void> saveFcmToken(String fcmToken) async {
    await _writeSecure(FCMTOKEN, fcmToken);
  }
}

// Top-level helper kept for backward compatibility with existing callers.
Future<void> setPrefrenceBool(String key, bool value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(key, value);
}
