import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

class OfflineQrService {
  /// Verifies HMAC signature and expiry. Returns purchaseId if valid, null otherwise.
  static String? verify(String token) {
    final parts = token.trim().split('|');
    if (parts.length != 3) return null;

    final purchaseId = parts[0];
    final epochStr = parts[1];
    final providedSig = parts[2];

    final epoch = int.tryParse(epochStr);
    if (epoch == null) return null;

    final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (epoch < nowEpoch) return null; // expired

    final payload = '$purchaseId|$epochStr';
    final key = utf8.encode(AppConstants.qrSecret);
    final bytes = utf8.encode(payload);
    final expectedSig = Hmac(sha256, key).convert(bytes).toString().substring(0, 32);

    if (expectedSig != providedSig) return null;
    return purchaseId;
  }

  /// Adds a confirmed scan to the local queue for later sync.
  static Future<void> enqueue(String purchaseId, int ridesCount) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.offlineQueueKey) ?? '[]';
    final list = List<Map<String, dynamic>>.from(
      (jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e as Map)),
    );
    list.add({
      'purchaseId': purchaseId,
      'ridesCount': ridesCount,
      'scannedAt': DateTime.now().toIso8601String(),
    });
    await prefs.setString(AppConstants.offlineQueueKey, jsonEncode(list));
  }

  /// Returns all pending offline scans.
  static Future<List<Map<String, dynamic>>> getQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.offlineQueueKey) ?? '[]';
    return List<Map<String, dynamic>>.from(
      (jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e as Map)),
    );
  }

  /// Removes successfully synced items from the queue.
  static Future<void> removeFromQueue(List<String> syncedPurchaseIds) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = await getQueue();
    final remaining = queue.where((e) => !syncedPurchaseIds.contains(e['purchaseId'])).toList();
    await prefs.setString(AppConstants.offlineQueueKey, jsonEncode(remaining));
  }
}
