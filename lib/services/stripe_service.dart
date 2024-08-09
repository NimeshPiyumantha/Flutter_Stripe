import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../consts.dart';

class StripeService {
  StripeService._();

  static final StripeService instance = StripeService._();

Future<void> makePayment() async {
  try {
    String? paymentIntentClientSecret =
        await _createPaymentInternt(100, "usd");
    if (paymentIntentClientSecret == null) {
      print("Failed to create payment intent");
      return;
    }
    
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntentClientSecret,
        merchantDisplayName: "Flutter Stripe Example",
      ),
    );
    await _processPayment();
  } catch (e) {
    print(e);
  }
}


  Future<String?> _createPaymentInternt(int amount, String current) async {
    try {
      final Dio dio = Dio();
      Map<String, dynamic> data = {
        "amount": _calculateAmount(amount),
        "currency": current,
      };

      var response = await dio.post(
        "https://api.stripe.com/v1/payment_intents",
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            "Authorization": "Bearer $stringSecretKey",
            "Content-Type": "application/x-www-form-urlencoded",
          },
        ),
      );
      if (response.data != null) {
        print(response.data);
        return response.data['client_secret'];
      }
      return null;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<void> _processPayment() async {
    try {
    await Stripe.instance.presentPaymentSheet();
    await Stripe.instance.confirmPaymentSheetPayment ();
    } catch (e) {
      print(e);
    }
  }

  String _calculateAmount(int amount) {
    return (amount * 100).toString();
  }
}
