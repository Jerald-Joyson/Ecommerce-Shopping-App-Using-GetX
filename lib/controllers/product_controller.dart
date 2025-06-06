import 'package:get/get.dart';
import 'package:myapp/models/product_model.dart';

class ProductController extends GetxController {
  final RxList<Product> _products = <Product>[].obs;

  List<Product> get products => _products;

  @override
  void onInit() {
    _fetchProducts();
  }

  void _fetchProducts() {
    List<Product> productData = [
      Product(
        id: 1,
        name: 'CAMPUS',
        desc: "CRYSTA PRO Running Shoes For Men  (Blue , 9)",
        price: 700.00,
        imgUrl:
            'https://rukminim2.flixcart.com/image/416/416/xif0q/shoe/i/r/n/-original-imahahxyjyxhjwzc.jpeg',
      ),
      Product(
        id: 2,
        name: 'TURNX',
        desc:
            "Hocky turnx Lightweight,Comfortable,Trendy,Breathable, Sports Running Shoes For Men  (White , 9)",
        price: 799.00,
        imgUrl:
            'https://rukminim2.flixcart.com/image/612/612/xif0q/shopsy-shoe/4/o/i/7-hockey-white-ornage-turnx-white-ornage-original-imah6zsxphhchdxj.jpeg',
      ),
      Product(
        id: 3,
        name: 'REEBOK',
        desc: "Voyager M Running Shoes For Men  (Black , 9)",
        price: 1090.00,
        imgUrl: 'https://rukminim2.flixcart.com/image/612/612/xif0q/shoe/j/k/y/-original-imahy3zu9sxapttx.jpeg',
      ),
    ];
    _products.assignAll(productData);
  }
}
