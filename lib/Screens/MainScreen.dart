import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'package:timecarditg/utils/Constants.dart';
import 'package:timecarditg/utils/sharedPreference.dart';
import 'package:timecarditg/utils/utils.dart';
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
  List<BottomButtons> bottomButtons = new List();

  @override
  void initState() {
    super.initState();

    _initValue();
    fetchUserData();
    callHomeInfoService();
    _initializeBottomList();
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
        // appBar: AppBar(
        //   automaticallyImplyLeading: false,
        //   centerTitle: true,
        //   title: Text(
        //     'Time card',
        //     textAlign: TextAlign.center,
        //     style: TextStyle(color: Colors.blue, fontSize: 16),
        //   ),
        //   backgroundColor: Color(0xFFEEEEEE),
        // ),
        body: WillPopScope(
      onWillPop: () async => false,
      child: SingleChildScrollView(
        child: BlocBuilder<HomeInfoBloc, BaseResultState>(
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
        }),
      ),
    ));
  }

  Widget buildHomeUi(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 40),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(flex: 2, child: buildUserPic()),
            // SizedBox(
            //   height: 20,
            // ),
            Flexible(
              flex: 0.5.toInt(),
              child: buildTextInGridView(
                  title: 'Today Check in', checkType: CheckType.checkIn),
            ),
            // SizedBox(
            //   height: 10,
            // ),
            Flexible(
              flex: 0.5.toInt(),
              child: buildTextInGridView(
                  title: 'You Can Check out At ',
                  checkType: CheckType.checkOut),
            ),
            // SizedBox(
            //   height: 10,
            // ),
            Flexible(
                flex: 0.5.toInt(),
                child: buildTextInGridView(title: 'Last Check out ')),

            // Spacer(
            //   flex: 1,
            // ),
            Flexible(flex: 2, child: buildSignIn(context)),
            // SizedBox(
            //   height: 20,
            // ),
            Flexible(flex: 1.5.toInt(), child: buildSignOut(context)),
            // Spacer(flex: 1,),
            Flexible(flex: 3, child: buildOtherButtons(context)),
            // Spacer(flex: 3,),
          ],
        ),
      ),
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
            child: GestureDetector(
              onTap: () {
                getImage();
              },
              child: ClipOval(
                child: prefs != null
                    ? prefs.getString(Constants.Img) != null ||
                            prefs.getString(Constants.Img) != ""
                        ? CachedNetworkImage(
                            fit: BoxFit.fill,
                            imageUrl: prefs.getString(Constants.Img),
                            placeholder: (context, text) {
                              return Image.asset("assets/images/logo.png");
                            },
                            errorWidget: (context, url, error) =>
                                Image.asset('assets/images/logo.png'),
                            //
                          )
                        : Image.asset('assets/images/logo.png')
                    : Image.asset('assets/images/logo.png'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSignIn(BuildContext context) {
    return GestureDetector(
      onTap: () => signInOnTap(context),
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(left: 15, right: 15),
        width: width * 0.65,
        height: 50,
        decoration: BoxDecoration(
          color: Color(0xff1295df),
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 7,
              offset: Offset(0, 3), //
            ),
          ],
        ),
        child: Text(
          'Check in',
          style: GoogleFonts.voces(color: Colors.white, fontSize: 16.0),
        ),
      ),
    );
  }

  signInOnTap(BuildContext context) async {
    bool returbned = await showDialog(
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

    if (returbned ?? false)
      showBottomSheet(
          context: context,
          builder: (context) => Text(
              "please try again with choose fromWhere you are login is mandatory"));
  }

  Widget buildSignOut(BuildContext context) {
    return GestureDetector(
      onTap: () => signOutOnTap(context),
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(left: 15, right: 15),
        width: width * 0.65,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.red[300],
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 7,
              offset: Offset(0, 3), //
            ),
          ],
        ),
        child: Text(
          'Check out',
          style: GoogleFonts.voces(color: Colors.white, fontSize: 16.0),
        ),
      ),
    );
  }

  signOutOnTap(BuildContext context) async {
    bool returbned = await showDialog(
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
    if (returbned ?? false)
      showBottomSheet(
          context: context,
          builder: (context) => Text(
              "please try again with choose fromWhere you are login is mandatory"));
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
                style: GoogleFonts.voces(color: Colors.black54, fontSize: 14.0),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                fetchTime(checkType) ?? "00.00.00",
                style: GoogleFonts.voces(color: Colors.black54, fontSize: 14.0),
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
        return _homeInfo.checkIn;
      } else if (checkType == CheckType.checkOut) {
        return _homeInfo.checkOutAt;
      } else {
        if (_homeInfo.lastCheckOutDate != null &&
            _homeInfo.lastCheckOutTime != null) {
          return _homeInfo.lastCheckOutDate + ' ' + _homeInfo.lastCheckOutTime;
        }
      }
    }
    return null;
  }

  Widget buildOtherButtons(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 60, right: 60, top: 40),
      child: ListView(
          scrollDirection: Axis.horizontal,
          children: bottomButtons
              .map((bottomButton) => buildLogOutButton(bottomButton))
              .toList() /*<Widget>[
          buildLogOutButton(),
          buildTransactionsButton(),
          buildRefreshButton(),
        ],*/
          ),
    );
  }

  Widget buildLogOutButton(BottomButtons bottomButton) {
    return Container(
      padding: EdgeInsetsDirectional.only(start: 10),
      child: GestureDetector(
          child: Column(children: <Widget>[
            CircleAvatar(
              radius: 31,
              backgroundColor: Colors.blue[300],
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(
                  bottomButton.icon /*Icons.exit_to_app*/,
                  size: 20.0,
                  color: Colors.blue[300],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Center(
              child: Text(
                bottomButton.name,
                style: GoogleFonts.voces(fontSize: 13.0),
              ),
            ),
          ]),
          onTap: bottomButton.onClick /*UtilsClass.logOut(context)*/

          //  onTap: print('test'),
          ),
    );
  }

/*  Widget buildRefreshButton() {
    return Container(
      padding: EdgeInsetsDirectional.only(start: 10),
      child: GestureDetector(
          child: Column(
            children: <Widget>[
              CircleAvatar(
                radius: 31,
                backgroundColor: Colors.blue,
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.cached,
                    size: 20.0,
                    color: Colors.blue,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: Text('Refresh'),
              ),
            ],
          ),
          onTap: () => callHomeInfoService()
          //  onTap: print('test'),
          ),
    );
  }*/

/*  Widget buildTransactionsButton() {
    return Container(
      padding: EdgeInsetsDirectional.only(start: 10),
      child: GestureDetector(
          child: Column(
            children: <Widget>[
              CircleAvatar(
                radius: 31,
                backgroundColor: Colors.blue,
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.calendar_today,
                    size: 20.0,
                    color: Colors.blue,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: Text(
                  'Transactions',
                ),
              )
            ],
          ),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => TransactionsScreen()))
          //  onTap: print('test'),
          ),
    );
  }*/

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
    if (homeInfo.checkIn == '') return;
    var date = DateTime.now();
    var formate2 = "${date.year}-${date.month}-${date.day}";
    String timeOfCheckIn = '$formate2 ${homeInfo.checkIn}';
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

  void _initializeBottomList() {
    bottomButtons
        .add(new BottomButtons(Icons.exit_to_app, 'Logout', makeLogout));
    bottomButtons.add(new BottomButtons(
        Icons.calendar_today, 'Transactions', goToTransactionScreen));
    bottomButtons
        .add(new BottomButtons(Icons.cached, 'Refresh', callHomeInfoService));
  }

  goToTransactionScreen() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => MultiBlocProvider(
              child: TransactionsScreen(),
              providers: [
                BlocProvider<ClientsBloc>(
                  create: (_) => ClientsBloc(),
                ),
                BlocProvider(
                  create: (_) => CheckBloc(),
                ),
              ],
            )));
  }

  makeLogout() {
    UtilsClass.logOut(context);
  }
}

enum CheckType { checkIn, checkOut }

class BottomButtons {
  IconData icon;

  String name;
  Function onClick;

  BottomButtons(this.icon, this.name, this.onClick);
}
