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
  List<TransactionItem> transactionItems = new List();

  @override
  void initState() {
    super.initState();
    _initCurrentDate();
  }

  void _initCurrentDate(){
    now = DateTime.now();
    formattedDate = '${now.year.toString()}/${now.month.toString()}/${now.day.toString()}';
    transactionItems.add(new TransactionItem(Icons.check_circle_outline, Colors.blue, 'Check in '));
    transactionItems.add(new TransactionItem(Icons.exit_to_app, Colors.green[400], 'Check out '));
    transactionItems.add(new TransactionItem(Icons.phonelink_erase, Colors.red[400], 'Offline synced'));
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: false,
          title: Text(
              'Transactions',
              textAlign: TextAlign.center,

              style: TextStyle(color: Colors.white,fontSize: 16),
            ),
            iconTheme: IconThemeData(
              color: Colors.white
            ),
          backgroundColor: Colors.blue,),
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
          return Column(
            children: <Widget>[
               buildEditDateText() ,
              Expanded(
                child: SafeArea(
                  bottom: true,
                  top: true,
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
            ],
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
      Card(
        elevation: 8.0,
        margin: EdgeInsets.all(10.0),
        color:  checkModel.sync == 0  ? Colors.red[300] :
        checkModel.checkType ==1 ? Colors.blue[300] : Colors.green[300] ,

        shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30.0),
         ),
        child: Container(
          margin: EdgeInsets.all(10.0),
          // padding: EdgeInsets.all(10.0),
          child: Center(
            child: buildCenterText(checkModel),
          ),
        ),
      );
  }



  Widget buildCenterText(CheckModel checkModel) {
    return Container(
        padding: EdgeInsets.all(5.0),
        child: Column(

          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(Icons.access_time,  color: Colors.white),
                    SizedBox(width: 10,),
                    Text(checkModel.date + ' ' + checkModel.time,
                      style: TextStyle(color: Colors.white),),
                  ],
                ),

              Row(
                children: <Widget>[
                  Icon(Icons.sync,
                      color: Colors.white
                  ),
                  SizedBox(width: 10,),
                  Text(
                    checkModel.sync == 1 ? 'Online synced' : 'Offline synced'
                    , style: TextStyle(color: Colors.white),),
                ],
              )
              ],
            ),
            SizedBox(height: 10,),

            SizedBox(height: 10,),
            Row(

              children: <Widget>[
                Icon(Icons.info_outline,  color: Colors.white),
                SizedBox(width: 10,),
                Text('Additional info',textAlign: TextAlign.left,
                  style: TextStyle(color: Colors.white),),

              ],
            ),
            SizedBox(width: 15,),
            SizedBox(height: 10,),
            Row(
              children: <Widget>[
                Icon(Icons.account_circle,
                    color: Colors.white
                ),
                SizedBox(width: 10,),
                Expanded(
                  child: Text(checkModel.client,
                    style: TextStyle(color: Colors.white),),
                ),

              ],
            ),
            SizedBox(height: 10,)
          ],


        )


    );
  }

  Widget buildEditDateText(){
    return Container(
      margin: EdgeInsets.all(10.0),
      width: MediaQuery.of(context).size.width,
      child:Column(
        children: <Widget>[
          SizedBox(height: 20,),

          Center(
            child: GestureDetector(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(width: 10,),
                  Icon(Icons.event, color: Colors.blue),
                  SizedBox(width: 10,),
                  Text( formattedDate,
                    textAlign: TextAlign.center,style: TextStyle(fontSize: 20),),
                  SizedBox(width: 10,),
                ],
              ),
              onTap: () =>   _pickDateDialog(),
            ),
          ),
          SizedBox(height: 20,),

          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
              children: transactionItems.map((transactionItem) => buildTransactionItemDetail(transactionItem)).toList(),
            )

        ],
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

 Widget buildTransactionItemDetail(TransactionItem transactionItem) {

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Icon(transactionItem.icon, color: transactionItem.color),
        // SizedBox(width: 5,),
        Text( transactionItem.title, textAlign: TextAlign.center,),
      ],
    );
  }


}


class TransactionItem {
  IconData icon ;
  Color color;
  String title;

  TransactionItem(this.icon, this.color, this.title);


}



