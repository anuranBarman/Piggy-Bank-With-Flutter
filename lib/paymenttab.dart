import 'package:flutter/material.dart';
import 'payment.dart';
import 'mydatabase.dart';
import 'goal.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

enum Actions { edit, delete }

Future<List<Payment>> fetchPaymentsFromDatabase(String goalId) async {
  var dbHelper = DBHelper();
  Future<List<Payment>> payments = dbHelper.getPayments(goalId);
  return payments;
}

class PaymentTab extends StatefulWidget {
  Goal goal;

  PaymentTab(this.goal);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _PaymentState();
  }
}

class _PaymentState extends State<PaymentTab> {
  final paymentController = TextEditingController();

  SharedPreferences prefs;
  String currentSymbol;

  _getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    currentSymbol = prefs.getString('currency_symbol') == null? '\u20B9':prefs.getString('currency_symbol');
    print(currentSymbol);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    _getSharedPreferences();
    return Stack(
      children: <Widget>[
        FutureBuilder(
          future: fetchPaymentsFromDatabase(widget.goal.id.toString()),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: <Widget>[
                      Container(
                        height: 50.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 5.0, left: 2.0, right: 10.0),
                              child: Icon(
                                Icons.av_timer,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              '${snapshot.data[index].date}',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 15.0),
                            ),
                            SizedBox(
                              width: 20.0,
                            ),
                            Text(
                              '+${currentSymbol} ${snapshot.data[index].amount}',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                  fontSize: 15.0),
                            ),
                            PopupMenuButton<Actions>(
                              onSelected: (Actions act) {
                                if (act == Actions.delete) {
                                  var dbHelper = DBHelper();
                                  dbHelper.deletePayment(
                                      widget.goal.id.toString(),
                                      snapshot.data[index]);
                                } else {
                                  paymentController.text = snapshot
                                      .data[index].amount
                                      .toStringAsFixed(0);
                                  showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                          title: Text(
                                            'Edit Payment',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              TextField(
                                                keyboardType:
                                                    TextInputType.number,
                                                controller: paymentController,
                                                maxLines: 1,
                                                style: TextStyle(
                                                    color: Colors.black),
                                                decoration: InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    labelText: 'Type Amount',
                                                    labelStyle: TextStyle(
                                                        color: Colors.blue)),
                                              ),
                                              Padding(
                                                  padding: EdgeInsets.all(20.0),
                                                  child: RaisedButton(
                                                    onPressed: () {
                                                      var dbHelper = DBHelper();
                                                      var now =
                                                          new DateTime.now();
                                                      var formatter =
                                                          new DateFormat(
                                                              'yyyy/MM/dd');
                                                      String formattedDate =
                                                          formatter.format(now);
                                                      dbHelper
                                                          .updatePayment(
                                                              widget.goal.id
                                                                  .toString(),
                                                              Payment(
                                                                  snapshot
                                                                      .data[
                                                                          index]
                                                                      .id
                                                                      .toString(),
                                                                  widget.goal.id
                                                                      .toString(),
                                                                  formattedDate,
                                                                  double.parse(
                                                                      paymentController
                                                                          .text)))
                                                          .then((result) {
                                                        print(result);
                                                        if (result == 0) {
                                                          print(
                                                              "ANURAN successful");
                                                        } else {
                                                          print(
                                                              "ANURAN failed");
                                                        }
                                                        Navigator
                                                            .of(context)
                                                            .pop();
                                                      });
                                                    },
                                                    textColor: Colors.white,
                                                    color: Colors.blue,
                                                    child: Text('Add Payment'),
                                                  )),
                                            ],
                                          )));
                                }
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<Actions>>[
                                    const PopupMenuItem<Actions>(
                                      value: Actions.edit,
                                      child: const Text('Edit'),
                                    ),
                                    const PopupMenuItem<Actions>(
                                      value: Actions.delete,
                                      child: const Text('Delete'),
                                    ),
                                  ],
                            )
                          ],
                        ),
                      ),
                      Divider(
                        height: 15.0,
                        color: Color.fromARGB(255, 46, 53, 91),
                      )
                    ],
                  );
                },
              );
            } else if (snapshot.hasError) {
              return new Text("${snapshot.error}");
            } else {
              return new Container(
                alignment: AlignmentDirectional.center,
                child: new CircularProgressIndicator(),
              );
            }
          },
        ),
        Positioned(
          bottom: 20.0,
          right: 20.0,
          child: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                      title: Text(
                        'Add Payment',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextField(
                            keyboardType: TextInputType.number,
                            controller: paymentController,
                            maxLines: 1,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Type Amount',
                                labelStyle: TextStyle(color: Colors.blue)),
                          ),
                          Padding(
                              padding: EdgeInsets.all(20.0),
                              child: RaisedButton(
                                onPressed: () {
                                  var dbHelper = DBHelper();
                                  var now = new DateTime.now();
                                  var formatter = new DateFormat('yyyy/MM/dd');
                                  String formattedDate = formatter.format(now);
                                  dbHelper
                                      .savePayment(
                                          widget.goal.id.toString(),
                                          Payment(
                                              '',
                                              widget.goal.id.toString(),
                                              formattedDate,
                                              double.parse(
                                                  paymentController.text)))
                                      .then((result) {
                                    print(result);
                                    if (result == 0) {
                                      print("ANURAN successful");
                                    } else {
                                      print("ANURAN failed");
                                    }

                                    Navigator.of(context).pop();
                                  });
                                },
                                textColor: Colors.white,
                                color: Colors.blue,
                                child: Text('Add Payment'),
                              )),
                        ],
                      )));
            },
          ),
        )
      ],
    );
  }
}
