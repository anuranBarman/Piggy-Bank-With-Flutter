import 'package:flutter/material.dart';
import 'goaltab.dart';
import 'paymenttab.dart';
import 'goal.dart';
import 'payment.dart';
import 'mydatabase.dart';

class SecondScreen extends StatefulWidget{

  Goal selectedGoal;

  SecondScreen(this.selectedGoal);

  @override
    State<StatefulWidget> createState() {
      // TODO: implement createState
      return _SecondScreenState();
    }

}

class _SecondScreenState extends State<SecondScreen> {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 61, 70, 120),
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.delete,color: Colors.white,),
              onPressed: (){
                var dbHelper = DBHelper();
                dbHelper.deleteGoal(widget.selectedGoal.id.toString());
                Navigator.of(context).pop();
              },
            )
          ],
          backgroundColor: Color.fromARGB(255, 61, 70, 120),
          bottom: TabBar(
            tabs: [
              Tab(
                text: 'Goal',
              ),
              Tab(
                text: 'Payments',
              ),
            ],
          ),
          title: Text(
            '${widget.selectedGoal.title}',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Raleway'),
          ),
        ),
        body: TabBarView(
          children: [
            GoalTab(widget.selectedGoal),
            PaymentTab(widget.selectedGoal), //widget.selectedGoal.payments
          ],
        ),
      ),
    );
  }
}

List<Payment> getPayments(){
  List<Payment> pays = [];

  for(int i =0 ; i<10;i++){
    pays.add(Payment('id', 'goalId', 'date', 10000.0*i));
  }
  return pays;
}