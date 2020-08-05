import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timecarditg/ApiCalls/apiCalls.dart';
import 'package:timecarditg/models/HomeInformation.dart';
import 'InternetConnectionBloc.dart';

class HomeInfoBloc extends Bloc<BaseEvent , BaseResultState> {
  @override
  // TODO: implement initialState
  BaseResultState get initialState => BaseResultState(result: dataResult.Empty);

  @override
  Stream<BaseResultState> mapEventToState(BaseEvent event) async* {
    if(event is HomeInfoEvent){
      yield BaseResultState(result: dataResult.Loading);
      var homeInfo =  await ApiCalls.fetchHomeInfo();
      if(homeInfo!=null){
        yield BaseResultState(result: dataResult.Loaded, model: homeInfo);
      }

      else {
        yield BaseResultState(result: dataResult.Error);
        print('errror => ${dataResult.Error}');
      }
    }
  }
}


class HomeInfoEvent extends BaseEvent {
  HomeInfo homeInfo ;
  HomeInfoEvent({this.homeInfo});
}


