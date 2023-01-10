import 'package:flutter/material.dart';
import './const.dart';
class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key); //コンストラクタ
  @override
  State<SettingScreen> createState() =>  _SettingScreenState();
}
class _SettingScreenState extends State<SettingScreen> {
  int? _type = cnsNotificationTypeVib;
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定画面')),
      body: SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children:  <Widget>[
                Row(mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Radio(activeColor: Colors.blue, value: cnsNotificationTypeVib, groupValue: _type, onChanged: _handleRadio, autofocus:true,),
                    const Text('バイブレーション', style:TextStyle(fontSize: 20.0),),
                  ],),
                Row(mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Radio(activeColor: Colors.blue, value: cnsNotificationTypeSE, groupValue: _type, onChanged: _handleRadio, autofocus:false,),
                    const Text('音', style:TextStyle(fontSize: 20.0),),
                  ],),
              ]
          )
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(label:'タイマー', icon: Icon(Icons.timer)),
          BottomNavigationBarItem(label:'設定', icon: Icon(Icons.settings)),
        ],
        onTap: (int index) {
          if (index == 0) {Navigator.pushNamed(context, '/');}
        },
      ),
    );
  }
  /*------------------------------------------------------------------
設定画面プライベートメソッド
 -------------------------------------------------------------------*/
//ラジオボタン選択時の処理
  void _handleRadio(int? e){
    setState(() {
      _type = e;
      if(e == cnsNotificationTypeVib){
       // isEnable = false; //毎日・・・0
       // _saveStrSetting('mode', cnsModeEveryDay);
      }else{
       // isEnable = true; //平日・・・1
     //   _saveStrSetting('mode', cnsModeNormalDay);
      }
    });

  //  loadSetting();

  }
}