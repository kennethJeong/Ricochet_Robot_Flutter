import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return dotenv.env['admob_aos_unitId_banner'].toString();
    } else if (Platform.isIOS) {
      return dotenv.env['admob_ios_unitId_banner'].toString();
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  static String get nativeAdUnitId {
    if (Platform.isAndroid) {
      return dotenv.env['admob_aos_unitId_native'].toString();
    } else if (Platform.isIOS) {
      return dotenv.env['admob_ios_unitId_native'].toString();
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return dotenv.env['admob_aos_unitId_interstitial'].toString();
    } else if (Platform.isIOS) {
      return dotenv.env['admob_ios_unitId_interstitial'].toString();
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }
}