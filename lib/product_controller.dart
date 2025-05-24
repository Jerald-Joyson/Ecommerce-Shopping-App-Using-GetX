import 'package:get/get.dart';
import 'package:myapp/product_model.dart';

class ProductController extends GetxController {
  final RxList<Product> _products = <Product>[].obs;

  List<Product> get products => _products;

  @override
  void onInit() {
    _fetchProducts();
  }
  void _fetchProducts(){
    List<Product> productData= [
      Product(
        id: 1,
        name: 'Nike Air Max',
        desc: "comfertible shoes",          
        price: 100,
        imgUrl: 'https://picsum.photos/200/300',
      ),
      Product(
        id: 2,
        name: 'Product 2',
        desc: "",
        price: 200,
        imgUrl: 'https://picsum.photos/200/300',
      ),
      Product(
        id: 3,
        name: 'Product 3',
        desc: "",
        price: 300,
        imgUrl: 'https://picsum.photos/200/300',
      ),
    ];
    _products.assignAll(productData);
  }
}