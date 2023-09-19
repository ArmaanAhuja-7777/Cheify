import 'package:flutter/services.dart';
import 'package:eventify/eventify.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io' show Platform;
import 'dart:convert';
import 'dart:convert';
import 'package:crypto/crypto.dart';
// import '../../infrastructure/models/data/profile_data.dart';

import 'package:http/http.dart' as http;
import 'package:riverpodtemp/domain/iterface/user.dart';
import 'package:riverpodtemp/infrastructure/repository/user_repository.dart';

// ProfileData profile = ProfileData();

// String? get phone => _phone;
// String? get email => _email;

class Razorpay {
  static final razorPayKey = "rzp_test_JCogGr6nrS7s3C";
  static final razorPaySecret = "mYV9H3AFI9VOP4o5qc0AvY4x";
  // Response codes from platform
  static const _CODE_PAYMENT_SUCCESS = 0;
  static const _CODE_PAYMENT_ERROR = 1;
  static const _CODE_PAYMENT_EXTERNAL_WALLET = 2;

  // Event names
  static const EVENT_PAYMENT_SUCCESS = 'payment.success';
  static const EVENT_PAYMENT_ERROR = 'payment.error';
  static const EVENT_EXTERNAL_WALLET = 'payment.external_wallet';

  // Payment error codes
  static const NETWORK_ERROR = 0;
  static const INVALID_OPTIONS = 1;
  static const PAYMENT_CANCELLED = 2;
  static const TLS_ERROR = 3;
  static const INCOMPATIBLE_PLUGIN = 4;
  static const UNKNOWN_ERROR = 100;

  static const MethodChannel _channel = const MethodChannel('razorpay_flutter');

  // EventEmitter instance used for communication
  late EventEmitter _eventEmitter;

  Razorpay() {
    _eventEmitter = new EventEmitter();
  }

  /// Opens Razorpay checkout
  Future<bool> open(Map<String, dynamic> options) async {
    Map<String, dynamic> validationResult = _validateOptions(options);

    if (!validationResult['success']) {
      _handleResult({
        'type': _CODE_PAYMENT_ERROR,
        'data': {
          'code': INVALID_OPTIONS,
          'message': validationResult['message']
        }
      });
      return false;
    }

    if (Platform.isAndroid) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      _channel.invokeMethod('setPackageName', packageInfo.packageName);
    }

    var response = await _channel.invokeMethod('open', options);
    var success = false;
    switch (response['type']) {
      case _CODE_PAYMENT_SUCCESS:
        success = true;
        Map<dynamic, dynamic>? data = response["data"];
        var payload = PaymentSuccessResponse.fromMap(data!);
        bool isPaymentSuccessful = verifySignature(payload.orderId ?? "",
            payload.paymentId ?? "", payload.signature ?? "", razorPaySecret);
        success = isPaymentSuccessful;
        break;

      case _CODE_PAYMENT_ERROR:
        success = false;
        break;

      case _CODE_PAYMENT_EXTERNAL_WALLET:
        success = false;
        break;

      default:
        success = false;
    }

    return success;

    // _handleResult(response);
  }

  bool verifySignature(String orderID, String razorpayPaymentID,
      String razorpaySignature, String secret) {
    String data = "$orderID|$razorpayPaymentID";

    // Create a HMAC-SHA256 hash of the data using the secret key
    var hmac = Hmac(sha256, utf8.encode(secret));
    var digest = hmac.convert(utf8.encode(data));

    // Convert the computed hash to hexadecimal format
    String computedSignature = digest.toString();

    // Compare the computed signature with the provided razorpaySignature
    print("SIG:" + computedSignature + " ;;;;; " + razorpaySignature);
    return computedSignature == razorpaySignature;
  }

  razorPayApi(num amount, String receiptId) async {
    var auth =
        'Basic ' + base64Encode(utf8.encode('$razorPayKey:$razorPaySecret'));
    var headers = {'content-type': 'application/json', 'Authorization': auth};
    var request =
        http.Request('POST', Uri.parse('https://api.razorpay.com/v1/orders'));
    request.body = json
        .encode({"amount": amount, "currency": "INR", "receipt": receiptId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    // print(response.statusCode);
    if (response.statusCode == 200) {
      return {
        "status": "success",
        "body": jsonDecode(await response.stream.bytesToString())
      };
    } else {
      return {"status": "fail", "message": (response.reasonPhrase)};
    }
  }

  Future<bool> openSession(
      {required num amount, required String orderId}) async {
    amount = (amount * 100).toInt();
    var order = await createOrder(amount: amount, orderId: orderId);
    if (order.toString().isNotEmpty) {
      var options = {
        'key': razorPayKey, //Razor pay API Key
        'amount': amount, //in the smallest currency sub-unit.
        'name': 'Cheify',
        'order_id': order, // Generate order_id using Orders API
        'description':
            'Order From App', //Order Description to be shown in razor pay page
        // 'timeout': 60, // in seconds
        // 'prefill': {
        //   'contact': phone,
        //   'email': email
        // } //contact number and email id of user
      };
      return await open(options);
    }
    return false;
  }

  createOrder({required num amount, required String orderId}) async {
    final myData = await razorPayApi(amount, orderId);
    if (myData["status"] == "success") {
      print(myData);
      return myData["body"]["id"];
    } else {
      return "";
    }
  }

  /// Handles checkout response from platform
  void _handleResult(Map<dynamic, dynamic> response) {
    String eventName;
    Map<dynamic, dynamic>? data = response["data"];

    dynamic payload;

    switch (response['type']) {
      case _CODE_PAYMENT_SUCCESS:
        eventName = EVENT_PAYMENT_SUCCESS;
        payload = PaymentSuccessResponse.fromMap(data!);
        break;

      case _CODE_PAYMENT_ERROR:
        eventName = EVENT_PAYMENT_ERROR;
        payload = PaymentFailureResponse.fromMap(data!);
        break;

      case _CODE_PAYMENT_EXTERNAL_WALLET:
        eventName = EVENT_EXTERNAL_WALLET;
        payload = ExternalWalletResponse.fromMap(data!);
        break;

      default:
        eventName = 'error';
        payload = PaymentFailureResponse(
            UNKNOWN_ERROR, 'An unknown error occurred.', null);
    }

    _eventEmitter.emit(eventName, null, payload);
  }

  /// Registers event listeners for payment events
  void on(String event, Function handler) {
    EventCallback cb = (event, cont) {
      handler(event.eventData);
    };
    _eventEmitter.on(event, null, cb);
    _resync();
  }

  /// Clears all event listeners
  void clear() {
    _eventEmitter.clear();
  }

  /// Retrieves lost responses from platform
  void _resync() async {
    var response = await _channel.invokeMethod('resync');
    if (response != null) {
      _handleResult(response);
    }
  }

  /// Validate payment options
  static Map<String, dynamic> _validateOptions(Map<String, dynamic> options) {
    var key = options['key'];
    if (key == null) {
      return {
        'success': false,
        'message': 'Key is required. Please check if key is present in options.'
      };
    }
    return {'success': true};
  }
}

class PaymentSuccessResponse {
  String? paymentId;
  String? orderId;
  String? signature;

  PaymentSuccessResponse(this.paymentId, this.orderId, this.signature);

  static PaymentSuccessResponse fromMap(Map<dynamic, dynamic> map) {
    String? paymentId = map["razorpay_payment_id"];
    String? signature = map["razorpay_signature"];
    String? orderId = map["razorpay_order_id"];

    return new PaymentSuccessResponse(paymentId, orderId, signature);
  }
}

class PaymentFailureResponse {
  int? code;
  String? message;
  Map<dynamic, dynamic>? error;

  PaymentFailureResponse(this.code, this.message, this.error);

  static PaymentFailureResponse fromMap(Map<dynamic, dynamic> map) {
    var code = map["code"] as int?;
    var message = map["message"] as String?;
    var responseBody = map["responseBody"] as Map<dynamic, dynamic>?;
    return new PaymentFailureResponse(code, message, responseBody);
  }
}

class ExternalWalletResponse {
  String? walletName;

  ExternalWalletResponse(this.walletName);

  static ExternalWalletResponse fromMap(Map<dynamic, dynamic> map) {
    var walletName = map["external_wallet"] as String?;
    return new ExternalWalletResponse(walletName);
  }
}
