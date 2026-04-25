import 'package:eshop_multivendor/Model/predefinedReturnReasonModel.dart';
import 'package:eshop_multivendor/repository/predefinedReturnReasonRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PredefinedReturnReasonListState {}

class PredefinedReturnReasonListInitial
    extends PredefinedReturnReasonListState {}

class PredefinedReturnReasonListInProgress
    extends PredefinedReturnReasonListState {}

class PredefinedReturnReasonListSuccess
    extends PredefinedReturnReasonListState {
  final List<PredefinedReasonData> predefinedReason;

  PredefinedReturnReasonListSuccess({required this.predefinedReason});
}

class PredefinedReturnReasonListFailure
    extends PredefinedReturnReasonListState {
  final String errorMessage;

  PredefinedReturnReasonListFailure(this.errorMessage);
}

class PredefinedReturnReasonListCubit
    extends Cubit<PredefinedReturnReasonListState> {
  final PredefinedReasonRepository predefinedReasonRepository;
  PredefinedReturnReasonListCubit({required this.predefinedReasonRepository})
      : super(PredefinedReturnReasonListInitial());

  void getPredefinedReturnReasonList() async {
    print("predefinedReasonRepository---->");
    emit(PredefinedReturnReasonListInProgress());
    try {
      emit(PredefinedReturnReasonListSuccess(
          predefinedReason:
              await predefinedReasonRepository.getAllPredefinedReason()));
    } catch (e) {
      emit(PredefinedReturnReasonListFailure(e.toString()));
    }
  }
}
