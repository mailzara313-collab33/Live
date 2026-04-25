import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:flutter/cupertino.dart';
import '../Model/Faqs_Model.dart';
import '../Model/User.dart';
import '../repository/cartRepository.dart';

class ProductDetailProvider extends ChangeNotifier {
  // error message
  String snackbarmessage = '';
  bool error = true;
// global varibales

  List<FaqsModel> faqsProductList = [];
  int faqsOffset = 0;
  int faqsTotal = 0;
  bool isLoadingmore = true;
  List<User> reviewList = [];
  List<imgModel> reviewImgList = [];
  int offset = 0;
  int total = 0;
  final GlobalKey<FormState> faqsKey = GlobalKey<FormState>();
  final edtFaqs = TextEditingController();
  bool qtyChange = false;
  bool isLoading = true;
  var star1 = '0', star2 = '0', star3 = '0', star4 = '0', star5 = '0';
  bool seeView = false;
  bool isFaqsLoading = true;

  // Track which product's reviews are currently loaded
  String? currentReviewProductId;

  final bool _reviewLoading = true;
  bool _moreProductLoading = true;
  bool _listType = false;
  bool _saleSectionlistType = false;
  bool _sectionlistType = false;

  List<Product> _compareList = [];

  get compareList => _compareList;

  get listType => _listType;
  get saleSectionListType => _saleSectionlistType;
  get sectionListType => _sectionlistType;

  get moreProductLoading => _moreProductLoading;

  get reviewLoading => _reviewLoading;

  ///-----------
  int _offset = 0;
  get offsetValue => _offset;

  bool _moreProNotiLoading = true;

  get moreProNotiLoading => _moreProNotiLoading;

  setProNotiLoading(bool loading) {
    _moreProNotiLoading = loading;
    notifyListeners();
  }

  int _total = 0;

  get totalValue => _total;

  void setCurrentProductId(String? id) {
    currentReviewProductId = id;
    notifyListeners();
  }

  setProTotal(int total) {
    _total = total;
    notifyListeners();
  }

  setcompareList(List<Product> list) {
    _compareList = list;
    notifyListeners();
  }

  setProductList(List<Product>? productList) {
    notifyListeners();
  }

  setProOffset(int offset) {
    _offset = offset;
    notifyListeners();
  }

  setReviewLoading(bool loading) {
    _moreProductLoading = loading;
    notifyListeners();
  }

  setListType(bool listType) {
    _listType = listType;
    notifyListeners();
  }

  setSectionListType(bool listType) {
    _sectionlistType = listType;
    notifyListeners();
  }

  setSaleSectionListType(bool listType) {
    _saleSectionlistType = listType;
    notifyListeners();
  }

  setProductLoading(bool loading) {
    _moreProductLoading = loading;
    notifyListeners();
  }

  addCompareList(Product compareList) {
    _compareList.add(compareList);
    notifyListeners();
  }

  Future<void> clearCartNow(BuildContext context) async {
    try {
      Map<String, dynamic> parameter = {
        // USER_ID: context.read<UserProvider>().userId,
      };

      Map<String, dynamic> result = await CartRepository.clearCart(
        parameter: parameter,
      );
      error = result['error'];
      snackbarmessage = result['message'];
    } catch (e) {
      snackbarmessage = e.toString();
    }
  }

  // Clear review data and notify listeners to update UI immediately
  void clearReviewData() {
    reviewList.clear();
    reviewImgList.clear();
    offset = 0;
    total = 0;
    star1 = '0';
    star2 = '0';
    star3 = '0';
    star4 = '0';
    star5 = '0';
    isLoading = true;
    currentReviewProductId = null; // Clear product ID tracking
    notifyListeners(); // This ensures UI updates immediately
  }

  // Set review images and notify listeners
  void setReviewImgList(List<imgModel> images) {
    reviewImgList = images;
    notifyListeners();
  }

  // Set review list and notify listeners
  void setReviewList(List<User> reviews) {
    reviewList = reviews;
    notifyListeners();
  }

  // Set star ratings and notify listeners
  void setStarRatings(String s1, String s2, String s3, String s4, String s5) {
    star1 = s1;
    star2 = s2;
    star3 = s3;
    star4 = s4;
    star5 = s5;
    notifyListeners();
  }

  // Set star ratings with product ID to track which product's data is loaded
  void setReviewDataForProduct(
      String productId, String s1, String s2, String s3, String s4, String s5) {
    currentReviewProductId = productId;
    star1 = s1;
    star2 = s2;
    star3 = s3;
    star4 = s4;
    star5 = s5;
    notifyListeners();
  }
}
