import 'package:flutter/material.dart';
import 'app_drawer.dart';

class TransactionsScreen extends StatefulWidget {

  static const String routeName = '/Transactions';


  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}


class _TransactionsScreenState extends State<TransactionsScreen> {

  final textController = new TextEditingController();

  DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text("Transactions"),
        ),
        drawer: AppDrawer(),
        body: buildBody());
  }

  Widget buildBody() {
    return
       Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 5, right: 5),
            child: Text('Date',
              textAlign:
              TextAlign.center,style: TextStyle(color: Colors.black,fontStyle: FontStyle.normal),),),
          new Expanded(
              child:
              Container(
                margin: EdgeInsets.all(5.0),
                child: Stack(
                  children: <Widget>[
                    TextField(
                      textAlign: TextAlign.center,
                      controller: textController,
                      decoration: InputDecoration(
                        isDense: true,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ) ,
                      ),
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                      ),
                      onTap: _pickDateDialog,
                    ),
                    Container(
                        alignment: Alignment.topRight,
                        padding: EdgeInsets.only(left: 2),
                        child: Icon(Icons.date_range),
                      ),
                  ],
                ),
              )
          ),
        ],
    );
  }

  void _pickDateDialog() {
    showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1990),
        lastDate: DateTime
            .now())
        .then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
        textController.text = _selectedDate.toString();
      });
    });
  }


}




