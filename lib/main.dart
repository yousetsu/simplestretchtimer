import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import './setting.dart';
List<Widget> _items = <Widget>[];
List<Map> map_stretchlist = <Map>[];
/*------------------------------------------------------------------
全共通のメソッド
 -------------------------------------------------------------------*/
//初回起動分の処理
Future<void> firstRun() async {
  String dbpath = await getDatabasesPath();
  //設定テーブル作成
  String path = p.join(dbpath, "internal_assets.db");
  //設定テーブルがなければ、最初にassetsから作る
  var exists = await databaseExists(path);
  if (!exists) {
    // Make sure the parent directory exists
    //親ディレクリが存在することを確認
    try {
      await Directory(p.dirname(path)).create(recursive: true);
    } catch (_) {}

    // Copy from asset
    ByteData data = await rootBundle.load(p.join("assets", "ex_stretch_db.db"));
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    // Write and flush the bytes written
    await File(path).writeAsBytes(bytes, flush: true);

  } else {
    //print("Opening existing database");
  }

}
void main() async{
  //SQLfliteで必要？
  WidgetsFlutterBinding.ensureInitialized();
  await firstRun();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const MainScreen(),
        '/setting': (context) => const SettingScreen(),
      },
    );
  }
}
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('タイマー')),
    //  body: SingleChildScrollView(
     //     child: Column(
        body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:  <Widget>[
                _listHeader(),
                Expanded(
                  child: ListView(children: _items,),
                ),
              ]
          ),
  //    ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(label:'タイマー', icon: Icon(Icons.timer)),
          BottomNavigationBarItem(label:'設定', icon: Icon(Icons.settings)),
        ],
        onTap: (int index) {
          if (index == 1) {Navigator.pushNamed(context, '/setting');}
        },
      ),
    );
  }
  Widget _listHeader() {
    return Container(
        decoration:  const BoxDecoration(
            border: Border(bottom: BorderSide(width: 1.0, color: Colors.grey))),

        child: ListTile(
            title:  Row(children:  <Widget>[
              Text('エクササイズリスト', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ])));

  }
  Future<void> getItems() async {
    List<Widget> list = <Widget>[];
    //アチーブメントユーザーマスタから達成状況をロード
    //  achievementUserMap = await  _loadAchievementUser();

    debugPrint('ループスタート');
    for (Map item in map_stretchlist) {

      debugPrint('title:${item['title']}');

      list.add(
          ListTile(
            //tileColor: Colors.grey,
            // tileColor: (item['getupstatus'].toString() == cnsGetupStatusS)
            //     ? Colors.green
            //     : Colors.grey,
            // leading: boolAchieveReleaseFlg
            //     ? const Icon(Icons.star, color: Colors.blue, size: 18,)
            //     : const Icon(Icons.star_border, size: 18,),
            title: Text('${item['title']} ${item['time']} ${item['otherside']}',
              style: TextStyle(color: Colors.black , fontSize: 13),),
            dense: true,
            // selected: listNo == item['No'],
            // onTap: () {
            //   listNo = item['No'];
            //   _tapTile();
            //},
          ));
    }
    setState(() {
      _items = list;
    });
  }
  void _tapTile() {

  }


  /*------------------------------------------------------------------
第一画面ロード
 -------------------------------------------------------------------*/
  Future<void>  loadList() async {
    String dbPath = await getDatabasesPath();
    String path = p.join(dbPath, 'internal_assets.db');
    Database database = await openDatabase(path, version: 1);
     map_stretchlist = await database.rawQuery("SELECT * From stretchlist ");

    //  await database.close();
  }
  /*------------------------------------------------------------------
初期処理
 -------------------------------------------------------------------*/
  void init() async {
    // await  testEditDB();
    await loadList();
    await getItems();
  }

}
