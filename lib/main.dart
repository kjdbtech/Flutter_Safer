import 'package:flutter/material.dart';
import 'package:sms_advanced/sms_advanced.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String phoneNum = '';
  String Msg = '';

  void sendSMS() async {
    // SMS보내기
    SmsSender smsSender = new SmsSender();
    String address = phoneNum;
    String message = Msg;
    SmsMessage smsMessage = new SmsMessage(address, message);

    smsMessage.onStateChanged.listen((state) {
      if (state == SmsMessageState.Sent) {
        print("문자 발송 상태");
      } else if (state == SmsMessageState.Delivered) {
        print("문자 전달 상태");
      }
    });
    // sms 전달
    smsSender.sendSms(smsMessage);
  }

  @override
  void initState() {
    super.initState();
      setState(() {});
    }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Example"),
        ),
        body: Column(
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  phoneNum = value;
                });
                print('입력된 전화번호 : ' + phoneNum);
              }, decoration: InputDecoration(
              labelText: '전화번호를 입력해 주세요',
              ),
            ),
            TextField(
              onChanged: (value) {
                setState(() {
                  Msg = value;
                  print("입력된 메세지 내용 : " + Msg);
                });
              },
              decoration: InputDecoration(
                labelText: '보내실 문자 내용을 작성',
              ),
            ),
            ElevatedButton(onPressed: sendSMS, child: Text('문자 보내기')),
          ],
        )
      ),
    );
  }
}
