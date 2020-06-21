import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timecarditg/ApiCalls/apiCalls.dart';
import 'InternetConnectionBloc.dart';

class CheckInBloc extends Bloc<BaseEvent , BaseResultState>{
  ApiCalls _apiCalls =ApiCalls();
  @override
  // TODO: implement initialState
  BaseResultState get initialState => BaseResultState(result: dataResult.Empty);

  @override
  Stream<BaseResultState> mapEventToState(BaseEvent event)async* {
    // TODO: implement mapEventToSta
    if (event is CheckInEvent ){
      _apiCalls.checkIn(event.apiKey, event.employeeId,
          event.checkInTime, event.logginMachine,
          event.location, event.client, event.addressInfo);
      yield BaseResultState(result: dataResult.Loaded);

    }
  }

}
class CheckInEvent extends BaseEvent {
 String  apiKey, employeeId, checkInTime, logginMachine, location, client, addressInfo;

 CheckInEvent({this.apiKey, this.employeeId, this.checkInTime,
      this.logginMachine, this.location, this.client, this.addressInfo});
}
