import 'package:flutter/material.dart';

class LoadingWidget extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LoadingWidgetState();
  }

}
class LoadingWidgetState extends State<LoadingWidget>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Image _img = Image.asset('assets/images/logo.png', width: 170);
  Image _imgGray = Image.asset(
    'assets/images/logo.png',
    color: Colors.grey,
    width: 170,
  );
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(seconds: 1), vsync: this);
    controller.addListener(() {
      if(mounted) {
        setState(() {});
      }
      if (controller.isCompleted) controller.repeat();
    });
    controller.forward();
  }

  //fixme remove commented code if not needed

  @override
  Widget build(BuildContext context) {
final height = MediaQuery.of(context).size.height;
final width = MediaQuery.of(context).size.width;
    return Stack(
      children: <Widget>[
        Image.asset('assets/images/splash.png', height:height ,width: width,),
        Container(
          color: Colors.white,
          child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal:15,vertical:15 ),
                child: Stack(children: <Widget>[
                  _imgGray,
                  ClipRect(clipper: CustomLoadingClip(controller.value), child: _img)
                ]),
              )),
        ),
      ],

    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
class CustomLoadingClip extends CustomClipper<Rect> {
  final double value;

  CustomLoadingClip(this.value);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0.0, 0.0, size.width * value, size.height);
  }

  @override
  bool shouldReclip(CustomLoadingClip oldClipper) {
    return true;
  }
}