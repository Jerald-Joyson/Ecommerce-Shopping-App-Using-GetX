import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/constants/constants.dart';
import 'package:myapp/controllers/cart_controller.dart';
import 'package:myapp/models/payment_method_model.dart';

class CheckoutController {
  final CartController cartController = Get.find<CartController>();

  final Rx<PaymentMethodModel?> _selectedPaymentMethod =
      Rx<PaymentMethodModel?>(null);
  PaymentMethodModel? get selectedPaymentMethod => _selectedPaymentMethod.value;

  static String _secretKey = AppConstants.secretKey;

  static const String paymentApiUrl =
      'https://api.stripe.com/v1/payment-intents';

  final RxString name = "".obs;
  final RxString email = "".obs;
  final RxString phone = "".obs;
  final RxString address = "".obs;
  final RxString city = "".obs;
  final RxString state = "".obs;
  final RxString postalCode = "".obs;
  final RxString country = "".obs;

  final RxInt currentStep = 0.obs;
  final RxBool isLoading = false.obs;

  final RxList<PaymentMethodModel> paymentMethods =
      <PaymentMethodModel>[
        PaymentMethodModel(
          id: 'cod',
          name: 'Cash on Delivery',
          icon: Icons.money,
          description: 'Pay with Cash upon Delivery',
        ),
        PaymentMethodModel(
          id: 'stripe',
          name: 'Credit/Debit Card',
          icon: Icons.credit_card,
          description: 'Pay with Stripe',
        ),
      ].obs;
  final RxString orderId = ''.obs;

  void selectPaymentMethod(PaymentMethodModel method) {
    _selectedPaymentMethod.value = method;
  }

  bool validateCustomerInfo() {
    if (name.value.isEmpty ||
        email.value.isEmpty ||
        phone.value.isEmpty ||
        address.value.isEmpty ||
        city.value.isEmpty ||
        state.value.isEmpty ||
        postalCode.value.isEmpty ||
        country.value.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill all the required fields",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        borderRadius: 8,
        duration: const Duration(seconds: 2),
        margin: EdgeInsets.all(10),
      );
      return false;
    }
    if (!GetUtils.isEmail(email.value)) {
      Get.snackbar(
        "Error",
        "Please enter a valid email address",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        borderRadius: 8,
        duration: const Duration(seconds: 2),
        margin: EdgeInsets.all(10),
      );
      return false;
    }
    return true;
  }

  Future<bool> processPayment() async {
    if (selectedPaymentMethod == null) {
      Get.snackbar(
        "Error",
        "please select a payment method",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        borderRadius: 8,
        duration: const Duration(seconds: 2),
        margin: EdgeInsets.all(10),
      );
      return false;
    }
    isLoading.value = true;
    try {
      orderId.value = "ORD-${DateTime.now().millisecondsSinceEpoch}";
      if (selectedPaymentMethod!.id == 'cod') {
        await Future.delayed(Duration(seconds: 1));
        isLoading.value = false;
        return true;
      } else if (selectedPaymentMethod!.id == 'stripe') {
        bool success = await _processStripePaymentSheet();
        isLoading.value = false;
        return success;
      }

      isLoading.value = false;
      return false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "Error",
        "Payment failed, please try again later",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        borderRadius: 8,
        duration: const Duration(seconds: 2),
        margin: EdgeInsets.all(10),
      );
      return false;
    }
  }

  static Map<String, String> headers = {
    'Authorization': 'Bearer $_secretKey',
    'Content-Type': 'application/x-www-form-urlencoded',
  };

  static Future<Map<String, dynamic>> createPaymentIntent({
    required String amount,
    required String currency,
    required int adminFee,
  }) async {
    try {
      int amountInCents = (double.parse(amount) * 100).toInt();
      int adminFeeInCents = (adminFee * 100).toInt();

      Map<String, dynamic> body = {
        'amount': amountInCents.toString(),
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      var response = await http.post(
        Uri.parse(paymentApiUrl),
        headers: headers,
        body: body,
      );
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception("Error creating payment intent: $e");
    }
  }

  Future<bool> _processStripePaymentSheet() async {
    try {
      if (Stripe.publishableKey.isEmpty) {
        throw Exception("Stripe publishable key is empty");
      }
      final paymentIntentData = await createPaymentIntent(
        amount: cartController.totalAmount.toString(),
        currency: 'usd',
        adminFee: 200,
      );

      if (!paymentIntentData.containsKey('client_secret') ||
          paymentIntentData['client_secret'] == null) {
        throw Exception("Error creating payment intent");
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['client_secret'],
          merchantDisplayName: 'Ecommerce Shopping App',
          billingDetails: BillingDetails(
            name: name.value,
            email: email.value,
            phone: phone.value,
            address: Address(
              city: city.value,
              country: country.value,
              line1: address.value,
              line2: '',
              state: state.value,
              postalCode: postalCode.value,
            ),
          ),
        ),
      );
      await Stripe.instance.presentCustomerSheet();

      Get.snackbar(
        'Success',
        'Payment successful',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        borderRadius: 8,
        duration: const Duration(seconds: 2),
        margin: EdgeInsets.all(10),
      );
      return true;
    } on StripeException catch (e) {
      String errorMessage = "Payment Failed";
      if (e.error.code == FailureCode.Canceled) {
        errorMessage = "Payment Cancelled";
      } else {
        errorMessage = 'Payment failed: ${e.error.localizedMessage}';
      }
      Get.snackbar(
        'Payment Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        borderRadius: 8,
        duration: const Duration(seconds: 2),
        margin: EdgeInsets.all(10),
      );

      return false;
    } catch (e) {
      Get.snackbar(
        'Payment Error',
        'An error occurred while processing the payment',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        borderRadius: 8,
        duration: const Duration(seconds: 2),
        margin: EdgeInsets.all(10),
      );
      return false;
    }
  }

  Future<void> completeOrder() async {
    try {
      final orderData = {
        'order_id': orderId.value,
        'customer': {
          'name': name.value,
          'email': email.value,
          'phone': phone.value,
        },
        'shipping': {
          'address': address.value,
          'city': city.value,
          'state': state.value,
          'country': country.value,
          'postal_code': postalCode.value,
        },
        'payment': {
          'method': selectedPaymentMethod?.id,
          'amount': cartController.totalAmount,
        },
        'items':
            cartController.cartItems.entries
                .map(
                  (entry) => {
                    'product_id': entry.key.id,
                    'name': entry.key.name,
                    'price': entry.key.price,
                    'quantity': entry.value,
                    'total': entry.key.price * entry.value,
                  },
                )
                .toList(),
        'orderDate': DateTime.now().toString(),
      };

      await Future.delayed(Duration(seconds: 2));
      debugPrint("Order Data: $orderData");
      Get.snackbar(
        "Success",
        "Order Completed Successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        borderRadius: 8,
        duration: const Duration(seconds: 2),
        margin: EdgeInsets.all(10),
      );
      cartController.clearCart();
      _resetForm();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to complete order",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        borderRadius: 8,
        duration: const Duration(seconds: 2),
        margin: EdgeInsets.all(10),
      );
    }
  }

  void _resetForm() {
    name.value = '';
    email.value = '';
    phone.value = '';
    address.value = '';
    city.value = '';
    state.value = '';
    country.value = '';
    postalCode.value = '';
    _selectedPaymentMethod.value = null;
  }
}
