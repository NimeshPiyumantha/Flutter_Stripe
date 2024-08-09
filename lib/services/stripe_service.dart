import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../consts.dart';

class StripeService {
  StripeService._();

  static final StripeService instance = StripeService._();

  Future<void> makePayment() async {
    try {
      String? result = await _createPaymentInternt(100, "usd");
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
            },),
      );
      if(response.data !=null){
        print(response.data);
        return "";
      }
      return null;
    } catch (e) {
      print(e);
    }
    return null;
  }

  String _calculateAmount(int amount) {
    return (amount * 100).toString();
  }
}
