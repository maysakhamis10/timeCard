import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:timecarditg/ApiCalls/apiCalls.dart';
import 'package:timecarditg/Blocs/CheckInBloc.dart';
import 'package:timecarditg/Blocs/ClientsBloc.dart';
import 'package:timecarditg/Blocs/InternetConnectionBloc.dart';
import 'package:timecarditg/Screens/MainScreen.dart';
import 'package:timecarditg/database/database.dart';
import 'package:timecarditg/models/CheckModel.dart';
import 'package:timecarditg/models/Employee.dart';
import 'package:timecarditg/models/checkInResponse.dart';
import 'package:timecarditg/utils/sharedPreference.dart';
import 'dart:io' show Platform;

import 'package:timecarditg/utils/utils.dart';


class AdditionalInfo extends StatefulWidget {


  @override
  _AdditionalInfoState createState() => _AdditionalInfoState();
}

class _AdditionalInfoState extends State<AdditionalInfo> {

String dropdownValue = "Client Name";
ClientsBloc _clientsBloc ;
Employee empModel ;
CheckInBloc _checkInBloc;
List<String> clients=List();
var width ,height;
  TextEditingController addressInfoController  =TextEditingController();
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    _clientsBloc= BlocProvider.of<ClientsBloc>(context);
    _checkInBloc= BlocProvider.of<CheckInBloc>(context);
  }

  String location='';
 Future<String> getLocation()async{
   Position position = await  Utils.getCurrentLocation();
   return position.latitude.toString()+":"+position.longitude.toString();
 }

DateTime now;
Color mainColor = Color(0xff1295df);
  @override
  Widget build(BuildContext context) {
    getLocation().then((onValue){
        location=onValue;
    });
    getApiKeyAndId().then((onValue)async{
      empModel=onValue;
      if(await Utils.checkConnectivity()==connectStatus.connected){
      _clientsBloc.add(ClientEvent(apiKey: empModel.apiKey));
      }
      else{

      }
    });
  width = MediaQuery.of(context).size.width;
  height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Text('Additional Info'),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 15),
        child: Column(

          children: <Widget>[
          SizedBox(height: height*.05,),
            Row(
              children: <Widget>[
                Text('Clients ', style: TextStyle(
                  color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                ),),Text('(Optional) ', style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16
                ),),
              ],
            ),
           checkInListener(),
            clientsListener(),
            SizedBox(height: height*.01,),
            Row(
              children: <Widget>[
                Text('Address Info ', style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                ),),Text('(Optional) ', style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16
                ),),
              ],
            ),
            Container(
            width: width*.9,
              child: TextFormField(
                controller: addressInfoController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    gapPadding: 5
                  )
                ),
                maxLines: 8,
              ),
            ),
            SizedBox(height: height*.08,),
            GestureDetector(
              onTap: ()async{
                if(await Utils.checkConnectivity()==connectStatus.connected){
                 now = DateTime.now();
                _checkInBloc.add(CheckInEvent(
                  apiKey: empModel.apiKey,
                  addressInfo: addressInfoController.text,
                  location: location ,
                  client: dropdownValue,
                  logginMachine:Platform.isAndroid ? 'Android' : 'IOS' ,
                  checkInTime:now.toString(),
                  employeeId: empModel.employeeId.toString()
                ));
                }
                else{
                  await saveChecksToDB(synced: false);
                  Utils.showMyDialog(content: 'There is no internet now , your transactions will saved locally and it will be synced later ',
                  context: context,
                  type: DialogType.warning,
                    onPressed:navigateToMain()
                  );

                }
              },
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(left: 15, right: 15),
                width: width,
                height: height * .08,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          Color(0xff1295df),
                          Color(0xff0d88cd)
                        ]
                    )
                ),
                child: Text('save', style: TextStyle(
                    color: Colors.white
                ),),
              ),
            )
          ],
        ),
      ),
    );
  }
  Widget dropDownList(){
    return SingleChildScrollView(
      child: Container(
        width: width,
        child: DropdownButton<String>(
            isExpanded: true,
        icon: Icon(Icons.arrow_drop_down),
          value: dropdownValue,
          elevation: 1,
          style: TextStyle(
              color: Colors.black
          ),
          focusColor: Colors.white,
          onChanged: (String newValue) {
            setState(() {
              dropdownValue = newValue;
            });
          },
          items: clients.length<=1 ? clients.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: dropdownValue ,
              child: Text(dropdownValue),
            );}).toList():clients
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          })
              .toList()
        ),
      ),
    );
}
  Widget clientsListener(){
    return BlocBuilder<ClientsBloc, ClientListState>(
      builder: (context , ClientListState realState){
        if(realState.result == dataResult.Empty)
        {
          clients.add('Client Name');
          return dropDownList();
        }
        else if(realState.result == dataResult.Loaded)
        {
          clients=realState.list;
          return dropDownList();
        }
        return Container();
      },
    );
  }
  Widget checkInListener(){
    return  BlocListener<CheckInBloc ,BaseResultState >(
      listener: (context, state){
        if(state.result==dataResult.Loaded)
        {
          var flag = (state.model as CheckInResponse).flag;
          if(flag ==1 ){
            saveChecksToDB(synced :true);
            Utils.showMyDialog(content: 'Checked In Successfully ',
            context: context,
            onPressed: navigateToMain(),
            type: DialogType.confirmation);

          }
          else{
            Utils.showMyDialog(content: 'There is something wrong please check in again ',
                context: context,
                onPressed: navigateToMain(),
                type: DialogType.confirmation);
          }
        }
      },
      child: Container(),
    );
  }

Future<Employee> getApiKeyAndId()async{
  return await SharedPreferencesOperations.getApiKeyAndId();
}
navigateToMain(){
  Navigator.push(context, MaterialPageRoute(
    builder: (context )=> BlocProvider(
      child: MainScreen(),
      create: (_)=>CheckInBloc(),
    )
  ));
}
saveChecksToDB({bool synced}){
var  nowDate = now.year.toString() + '/'+now.month.toString() + '/'+now.day.toString();
  var nowTime= now.hour.toString() + ':'+now.minute.toString() + ':'+now.second.toString();
    DbOperations _operations = DbOperations();
    _operations.openMyDatabase().then((onValue){
      _operations.insertTransaction(CheckModel(
          apiKey: empModel.apiKey,
          addressInfo: addressInfoController.text,
          location: location ,
          client: dropdownValue,
          logginMachine:Platform.isAndroid ? 'Android' : 'IOS' ,
          date:nowDate  ,
          time: nowTime,
          checkType: 1,
          sync: synced ?1 :0,
          isOnline: synced? 1:0,
          employeeId: empModel.employeeId.toString()
      ));
    });
}
}



