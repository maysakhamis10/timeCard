import 'package:sqflite/sqflite.dart';
import 'package:timecarditg/models/CheckModel.dart';

class DbOperations {
  Database _database;
  final tableName = 'CheckModel';
  var databasesPath;
  String path;

  Future<bool> openMyDatabase() async {
    await getDatabasePath();
    _database = await openDatabase(path, version: 2,
        onCreate: (Database db, int version) async {
          // When creating the db, create the table
          await db.execute(
              'CREATE TABLE $tableName (employee_id INTEGER , date TEXT, '
                  'time INTEGER,api_key TEXT,check_type INTEGER , '
                  'client TEXT , address_info TEXT , loggin_machine TEXT , '
                  'location TEXT , sync INTEGER ,  isOnline INTEGER ,  isAdded INTEGER )');});

   return _database.isOpen ;
  }

  getDatabasePath() async {
    databasesPath = await getDatabasesPath();
    path = databasesPath + '/timeCard.db';
  }

  deleteMyDatabase() async {
    await getDatabasePath();
    await deleteDatabase(path);
  }

 void insertTransaction(CheckModel checkInfo) async {
         await _database.transaction((txn) async {
        checkInfo.isAdded = 1;
        int id1 = await txn.rawInsert(
            'INSERT INTO $tableName(employee_id, date, time ,api_key,check_type ,client '
                ',address_info, loggin_machine,'
                'location, sync ,isOnline, isAdded)'
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
                '${checkInfo.isOnline},'
                '${checkInfo.isAdded}'
                ')');
        print('inserted into db $id1');
        print('object inside database ==> ${checkInfo.toJson()}');
      });
  }


  void updateTransaction(CheckModel checkInfo) async {
    await _database.transaction((txn) async {
      Map<String, dynamic> values = new Map();
      values.putIfAbsent('sync', () => 1);;
      int id1 = await txn.update(tableName , values ,
          where: 'sync = ? AND employee_id = ? ',
          whereArgs: [0,checkInfo.employeeId],
          conflictAlgorithm: ConflictAlgorithm.replace );
      print('inserted into db $id1');
      print('object inside database ==> ${checkInfo.toJson()}');
    });
  }


 Future<List<CheckModel>> fetchTransactionsForSomeDate(String date) async {
    print('date is ==> $date');
   /// var formattedOne  = new DateFormat('');
    List<Map<String, dynamic>> rows  = await _database.rawQuery('SELECT * FROM '
       '$tableName Where  date = ?  ', [date] );
   if(rows.length != 0 ) {
     List<CheckModel> list = _parseRows(rows);
     return list ;
   }
   return null ;
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


  Future<CheckModel> fetchSaveTransInDb() async {
    List<Map<String, dynamic>> rows =  await _database.rawQuery(
        'SELECT * FROM $tableName ORDER BY rowId  DESC LIMIT 1');
    List<CheckModel> list = _parseRows(rows);
    if (list.length != 0) {
      assert(list.length > 0);
      return list[0];
    }
    return null ;
  }


  List<CheckModel> _parseRows(List<Map<String, dynamic>> rows) {
    List<CheckModel> dataObjects = new List();
    rows.forEach((row) {
      try {
        CheckModel d = CheckModel.fromJson(row);
        print('rowwww is ===>  ${d.toJson()}');
        dataObjects.add(d);
      } catch (err) {
        print(err);
      }
    });
    return dataObjects;

  }



}