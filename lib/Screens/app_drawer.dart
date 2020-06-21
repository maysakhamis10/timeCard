import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timecarditg/Blocs/CheckInBloc.dart';
import 'package:timecarditg/Screens/transactions_screens.dart';
import 'MainScreen.dart';


class AppDrawer extends StatelessWidget {



  @override
  Widget build(BuildContext context) {

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _createHeader(),
          _createDrawerItem( text: 'Home',
              onTap: () =>
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return  BlocProvider(
                        child: MainScreen(),
                        create:(_)=> CheckInBloc(),
                      );
                    }),
                  )

          ),

          _createDrawerItem(text: 'Transactions',
              onTap: () =>
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (BuildContext context) => TransactionsScreen()))
          ),

          _createDrawerItem( text: 'Logout',),

        ],
      ),
    );
  }
  Widget _createHeader() {
    return DrawerHeader(
        child: Container(
          child:Image.asset("assets/images/logo.png",),),
      );
  }

  Widget _createDrawerItem(
      {String text, GestureTapCallback onTap}) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(text),
          )
        ],
      ),
      onTap: onTap,
    );
  }

}