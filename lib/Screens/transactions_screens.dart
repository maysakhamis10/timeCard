import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:timecarditg/Blocs/CheckInBloc.dart';
import 'package:timecarditg/Blocs/InternetConnectionBloc.dart';
import 'package:timecarditg/Blocs/LoginBloc.dart';
import 'package:timecarditg/Blocs/home_bloc.dart';
import 'package:timecarditg/Screens/MainScreen.dart';
import 'package:timecarditg/database/database.dart';
import 'package:timecarditg/models/CheckModel.dart';
import 'package:timecarditg/models/checkInResponse.dart';

import 'package:timecarditg/utils/utils.dart';

class TransactionsScreen extends StatefulWidget {
  static const String routeName = '/Transactions';

  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  // final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DbOperations _operations = DbOperations();
  List<CheckModel> _allTranactions = [];
  DateTime now;
  CheckModel _checkObject;
  var formattedDate;
  CheckBloc _checkInBloc;
  ProgressDialog progressLoading;
  bool isNeededToLoading= false;

  List<TransactionItem> transactionItems = new List();

  @override
  void initState() {
    super.initState();
    _checkObject = new CheckModel();
    _checkInBloc = BlocProvider.of<CheckBloc>(context);
    _initCurrentDate();
    _sendOfflineTransactionToApi();
  }

  void _initCurrentDate() {
    now = DateTime.now();
    formattedDate =
        '${now.year.toString()}/${now.month.toString()}/${now.day.toString()}';
    transactionItems.add(new TransactionItem(
        Icons.check_circle_outline, Colors.blue[300], 'Check in '));
    transactionItems.add(new TransactionItem(
        Icons.exit_to_app, Colors.green[300], 'Check out '));
    transactionItems.add(new TransactionItem(
        Icons.phonelink_erase, Colors.red[300], 'Offline synced'));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
             isNeededToLoading ?    Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return MultiBlocProvider(
                      providers: [
                        BlocProvider<HomeInfoBloc>(
                          create: (_) => HomeInfoBloc(),
                        ),
                        BlocProvider<LoginBloc>(
                          create: (_) => LoginBloc(),
                        ),
                      ],
                      child: MainScreen(),
                    ) ;
                  }
                )): Navigator.pop(context);
            }),
          title: Text("Transactions"),
          centerTitle: false,
        ),
        body: BlocListener<CheckBloc, BaseResultState>(
            listener: (context, state) {
              if (state.result == dataResult.Loaded) {
                if (progressLoading != null) {
                  progressLoading.hide();
                }
                var flag = (state.model as CheckInResponse).flag;
                var message = (state.model as CheckInResponse).message;
                if (flag == 1) {
                  saveChecksToDB(true, _checkObject);
                  UtilsClass.showMyDialog(
                      content:
                          "Tansaction offline sent online successfully" /* message.toString()*/,
                      context: context,
                      onPressed: () => Navigator.pop(context),
                      type: DialogType.confirmation);
                  if(mounted) {
                    setState(() {});
                  }
                } else {
                  UtilsClass.showMyDialog(
                      content:
                      "There is error in server please try later",
                      context: context,
                      onPressed: () => Navigator.pop(context),
                      type: DialogType.confirmation);
                }
              }
            },
            child: buildBody()));
  }
  Future<Null> _handleRefresh() async {
    print("on Refreshing ..");
    _sendOfflineTransactionToApi();
    return null;
  }
  Widget buildBody() {
    return Container(
        child:buildListView(),

    );
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

  Widget buildListView() {
    return FutureBuilder<List<CheckModel>>(
      future: _fetchAllSyncTransactions(formattedDate),
      builder:
          (BuildContext context, AsyncSnapshot<List<CheckModel>> snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: <Widget>[
              buildEditDateText(),
              Expanded(
                child: SafeArea(
                  bottom: true,
                  top: true,
                  child:
                  RefreshIndicator(
                    onRefresh: _handleRefresh,
                       child: ListView.builder(
                        itemCount: snapshot.data.length,
                        scrollDirection: Axis.vertical,
                        physics: ScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return buildTransactionItem(_allTranactions[index]);
                        },
                    ),
                     ),
                  ),
                ),
            ],
          );
        } else if (snapshot.hasError) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Color(0xff1295df)),
            ),
          );
        } else {
          return Center(
              child: Text(
            'No Transactions yet',
            style: GoogleFonts.voces(
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.bold),
          ));
        }
      },
    );
  }

  Widget buildTransactionItem(CheckModel checkModel) {
    return Card(
      elevation: 8.0,
      margin: EdgeInsets.all(10.0),
      color: checkModel.sync == 0
          ? Colors.red[300]
          : checkModel.checkType == 1 ? Colors.blue[300] : Colors.green[300],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Container(
        margin: EdgeInsets.all(10.0),
        // padding: EdgeInsets.all(10.0),
        child: buildCenterText(checkModel),
      ),
    );
  }

  Widget buildCenterText(CheckModel checkModel) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(Icons.access_time, color: Colors.white),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      checkModel.date + ' ' + checkModel.time,
                      style: GoogleFonts.voces(
                          color: Colors.white, fontSize: 13.0),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: <Widget>[
                  Icon(Icons.sync, color: Colors.white),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    checkModel.sync == 1 ? 'Online synced' : 'Offline synced',
                    style:
                        GoogleFonts.voces(color: Colors.white, fontSize: 13.0),
                  ),
                ],
              ),
            ),
          ],
        ),
        children: <Widget>[
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 13),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: <Widget>[
                    Icon(Icons.info_outline, color: Colors.white),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Additional info',
                      textAlign: TextAlign.left,
                      style: GoogleFonts.voces(
                          color: Colors.white, fontSize: 13.0),
                    ),
                  ],
                ),
                SizedBox(
                  width: 15,
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: <Widget>[
                    Icon(Icons.account_circle, color: Colors.white),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        checkModel.client,
                        style: GoogleFonts.voces(
                            color: Colors.white, fontSize: 13.0),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEditDateText() {
    return Container(
      margin: EdgeInsets.all(10.0),
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Center(
            child: GestureDetector(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 10,
                  ),
                  Icon(Icons.event, color: Colors.blue[300]),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    formattedDate,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.voces(fontSize: 18.0),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                ],
              ),
              onTap: () => _pickDateDialog(),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: transactionItems
                .map((transactionItem) =>
                    buildTransactionItemDetail(transactionItem))
                .toList(),
          )
        ],
      ),
    );
  }

  void _pickDateDialog() {
    showDatePicker(
      initialDatePickerMode:DatePickerMode.day ,
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now().add((Duration(days: 365))),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      if(mounted) {
      setState(() {
        formattedDate =
        '${pickedDate.year.toString()}/${pickedDate.month.toString()}'
            '/${pickedDate.day.toString()}';
        _fetchAllSyncTransactions(formattedDate);
      });
    }
    });
  }

  Future<List<CheckModel>> _fetchAllSyncTransactions(String date) async {
    if (await _operations.openMyDatabase()) {
      _allTranactions =
          await _operations.fetchTransactionsForSomeDate(date.trim());
      return _allTranactions;
    } else {
      return null;
    }
  }

  Widget buildTransactionItemDetail(TransactionItem transactionItem) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Icon(transactionItem.icon, color: transactionItem.color),
        // SizedBox(width: 5,),
        Text(
          transactionItem.title,
          textAlign: TextAlign.center,
          style: GoogleFonts.voces(fontSize: 13.0),
        ),
      ],
    );
  }

  void _sendOfflineTransactionToApi() async {
    print("Call Send To Api ");
    if (await UtilsClass.checkConnectivity() == connectStatus.connected) {
      CheckModel savedOne = await _operations.fetchSaveTransInDb();
      if (savedOne != null && savedOne.sync != 1) {
        await Future.delayed(const Duration(milliseconds: 100), () {
          progressLoading = ProgressDialog(
            context,
            type: ProgressDialogType.Normal,
            isDismissible: true,
            showLogs: false,
          );
          progressLoading.show();
        });
        print('saved one is => ${savedOne.isAdded}');
        this._checkObject = savedOne;
        _checkInBloc.add(savedOne);
        progressLoading.hide();
        //=======
        setState(() {
          isNeededToLoading = true;
        });
      } else {
        print("not founddddd");
        // this._checkObject = checkObject;
        // _checkInBloc.add(_checkObject);
        // print('online object => ${_checkObject.toJson()}');
      }
    }
  }
}

class TransactionItem {
  IconData icon;

  Color color;
  String title;

  TransactionItem(this.icon, this.color, this.title);
}
