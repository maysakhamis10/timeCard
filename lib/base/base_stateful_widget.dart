import 'package:flutter/material.dart';
import 'package:timecarditg/resources/colors.dart';

import 'layout_utilities.dart';

final RouteObserver<PageRoute> routeObserver = new RouteObserver<PageRoute>();

abstract class BaseStatefulWidget extends StatefulWidget {}

abstract class BaseState<T extends BaseStatefulWidget> extends State<T>
    with RouteAware {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool resizeToAvoidBottomPadding = false;

  @override
  void initState() {
    //bytes = ThemHelper.getThem();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutUtils.wrapWithtinLayoutDirection(Scaffold(
      backgroundColor: white_color,
      resizeToAvoidBottomPadding: resizeToAvoidBottomPadding,
      key: getScreenKey,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60), child: getAppbar()),
      drawer: getDrawer(),
      body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: getBody(context)),
      floatingActionButton: buildFloatButton(),
    ));
  }

  Widget getDrawer() {
    return null;
  }

  Widget getBottomNavigationBar() {
    return null;
  }

  Widget getAppbar();

  get getScreenKey {
    return _scaffoldKey;
  }

  Widget getBody(BuildContext context);

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //routeObserver.subscribe(this, ModalRoute.of(context)); temp fix for calling getbody twice
  }

  // Called when the top route has been popped off, and the current route shows up.
  void didPopNext() {
    debugPrint("didPopNext $runtimeType");
    setState(() {});
  }

  buildFloatButton() {
    return null;
  }
}
