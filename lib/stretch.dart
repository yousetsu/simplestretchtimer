import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import './const.dart';
class StretchScreen extends StatefulWidget {
  String mode = '';
  int no = 0;
  StretchScreen(this.mode,this.no);

  //const StretchScreen({Key? key}) : super(key: key); //コンストラクタ

  @override
  State<StretchScreen> createState() =>  _StretchScreenState(mode,no);
}
class _StretchScreenState extends State<StretchScreen> {
  String mode = '';
  int no = 0;
  _StretchScreenState(this.mode,this.no);

  final _formTitleKey = GlobalKey<FormState>();
  final _formPreSecondKey = GlobalKey<FormState>();
  final _textControllerTitle = TextEditingController();
  final _textControllerPreSecond = TextEditingController();


  String title = 'モードなし';
  DateTime _time = DateTime.utc(0, 0, 0);
  String buttonName = '登録';

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
      appBar: AppBar(title:  Text(title),backgroundColor: const Color(0xFF6495ed),),
      body: SingleChildScrollView(

        child: Container(
          margin: const EdgeInsets.fromLTRB(15,50,15,5),
          //padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12,width: 2),
            borderRadius: BorderRadius.circular(20),
         //   color: Colors.lightBlueAccent,
            boxShadow: [
              BoxShadow(
                  color: Colors.white,
                  blurRadius: 10.0,
                  spreadRadius: 1.0,
                  offset: Offset(5, 5))
            ],
          ),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:  <Widget>[
                Padding(padding: EdgeInsets.all(10)),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:  <Widget>[
              Icon(Icons.label,size: 25,color: Colors.blue),
                Text('タイトル',style:TextStyle(fontSize: 25.0,color: Color(0xFF191970))),
                ],),

                Container(
                  padding: const EdgeInsets.all(5.0),
                  alignment: Alignment.bottomCenter,
                  width: 300.0,
                  height: 70,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.lightBlueAccent),
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.lightBlueAccent,
                  ),
                  child:Form(
                    key: _formTitleKey,
                    child: TextFormField(
                      controller: _textControllerTitle,
                      validator: (value) {
                        debugPrint('title $value');

                        if (value == null  || value.isEmpty) {
                          return '必ず何か入力してください。';
                        // }else if(value.toString().length > 60.0){
                        //   return '全角３０文字までです';
                        }
                        return null;
                      },
                       decoration: const InputDecoration(hintText: "タイトルを入力してください"),
                      style: const TextStyle(fontSize: 20, color: Colors.white,),
                      textAlign: TextAlign.center,
                      onFieldSubmitted: (String value){

                      },
                      maxLength: 20,

                   //   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ),

                const Padding(padding: EdgeInsets.all(10)),
                ///時間
                Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                     Icon(Icons.timer,size: 25,color: Colors.blue),
                     Text('時間（分秒）',style:TextStyle(fontSize: 25.0,color: Color(0xFF191970))),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.lightBlueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),),
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
                  child: Text('${_time.minute.toString().padLeft(2,'0')}分${_time.second.toString().padLeft(2,'0')}秒', style: const TextStyle(fontSize: 30),),
                ),
                ///左右上下反対側のストレッチ
                const Padding(padding: EdgeInsets.all(10)),

          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const  <Widget>[
                Icon(Icons.swap_horiz,size: 30,color: Colors.blue),
                Text('反対側のストレッチ',style:TextStyle(fontSize: 25.0,color: Color(0xFF191970))),

              ]),
                Checkbox(
                  activeColor: Colors.blue, // Onになった時の色を指定
                  value: _otherSideFlag, // チェックボックスのOn/Offを保持する値
                  onChanged: _handleCheckbox, // チェックボックスを押下した際に行う処理
                ),
                Padding(padding: EdgeInsets.all(10)),

                ///ストレッチを準備する時間（秒）
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:  <Widget>[
                          Icon(Icons.self_improvement,size: 30,color: Colors.blue),
                          Text('準備時間(秒)',style:TextStyle(fontSize: 25.0,color: Color(0xFF191970))),
                        ]),
                Container(
                  padding: const EdgeInsets.all(5.0),
                  alignment: Alignment.bottomCenter,
                  width: 70.0,
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
                        }else if(int.parse(value!) > 59){
                          return '最高59秒までです';
                        }
                        return null;
                      },
                       decoration: InputDecoration(hintText: "秒"),
                      style: const TextStyle(fontSize: 25, color: Colors.white,),
                      textAlign: TextAlign.center,
                      maxLength: 2,
                         inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.all(10)),
                ///保存ボタン
                SizedBox(
                  width: 200, height: 70,
                  child: ElevatedButton(
                    onPressed: buttonPressed,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.blue
                      , elevation: 16
                      ,shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    ),
                    child: Text( buttonName, style:  TextStyle(fontSize: 30.0, color: Colors.white,),),
                  ),
                ),
                Padding(padding: EdgeInsets.all(10)),
              ]
          ),
      ),
      ),

    );
  }
  void buttonPressed() async{
    if (!_formTitleKey.currentState!.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('入力内容に足りない項目があります'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    int intMax = 0;
    switch (mode) {
    //登録モード
      case cnsStretchScreenIns:
        intMax =  await getMaxStretchNo();
        await insertStretchData(intMax+1);
        break;
    //編集モード
      case cnsStretchScreenUpd:
        await updateStretchData(no);
        break;
    }

    Navigator.pop(context);
  }
  void init(){
    switch (mode) {
    //登録モード
      case cnsStretchScreenIns:
        title = '登録画面';
        buttonName  = '登録';
        break;
    //編集モード
      case cnsStretchScreenUpd:
        title = '編集画面';
        buttonName  = '更新';
         loadEditData(no);
        break;
    }
  }
 void loadEditData(int editNo) async{

   String lcTitle = '';
   String lcTime = '';
   int    lcOtherSideFlag = 0;
   int lcPreSecond = 0;

   String dbPath = await getDatabasesPath();
   String path = p.join(dbPath, 'internal_assets.db');
   Database database = await openDatabase(path, version: 1);
   List<Map> result = await database.rawQuery("SELECT * From stretchlist where no = $editNo");
   for (Map item in result) {
     lcTitle = item['title'];
      lcTime = item['time'];
      lcOtherSideFlag = item['otherside'];
      lcPreSecond = (item['presecond'] == null)?0:item['presecond'];
   }

   setState(() {
     _textControllerTitle.text = lcTitle;
     _time = DateTime.parse(lcTime);
     if(lcOtherSideFlag == cnsOtherSideOff){
       _otherSideFlag = false;
     }else{
       _otherSideFlag = true;
     }

     _textControllerPreSecond.text = lcPreSecond.toString();

   });

  }
  Future<void>  insertStretchData(int lcNo)async{
    int lcOtherSide = 0 ;
    String dbPath = await getDatabasesPath();
    String query = '';
    String path = p.join(dbPath, 'internal_assets.db');
    int preSecond = 0;
    Database database = await openDatabase(path, version: 1,);
    if(_otherSideFlag){
      lcOtherSide = 1;
    }

    //準備時間がnullだったらゼロにする
    preSecond = (_textControllerPreSecond.text.isEmpty)? 0:int.parse(_textControllerPreSecond.text);

    query = 'INSERT INTO stretchlist(no,title,time,otherside,presecond,kaku1,kaku2,kaku3,kaku4) values($lcNo,"${_textControllerTitle.text}","${_time.toString()}",$lcOtherSide,"$preSecond",null,null,null,null) ';
    await database.transaction((txn) async {
      await txn.rawInsert(query);
    });
  }
  Future<void>  updateStretchData(int lcNo)async{
    int lcOtherSide = 0 ;
    int lcPreSecond = 0 ;
    String dbPath = await getDatabasesPath();
    String query = '';
    String path = p.join(dbPath, 'internal_assets.db');
    Database database = await openDatabase(path, version: 1,);
    if(_otherSideFlag){
      lcOtherSide = 1;
    }
    lcPreSecond =  int.parse(_textControllerPreSecond.text);
    query = "UPDATE stretchlist set title = '${_textControllerTitle.text}', time = '${_time.toString()}',otherside = $lcOtherSide, presecond = ${lcPreSecond} where no = $lcNo ";
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
