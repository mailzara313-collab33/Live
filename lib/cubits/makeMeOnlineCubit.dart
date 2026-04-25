import 'package:eshop_multivendor/repository/chatRepository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class MakeMeOnlineState {}

class MakeMeOnlineInitial extends MakeMeOnlineState {}

class MakeMeOnlineInProgress extends MakeMeOnlineState {}

class MakeMeOnlineSuccess extends MakeMeOnlineState {
  MakeMeOnlineSuccess();
}

class MakeMeOnlineFailure extends MakeMeOnlineState {
  final String errorMessage;

  MakeMeOnlineFailure(this.errorMessage);
}

class MakeMeOnlineCubit extends Cubit<MakeMeOnlineState> {
  final ChatRepository _chatRepository;

  MakeMeOnlineCubit(this._chatRepository) : super(MakeMeOnlineInitial());

  void makeMeOnline() async {
    emit(MakeMeOnlineInProgress());
    try {
      await _chatRepository.makeMeOnline();
      if (kDebugMode) {
        print('Is Online');
      }
      emit(MakeMeOnlineSuccess());
    } catch (e) {
      emit(MakeMeOnlineFailure(e.toString()));
    }
  }
}
