import 'package:dio/dio.dart';
import 'package:nfc_manager/nfc_manager.dart';
import '../config/api_config.dart';
import '../models/group_model.dart';
import '../models/api_response.dart';
import 'api_service.dart';

class NfcScanService {
  final ApiService _api = ApiService();

  Future<bool> get isAvailable => NfcManager.instance.isAvailable();

  /// Starts an NFC reader session (bypasses Android dispatch via enableReaderMode).
  /// [onTagRead] fires with the card UID hex string when a tag is tapped.
  /// [onError]   fires with a human-readable message on failure.
  ///
  /// IMPORTANT: await this call — it resolves only after enableReaderMode is
  /// registered on the Android NfcAdapter, so the system dispatch is already
  /// suppressed before the function returns.
  Future<void> startListening({
    required void Function(String uid) onTagRead,
    required void Function(String error) onError,
  }) async {
    final available = await isAvailable;
    if (!available) {
      onError('NFC is not available on this device');
      return;
    }

    // Awaiting startSession() ensures enableReaderMode() is registered
    // BEFORE this function returns, eliminating the race with Android dispatch.
    await NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          final uid = _extractUid(tag);
          onTagRead(uid);
        } catch (e) {
          onError(e.toString().replaceFirst('Exception: ', ''));
        }
      },
    );
  }

  Future<void> stopSession() => NfcManager.instance.stopSession();

  String _extractUid(NfcTag tag) {
    final data = tag.data;

    // isodep = phone HCE / smart card — not a UGO ride card
    if (data.containsKey('isodep')) {
      throw Exception(
        'This looks like a phone, not a UGO NFC card.\nUse the QR Code tab to scan a QR code.',
      );
    }

    List<int>? identifier;

    if (data.containsKey('nfca')) {
      identifier = List<int>.from(data['nfca']['identifier'] as List);
    } else if (data.containsKey('nfcb')) {
      identifier = List<int>.from(data['nfcb']['applicationData'] as List);
    } else if (data.containsKey('nfcf')) {
      identifier = List<int>.from(data['nfcf']['identifier'] as List);
    } else if (data.containsKey('nfcv')) {
      identifier = List<int>.from(data['nfcv']['identifier'] as List);
    } else if (data.containsKey('mifareclassic')) {
      identifier = List<int>.from(data['mifareclassic']['identifier'] as List);
    } else if (data.containsKey('mifareultralight')) {
      identifier = List<int>.from(data['mifareultralight']['identifier'] as List);
    }

    if (identifier == null || identifier.isEmpty) {
      throw Exception('Unrecognised card type. Please use a UGO NFC ride card.');
    }

    return identifier
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join(':')
        .toUpperCase();
  }

  Future<ApiResponse<ScanResult>> previewScan(String cardUid) async {
    try {
      final response = await _api.get(
        ApiConfig.nfcScan,
        queryParameters: {'uid': cardUid},
      );
      if (response.statusCode == 200) {
        return ApiResponse.success(
          data: ScanResult.fromJson(response.data['data']),
          message: response.data['message'],
        );
      }
      return ApiResponse.failure(
        message: response.data['error']?['message'] ?? 'NFC scan failed',
      );
    } on DioException catch (e) {
      return ApiResponse.failure(message: _api.handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> confirmScan(
      String purchaseId, int ridesCount) async {
    try {
      final response = await _api.post(ApiConfig.nfcConfirm, data: {
        'purchase_id': purchaseId,
        'rides_count': ridesCount,
      });
      if (response.statusCode == 200) {
        return ApiResponse.success(
          data: Map<String, dynamic>.from(response.data['data']),
          message: response.data['message'],
        );
      }
      return ApiResponse.failure(
        message: response.data['error']?['message'] ?? 'Confirmation failed',
      );
    } on DioException catch (e) {
      return ApiResponse.failure(message: _api.handleError(e));
    }
  }
}
