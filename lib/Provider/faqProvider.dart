import 'package:flutter/material.dart';
import '../Helper/String.dart';
import '../repository/faqRepository.dart';

enum FaQProviderStatus {
  initial,
  inProgress,
  isSuccsess,
  isFailure,
}

class FaQProvider extends ChangeNotifier {
  String? currentProductId, question;
  String errorMessage = '';
  changeStatus(FaQProviderStatus status) {
    notifyListeners();
  }

  setProdId(String? value) {
    currentProductId = value;
    notifyListeners();
  }

  setquestion(String? value) {
    question = value;
    notifyListeners();
  }

  // add new Q.
  Future<Map<String, dynamic>> setFaqsQue(BuildContext context) async {
    try {
      var parameter = {PRODUCT_ID: currentProductId, QUESTION: question};

      var result =
          await FaqRepository.setFaqsQueOnProduct(parameter: parameter);
      return result;
    } catch (e) {
      errorMessage = e.toString();
      return {};
    }
  }
}
