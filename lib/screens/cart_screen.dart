import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controllers/cart_controller.dart';
import 'package:myapp/screens/checkout_screen.dart';

import '../models/product_model.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ShoppingCart',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () {
              if (cartController.itemCount > 0) {
                Get.defaultDialog(
                  title: 'Clear Cart',
                  titleStyle: TextStyle(fontWeight: FontWeight.bold),
                  content: Text(
                    'Are you sure you want to clear your cart?',
                    textAlign: TextAlign.center,
                  ),
                  contentPadding: EdgeInsets.all(20),
                  radius: 10,
                  confirm: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF5368E9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(8),
                      ),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      cartController.clearCart();
                      Get.back();
                    },
                    child: Text("Yes", style: TextStyle(color: Colors.white)),
                  ),
                  cancel: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFF5368E9)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(8),
                      ),
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                      Get.back();
                    },
                    child: Text("No"),
                  ),
                );
              } else {
                Get.snackbar(
                  'Empty Cart',
                  'Your cart is empty.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  borderRadius: 10,
                  margin: EdgeInsets.all(20),
                  duration: Duration(seconds: 2),
                );
              }
            },
          ),
        ],
      ),
      body: Obx(
        () =>
            cartController.cartItems.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 100,
                        color: Color(0xFFD1D9E6),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Your cart is empty",
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF5368E9),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Add items to your cart",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFD1D9E6),
                        ),
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                  padding: EdgeInsets.all(15),
                  itemCount: cartController.cartItems.length,
                  itemBuilder: (context, index) {
                    final product =
                        cartController.cartItems.keys.toList()[index];
                    final quantity = cartController.cartItems[product]!;
                    return CartItemCard(
                      product: product,
                      quantity: quantity,
                      cartController: cartController,
                    );
                  },
                ),
      ),
      bottomNavigationBar: Obx(
        () =>
            cartController.cartItems.isEmpty
                ? SizedBox.shrink()
                : Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              '\$${cartController.totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5368E9),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF5368E9),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            minimumSize: Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            // Get.snackbar(
                            //   'Order Placed',
                            //   "Your order has been placed successfully",
                            //   snackPosition: SnackPosition.BOTTOM,
                            //   duration: Duration(seconds: 2),
                            //   backgroundColor: Colors.green,
                            //   colorText: Colors.white,
                            //   borderRadius: 8,
                            //   margin: const EdgeInsets.all(10),
                            // );
                            // cartController.clearCart();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CheckoutScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Checkout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final Product product;
  final int quantity;
  final CartController cartController;

  const CartItemCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.cartController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  product.imgUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, StackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.grey,
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      GestureDetector(
                        onTap:
                            () => cartController.removeProductCommpletely(
                              product,
                            ),
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, size: 16, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF5368E9),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              onTap:
                                  () => cartController.removeFromCart(product),
                              child: Container(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.remove, size: 16),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                quantity.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5368E9),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap:
                                  () => cartController.addToCart(
                                    product,
                                    showSnakbar: false,
                                  ),
                              child: Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF5368E9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Text(
                        '\$${(product.price * quantity).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
