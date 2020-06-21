import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timecarditg/ApiCalls/apiCalls.dart';
import 'package:timecarditg/models/checkInResponse.dart';
import 'InternetConnectionBloc.dart';

class CheckInBloc extends Bloc<BaseEvent , BaseResultState>{
  @override
  // TODO: implement initialState
  BaseResultState get initialState => BaseResultState(result: dataResult.Empty);

  @override
  Stream<BaseResultState> mapEventToState(BaseEvent event)async* {
    // TODO: implement mapEventToSta
    if (event is CheckInEvent ){
   CheckInResponse checkInResponse=  await ApiCalls.checkIn(event.apiKey, event.employeeId,
          event.checkInTime, event.logginMachine,
          event.location, event.client, event.addressInfo);
      yield BaseResultState(result: dataResult.Loaded,model: checkInResponse );
    }
    else if(event is CheckOutEvent){
      var checkInResponse =await  ApiCalls.checkOut(event.apiKey, event.employeeId, event.checkOutTime, event.logginMachine,
          event.location, event.client, event.addressInfo);
      yield BaseResultState(result: dataResult.Loaded, model: checkInResponse);
    }
  }

}
class CheckOutEvent extends BaseEvent {
  String  apiKey, employeeId, checkOutTime, logginMachine, location, client, addressInfo;

  CheckOutEvent({this.apiKey, this.employeeId, this.checkOutTime,
    this.logginMachine, this.location, this.client, this.addressInfo});
}
class CheckInEvent extends BaseEvent {
 String  apiKey, employeeId, checkInTime, logginMachine, location, client, addressInfo;

 CheckInEvent({this.apiKey, this.employeeId, this.checkInTime,
      this.logginMachine, this.location, this.client, this.addressInfo});
}
