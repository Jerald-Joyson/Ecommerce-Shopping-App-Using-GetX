import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:myapp/controllers/cart_controller.dart';
import 'package:myapp/controllers/checkout_controller.dart';
import 'package:myapp/models/payment_method_model.dart';
import 'package:myapp/models/product_model.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CheckoutController checkoutController = Get.put(CheckoutController());

    final CartController cartController = Get.find<CartController>();

    final List<String> steps = ['Shipping', 'Payment', 'Review'];

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FD),
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        elevation: 0,
        backgroundColor: Color(0xFF5368E9),
      ),
      body: Obx(() {
        return Column(
          children: [
            _buildHorizontalStepper(
              steps,
              checkoutController.currentStep.value,
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: _buildStepContent(
                      checkoutController.currentStep.value,
                      checkoutController,
                      cartController,
                    ),
                  ),
                ),
              ),
            ),

            _buildBottomButtons(
              checkoutController.currentStep.value,
              checkoutController,
              cartController,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildBottomButtons(
    int currentStep,
    CheckoutController checkoutController,
    CartController cartController,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (currentStep > 0 && currentStep < 2)
            Container(
              height: 55,
              width: 55,
              margin: EdgeInsets.only(right: 12),
              child: OutlinedButton(
                onPressed: () {
                  checkoutController.currentStep.value--;
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  side: BorderSide(color: Color(0xFF5368E9)),
                ),
                child: Icon(Icons.arrow_back, color: Color(0xFF5368E9)),
              ),
            ),
          Expanded(
            child: Container(
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor:
                      currentStep == 2 ? Colors.green : Color(0xFF5368E9),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  if (currentStep == 0) {
                    if (checkoutController.validateCustomerInfo()) {
                      checkoutController.currentStep.value = 1;
                    }
                  } else if (currentStep == 1) {
                    checkoutController.processPayment().then((success) {
                      if (success) {
                        checkoutController.currentStep.value = 2;
                      }
                    });
                  } else if (currentStep == 2) {
                    checkoutController.completeOrder().then((_) {
                      // Get.offAll(()=>OrderConfirmationScreen());
                    });
                  }
                },
                child: Text(
                  currentStep == 0
                      ? 'CONTINUE TO PAYMENT'
                      : currentStep == 1
                      ? 'PROCESS TO REVIEW'
                      : 'PLACE ORDER',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingInfoContent(CheckoutController checkoutController) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Shipping Information",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 20),
          _buildFormField(
            labelText: "Full Name",
            icon: Icons.person,
            onChanged: (value) => checkoutController.name.value = value,
          ),
          SizedBox(height: 16),
          _buildFormField(
            labelText: "Email",
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => checkoutController.email.value = value,
          ),
          SizedBox(height: 16),
          _buildFormField(
            labelText: "Phone Number",
            icon: Icons.phone,
            onChanged: (value) => checkoutController.phone.value = value,
          ),
          SizedBox(height: 16),
          _buildFormField(
            labelText: "Address",
            icon: Icons.location_on,
            onChanged: (value) => checkoutController.address.value = value,
          ),
          SizedBox(height: 16),
          _buildFormField(
            labelText: "City",
            icon: Icons.location_city,
            onChanged: (value) => checkoutController.city.value = value,
          ),
          SizedBox(height: 16),
          _buildFormField(
            labelText: "State",
            icon: Icons.location_city,
            onChanged: (value) => checkoutController.state.value = value,
          ),
          SizedBox(height: 16),
          _buildFormField(
            labelText: "Zip Code",
            icon: Icons.code,
            keyboardType: TextInputType.number,
            onChanged: (value) => checkoutController.postalCode.value = value,
          ),
          SizedBox(height: 16),
          _buildFormField(
            labelText: "Country",
            icon: Icons.flag,
            onChanged: (value) => checkoutController.country.value = value,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodContent(CheckoutController checkoutController) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Payment Method",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 20),
          ...checkoutController.paymentMethods.map((method) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: _buildPaymentMethodCard(method, checkoutController),
            );
          }).toList(),
          if (checkoutController.isLoading.value)
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF5368E9)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    PaymentMethodModel method,
    CheckoutController checkoutController,
  ) {
    final isSelected =
        checkoutController.selectedPaymentMethod?.id == method.id;
    return GestureDetector(
      onTap: () => checkoutController.selectPaymentMethod(method),
      child: AnimatedContainer(
        duration: Duration(microseconds: 150),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF5368E9) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Color(0xFF5368E9) : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Color(0xFF5368E9).withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ]
                  : [],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.white : Color(0xFF5368E9),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: Color(0xFF5368E9).withOpacity(0.2),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ]
                        : [],
              ),
              child: Center(
                child: Icon(
                  method.icon,
                  color: isSelected ? Color(0xFF5368E9) : Colors.white,
                  size: 28,
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  Text(
                    method.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isSelected ? Colors.white : Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    method.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Color(0xFF5368E9),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryContent(
    CartController cartController,
    CheckoutController checkoutController,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order Items ${cartController.uniqueItemsCount}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSummaryRow(
                  label: 'Subtotal',
                  value: '\$${cartController.totalAmount.toStringAsFixed(2)}',
                ),
                SizedBox(height: 12),
                _buildSummaryRow(
                  label: 'Shipping',
                  value: 'FREE',
                  valueColor: Colors.green,
                ),
                SizedBox(height: 12),
                Divider(color: Colors.grey.shade200),
                SizedBox(height: 12),
                _buildSummaryRow(
                  label: 'Total',
                  value: '\$${cartController.totalAmount.toStringAsFixed(2)}',
                  valueColor: Color(0xFF5368E9),
                  isTotal: true,
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF5368E9).withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green.shade300, width: 1),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check,
                      size: 24,
                      color: Colors.green.shade600,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Confirm Order',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'you order will be processed immedietaly after confirmation',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Product product, int quantity) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.imgUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, StackTrace) {
                  return Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${quantity} x \$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    Color? valueColor,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            color:
                valueColor ??
                (isTotal ? Color(0xFF5368E9) : Colors.grey.shade600),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalStepper(List<String> steps, int currentStep) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Row(
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index % 2 == 0) {
                final stepIndex = index ~/ 2;
                final isActive = stepIndex <= currentStep;
                final isCurrentStep = stepIndex == currentStep;
                return Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              isActive
                                  ? Color(0xFF5368E9)
                                  : Colors.grey.shade100,
                          border: Border.all(
                            color:
                                isCurrentStep
                                    ? Color(0xFF5368E9)
                                    : Colors.grey.shade300,
                            width: isCurrentStep ? 2 : 1,
                          ),
                          boxShadow:
                              isCurrentStep
                                  ? [
                                    BoxShadow(
                                      color: Color(0xFF5368E9).withOpacity(0.2),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                      offset: Offset(0, 2),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: Center(
                          child:
                              isActive
                                  ? Icon(
                                    stepIndex < currentStep
                                        ? Icons.check
                                        : Icons.circle,
                                    size: stepIndex < currentStep ? 18 : 12,
                                    color: Colors.white,
                                  )
                                  : Text(
                                    '${stepIndex + 1}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        steps[stepIndex],
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              isActive
                                  ? Color(0xFF5368E9)
                                  : Colors.grey.shade600,
                          fontWeight:
                              isCurrentStep
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                final isActive = index ~/ 2 <= currentStep - 1;
                return Expanded(
                  child: Container(
                    height: 2,
                    color: isActive ? Color(0xFF5368E9) : Colors.grey.shade300,
                  ),
                );
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(
    int stepIndex,
    CheckoutController checkoutController,
    CartController cartController,
  ) {
    switch (stepIndex) {
      case 0:
        return _buildShippingInfoContent(checkoutController);
      case 1:
        return _buildPaymentMethodContent(checkoutController);
      case 2:
        return _buildOrderSummaryContent(cartController, checkoutController);
      default:
        return SizedBox();
    }
  }

  Widget _buildFormField({
    required String labelText,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: TextField(
            keyboardType: keyboardType,
            maxLines: maxLines,
            onChanged: onChanged,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Color(0xFF5368E9), size: 22),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              hintText: 'Enter $labelText',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}
