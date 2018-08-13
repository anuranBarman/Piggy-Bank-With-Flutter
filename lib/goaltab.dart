import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'dart:math';
import 'goal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalTab extends StatefulWidget {

  Goal selectedGoal;

  GoalTab(this.selectedGoal);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _GolaTabState();
  }
}

class _GolaTabState extends State<GoalTab>
    with TickerProviderStateMixin, AfterLayoutMixin<GoalTab> {
  AnimationController _controller;
  Animation<double> _animation;
  int _percentage = 0;
  SharedPreferences prefs;
  String currentSymbol;

  _getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    currentSymbol = prefs.getString('currency_symbol') == null? '\u20B9':prefs.getString('currency_symbol');
    print(currentSymbol);
  }

  @override
  initState() {
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = _controller;
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // Calling the same function "after layout" to resolve the issue.
    Random rng = new Random();
    setState(() {
      _percentage += ((widget.selectedGoal.saved/widget.selectedGoal.total)*100).round();
      _animation = new Tween<double>(
        begin: _animation.value,
        end: _percentage + .0,
      ).animate(new CurvedAnimation(
        curve: Curves.fastOutSlowIn,
        parent: _controller,
      ));
    });
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {

    _getSharedPreferences();
    TextTheme textTheme = Theme.of(context).textTheme;
    // TODO: implement build
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(20.0),
          child: Container(
              width: 200.0,
              decoration: BoxDecoration(
                  border: Border.all(
                      color: Color.fromARGB(255, 46, 53, 91), width: 5.0),
                  color: Colors.green,
                  shape: BoxShape.circle),
              child: Center(
                  child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (BuildContext context, Widget child) {
                        return Text(
                          _animation.value.toStringAsFixed(0) + "%",
                          style: TextStyle(fontSize: 40.0, color: Colors.white),
                        );
                      },
                    ),
                    // Text('50%',
                    //     textAlign: TextAlign.center,
                    //     style: TextStyle(fontSize: 40.0, color: Colors.white)),
                    Text('REACHED',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12.0, color: Colors.white))
                  ],
                ),
              )
                  // child: CircularProgressIndicator(
                  //   backgroundColor: Color.fromARGB(255, 46, 53, 91),
                  //   value: 70.0 * .01,
                  // ),
                  )),
        ),
        Text(
          'SAVED',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Color.fromARGB(255, 46, 53, 91),
              fontSize: 14.0,
              fontFamily: 'RalewayBold'),
        ),
        Text(
          '${currentSymbol} ${widget.selectedGoal.saved}',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 35.0, color: Colors.white),
        ),
        Padding(
          padding: EdgeInsets.only(top: 100.0),
        ),
        Row(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'REMAINING',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color.fromARGB(255, 46, 53, 91),
                      fontSize: 12.0,
                      fontFamily: 'RalewayBold'),
                ),
                Text(
                  '${currentSymbol} ${(widget.selectedGoal.total-widget.selectedGoal.saved).toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'TOTAL',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color.fromARGB(255, 46, 53, 91),
                      fontSize: 12.0,
                      fontFamily: 'RalewayBold'),
                ),
                Text(
                  '${currentSymbol} ${widget.selectedGoal.total.toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
              ],
            )
          ],
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
        )
      ],
    );
  }
}