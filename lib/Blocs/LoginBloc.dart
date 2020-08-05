import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timecarditg/ApiCalls/apiCalls.dart';
import 'package:timecarditg/models/BaseModel.dart';
import 'package:timecarditg/models/user.dart';
import 'package:timecarditg/utils/utils.dart';

import 'InternetConnectionBloc.dart';

class LoginBloc extends Bloc<BaseEvent , BaseResultState> {

  @override
  // TODO: implement initialState
  BaseResultState get initialState => BaseResultState(result: dataResult.Empty);

  @override
  Stream<BaseResultState> mapEventToState(BaseEvent event) async*{
    // TODO: implement mapEventToState
    if(event is LoginEvent){
      yield BaseResultState(result: dataResult.Loading);

      var status = await ApiCalls.loginCall(event.user);
      print('my object ===>>>>>>>>> ${event.user.password + "                 "+
          event.user.username  + "            "  + event.user.macAddress}');
      if(status!=null){
        yield BaseResultState(result: dataResult.Loaded,model: status);
      }

      else {
        yield BaseResultState(result: dataResult.Error);
        print('errror => ${dataResult.Error}');
      }
    }
  }



}

class LoginEvent extends BaseEvent {
  Logginer user ;
  LoginEvent({this.user});
}
