
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timecarditg/ApiCalls/apiCalls.dart';
import 'package:timecarditg/models/Employee.dart';
import 'package:timecarditg/models/login_error.dart';
import 'package:timecarditg/models/user.dart';

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
      if(status is LoginError){
        yield BaseResultState(result: dataResult.Error,model: status);

      }else
      if(status is Employee){
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
