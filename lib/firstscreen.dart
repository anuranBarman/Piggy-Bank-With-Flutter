import 'package:flutter/material.dart';
import 'goal.dart';
import 'secondscreen.dart';
import 'addgoal.dart';
import 'dart:async';
import 'mydatabase.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'currency.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<Goal>> fetchGaolsFromDatabase() async {
  var dbHelper = DBHelper();
  Future<List<Goal>> employees = dbHelper.getGoals();
  return employees;
}

class FirstScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _FirstScreenState();
  }
}

class _FirstScreenState extends State<FirstScreen> {
  SharedPreferences prefs;
  String currentSymbol;

  List<Currency> currencies;
  Future loadCurrency() async {
    String jsonCurrency = await _loadCurrencyAsset();
    currencies = (JSON.decode(jsonCurrency) as List)
        .map((e) => Currency.fromJson(e))
        .toList();
    _value = currencies[0].cc;
  }

  String getRelatedCurrencySymbol(String cc){
    for(var c in currencies){
      if(c.cc == cc){
        return c.symbol;
      }
    }
    return '\u20B9';
  }

  String _value = "";

  _getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    currentSymbol = prefs.getString('currency_symbol') == null? '\u20B9':prefs.getString('currency_symbol');
    print(currentSymbol);
  }

  void _onChanged(String c) {
    setState(() {
      _value = c;
    });
    prefs.setString('currency_symbol', getRelatedCurrencySymbol(c));
  }

  Future<String> _loadCurrencyAsset() async {
    return await rootBundle.loadString('assets/currency.json');
  }

  @override
  void initState() {
    // TODO: implement initState
    loadCurrency();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    _getSharedPreferences();
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          elevation: 4.0,
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => AddGoal()));
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        backgroundColor: Color.fromARGB(255, 61, 70, 120),
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.monetization_on),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                        title: Text(
                          'Choose Currency',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            DropdownButton(
                              value: _value,
                              items: currencies.map((Currency c) {
                                return DropdownMenuItem(
                                    value: c.cc,
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          c.cc,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          " (" + c.symbol + ") ",
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic),
                                        ),
                                      ],
                                    ));
                              }).toList(),
                              onChanged: (String c) {
                                print(c);
                                _onChanged(c);
                                Navigator.of(context).pop();
                              },
                            )
                          ],
                        )));
              },
            )
          ],
          backgroundColor: Color.fromARGB(255, 61, 70, 120),
          title: Center(
            child: Text(
              'Piggy Bank',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Raleway'),
            ),
          ),
          elevation: 0.0,
        ),
        body: Column(children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 8.0),
              ),
              Text(
                'Goals',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green), //fromARGB(255, 46, 53, 91)
              ),
            ],
          ),
          FutureBuilder<List<Goal>>(
            future: fetchGaolsFromDatabase(),
            builder: (context, snapshot) {
              print(snapshot);
              if (snapshot.hasData) {
                print("ANURAN ${snapshot.data.length}");
                return Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: <Widget>[
                            ListTile(
                              onTap: () {
                                //Navigator.pushNamed(context, '/goal');
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SecondScreen(
                                            snapshot.data[index])));
                              },
                              contentPadding:
                                  EdgeInsets.only(left: 8.0, right: 8.0),
                              leading: Text(
                                ' ${snapshot.data[index].title}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              trailing: Text(
                                '${currentSymbol} ${(snapshot.data[index].total-snapshot.data[index].saved).toStringAsFixed(2)} remaining',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Roboto'),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 8.0, right: 8.0),
                              child: LinearProgressIndicator(
                                backgroundColor:
                                    Color.fromARGB(255, 46, 53, 91),
                                value: ((snapshot.data[index].saved /
                                                snapshot.data[index].total) *
                                            100)
                                        .round() *
                                    .01,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 10.0),
                              child: Divider(
                                  height: 15.0,
                                  color: Color.fromARGB(255, 46, 53, 91)),
                            )
                          ],
                        );
                      }),
                );
              } else if (snapshot.hasError) {
                print("${snapshot.error}");
                return new Text("${snapshot.error}");
              }
              //return Container(width: 0.0,height: 0.0,);
              return new Container(
                alignment: AlignmentDirectional.center,
                child: new CircularProgressIndicator(),
              );
            },
          )
        ]));
  }
}
