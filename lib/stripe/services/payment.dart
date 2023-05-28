import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_restaurant/stripe/stripe_payment.dart';
import 'package:stripe_payment/stripe_payment.dart';


class StripeTransactionResponse {
  String message;
  bool success;
  
  StripeTransactionResponse({this.message, this.success});
}

class StripeService {
  static var response;
  static SharedPreferences sharedPreferences;
  static String prefs2;
          

  static String apiBase = 'https://api.stripe.com/v1';
  static String paymentApiUrl = '${StripeService.apiBase}/payment_intents';
  static String secret =
      'sk_test_KEMcYbPmdycqV7kQ2wjswqWT001BOenK0W';
  static Map<String, String> headers = {
    'Authorization': 'Bearer ${StripeService.secret}',
    'Content-Type': 'application/x-www-form-urlencoded'
  };
  static init() {
    var setOptions = StripePayment.setOptions(StripeOptions(
        publishableKey:
            "pk_test_gAgY09QiCEMPOsxdOCQ0CsmR00QGivjbU8",
        merchantId: "Test",
        androidPayMode: 'test'));
  }

  

  static Future<StripeTransactionResponse> payViaExistingCard(
      {String amount, String currency, CreditCard card}) async {
    try {
      var paymentMethod = await StripePayment.createPaymentMethod(PaymentMethodRequest(card: card));
      var paymentIntent = await StripeService.createPaymentIntent(amount, currency);
      response = await StripePayment.confirmPaymentIntent(PaymentIntent(
          clientSecret: paymentIntent['client_secret'], paymentMethodId: paymentMethod.id));
      if (response.status == 'succeeded') {
        return new StripeTransactionResponse(message: 'Transaction successful', success: true);

      } else {
        return new StripeTransactionResponse(message: 'Transaction failed', success: false);
      }
    } on PlatformException catch (err) {
      return StripeService.getPlatformExceptionErrorResult(err);
    } catch (err) {
      return new StripeTransactionResponse(
          message: 'Transaction failed: ${err.toString()}', success: false);
    }
  }

  static Future<StripeTransactionResponse> payWithNewCard({String amount, String currency}) async {
    try {
      var paymentMethod = await StripePayment.paymentRequestWithCardForm(CardFormPaymentRequest());
      var paymentIntent = await StripeService.createPaymentIntent(amount, currency);
      response = await StripePayment.confirmPaymentIntent(PaymentIntent(
          clientSecret: paymentIntent['client_secret'], paymentMethodId: paymentMethod.id));
        
        
      
      if (response.status == 'succeeded') {
        print ("paymentIntentId: "); 
         print(amount);
         
        
         saveValue(response.paymentIntentId);

         print("paymentMethodId: ");
          print(response.paymentMethodId);

          
        return new StripeTransactionResponse(message: 'Transaction successful', success: true);

      } else {
         print ("paymentIntentId: "); 
         print(amount);
        return new StripeTransactionResponse(message: 'Transaction failed', success: false);
      }
    } on PlatformException catch (err) {
         print ("paymentIntentId: "); 
         print(amount);
      return StripeService.getPlatformExceptionErrorResult(err);
    } catch (err) {
        print ("paymentIntentId: "); 
         print(amount);
      return new StripeTransactionResponse(
          message: 'Transaction failed: ${err.toString()}', success: false);
    }
  }

  static getPlatformExceptionErrorResult(err) {
    String message = 'Something went wrong';
    print("The Stripe error is given below: ");
    print(err);
    if (err.code == 'cancelled') {
      message = 'Transaction cancelled';
    }

    return new StripeTransactionResponse(message: message, success: false);
  }

  static Future<Map<String, dynamic>> createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card'
      };
      var response =
          await http.post(Uri.parse(StripeService.paymentApiUrl), body: body, headers: StripeService.headers);
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
    return null;
  }


  static Future<void> saveValue(var paymentIntentId) async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();

    var tranId = await prefs.setString("transaction_id", paymentIntentId);
    print("Shared Preference Nizaam");
    print(tranId);
    print("Shared Preference Nizaam 2");
    print(prefs.getString("transaction_id"));

    prefs2 = prefs.getString("transaction_id");
    
  }

  static String getValue2() {
    return prefs2;
  }

  // static Future<String> getValue() async {
  //   // Obtain shared preferences.
  //   final prefs = await SharedPreferences.getInstance();

  //   String tranId =  prefs.getString("transaction_id");
  //    print(prefs.getString("transaction_id"));
  //   return tranId;

  // }




}
