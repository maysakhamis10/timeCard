import 'package:sqflite/sqflite.dart';
import 'package:timecarditg/models/CheckModel.dart';

class DbOperations {
  Database _database;
  final tableName = 'CheckModel';
  var databasesPath;

  String path;

  Future openMyDatabase() async {
    await getDatabasePath();
    _database = await openDatabase(path, version: 2,
        onCreate: (Database db, int version) async {
          // When creating the db, create the table
          await db.execute(
              'CREATE TABLE $tableName (employee_id INTEGER , date TEXT, '
                  'time INTEGER,api_key TEXT,check_type INTEGER , '
                  'client TEXT , address_info TEXT , loggin_machine TEXT , location TEXT , sync INTEGER , isOnline INTEGER)');
        });
  }

  getDatabasePath() async {
    databasesPath = await getDatabasesPath();
    path = databasesPath + '/timeCard.db';
  }

  deleteMyDatabase() async {
    await getDatabasePath();
    await deleteDatabase(path);
  }

  Future <bool> insertTransaction(CheckModel checkInfo) async {
    await _database.transaction((txn) async {
      int id1 = await txn.rawInsert(
          'INSERT INTO $tableName(employee_id, date, time ,api_key,check_type ,client ,address_info, loggin_machine,'
              'location,sync,isOnline)'
              ' VALUES("${checkInfo.employeeId}",'
              '"${checkInfo.date}",'
              '"${checkInfo.time}",'
              '"${checkInfo.apiKey}",'
              '${checkInfo.checkType},'
              '"${checkInfo.client}",'
              '"${checkInfo.addressInfo}",'
              '"${checkInfo.logginMachine}",'
              '"${checkInfo.location}",'
              '${checkInfo.sync},'
              '${checkInfo.sync}'
              ')');
      print('inserted into db $id1');
      return id1;
    });
  }

  getTransactionsForSomeDate(String date) async {
    List<Map> list = await _database.rawQuery(
        'SELECT * FROM $tableName Where date=? ', [date]);
    print(list.length ?? 0);
    list.forEach((f) {
      print(f['loggin_machine']);
    });
  }

  getAllUnSyncedTransactions() async {
    List<Map> list = await _database.rawQuery(
        'SELECT * FROM $tableName Where sync=? ', [0]);
    print(list.length ?? 0);
    list.forEach((f) {
      print(f['loggin_machine']);
    });
  }

  getAllUnSyncedCheckOuts() async {
    List<Map> list = await _database.rawQuery(
        'SELECT * FROM $tableName Where  check_type = ? And sync=? ', [2,0]);
    print(list.length ?? 0);
    list.forEach((f) {
      print(f['time']);
    });
  }
  getAllUnSyncedCheckIns() async {
    List<Map> list = await _database.rawQuery(
        'SELECT * FROM $tableName Where  check_type = ? And sync=? ', [1,0]);
    print(list.length ?? 0);
    list.forEach((f) {
      print(f['time']);
    });
  }

}