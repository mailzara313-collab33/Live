import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Model/predefinedReturnReasonModel.dart';

class PredefinedReasonRepository {
  Future<List<PredefinedReasonData>> getAllPredefinedReason() async {
    print("PredefinedReason---->");
    try {
      var responseData =
          await ApiBaseHelper().postAPICall(getPredefiendReasonsApi, {});
      return responseData['data']
          .map<PredefinedReasonData>((e) => PredefinedReasonData.fromJson(e))
          .toList();
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }
}
