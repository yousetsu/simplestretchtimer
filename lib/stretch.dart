import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import './main.dart';
import './const.dart';
class StretchScreen extends StatefulWidget {
  String mode = '';
  StretchScreen(this.mode);

  //const StretchScreen({Key? key}) : super(key: key); //コンストラクタ

  @override
  State<StretchScreen> createState() =>  _StretchScreenState(mode);
}
class _StretchScreenState extends State<StretchScreen> {
  String mode = '';
  _StretchScreenState(this.mode);

  final _formTitleKey = GlobalKey<FormState>();
  final _formPreSecondKey = GlobalKey<FormState>();
  final _textControllerTitle = TextEditingController();
  final _textControllerPreSecond = TextEditingController();


  String title = 'モードなし';
  DateTime _time = DateTime.utc(0, 0, 0);

  bool _otherSideFlag = false;

  void _handleCheckbox(bool? e) {
    setState(() {
      _otherSideFlag = e!;
    });
  }

  @override
  void initState() {
    super.initState();
     init();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:  Text(title)),
      body: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:  <Widget>[

                Text(title,style:TextStyle(fontSize: 20.0)),

                Text('タイトル',style:TextStyle(fontSize: 20.0)),
                Container(
                  padding: const EdgeInsets.all(5.0),
                  alignment: Alignment.bottomCenter,
                  width: 300.0,
                  height: 70,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.lightBlueAccent),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.lightBlueAccent,
                  ),
                  child:Form(
                    key: _formTitleKey,
                    child: TextFormField(
                      controller: _textControllerTitle,
                      validator: (value) {
                        if (value != null && value.isEmpty) {
                          return '何か入力してください';
                        }else if(int.parse(value!) > 180){
                          return 'Please input 1 - 180';
                        }
                        return null;
                      },
                      // decoration: InputDecoration(hintText: "1~180"),
                      style: const TextStyle(fontSize: 25, color: Colors.white,),
                      textAlign: TextAlign.center,
                      //maxLength: 3,
                   //   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ),

                ///時間
                Text('時間',style:TextStyle(fontSize: 20.0)),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.lightBlueAccent, padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 80),),
                  onPressed: () async {
                    Picker(
                        adapter: DateTimePickerAdapter(
                            type: PickerDateTimeType.kHMS,
                            value: _time,
                            customColumnType: [4, 5]),
                        title: const Text("Select Time"),
                        onConfirm: (Picker picker, List value) {
                          setState(() => {
                            _time = DateTime.utc(2016, 5, 1, 0,value[0], value[1]),
                           // _saveStrSetting('goalgetuptime',_goalgetuptime.toString()),
                          });
                        },
                        onSelect: (Picker picker, int index, List<int> selected){
                          _time = DateTime.utc(2016, 5, 1, 0,selected[0], selected[1]);
                        }
                    ).showModal(context);
                  },
                  child: Text('${_time.minute.toString().padLeft(2,'0')}分${_time.second.toString().padLeft(2,'0')}秒', style: const TextStyle(fontSize: 35),),
                ),
                ///左右上下反対側のストレッチ

          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:  <Widget>[
                Checkbox(
                  activeColor: Colors.blue, // Onになった時の色を指定
                  value: _otherSideFlag, // チェックボックスのOn/Offを保持する値
                  onChanged: _handleCheckbox, // チェックボックスを押下した際に行う処理
                ),
                Text('反対側のストレッチ',style:TextStyle(fontSize: 20.0)),
              ]),

                ///ストレッチを準備する時間（秒）
                Text('ストレッチを準備する時間',style:TextStyle(fontSize: 20.0)),
                Container(
                  padding: const EdgeInsets.all(5.0),
                  alignment: Alignment.bottomCenter,
                  width: 150.0,
                  height: 70,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.lightBlueAccent),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.lightBlueAccent,
                  ),
                  child:Form(
                    key: _formPreSecondKey,
                    child: TextFormField(
                      controller: _textControllerPreSecond,
                      validator: (value) {
                        if (value != null && value.isEmpty) {
                          return '何か入力してください';
                        }else if(int.parse(value!) > 99){
                          return '最高99秒までです';
                        }
                        return null;
                      },
                      // decoration: InputDecoration(hintText: "1~180"),
                      style: const TextStyle(fontSize: 25, color: Colors.white,),
                      textAlign: TextAlign.center,
                      maxLength: 2,
                         inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ),

                ///保存ボタン
                SizedBox(
                  width: 200, height: 70,
                  child: ElevatedButton(
                   // style: ElevatedButton.styleFrom(foregroundColor: Colors.blue , elevation: 16),
                    onPressed: buttonPressed,
                    child: Text( '保存', style:  TextStyle(fontSize: 30.0, color: Colors.white,),),
                  ),
                ),

              ]
          )
      ),

    );
  }
  void buttonPressed() async{
    int intMax = 0;
    intMax =  await getMaxStretchNo();
    await insertStretchData(intMax+1);
    Navigator.pop(context);
  }
  void init(){
    switch (mode) {
    //登録モード
      case cnsStretchScreenIns:
        title = '登録画面';

        break;
    //編集モード
      case cnsStretchScreenUpd:
        title = '編集画面';
        break;
    }
  }
  Future<void>  insertStretchData(int lcNo)async{
    int lcOtherSide = 0 ;
    String dbPath = await getDatabasesPath();
    String query = '';
    String path = p.join(dbPath, 'internal_assets.db');
    Database database = await openDatabase(path, version: 1,);
    if(_otherSideFlag){
      lcOtherSide = 1;
    }
    query = 'INSERT INTO stretchlist(no,title,time,otherside,presecond,kaku1,kaku2,kaku3,kaku4) values($lcNo,"${_textControllerTitle.text}","${_time.toString()}",$lcOtherSide,"${_textControllerPreSecond.text}",null,null,null,null) ';
    await database.transaction((txn) async {
      await txn.rawInsert(query);
    });
  }
  Future<int>  getMaxStretchNo() async{
    int lcMaxNo = 0;
    String dbPath = await getDatabasesPath();
    String path = p.join(dbPath, 'internal_assets.db');
    Database database = await openDatabase(path, version: 1,);
    List<Map> result = await database.rawQuery("SELECT MAX(no) no From stretchlist");
    for (Map item in result) {
      lcMaxNo = item['no'];
    }
    return lcMaxNo;
  }

}
