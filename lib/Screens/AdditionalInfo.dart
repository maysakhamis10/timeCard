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
  int checkType;
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
  ClientsBloc _clientsBloc;
  CheckModel _checkObject;
  ProgressDialog progressLoading;
  DbOperations _operations = DbOperations();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkObject = new CheckModel();
    _clientsBloc = BlocProvider.of<ClientsBloc>(context);
    _checkInBloc = BlocProvider.of<CheckBloc>(context);
    _operations.openMyDatabase();
    clients.add(dropdownValue);
    fetchLocation();
    fetchApiKey();
  }

  Future<String> getLocation() async {
    Position position = await UtilsClass.getCurrentLocation();
    return position.latitude.toString() + ":" + position.longitude.toString();
  }

  void fetchLocation() async {
    location = await getLocation();
  }

  void fetchApiKey() async {
    empModel = await getApiKeyAndId();
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
        //   appBar: AppBar(
        //   backgroundColor: mainColor,
        //   title: Text('Additional Info'),
        // ),
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  buildRowOfClientDropDown(),
                  SizedBox(
                    height: height * .01,
                  ),
                  // buildAdditionalInfoTxt(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: buildContainerTxt(),
                  ),
                  Divider(
                    color: Colors.grey,
                    endIndent: 30,
                    indent: 30,
                  ),
                  SizedBox(
                    height: height * .08,
                  ),
                  buildSaveBtn(),
                  SizedBox(
                    height: height * .08,
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget buildRowOfClientDropDown() {
    return Container(
      margin: EdgeInsets.all(20),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
//          buildClientTxt(),
          SizedBox(
            width: 2,
          ),
          checkListener(),
          clientsListener(),
          SizedBox(
            width: 2,
          ),
          // dropDownList(),
        ],
      ),
    );
  }

  Widget buildClientTxt() {
    return Row(
      children: <Widget>[
        Text(
          'Clients ',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          '(Optional) ',
          style: TextStyle(color: Colors.black54, fontSize: 16),
        ),
      ],
    );
  }

  Widget buildContainerTxt() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      width: width,
      child: TextFormField(
        // textAlign: TextAlign.center,
        controller: addressInfoController,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          fillColor: Colors.white,
          hintText: 'Additional info ...',
          border: InputBorder.none,
        ),
        showCursor: true,
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
        height: 50,
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff1295df), Color(0xff0d88cd)],
            ),
            borderRadius: BorderRadius.circular(30)),
        child: Text(
          'save',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }

  saveButtonOnTap() async {
    CheckModel checkObject = new CheckModel();
    now = DateTime.now();
    var nowDate = now.year.toString() +
        '/' +
        now.month.toString() +
        '/' +
        now.day.toString();
    var nowTime = now.hour.toString() +
        ':' +
        now.minute.toString() +
        ':' +
        now.second.toString();
    checkObject.apiKey = empModel.apiKey;
    checkObject.addressInfo = addressInfoController.text;
    checkObject.location = location;
    checkObject.date = nowDate.toString();
    checkObject.client = dropdownValue;
    checkObject.logginMachine = Platform.isAndroid ? 'Android' : 'IOS';
    checkObject.checkType = widget.checkType;
    checkObject.employeeId = empModel.employeeId;
    checkObject.time = nowTime.toString();
    print('CHECK OBJECT FROM SAVE BTN ${checkObject.toJson()}');
    if (await UtilsClass.checkConnectivity() == connectStatus.connected) {
      showProgressDialog();
      CheckModel savedOne = await _operations.fetchSaveTransInDb();
      if (savedOne != null && savedOne.sync != 1) {
        print('saved one is => ${savedOne.isAdded}');
        this._checkObject = savedOne;
        _checkInBloc.add(savedOne);
      } else {
        this._checkObject = checkObject;
        _checkInBloc.add(_checkObject);
        print('online object => ${_checkObject.toJson()}');
      }
    } else {
      await saveChecksToDB(false, checkObject);
      UtilsClass.showMyDialog(
          content:
              'There is no internet now , your transactions will saved locally and it will be synced later ',
          context: context,
          type: DialogType.warning,
          onPressed: navigateToMain);
    }
  }

  Widget dropDownList() {
    return SingleChildScrollView(
      child: Container(
        width: width,
        child: DropdownButton<String>(
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down),
            value: dropdownValue,
            elevation: 1,
            style: TextStyle(color: Colors.black),
            focusColor: Colors.white,
            onChanged: (String newValue) {
              setState(() {
                dropdownValue = newValue;
              });
            },
            items: clients.length <= 1
                ? clients.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: dropdownValue,
                      child: Text(dropdownValue),
                    );
                  }).toList()
                : clients.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList()),
      ),
    );
  }

  showProgressDialog() async {
    await Future.delayed(const Duration(milliseconds: 100), ()  {
      progressLoading =  ProgressDialog(context,type: ProgressDialogType.Normal,
        isDismissible: true,
        showLogs: false,);
      progressLoading.show();
    });
  }

  Widget checkListener() {
    return BlocListener<CheckBloc, BaseResultState>(
      listener: (context, state) {
        if (progressLoading != null) {
          progressLoading.hide();
        }
        if (state.result == dataResult.Loaded) {
          var flag = (state.model as CheckInResponse).flag;
          var message = (state.model as CheckInResponse).message;
          if (flag == 1) {
            saveChecksToDB(true, _checkObject);
            UtilsClass.showMyDialog(
                content: message.toString(),
                context: context,
                onPressed: navigateToMain,
                type: DialogType.confirmation);
          } else {
            UtilsClass.showMyDialog(
                content: 'There is something wrong please check in again ',
                context: context,
                onPressed: navigateToMain,
                type: DialogType.confirmation);
          }
        }
      },
      child: Container(),
    );
  }

  Widget clientsListener() {
    return BlocBuilder<ClientsBloc, ClientListState>(
      builder: (context, ClientListState realState) {
        if (realState.result == dataResult.Empty) {
          //clients.add('Client Name');
          return dropDownList();
        } else if (realState.result == dataResult.Loaded) {
          clients = realState.list;
          return dropDownList();
        }
        return Container();
      },
    );
  }

  Future<Employee> getApiKeyAndId() async {
    return await SharedPreferencesOperations.getApiKeyAndId();
  }

  navigateToMain() {
    Navigator.of(context).pop();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => BlocProvider(
                  child: MainScreen(),
                  create: (_) => HomeInfoBloc(),
                )));
  }

  saveChecksToDB(bool synced, CheckModel checkObject) {
    checkObject.isOnline = synced ? 1 : 0;
    checkObject.sync = synced ? 1 : 0;
    if (checkObject.isAdded == 1) {
      _operations.updateTransaction(checkObject);
    } else {
      _operations.insertTransaction(checkObject);
    }
  }

  Future<CheckModel> fetchSavedTransactionFromDB() async {
    CheckModel savedObject = await _operations.fetchSaveTransInDb();
    return savedObject;
  }
}
