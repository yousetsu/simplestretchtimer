import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:flutter_beep/flutter_beep.dart';
import './setting.dart';
import './stretch.dart';
import './const.dart';
List<Widget> _items = <Widget>[];
List<Map> map_stretchlist = <Map>[];
//didpop使う為
final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();
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
      //didipop使うため
      navigatorObservers: [routeObserver],
    );
  }
}
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with RouteAware {

  @override
  void initState() {
    super.initState();
    init();
  }
  @override
  void didChangeDependencies() { // 遷移時に呼ばれる関数
    // routeObserverに自身を設定(didPopのため)
    super.didChangeDependencies();
    if (ModalRoute.of(context) != null) {
      routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
    }
  }

  @override
  void dispose() {
    // routeObserverから自身を外す(didPopのため)
    routeObserver.unsubscribe(this);
    super.dispose();
  }
  @override
  void didPopNext() {
    // 再描画
    debugPrint("didpop");
    init();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('タイマー')),
        body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:  <Widget>[
                _listHeader(),
                Expanded(
                  child: ListView(children: _items,),
                ),
              ],
          ),

      floatingActionButton: FloatingActionButton(
        onPressed: insertStretch,
        tooltip: '登録',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatt

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
  void insertStretch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StretchScreen('登録')),
    );
  }
  void updStretch(){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => StretchScreen('編集')),
      );
  }

  Future<void> delStretch(int lcNo) async{

    await delStretchDB(lcNo);
    await loadList();
    await getItems();
  }
  Future<void>  delStretchDB(int lcNo)async{
    String dbPath = await getDatabasesPath();
    String query = '';
    String path = p.join(dbPath, 'internal_assets.db');
    Database database = await openDatabase(path, version: 1,);
    query = 'DELETE From stretchlist where no = $lcNo';
    await database.transaction((txn) async {
      await txn.rawInsert(query);
    });
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
    int listNo = 0;
    String listTitle ='';
    String listTime ='';
    int listOtherSide = 0;
    String strOtherSideText = '';
    String strTimeText = '';
    DateTime dtTime = DateTime.now();
    final lists = ['編集', '削除' ];

    //アチーブメントユーザーマスタから達成状況をロード
    //  achievementUserMap = await  _loadAchievementUser();

    for (Map item in map_stretchlist) {

      //反対側ありなし判定
      if( item['otherside'] == cnsOtherSideOn) {
        strOtherSideText = 'ずつ';
      }else{
        strOtherSideText = '';
      }
      dtTime = DateTime.parse(item['time']);
      strTimeText = '${dtTime.minute.toString().padLeft(2,'0')}分${dtTime.second.toString().padLeft(2,'0')}秒';

      list.add(
          ListTile(
            //tileColor: Colors.grey,
            // tileColor: (item['getupstatus'].toString() == cnsGetupStatusS)
            //     ? Colors.green
            //     : Colors.grey,
            //  leading: boolAchieveReleaseFlg
            //      ? const Icon(Icons.play_circle, color: Colors.blue, size: 18,)
            //      : const Icon(Icons.stop_circle, size: 18,),
            title: Text('${item['title']}  ', style: TextStyle(color: Colors.black , fontSize: 20),),
            subtitle: Row(children:  <Widget>[Text('$strTimeText ', style: TextStyle(color: Colors.black , fontSize: 25) ), Text('$strOtherSideText', style: TextStyle(color: Colors.black , fontSize: 15),)] ),
            trailing: PopupMenuButton(
              itemBuilder: (context) {
                return lists.map((String list) {
                  return PopupMenuItem(
                    value: list,
                    child: Text(list),
                  );
                }).toList();
              },
              onSelected: (String list) {
                debugPrint(list);
                switch (list) {
                  case '編集':
                    updStretch();
                    break;
                  case '削除':
                    delStretch(item['no']);
                    break;
                }
              },
            ),

            isThreeLine: true,
             selected: listNo == item['no'],
             onTap: () {
               listNo = item['no'];
               listTitle = item['title'];
               listTime = item['time'];
               listOtherSide = item['otherside'];
               _tapTile(listTitle,listTime,listOtherSide);
            },
          ),
      );
    }
    setState(() {_items = list;});
  }
  void _tapTile(String listTitle ,String listTime, int listOtherSide) {

    showDialog(
        context: context,
        builder: (_) {
          return AwesomeDialog(listTitle,listTime,listOtherSide);
        },
    );
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
    debugPrint("loadList");
    await loadList();
    debugPrint("getItems");
    await getItems();
  }
}
/*------------------------------------------------------------------
Statefulなダイアログ
 -------------------------------------------------------------------*/
class AwesomeDialog extends StatefulWidget {
  String dialogTitle = '';
  String dialogTime = '';
  int dialogOtherSide = 0;

  AwesomeDialog(this.dialogTitle, this.dialogTime ,this.dialogOtherSide);

  @override
  _AwesomeDialogState createState() => _AwesomeDialogState(dialogTitle, dialogTime ,dialogOtherSide);
}

class _AwesomeDialogState extends State<AwesomeDialog> {
  String strTime = '';
  String aweDialogTitle = '';
  String aweDialogTime = '';
  int aweDialogOtherSide = 0;
  DateTime dtCntTime = DateTime.now();
  Timer? timer;
  bool playFlg = true;
  bool otherFlg = false;

  _AwesomeDialogState(this.aweDialogTitle, this.aweDialogTime ,this.aweDialogOtherSide);

  @override
  void initState() {
    super.initState();
     dtCntTime = DateTime.parse(aweDialogTime);
    timer = Timer.periodic(Duration(seconds: 1), _onTimer);
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(this.aweDialogTitle),
      content: Row(
          children:<Widget>[
            Text('$strTime', style: TextStyle(fontSize: 30, color: Colors.blue)),
          ]),
      actions: <Widget>[
        TextButton(
            child: Text('一時停止'),
            onPressed: () => resultAlert('pause')),
        TextButton(
            child: Text('中止'),
            onPressed: () => resultAlert('stop')),
      ],
    );
  }
  void resultAlert(String value) {
    setState(() {
      switch (value) {
        case 'pause':
          playFlg = !playFlg;
          break;
        case 'stop':
          timer?.cancel();
          Navigator.pop(context);
          break;
      }
    });
  }
  /*------------------------------------------------------------------
リアルタイムカウントダウン
 -------------------------------------------------------------------*/
  void _onTimer(Timer timer) {

    if(playFlg) {
      dtCntTime = dtCntTime.subtract(Duration(seconds: 1));
    }

    if(dtCntTime.minute <= 0 && dtCntTime.second <= 0){

      debugPrint('時間経過！');
      FlutterBeep.beep();
      if(aweDialogOtherSide == cnsOtherSideOff){
        timer?.cancel();
        Navigator.pop(context);
      }else{
        if(otherFlg == true){
          timer?.cancel();
          Navigator.pop(context);
        }else{
          otherFlg = true;
          setState(() => {
            aweDialogTitle = '$aweDialogTitle(反対側)',
            dtCntTime = DateTime.parse(aweDialogTime),
            strTime = '${dtCntTime.minute.toString().padLeft(2,'0')}分 ${dtCntTime.second.toString().padLeft(2,'0')}秒'
          });
        }
      }
    }else{
      setState(() => {
        strTime = '${dtCntTime.minute.toString().padLeft(2,'0')}分 ${dtCntTime.second.toString().padLeft(2,'0')}秒'
      });
    }
  }
}