import 'package:flutter/material.dart';
class StretchScreen extends StatefulWidget {
  const StretchScreen({Key? key}) : super(key: key); //コンストラクタ
  @override
  State<StretchScreen> createState() =>  _StretchScreenState();
}
class _StretchScreenState extends State<StretchScreen> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:  Text('登録・編集画面')),
      body: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:  <Widget>[
                Text('登録・編集画面です。',style:TextStyle(fontSize: 20.0)),
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
