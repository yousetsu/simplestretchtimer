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
  int dialogPreSecond = 0;
  int dialognotificationType = 0;
  AwesomeDialog(this.dialogTitle, this.dialogTime ,this.dialogOtherSide,this.dialogPreSecond,this.dialognotificationType);

  @override
  _AwesomeDialogState createState() => _AwesomeDialogState(dialogTitle, dialogTime ,dialogOtherSide,dialogPreSecond,dialognotificationType);
}

class _AwesomeDialogState extends State<AwesomeDialog> {
  String strTime = '';
  String aweDialogTitle = '';
  String aweDialogTime = '';
  int aweDialogOtherSide = 0;
  int aweDialogPreSecond = 0;
  int notificationType = 0;
  String realDialogTitle = '';
  int countState = 0;

  DateTime dtCntTime = DateTime.now();
  int dtCntTimeSecond = 0;
  Timer? timer;
  bool playFlg = true;

  _AwesomeDialogState(this.aweDialogTitle, this.aweDialogTime,
      this.aweDialogOtherSide, this.aweDialogPreSecond, this.notificationType);

  @override
  void initState() {
    super.initState();

    //通知モードがバイブレーションならセットアップしない
    if (notificationType != cnsNotificationTypeVib) {
      _setupSession();
    }

    //初期の状態セット
    if (aweDialogPreSecond > 0) {
      countState = cnsCountStateReady;
      realDialogTitle = '開始まであと';
      dtCntTime = DateTime.utc(0, 0, 0, 0, 0, aweDialogPreSecond);
      dtCntTimeSecond = aweDialogPreSecond;
    } else {
      countState = cnsCountStateStretch;
      realDialogTitle = aweDialogTitle;
      dtCntTime = DateTime.parse(aweDialogTime);
      dtCntTimeSecond = dtCntTime.minute * 60 + dtCntTime.second;
    }
    timer = Timer.periodic(Duration(seconds: 1), _onTimer);
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(realDialogTitle, style: const TextStyle( color: Color(0xFF191970))),
      content: Row(
          children: <Widget>[
            Text(
                '$strTime', style: const TextStyle(fontSize: 30, color: Colors.blue)),
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
_setupSession
 -------------------------------------------------------------------*/
  Future<void> _setupSession() async {
    _player = AudioPlayer();
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
  }
  /*------------------------------------------------------------------
通知
 -------------------------------------------------------------------*/
  void notification(int state) {
    switch (notificationType) {
      case cnsNotificationTypeNo:
        //無し
        break;
      case cnsNotificationTypeVib:
        switch(state){
          case cnsCountStateReady:
            Vibration.vibrate(
              pattern: [0,300,10,300],
            );
            break;
          case cnsCountStateStretch:
            Vibration.vibrate(duration: 1000);
            break;
          case cnsCountStateReadyOther:

            Vibration.vibrate(
              pattern: [0, 300,10,300],
            );
            break;
          case cnsCountStateStretchOther:
            Vibration.vibrate(duration: 1000);
            break;
        }

        break;

      case cnsNotificationTypeSE:
        switch(state){
          case cnsCountStateReady:
            _player.setAsset('assets/audio/se01.mp3');
            _player.play();
            break;
          case cnsCountStateStretch:
            _player.setAsset('assets/audio/se02.mp3');
            _player.play();
            break;
          case cnsCountStateReadyOther:
            _player.setAsset('assets/audio/se01.mp3');
            _player.play();
            break;
          case cnsCountStateStretchOther:
            _player.setAsset('assets/audio/se02.mp3');
            _player.play();
            break;
        }
        break;
        //ボイスモード一旦なし
      // case cnsNotificationTypeVoice:
      //   switch(state){
      //     case cnsCountStateReady:
      //       //開始
      //       break;
      //     case cnsCountStateStretch:
      //       //反対側・反対側準備
      //       break;
      //     case cnsCountStateReadyOther:
      //       //開始
      //       break;
      //     case cnsCountStateStretchOther:
      //       //終了
      //       break;
      //   }
      //   break;
    }
  }

  /*------------------------------------------------------------------
準備終了
 -------------------------------------------------------------------*/
  void readyEnd() {
    //次の状態はストレッチ
    countState = cnsCountStateStretch;

    setState(() => {
      realDialogTitle = aweDialogTitle
    });

    dtCntTime = DateTime.parse(aweDialogTime);
    dtCntTimeSecond = dtCntTime.minute * 60 + dtCntTime.second;
  }

  /*------------------------------------------------------------------
ストレッチ終了
 -------------------------------------------------------------------*/
  void stretchEnd() {
    if (aweDialogOtherSide == cnsOtherSideOff) {
      timer?.cancel();
      Navigator.pop(context);
    }else{
      if(aweDialogPreSecond > 0) {
        //次の状態は反対側の準備
        countState = cnsCountStateReadyOther;
        setState(() =>
        {
          realDialogTitle = '反対側開始まであと'
        });
        dtCntTime = DateTime.utc(0, 0, 0, 0, 0, aweDialogPreSecond);
        dtCntTimeSecond = aweDialogPreSecond;
      }else{
        //次の状態は反対側のストレッチ
        countState = cnsCountStateStretchOther;

        setState(() => {
          realDialogTitle = '$aweDialogTitle(反対側)',
        });

        dtCntTime = DateTime.parse(aweDialogTime);
        dtCntTimeSecond = dtCntTime.minute * 60 + dtCntTime.second;
      }
    }
  }
  /*------------------------------------------------------------------
ストレッチ終了
 -------------------------------------------------------------------*/
  void ReadyOtherEnd() {
    //次の状態はストレッチ反対側
    countState = cnsCountStateStretchOther;

    setState(() => {
      realDialogTitle = '$aweDialogTitle(反対側)',
    });

    dtCntTime = DateTime.parse(aweDialogTime);
    dtCntTimeSecond = dtCntTime.minute * 60 + dtCntTime.second;
  }
  /*------------------------------------------------------------------
リアルタイムカウントダウン(反対側なし)
 -------------------------------------------------------------------*/
  void _onTimer(Timer timer) {

    ///ストレッチ時間経過(0:ストレッチ準備、1:ストレッチ、2:ストレッチ準備 3:ストレッチ反対側)
    if (dtCntTimeSecond < 0) {
      debugPrint('時間経過！');
      notification(countState);

      switch (countState) {
        case cnsCountStateReady:
          readyEnd();
          break;

        case cnsCountStateStretch:
          stretchEnd();
          break;

        case cnsCountStateReadyOther:
          ReadyOtherEnd();
          break;

        case cnsCountStateStretchOther:
          dtCntTime = DateTime(0,0,0,0,0);
          timer?.cancel();
          Navigator.pop(context);
          break;
      }
    }
    ///時間表示
    setState(() =>
    {
      strTime = '${dtCntTime.minute.toString().padLeft(2, '0')}分 ${dtCntTime.second.toString().padLeft(2, '0')}秒'
    });

    ///カウントダウン処理
    if (playFlg) {
      dtCntTime = dtCntTime.subtract(Duration(seconds: 1));
      dtCntTimeSecond--;
    }

  }
}