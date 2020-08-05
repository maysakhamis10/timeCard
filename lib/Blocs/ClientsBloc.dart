
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timecarditg/ApiCalls/apiCalls.dart';

import 'InternetConnectionBloc.dart';

class ClientsBloc extends Bloc<BaseEvent , ClientListState>{
  @override
  // TODO: implement initialState
  ClientListState get initialState => ClientListState(result: dataResult.Empty);

  @override
  Stream<ClientListState> mapEventToState(BaseEvent event)async* {
    // TODO: implement mapEventToSta
    if (event is ClientEvent ){
      List<String> clientNames =await ApiCalls.fetchClientNames(event.apiKey);
      yield ClientListState(result: dataResult.Loaded,list: clientNames);
    }
  }
}

class ClientEvent extends BaseEvent{
  String apiKey;

  ClientEvent({this.apiKey});

}class ClientListState extends BaseResultState{
 List<String> list;
 dataResult result;

 ClientListState({this.list,this.result});
}
