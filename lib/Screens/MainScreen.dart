import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timecarditg/Blocs/CheckInBloc.dart';
import 'package:timecarditg/utils/utils.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}
class _MainScreenState extends State<MainScreen> {
CheckInBloc _bloc ;
@override
  void initState() {
    // TODO: implement initState
    super.initState();
_bloc = BlocProvider.of<CheckInBloc>(context)  ;
}
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xff1295df),
                        Colors.white
                      ]
                  )
              ),
          ),
          Column(
            children: <Widget>[
              SizedBox(height: height*.06,),
              Container(
                height: height*.5,
                child: GridView(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: false,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 0.0,
                    mainAxisSpacing: 0.0,
                    childAspectRatio: 2
                  ),
                  children: <Widget>[
                    Item('Today Check in'),
                    Item('You Can Check out At '),
                    Item('Today Break out'),
                    Item('Today Break in'),
                    Item('Today short Break'),
                    Item('Last Check out '),
                  ],
                ),
              ),
              SizedBox(height: height*.05,),
                GestureDetector(
                  onTap:(){
                    //_bloc.add();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(left: 15, right: 15),
                    width: width,
                    height: height * .08,
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Text('Check in'),
                  ),
                ),
              SizedBox(height: height*.01,),
              GestureDetector(
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
                    child: Text('Check out', style: TextStyle(
                      color: Colors.white
                    ),),
                  ),
                ),

            ],
          )
        ],
      ),
    );
  }
  Widget Item (String title){
    return Container(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.access_time),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
                Text(title, style: TextStyle(color: Colors.black54),),
                Text('12.00.00', style: TextStyle(color: Colors.blue),),
            ],
          )
        ],
      ),
    );
  }
}
