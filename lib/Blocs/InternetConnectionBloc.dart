
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timecarditg/models/BaseModel.dart';
import 'package:timecarditg/utils/utils.dart';

class InterneConnectionBloc extends Bloc<BaseEvent , BaseResultState> {

  @override
  // TODO: implement initialState
  BaseResultState get initialState => BaseResultState(result: dataResult.Empty);

  @override
  Stream<BaseResultState> mapEventToState(BaseEvent event) async*{
    // TODO: implement mapEventToState
    if(event is CheckInternetEvent){
      connectStatus status = await UtilsClass.checkConnectivity();
    if(status==connectStatus.connected){
      yield BaseResultState(result: dataResult.Loaded);
    }
    else yield BaseResultState(result: dataResult.Error);
    }
  }
}
class BaseEvent {}
class CheckInternetEvent extends BaseEvent {}
class BaseResultState {
  BaseModel model ;
  dataResult result ;
  BaseResultState({this.model, this.result});
}
enum dataResult {
  Empty , Loading , Loaded , Error
}