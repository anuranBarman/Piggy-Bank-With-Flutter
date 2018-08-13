import 'package:flutter/material.dart';
import 'goal.dart';
import 'mydatabase.dart';
import 'dart:async';

class AddGoal extends StatefulWidget {
  
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AddGoalState();
  }

  
}

class _AddGoalState extends State<AddGoal> {
  final _formKey = GlobalKey<FormState>();
  bool is_Checked = false;
  final goalNameController = TextEditingController();
  final goalAmountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 61, 70, 120),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 61, 70, 120),
          title: Center(
            child: Text(
              'Add a Goal',
              style: TextStyle(fontFamily: 'Roboto'),
            ),
          ),
          elevation: 0.0,
        ),
        body: SingleChildScrollView(child: 
        Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: goalNameController,
                    maxLines: 1,
                    maxLength: 20,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Type a Goal Name',
                        labelStyle: TextStyle(color: Colors.greenAccent)),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter some text';
                      }
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: TextFormField(
                      maxLines: 1,
                      controller: goalAmountController,
                      style: TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Type Total Amount',
                          labelStyle: TextStyle(color: Colors.greenAccent)),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter some text';
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Checkbox(
                          value: is_Checked,
                          onChanged: (bool isChecked) {
                            setState(() {
                              is_Checked = isChecked;
                              SnackBar(
                                content: Text('value changed'),
                              );
                            });
                          },
                        ),
                        Text(
                          'As Favorite',
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Container(
                        width: 200.0,
                        child: RaisedButton(
                          onPressed: () {
                            // Validate will return true if the form is valid, or false if
                            // the form is invalid.
                            if (_formKey.currentState.validate()) {
                              
                              Goal goal = Goal(
                                  1,
                                  goalNameController.text,
                                  double.parse(goalAmountController.text),
                                  0.0,
                                  [],
                                  is_Checked);
                              print(goal.isFavorite);
                              var dbHelper = DBHelper();
                              dbHelper.saveGoal(goal);
                              print("saved goal");
                              Navigator.of(context).pop();
                            }
                          },
                          color: Colors.blue,
                          textColor: Colors.white,
                          child: Text('Add'),
                        ),
                      )),
                ],
              ),
            )),));
  }
}
