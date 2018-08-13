import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'goal.dart';
import 'payment.dart';

class DBHelper{

  static Database _db;

  Future<Database> get db async {
    if(_db != null)
      return _db;
    _db = await initDb();
    return _db;
  }

  //Creating a database with name test.dn in your directory
  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "piggy_bank.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  // Creating a table name Employee with fields
  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    await db.execute(
    "CREATE TABLE Goal (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, total REAL, saved REAL,isFavorite INTEGER)");
    await db.execute(
    "CREATE TABLE Payment (id INTEGER PRIMARY KEY AUTOINCREMENT, goalID INTEGER, amount REAL, date TEXT)");
    print("Created tables");
  }
  
  
  Future<List<Goal>> getGoals() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Goal order by id DESC');
    List<Goal> goals = new List();
    for (int i = 0; i < list.length; i++) {
      goals.add(new Goal(list[i]["id"],list[i]["title"], list[i]["total"], list[i]["saved"],[],(list[i]["isFavorite"]=="1"?true:false)));
    }
    //print("ANURAN${goals[3].title}");
    return goals;
  }

  Future<List<Payment>> getPayments(String goalId) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Payment where goalID=\'${goalId}\' order by id DESC');
    List<Payment> payments = new List();
    for (int i = 0; i < list.length; i++) {
      payments.add(new Payment(list[i]["id"].toString(),list[i]["goalID"].toString(), list[i]["date"], list[i]["amount"]));
    }
    //print("ANURAN${payments[0].amount}");
    return payments;
  }

  void saveGoal(Goal goal) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      return await txn.rawInsert(
          'INSERT INTO Goal(title, total, saved, isFavorite ) VALUES(' +
              '\'' +
              goal.title +
              '\'' +
              ',' +
              '\'' +
              goal.total.toString() +
              '\'' +
              ',' +
              '\'' +
              goal.saved.toString() +
              '\'' +
              ',' +
              '\'' +
              (goal.isFavorite == true ? '1':'0') +
              '\'' +
              ')');
    });
  }

  Future<int> savePayment(String goalID,Payment payment) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      
      List<Map> goals = await txn.rawQuery('SELECT * FROM Goal WHERE id=\'${goalID}\'');
      Goal goal = Goal(goals[0]["id"],goals[0]["title"],goals[0]["total"],goals[0]["saved"],[],false);
      double totalSaved = goal.saved + payment.amount;
      if(!(totalSaved>goal.total)){
        await txn.rawInsert(
          'INSERT INTO Payment(goalID, amount, date) VALUES(' +
              '\'' +
              (payment.goalId)+
              '\'' +
              ',' +
              '\'' +
              payment.amount.toStringAsFixed(2) +
              '\'' +
              ',' +
              '\'' +
              payment.date+
              '\')');
        await txn.rawQuery('UPDATE Goal SET saved=\'${totalSaved}\' where id=\'${goalID}\'');
        return 0;
      }else {
        return 1;
      }
      
    });
  }

  Future<int> updatePayment(String goalID,Payment pay) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      
      List<Map> goals = await txn.rawQuery('SELECT * FROM Goal WHERE id=\'${goalID}\'');
      Goal goal = Goal(goals[0]["id"],goals[0]["title"],goals[0]["total"],goals[0]["saved"],[],false);
      

      List<Map> payments = await txn.rawQuery('SELECT * FROM Payment WHERE id=\'${pay.id}\'');
      Payment payment = Payment(payments[0]["id"].toString(),payments[0]["goalID"].toString(),payments[0]["date"],payments[0]["amount"]);
      double diff = payment.amount - pay.amount;
      double totalSaved=0.0;
      if(diff > 0){
        totalSaved = goal.saved - diff;
      }else {
        totalSaved = goal.saved + (-diff);
      }
      if(!(totalSaved>goal.total)){
        
        await txn.rawQuery('UPDATE Payment SET amount=\'${pay.amount}\' where id=\'${pay.id}\'');
        await txn.rawQuery('UPDATE Goal SET saved=\'${totalSaved}\' where id=\'${goalID}\'');

        return 0;
      }else {
        return 1;
      }
      
    });
  }

  Future<int> deletePayment(String goalID,Payment payment) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {

      await txn.rawQuery('DELETE FROM Payment where id=\'${payment.id}\'');
      
      List<Map> goals = await txn.rawQuery('SELECT * FROM Goal WHERE id=\'${goalID}\'');
      Goal goal = Goal(goals[0]["id"],goals[0]["title"],goals[0]["total"],goals[0]["saved"],[],false);
      double totalSaved = goal.saved - payment.amount;
      
      await txn.rawQuery('UPDATE Goal SET saved=\'${totalSaved}\' where id=\'${goalID}\'');
  
    });
  }

  Future<int> deleteGoal(String goalID) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {

      await txn.rawQuery('DELETE FROM Goal where id=\'${goalID}\'');
    
      await txn.rawQuery('DELETE FROM Payment where goalID=\'${goalID}\'');
  
    });
  }

}