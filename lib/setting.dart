import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import './const.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key); //コンストラクタ
  @override
  State<SettingScreen> createState() =>  _SettingScreenState();
}
class _SettingScreenState extends State<SettingScreen> {
  //バナー広告初期化
  final BannerAd myBanner = BannerAd(
    adUnitId : strCnsBannerID,
    size: AdSize.banner,
    request: const AdRequest(),
    listener: BannerAdListener(
      onAdLoaded: (Ad ad) => print('バナー広告がロードされました'),
      // Called when an ad request failed.
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        // Dispose the ad here to free resources.
        ad.dispose();
        //  print('バナー広告の読み込みが次の理由で失敗しました: $error');
      },
      // Called when an ad opens an overlay that covers the screen.
      onAdOpened: (Ad ad) => print('バナー広告が開かれました'),
      // Called when an ad removes an overlay that covers the screen.
      onAdClosed: (Ad ad) => print('バナー広告が閉じられました'),
      // Called when an impression occurs on the ad.
      onAdImpression: (Ad ad) => print('Ad impression.'),
    ),
  );
  int? _type = cnsNotificationTypeVib;
  @override
  void initState() {
    super.initState();
    loadSetting();
  }
  @override
  Widget build(BuildContext context) {
    //動画バナーロード
    myBanner.load();
    final AdWidget adWidget = AdWidget(ad: myBanner);
    final Container adContainer = Container(
      alignment: Alignment.center,
      width: myBanner.size.width.toDouble(),
      height: myBanner.size.height.toDouble(),
      child: adWidget,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('設定'),backgroundColor: const Color(0xFF6495ed),),
      body: Column(
             // mainAxisAlignment: MainAxisAlignment.center,

              children:  <Widget>[
                Padding(padding: EdgeInsets.all(30)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.notification_add,color:Colors.blue,size:25),
                    const Text(' 通知音の設定', style:TextStyle(fontSize: 25.0,color: Color(0xFF191970)),),
                  ],),
                Container(
                  margin: const EdgeInsets.fromLTRB(15,0,15,5),
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
                  child:Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children:  <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Radio(activeColor: Colors.blue, value: cnsNotificationTypeNo, groupValue: _type, onChanged: _handleRadio, autofocus:true,),
                    const Text('なし', style:TextStyle(fontSize: 20.0),),
                  ],),
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
                // Row(mainAxisAlignment: MainAxisAlignment.start,
                //   children: <Widget>[
                //     Radio(activeColor: Colors.blue, value: cnsNotificationTypeVoice, groupValue: _type, onChanged: _handleRadio, autofocus:false,),
                //     const Text('声', style:TextStyle(fontSize: 20.0),),
                //   ],),
                ],),
                ),
                adContainer,
              ],

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
  void _handleRadio(int? e) async{
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

    await saveSetting(e);

  }
  Future<void> saveSetting(int? type) async{
    String dbPath = await getDatabasesPath();
    String query = '';
    String path = p.join(dbPath, 'internal_assets.db');
    Database database = await openDatabase(path, version: 1,);
    query = "UPDATE setting set notificationsetting = '$type' ";
    await database.transaction((txn) async {
      await txn.rawInsert(query);
    });
  }
  Future<void> loadSetting() async{

    String dbPath = await getDatabasesPath();
    String path = p.join(dbPath, 'internal_assets.db');
    Database database = await openDatabase(path, version: 1,);
    List<Map> mapSetting = await database.rawQuery("SELECT * From setting limit 1");
   for(Map item in mapSetting){
     setState(() {   _type = item['notificationsetting'];  });
   }

  }

}