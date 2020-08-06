import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timecarditg/database/database.dart';
import 'package:timecarditg/models/CheckModel.dart';

class TransactionsScreen extends StatefulWidget {

  static const String routeName = '/Transactions';

  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}


class _TransactionsScreenState extends State<TransactionsScreen> {

 // final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DbOperations _operations = DbOperations();
  List<CheckModel> _allTranactions =  [];
  DateTime now;
  var formattedDate;

  @override
  void initState() {
    super.initState();
    _initCurrentDate();
  }

  void _initCurrentDate(){
    now = DateTime.now();
    formattedDate = '${now.year.toString()}/${now.month.toString()}/${now.day.toString()}';
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
              'Transactions',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black87),
            ),
          backgroundColor: Color(0xFFEEEEEE),),
        body: buildBody());
  }

  Widget buildBody() {
   return Container(
     child: buildListView(),
   );
  }

  Widget buildListView(){
    return FutureBuilder<List<CheckModel>>(
      future: _fetchAllSyncTransactions(formattedDate),
      builder: (BuildContext context , AsyncSnapshot<List<CheckModel>> snapshot){
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data.length+1,
            scrollDirection: Axis.vertical,
            physics: ScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              if ( index == 0 )
                return buildEditDateText() ;
              return buildTransactionItem(_allTranactions[index-1]);
            },
          );
        }
        else if(snapshot.hasError){
          return Center(
            child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Color(0xff1295df)),
            ),
          );
        }
        else {
          return Center(
              child: Text('No Transactions yet')
          );
        }
      },

    );
  }

  Widget buildTransactionItem(CheckModel checkModel) {
    return
      Stack(
        children: <Widget>[
          Container(
              margin: EdgeInsets.all(10.0),
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black38,
                    offset: Offset(0.0, 2.0),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  children: <Widget>[
                    buildCenterText(checkModel),
                  ],
                ),
              )
          ),
        ],
      );
  }

  Widget buildCenterText(CheckModel checkModel) {
    return Center(child: Row(
        children: <Widget>[
          Icon(
            checkModel.checkType == 1 ? Icons.check_box : Icons.exit_to_app,
            size: 30.0,
            color: checkModel.checkType == 1
                ? Colors.green
                : Colors.red,
          ),
          SizedBox(width: 10,),
          Text(checkModel.date + '\n' + checkModel.time,style: TextStyle(color: Colors.black26 ),),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Container(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(checkModel.checkType == 1?'Checked in' : 'Checked out',
                    style: TextStyle(
                      color: checkModel.checkType == 1 ? Color(0xff1295df) : Colors.red,),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                ),
              )
          )
        ],
      ),
    );
  }

  Widget buildEditDateText(){
    return Container(
      margin: EdgeInsets.all(10.0),
             width: MediaQuery.of(context).size.width,
             decoration: BoxDecoration(
               color: Color(0xff1295df),
               borderRadius: BorderRadius.circular(10.0),
               boxShadow: [
                 BoxShadow(
                   color: Colors.white,
                   offset: Offset(0.0, 2.0),
                 ),
               ],
             ),
             child: RaisedButton(
               color: Color(0xff1295df),
               textColor: Colors.white,
               child: Text('Date : '+ formattedDate, ),
               onPressed: _pickDateDialog ,
             ),
    );
  }


  void _pickDateDialog() {
    showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1990),
        lastDate: DateTime.now().add((Duration(days: 365))),
        )
        .then((pickedDate) {
      if (pickedDate == null) {
        return;
      }

      setState(() {
        formattedDate = '${pickedDate.year.toString()}/${pickedDate.month.toString()}''/${pickedDate.day.toString()}' ;
        _fetchAllSyncTransactions(formattedDate);
      });

    });
  }

  Future<List<CheckModel>> _fetchAllSyncTransactions(String date)async{
    if( await _operations.openMyDatabase()) {
      _allTranactions = await _operations.fetchTransactionsForSomeDate(date.trim());
      return _allTranactions ;
    }
    else
      {
        return null ;
      }
  }

//  @override
//  void dispose() {
//    // TODO: implement dispose
//    super.dispose();
//    Navigator.pop(_scaffoldKey.currentState.context);
//  }

}




