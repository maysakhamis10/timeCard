import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:timecarditg/Blocs/CheckInBloc.dart';
import 'package:timecarditg/Blocs/ClientsBloc.dart';
import 'package:timecarditg/Blocs/InternetConnectionBloc.dart';
import 'package:timecarditg/Blocs/home_bloc.dart';
import 'package:timecarditg/Screens/MainScreen.dart';
import 'package:timecarditg/database/database.dart';
import 'package:timecarditg/models/CheckModel.dart';
import 'package:timecarditg/models/Employee.dart';
import 'package:timecarditg/models/checkInResponse.dart';
import 'package:timecarditg/utils/sharedPreference.dart';
import 'dart:io' show Platform;
import 'package:timecarditg/utils/utils.dart';


class AdditionalInfo extends StatefulWidget {

  int checkType ;
  AdditionalInfo({this.checkType});

  @override
  _AdditionalInfoState createState() => _AdditionalInfoState();
}

class _AdditionalInfoState extends State<AdditionalInfo> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String dropdownValue = "Client Name";
  Employee empModel;
  CheckBloc _checkInBloc;
  List<String> clients = List();
  var width, height;
  TextEditingController addressInfoController = TextEditingController();
  String location = '';
  DateTime now;
  Color mainColor = Color(0xff1295df);
  ClientsBloc _clientsBloc ;
  CheckModel _checkObject ;
  ProgressDialog pr;
  DbOperations _operations = DbOperations();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkObject = new CheckModel();
    _clientsBloc = BlocProvider.of<ClientsBloc>(context);
    _checkInBloc = BlocProvider.of<CheckBloc>(context);
    _operations.openMyDatabase() ;
    clients.add(dropdownValue);
    fetchLocation();
    fetchApiKey();
  }

  Future<String> getLocation() async {
    Position position = await UtilsClass.getCurrentLocation();
    return position.latitude.toString() + ":" + position.longitude.toString();
  }

  void fetchLocation()async{
    location = await getLocation();
  }

  void fetchApiKey() async{
     empModel = await getApiKeyAndId() ;
      if (await UtilsClass.checkConnectivity() == connectStatus.connected) {
        _clientsBloc.add(ClientEvent(apiKey: empModel.apiKey));
      }
  }


  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
        backgroundColor: mainColor,
        title: Text('Additional Info'),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                SizedBox(height: height * .01,),
                buildRowOfClientDropDown(),
                SizedBox(height: height * .02,),
                // buildAdditionalInfoTxt(),
                buildContainerTxt(),
                SizedBox(height: height * .08,),
                buildSaveBtn()
              ],
            ),
          ),
        ],
      )
    );
  }


  Widget buildRowOfClientDropDown(){
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center ,
        children: <Widget>[
          buildClientTxt(),
          SizedBox(width: 2,),
          checkListener(),
          SizedBox(width: 2,),
          dropDownList(),
        ],
      ),
    );
  }

  Widget buildClientTxt() {
    return Row(
      children: <Widget>[
        Text('Clients ', style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16
        ),), Text('(Optional) ', style: TextStyle(
            color: Colors.black54,
            fontSize: 16
        ),),
      ],
    );
  }


  Widget buildContainerTxt() {
    return Container(
      margin: EdgeInsets.only(left: 10,right: 10),
      width: width,
      child: TextFormField(
        textAlign: TextAlign.center,
        controller: addressInfoController,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
            fillColor: Colors.white,
            hintText : 'Additional info ...',
            border: OutlineInputBorder(
                gapPadding: 5
            )
        ),
        maxLines: 8,
      ),
    );
  }

  Widget buildSaveBtn() {
    return GestureDetector(
      onTap: () => saveButtonOnTap(),
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
    );
  }

  saveButtonOnTap() async {
    CheckModel checkObject = new CheckModel();
    now = DateTime.now();
    var nowDate = now.year.toString() + '/' + now.month.toString() + '/' +
        now.day.toString();
    var nowTime = now.hour.toString() + ':' + now.minute.toString() + ':' +
        now.second.toString();
    checkObject.apiKey =  empModel.apiKey;
    checkObject.addressInfo=  addressInfoController.text;
    checkObject.location =  location;
    checkObject.date= nowDate.toString();
    checkObject.client = dropdownValue;
    checkObject.logginMachine =  Platform.isAndroid ? 'Android' : 'IOS' ;
    checkObject.checkType = widget.checkType;
    checkObject.employeeId = empModel.employeeId;
    checkObject.time =  nowTime.toString() ;
    print('CHECK OBJECT FROM SAVE BTN ${checkObject.toJson()}');
    if (await UtilsClass.checkConnectivity() == connectStatus.connected) {
      showProgressDialog();
      CheckModel savedOne = await _operations.fetchSaveTransInDb();
      if (savedOne != null && savedOne.sync != 1) {
        print('saved one is => ${savedOne.isAdded}');
        this._checkObject = savedOne;
        _checkInBloc.add(savedOne);
      }
      else {
        this._checkObject = checkObject;
        _checkInBloc.add(_checkObject);
        print('online object => ${_checkObject.toJson()}');
      }

    }
    else {
      await saveChecksToDB(false,checkObject);
      UtilsClass.showMyDialog(
          content: 'There is no internet now , your transactions will saved locally and it will be synced later ',
          context: context,
          type: DialogType.warning,
          onPressed: navigateToMain()
      );

    }
  }

  Widget dropDownList() {
    return SingleChildScrollView(
      child: Container(
        width: width*0.5,
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
            items:
            clients.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList()
        ),
      ),
    );
  }

  showProgressDialog()async{
    pr = await ProgressDialog(context,type: ProgressDialogType.Normal,
      isDismissible: true,
      showLogs: false,);
    pr..style(
        message: 'Loading ...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(backgroundColor: Colors.grey,),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600)
    );
    pr.show();
  }

  Widget checkListener() {
    return BlocListener<CheckBloc, BaseResultState>(
      listener: (context, state) {
        if(pr!=null) {
          pr.hide();
        }
        if (state.result == dataResult.Loaded) {
          var flag = (state.model as CheckInResponse).flag;
          var message = (state.model as CheckInResponse).message;
          if (flag == 1) {
            saveChecksToDB(true, _checkObject);
            UtilsClass.showMyDialog(content:  message.toString(),
                context: _scaffoldKey.currentContext,
                onPressed: navigateToMain(),
                type: DialogType.confirmation);
          }
          else {
            UtilsClass.showMyDialog(
                content: 'There is something wrong please check in again ',
                context: _scaffoldKey.currentContext,
                onPressed: navigateToMain(),
                type: DialogType.confirmation);
          }
        }
      },
      child: Container(),
    );
  }

  Future<Employee> getApiKeyAndId() async {
    return await SharedPreferencesOperations.getApiKeyAndId();
  }

  navigateToMain() {
    pr.hide();
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) =>
            BlocProvider(
              child: MainScreen(),
              create: (_) => HomeInfoBloc(),
            )
    ));
  }

  saveChecksToDB(bool synced, CheckModel checkObject ) {

      checkObject.isOnline = synced ? 1 : 0;
      checkObject.sync = synced ? 1 : 0;
      if(checkObject.isAdded==1) {
        _operations.updateTransaction(checkObject);
      }
      else{
        _operations.insertTransaction(checkObject);
      }


  }

  Future <CheckModel> fetchSavedTransactionFromDB()async{
   CheckModel savedObject = await _operations.fetchSaveTransInDb() ;
   return savedObject ;
  }

   @override
  void dispose() {
    // TODO: implement dispose
  super.dispose();
    Navigator.pop(_scaffoldKey.currentContext);
  }

}



