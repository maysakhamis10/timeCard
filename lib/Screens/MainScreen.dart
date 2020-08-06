import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timecarditg/Blocs/CheckInBloc.dart';
import 'package:timecarditg/Blocs/ClientsBloc.dart';
import 'package:timecarditg/Blocs/InternetConnectionBloc.dart';
import 'package:timecarditg/Blocs/home_bloc.dart';
import 'package:timecarditg/customWidgets/CircleProgress.dart';
import 'package:timecarditg/models/Employee.dart';
import 'package:timecarditg/models/HomeInformation.dart';
import 'package:timecarditg/utils/sharedPreference.dart';
import 'package:timecarditg/utils/utils.dart';
import 'AdditionalInfo.dart';
import 'AdditionalInfo.dart';
import 'transactions_screens.dart';
import 'package:path/path.dart' as Path;

class MainScreen extends StatefulWidget {
  static const String routeName = '/home';
  MainScreen();

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  HomeInfo _homeInfo;
  var height, width;
  HomeInfoBloc homeInfoBloc;
  AnimationController progressController;
  Animation animation;
  double percentage = 0;
  File _image;
  final picker = ImagePicker();
  SharedPreferences prefs;
  Employee empModel;
  ProgressDialog progressLoading;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _initValue();
    fetchUserData();
    callHomeInfoService();
  }

  void fetchUserData() async {
    empModel = await getUserData();
  }

  Future<Employee> getUserData() async {
    return await SharedPreferencesOperations.getApiKeyAndId();
  }

  _initValue() async {
    prefs = await SharedPreferences.getInstance();
    _homeInfo = new HomeInfo();
    homeInfoBloc = BlocProvider.of<HomeInfoBloc>(context);
    progressController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    animation = Tween<double>(begin: 0, end: percentage)
        .animate(progressController)
          ..addListener(() {});
  }

  void callHomeInfoService() async {
    if (await UtilsClass.checkConnectivity() == connectStatus.connected) {
      homeInfoBloc.add(HomeInfoEvent());
    } else {
      String fetchHomeStr = await SharedPreferencesOperations.fetchHomeData();
      var homeJson = jsonDecode(fetchHomeStr);
      if (mounted) {
        setState(() {
          _homeInfo = HomeInfo.fromJson(homeJson);
          calDifferenceHours(_homeInfo);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: new Center(
            child: Text(
              'TimeCard',
              textAlign: TextAlign.center,
            ),
          ),
          backgroundColor: Color(0xff1295df),
        ),
        body: BlocBuilder<HomeInfoBloc, BaseResultState>(
            builder: (context, state) {
          if (state.result == dataResult.Loading) {
            if (mounted) {
              showProgressDialog();
            }
          } else if (state.result == dataResult.Loaded) {
            _homeInfo = state.model;
            dismissLoading();
            calDifferenceHours(_homeInfo);
            print(('object from api => ${_homeInfo.toJson()}'));
          } else if (state.result == dataResult.Error) {
            dismissLoading();
          }
          return buildHomeUi(context);
        }));
  }

  Widget buildHomeUi(BuildContext context) {
    return ListView(
      children: <Widget>[
        Center(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              buildUserPic(),
              SizedBox(
                height: 20,
              ),
              buildTextInGridView(
                  title: 'Today Check in', checkType: CheckType.checkIn),
              SizedBox(
                height: 20,
              ),
              buildTextInGridView(
                  title: 'You Can Check out At ',
                  checkType: CheckType.checkOut),
              SizedBox(
                height: 20,
              ),
              buildTextInGridView(title: 'Last Check out '),
              SizedBox(
                height: 20,
              ),
              buildSignIn(context),
              SizedBox(
                height: 20,
              ),
              buildSignOut(context),
              SizedBox(
                height: 20,
              ),
              buildOtherButtons(context)
            ],
          ),
        ),
      ],
    );
  }

  Widget buildUserPic() {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Center(
        child: CustomPaint(
          foregroundPainter: CircleProgress(percentage),
          child: Container(
            width: 120,
            height: 120,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  getImage();
                },
                child: CircleAvatar(
                  radius: 120,
                  backgroundImage: prefs != null
                      ? prefs.getString('user_profile_image') != null
                          ? FileImage(
                              File(prefs.getString('user_profile_image')),
                              scale: 1.0)
                          : NetworkImage(
                              'http://kundenarea.at/app-assets/images/user/12.jpg')
                      : NetworkImage(
                          'http://kundenarea.at/app-assets/images/user/12.jpg'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildUserName() {
    return Text(
      '${empModel.username}',
      style: TextStyle(color: Colors.black, fontSize: 25),
    );
  }

  Widget buildSignIn(BuildContext context) {
    return GestureDetector(
      onTap: () => signInOnTap(context),
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(left: 15, right: 15),
        width: width * 0.6,
        height: height * .07,
        decoration: BoxDecoration(
          color: Color(0xff1295df),
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(
              color: Colors.white,
              offset: Offset(0.0, 2.0),
            ),
          ],
        ),
        child: Text(
          'Check in',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  signInOnTap(BuildContext context) {
    // Navigator.of(context, rootNavigator:true).push(
    //   MaterialPageRoute(
    //       builder: (context) => MultiBlocProvider(
    //             child: AdditionalInfo(
    //               checkType: 1,
    //             ),
    //             providers: [
    //               BlocProvider<ClientsBloc>(
    //                 create: (_) => ClientsBloc(),
    //               ),
    //               BlocProvider(
    //                 create: (_) => CheckBloc(),
    //               ),
    //             ],
    //           ),
    //       fullscreenDialog: true),
    // );
    showDialog(
      context: context,
      builder: (context) => MultiBlocProvider(
        child: Container(
          margin: EdgeInsets.all(30),
          child: AdditionalInfo(
            checkType: 1,
          ),
        ),
        providers: [
          BlocProvider<ClientsBloc>(
            create: (_) => ClientsBloc(),
          ),
          BlocProvider(
            create: (_) => CheckBloc(),
          ),
        ],
      ),
    );
  }

  Widget buildSignOut(BuildContext context) {
    return GestureDetector(
      onTap: () => signOutOnTap(context),
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(left: 15, right: 15),
        width: width * 0.6,
        height: height * .07,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(
              color: Colors.white,
              offset: Offset(0.0, 2.0),
            ),
          ],
        ),
        child: Text(
          'Check out',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  signOutOnTap(BuildContext context) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => MultiBlocProvider(
    //       child: AdditionalInfo(
    //         checkType: 0,
    //       ),
    //       providers: [
    //         BlocProvider<ClientsBloc>(
    //           create: (_) => ClientsBloc(),
    //         ),
    //         BlocProvider(
    //           create: (_) => CheckBloc(),
    //         ),
    //       ],
    //     ),
    //   ),
    // );

    showDialog(
      context: context,
      builder: (context) => MultiBlocProvider(
        child: Container(
          margin: EdgeInsets.all(30),
          child: AdditionalInfo(
            checkType: 0,
          ),
        ),
        providers: [
          BlocProvider<ClientsBloc>(
            create: (_) => ClientsBloc(),
          ),
          BlocProvider(
            create: (_) => CheckBloc(),
          ),
        ],
      ),
    );
  }

  Widget buildTextInGridView({String title, CheckType checkType}) {
    return Container(

        ///  margin: EdgeInsets.only(right: 10.0),
        child: Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(color: Colors.black54),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                fetchTime(checkType) ?? "00.00.00",
                style: TextStyle(color: Colors.black54),
              ),
            ],
          )
        ],
      ),
    ));
  }

  String fetchTime(CheckType checkType) {
    if (_homeInfo != null) {
      if (checkType == CheckType.checkIn) {
        return _homeInfo.CheckIn;
      } else if (checkType == CheckType.checkOut) {
        return _homeInfo.CheckOutAt;
      } else {
        if (_homeInfo.LastCheckOutDate != null &&
            _homeInfo.LastCheckOutTime != null) {
          return _homeInfo.LastCheckOutDate + ' ' + _homeInfo.LastCheckOutTime;
        }
      }
    }
    return null;
  }

  Widget buildOtherButtons(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 60, right: 60, top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          buildLogOutButton(),
          buildRefreshButton(),
          buildTransactionsButton(),
        ],
      ),
    );
  }

  Widget buildLogOutButton() {
    return GestureDetector(
        child: Column(
          children: <Widget>[
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.add_to_home_screen,
                size: 20.0,
                color: Colors.black,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text('Logout')
          ],
        ),
        onTap: () => UtilsClass.logOut(context)

        //  onTap: print('test'),
        );
  }

  Widget buildRefreshButton() {
    return GestureDetector(
        child: Column(
          children: <Widget>[
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.black26,
              child: Icon(
                Icons.refresh,
                size: 15.0,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text('Refresh')
          ],
        ),
        onTap: () => callHomeInfoService()
        //  onTap: print('test'),
        );
  }

  Widget buildTransactionsButton() {
    return GestureDetector(
        child: Column(
          children: <Widget>[
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.black26,
              child: Icon(
                Icons.date_range,
                size: 15.0,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text('Transactions')
          ],
        ),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => TransactionsScreen()))
        //  onTap: print('test'),
        );
  }

  showProgressDialog() async {
    await Future.delayed(const Duration(milliseconds: 100), () {
      progressLoading = ProgressDialog(
        context,
        type: ProgressDialogType.Normal,
        isDismissible: true,
        showLogs: false,
      );
      progressLoading.show();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future getImage() async {
    prefs.remove('user_profile_image');
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
    final String path = await findLocalPath();
    String fileNameOfSelectedImage = Path.basename(_image.path);
    final File newImage = await _image.copy('$path/$fileNameOfSelectedImage');
    var fileName = Path.basename(newImage.path);
    var tesssst = '$path/$fileName';
    print('pathhhhhhhhhh=====>>>>> $tesssst');
    prefs.setString('user_profile_image', '$path/$fileName');
  }

  Future<String> findLocalPath() async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }

  void calDifferenceHours(HomeInfo homeInfo) {
    var date = DateTime.now();
    var formate2 = "${date.year}-${date.month}-${date.day}";
    String timeOfCheckIn = '${formate2} ${homeInfo.CheckIn}';
    var pos = timeOfCheckIn.lastIndexOf(' ');
    String result =
        (pos != -1) ? timeOfCheckIn.substring(0, pos) : timeOfCheckIn;
    DateTime checkInpDate = new DateFormat("yyyy-MM-dd hh:mm:ss").parse(result);
    DateTime currentDate = DateTime.now();
    print('tesst $result');
    final difference = currentDate.difference(checkInpDate).inHours;
    print('hourssss =>> $difference');
    percentage = (difference / 9) * 100;
    progressController.forward();
  }

  void dismissLoading() async {
    await Future.delayed(const Duration(milliseconds: 100), () {
      progressLoading.hide();
    });
  }

  @override
  void dispose() {
    progressController.dispose();
    // TODO: implement dispose
    super.dispose();
  }
}

enum CheckType { checkIn, checkOut }
