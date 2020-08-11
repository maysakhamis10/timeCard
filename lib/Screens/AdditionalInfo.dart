
import 'package:flutter/cupertino.dart';
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

class _AdditionalInfoState extends State<AdditionalInfo>  {
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
  bool _isExpand = false ;


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
        backgroundColor: Colors.transparent,
        body: Align(
            alignment: Alignment.center,
            child:  Container(
                height: height*0.6,
                alignment: Alignment.center,
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                child: ListView(
                  children: <Widget>[
                        buildRowOfClientDropDown(),
                        SizedBox(height: 2,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: buildContainerTxt(),
                        ),
                    SizedBox(height: 10,),
                    buildSaveBtn(),
                    SizedBox(height: 2,)
                  ],
                )
              ),
            ),
    );
  }

  Widget buildRowOfClientDropDown() {
    return Container(
      margin: EdgeInsets.all(10),
      padding:EdgeInsets.all(10),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 5,
          ),
          checkListener(),
          clientsListener(),
          SizedBox(
            width: 5,
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
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
          color:  Colors.white30,
          border: Border.all(
            color: Color(0xFFD6D6D6),
          ),
          borderRadius: BorderRadius.all(Radius.circular(25))),
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
        maxLines: 5,
      ),
    );
  }

  Widget buildSaveBtn() {
    return GestureDetector(
      onTap: () => saveButtonOnTap(),
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(left: 20, right: 20),
        width: width,
        height: 50,
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff1295df), Color(0xff0d88cd)],
            ),
            borderRadius: BorderRadius.circular(30)),
        child: Text(
          'Save',
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
    }
    else {
      await saveChecksToDB(false, checkObject);
      UtilsClass.showMyDialog(
          content:
              'There is no internet now , your transactions will saved locally and it will be synced later ',
          context: context,
          type: DialogType.warning,
          onPressed: navigateToMain);
    }
  }


//  Widget test(){
//    return MenuButton(
//      child: button(),
//      items: clients,
//      topDivider: true,
//      popupHeight: 200,
//      scrollPhysics: AlwaysScrollableScrollPhysics(),
//      itemBuilder: (value) => Container(
//          width: width,
//          height: 40,
//          alignment: Alignment.centerLeft,
//          padding: const EdgeInsets.symmetric(horizontal: 16),
//          child: Text(value)
//      ),
//      toggledChild: Container(
//        color: Colors.white,
//        child: button(),
//      ),
//      divider: Container(
//        height: 1,
//        color: Colors.grey,
//      ),
//      onItemSelected: (value) {
//        dropdownValue = value;
//        // Action when new item is selected
//      },
//      decoration: BoxDecoration(
//          border: Border.all(color: Colors.grey[300]),
//          borderRadius: const BorderRadius.all(Radius.circular(30.0)),
//          color: Colors.white
//      ),
//      onMenuButtonToggle: (isToggle) {
//        print(isToggle);
//      },
//    );
//  }

//  Widget dropDownList( ) {
//   return MenuButton(
//        child: buildBtn(),
//        items: clients,
//        topDivider: true,
//        popupHeight: height*0.4,
//        scrollPhysics: AlwaysScrollableScrollPhysics(),
//        itemBuilder: (value) => Container(
//            width: width,
//            height: height*0.1,
//            alignment: Alignment.centerLeft,
//            padding: const EdgeInsets.symmetric(horizontal: 10),
//            child: Text(value)
//        ),
//        toggledChild: Container(
//          color: Colors.white,
//          child: buildBtn(),
//        ),
//        divider: Container(
//          height: 1,
//          color: Colors.grey,
//        ),
//        onItemSelected: (value) {
//          dropdownValue = value;
//        },
//        decoration: BoxDecoration(
//            border: Border.all(color: Colors.grey[300]),
//            borderRadius: const BorderRadius.all(Radius.circular(20.0)),
//            color: Colors.white
//        ),
//        onMenuButtonToggle: (isToggle) {
//          print('isToggle ==> $isToggle');
//        },
//      );
//  }
//
//

  Widget buildDropDownList(){
    return Column(
      children: <Widget>[
        SizedBox(height: 10,),
        buildExpandedUi(),
        buildExpandedList(),

      ],
    );
  }

  Widget buildExpandedUi(){
   return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
            color:  Colors.white30 ,
            border: Border.all(
              color: Colors.black12,
            ),
            borderRadius: BorderRadius.all(Radius.circular(25))
        ),
        width: width,
        height: 40,
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                child: Text(
                  dropdownValue,
                  style: TextStyle(color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                  width: 14,
                  height: 17,
                  child: FittedBox(
                      fit: BoxFit.fill,
                      child: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey,
                      )
                  )
              ),
            ],
          ),
        ),
      ),
      onTap:()=> _toggle(),
    );
  }

  Widget buildExpandedList(){
    return Visibility(
      visible: _isExpand,
      child: Container(
        height: height*0.14,
        width: width,
        child:  ListView.builder(
        itemCount: clients.length,
        scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.all(2.0),
            margin: EdgeInsets.only(left: 10,right: 10),
            child:  Column(
              children: <Widget>[
                GestureDetector(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(clients[index], style: TextStyle(color: Colors.black,),textDirection: TextDirection.ltr,),
                  ),
                  onTap: ()=> onItemSelected(clients[index]),
                ),
                Divider(),
              ],
            ),
          );
        },
        ),
      ),
    );

  }

  void onItemSelected(String selectedOne){
    print('selected one is => $selectedOne');
    setState(() {
      dropdownValue = selectedOne ;
      _toggle();
    });
  }




//  Widget dropDownList( ) {
//    return Container(
//      width: width,
//      child: DefaultDropdownMenuController(
//        child: Container(
//            height: /*clients.length> 1 ?( _isExpand ? height*0.1 : height*0.2):*/ height*0.4 ,
//            child: Column(
//              children: <Widget>[
//                buildDropdownHeader(onTap:_onTapHead),
//                 Expanded(
//                    child:  Stack(
//                      children: <Widget>[
//                        buildDropdownMenu()
//                      ],
//                    ))
//              ],
//            ),
//          ),
//        onSelected: ({int menuIndex, int index, int subIndex, dynamic data}) {
////          if(_isExpand){
////            setState(() {
////                _isExpand = true;
////            });
////          }
////          else{
////            setState(() {
////              _isExpand = false;
////            });
////          }
//        },
//      ),
//    );
//  }

//  Widget buildDropdownHeader({DropdownMenuHeadTapCallback onTap}) {
//    return Container(
//      width: width,
//      child: Column(
//        mainAxisSize: MainAxisSize.max,
//        crossAxisAlignment: CrossAxisAlignment.start,
//        children: <Widget>[
//          DropdownHeader(
//             height: 60.0,
//             titles: [clients[0]],
//         ),
//        ],
//      ),
//    );
//  }
//
//  void _onTapHead(int index) {
//     print('yess done is done ');
//  }
//
//  DropdownMenu buildDropdownMenu() {
//    return  DropdownMenu(
//        maxMenuHeight: kDropdownMenuItemHeight * 10,
//        switchStyle: DropdownMenuShowHideSwitchStyle.directHideAnimationShow,
//        menus: [
//           DropdownMenuBuilder(
//
//             builder: (BuildContext context) {
//                return  DropdownListMenu(
//                  selectedIndex: 0,
//                  itemExtent: 60.0,
//                  data: clients,
//                  itemBuilder: (BuildContext context, dynamic data,
//                      bool selected) {
//                    return  DecoratedBox(
//                        decoration:  BoxDecoration(
//                            border:  Border(bottom:  Divider.createBorderSide(context))),
//                        child:  Padding(
//                          padding: const EdgeInsets.only(
//                              top: 10, bottom: 10),
//                          child: Row(
//                            children: <Widget>[
//                              Expanded(
//                                child: Text('${data.toString()}',
//                                  maxLines: 6,
//                                  textDirection: TextDirection.ltr,
//                                ),
//                              ),
//                            ],
//                          ),
//                        )
//                    );
//                  }
//                  );
//                },
//               height: kDropdownMenuItemHeight * clients.length
//
//
//           ),
//        ],
//    );
//  }

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
   // showProgressDialog();

    return BlocBuilder<ClientsBloc, ClientListState>(
      builder: (context, ClientListState realState) {
        if (realState.result == dataResult.Empty) {
//          if (progressLoading.isShowing()) {
//            progressLoading.hide();
//          }
          return buildDropDownList();

        } else if (realState.result == dataResult.Loaded) {
//          if (progressLoading.isShowing()) {
//            progressLoading.hide();
//          }
          clients = realState.list;
          print('sizeee==> ${clients.length}');
          return buildDropDownList();
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

  void _toggle() {
    setState(() {
      _isExpand= !_isExpand;
      print('testtttt');
    });
  }

}
