import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timecarditg/ApiCalls/apiCalls.dart';
import 'package:timecarditg/models/CheckModel.dart';
import 'package:timecarditg/models/checkInResponse.dart';
import 'InternetConnectionBloc.dart';

class CheckBloc extends Bloc<BaseEvent , BaseResultState> {
  @override
  // TODO: implement initialState
  BaseResultState get initialState => BaseResultState(result: dataResult.Empty);

  @override
  Stream<BaseResultState> mapEventToState(BaseEvent event) async* {
    // TODO: implement mapEventToSta
    if (event is CheckModel) {
      CheckInResponse checkInResponse = await ApiCalls.checkService(event);
      yield BaseResultState(result: dataResult.Loaded, model: checkInResponse);
    }
  }
}
