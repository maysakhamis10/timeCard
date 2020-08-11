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
      backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
              'Transactions',
              textAlign: TextAlign.center,

              style: TextStyle(color: Colors.blue,fontSize: 16),
            ),
            iconTheme: IconThemeData(
              color: Colors.blue
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
              padding: EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                  color:  checkModel.sync == 0  ? Colors.red[500] :
                  checkModel.checkType ==1 ? Colors.blue : Colors.green[400] ,
                  border: Border.all(
                    color: Color(0xFFD6D6D6),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(25))
              ),
              child: Center(
                child: buildCenterText(checkModel),
              ),
          ),
        ],
      );
  }



  Widget buildCenterText(CheckModel checkModel) {
    return Container(
        padding: EdgeInsets.all(5.0),
        child: Row(

          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Icon(Icons.access_time, size: 30.0, color: Colors.white),
                    SizedBox(width: 10,),
                    Text(checkModel.date + ' ' + checkModel.time,
                      style: TextStyle(color: Colors.white),),
                  ],
                ),
                SizedBox(height: 10,),
                Row(

                  children: <Widget>[
                    Icon(Icons.info_outline, size: 30.0, color: Colors.white),
                    SizedBox(width: 10,),
                    Text('Additional info',textAlign: TextAlign.left,
                      style: TextStyle(color: Colors.white),),

                  ],
                ),

              ],

            ),
            SizedBox(width: 15,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(height: 10,),
                Row(
                  children: <Widget>[
                    Icon(Icons.account_circle,
                        size: 30.0,
                        color: Colors.white
                    ),
                    SizedBox(width: 10,),
                    Text(checkModel.client,
                      style: TextStyle(color: Colors.white),),

                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  children: <Widget>[
                    Icon(Icons.sync,
                        size: 30.0,
                        color: Colors.white
                    ),
                    SizedBox(width: 10,),
                    Text(
                      checkModel.sync == 1 ? 'Online synced' : 'Offline synced'
                      , style: TextStyle(color: Colors.white),),

                  ],
                ),
                ],
            )
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
                  Icon(Icons.event, size: 30.0, color: Colors.blue),
                  SizedBox(width: 10,),
                  Text( formattedDate, textAlign: TextAlign.center,style: TextStyle(fontSize: 25),),
                  SizedBox(width: 10,),
                ],
              ),
              onTap: () =>   _pickDateDialog(),
            ),
          ),
          SizedBox(height: 20,),

          Center(
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(width: 10,),
                  Icon(Icons.check_circle_outline, size: 30.0, color: Colors.blue),
                  SizedBox(width: 5,),
                  Text( 'Check in ', textAlign: TextAlign.center,),
                  SizedBox(width: 10,),
                  Icon(Icons.exit_to_app, size: 30.0, color: Colors.green[400]),
                  SizedBox(width: 5,),
                  Text( 'Check out ', textAlign: TextAlign.center,),
                  SizedBox(width: 10,),
                  Icon(Icons.phonelink_erase, size: 30.0, color: Colors.red[400]),
                  SizedBox(width: 5,),
                  Text( 'Offline synced', textAlign: TextAlign.center,),

                ],
              ),

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


}




