import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:flutter/cupertino.dart';

class CategoryProvider extends ChangeNotifier {
  List<Product>? _subList = [];
  List<Product>? _productList = [];
  int _curCat = 0;
  bool _isLoadingProducts = false;

  get subList => _subList;

  get productList => _productList;

  get curCat => _curCat;

  get isLoadingProducts => _isLoadingProducts;

  setCurSelected(int index) {
    _curCat = index;
    notifyListeners();
  }

  setSubList(List<Product>? subList) {
    _subList = subList;
    notifyListeners();
  }

  setProductList(List<Product>? productList) {
    _productList = productList;
    notifyListeners();
  }

  setLoadingProducts(bool loading) {
    _isLoadingProducts = loading;
    notifyListeners();
  }

  clearProductList() {
    _productList = [];
    notifyListeners();
  }
}
