import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import './const.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

late AudioPlayer _player;
///*------------------------------------------------------------------
///Statefulなダイアログ
/// -------------------------------------------------------------------*/
class AwesomeDialog extends StatefulWidget {
  String dialogTitle = '';
  String dialogTime = '';
  int dialogOtherSide = 0;
  int dialognotificationType = 0;
  AwesomeDialog(this.dialogTitle, this.dialogTime ,this.dialogOtherSide,this.dialognotificationType);

  @override
  _AwesomeDialogState createState() => _AwesomeDialogState(dialogTitle, dialogTime ,dialogOtherSide,dialognotificationType);
}

class _AwesomeDialogState extends State<AwesomeDialog> {
  String strTime = '';
  String aweDialogTitle = '';
  String aweDialogTime = '';
  int aweDialogOtherSide = 0;
  int notificationType = 0;
  DateTime dtCntTime = DateTime.now();
  Timer? timer;
  bool playFlg = true;
  bool otherFlg = false;

  _AwesomeDialogState(this.aweDialogTitle, this.aweDialogTime ,this.aweDialogOtherSide,this.notificationType );

  @override
  void initState() {
    super.initState();

    _setupSession();
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
通知
 -------------------------------------------------------------------*/
  void notification(){
    switch (notificationType) {
      case cnsNotificationTypeVib:
        Vibration.vibrate(duration: 1000);
        break;

      case cnsNotificationTypeSE:
        _player.setAsset('assets/audio/se01.mp3');
        _player.play();
        break;

      case cnsNotificationTypeVoice:
      // Vibration.vibrate(duration: 1000);
        break;
    }
  }
  /*------------------------------------------------------------------
リアルタイムカウントダウン
 -------------------------------------------------------------------*/
  void _onTimer(Timer timer) {

    ///カウントダウン処理
    if(playFlg) {
      dtCntTime = dtCntTime.subtract(Duration(seconds: 1));
    }


    ///ストレッチ時間減少
    if(dtCntTime.minute <= 0 && dtCntTime.second <= 0){

      debugPrint('時間経過！');

      notification();

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
  /*------------------------------------------------------------------
_setupSession
 -------------------------------------------------------------------*/
  Future<void> _setupSession() async {
    _player = AudioPlayer();
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
  }

}