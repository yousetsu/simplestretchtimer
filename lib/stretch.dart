import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import "package:intl/intl.dart";

class StretchScreen extends StatefulWidget {
  String title = '';
  StretchScreen(this.title);

  //const StretchScreen({Key? key}) : super(key: key); //コンストラクタ

  @override
  State<StretchScreen> createState() =>  _StretchScreenState(title);
}
class _StretchScreenState extends State<StretchScreen> {
  String title = '';
  _StretchScreenState(this.title);

  final _formKey = GlobalKey<FormState>();
  final _textControllerTitle = TextEditingController();
  DateTime _time = DateTime.utc(0, 0, 0);
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:  Text(title)),
      body: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:  <Widget>[

                Text('登録・編集画面です。',style:TextStyle(fontSize: 20.0)),

                Text('タイトル',style:TextStyle(fontSize: 20.0)),
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
                    key: _formKey,
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
                            type: PickerDateTimeType.kHM,
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
                  child: Text(DateFormat.Hm().format(_time), style: const TextStyle(fontSize: 35),),
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
  void buttonPressed(){
    Navigator.pop(context);
  }
}
