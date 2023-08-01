import 'dart:async';

import 'package:example/public/menu_bottom.dart';
import 'package:location/location.dart' as LocationPackage;
import 'package:flutter/material.dart';
import 'package:sms_advanced/sms_advanced.dart';
import 'package:geolocator/geolocator.dart' ;
import 'package:flutter/services.dart';
import 'package:sms_mms/sms_mms.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';


void main() {
  runApp(MaterialApp(home:Safer(),));
}


class Safer extends StatefulWidget {
  const Safer({Key? key}) : super(key: key);

  @override
  State<Safer> createState() => _SaferState();
}


class _SaferState extends State<Safer> {
  String phoneNum = '';
  String Msg = '';
  String locationMessage = '';
  String locationResult = '';
  SmsMessageState? msgState;
  List<String> recipients = [];

  var gpsSwitch = true;
  var msgSwitch = false;

  double latitude = 0;
  double longitude = 0;

  bool isLoading = false;

  LocationPackage.Location location = LocationPackage.Location();
  LocationPackage.LocationData? currentLocation;

  ValueNotifier<bool> isDialOpen = ValueNotifier(false);    // 플러팅 버튼('+') on/off

  // FlutterBlue flutterBlue = FlutterBlue.instance;     // 블루투스 인스턴스
  // BluetoothDevice? selectedDevice;
  // BluetoothCharacteristic? characteristic;

  // final String _service_uuid = '';  // BLE 기기의 서비스 UUID
  // final String _characteristicUUID = '';  // BLE 기기의 특성 UUID



  @override
  void initState() {
    super.initState();
    setState(() {});
    getLocation();
    if(mounted){
      _startLocationUpdates();
    }
  }


  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }




  void sendSMS() async {
    // SMS보내기
    SmsSender smsSender = new SmsSender();    // SMS를 보내기 위한 생성자
    String address = phoneNum;
    String message = Msg;
    SmsMessage smsMessage;

    if(msgSwitch && !gpsSwitch) {
      smsMessage = new SmsMessage(address, message); // 번호와 메세지를 가지고 새로운 SMS 메세지 생성
    } else if (!msgSwitch && gpsSwitch) {
      message = "위치정보\nhttps://map.naver.com/v5/zoom/location/$longitude/$latitude";
      smsMessage = new SmsMessage(address, message); // 번호와 메세지를 가지고 새로운 SMS 메세지 생성
    } else {
      // smsMessage = new SmsMessage(address, message+("\n\n위치정보\nhttps://map.naver.com/v5/zoom/location/$longitude/$latitude").toString()); // 번호와 메세지를 가지고 새로운 SMS 메세지 생성
      // smsSender.sendSms(smsMessage);
      recipients.add(phoneNum);
      message += "\n\n위치정보\nhttps://map.naver.com/v5/zoom/location/$longitude/$latitude";
      await SmsMms.send(recipients: recipients, message: message);
    }



    if (msgState == SmsMessageState.Sent) {
      // SMS 발송 완료 시
      print("문자 발송 완료");
      _showAlertDialog('알림', '문자가 성공적으로 발송되었습니다.');
    } else if (msgState == SmsMessageState.Delivered) {
      // 수신자에게 전달 완료 시
      print("문자 수신자에게 성공적으로 수신 완료");
      _showAlertDialog('알림', '문자가 성공적으로 발송되었습니다.');
    } else if (msgState == SmsMessageState.Fail) {
      print('문자 전송 실패');
      _showAlertDialog('알림', '문자가 실패적으로 발송되었습니다.');
    } else if (msgState == SmsMessageState.Sending) {
      print('문자 발송 중 입니다.' );
      _showAlertDialog('알림', '문자가 성공적으로 발송되었습니다.');
    }

    // smsSender.sendSms(smsMessage);
  }




  // 위치 정보 가져오는 함수
  getLocation() async {
    LocationPermission permission;
    LocationPermission permissionCheckResult;

    // 위치 권한 확인
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        locationMessage = '위치 권한 거부';
      });
      return;
    }

    // 위치 권한 요청
    if (permission == LocationPermission.denied) {
      permissionCheckResult = await Geolocator.requestPermission();
      if (permissionCheckResult != LocationPermission.whileInUse
          && permissionCheckResult != LocationPermission.always) {
        setState(() {
          locationMessage = '위치 권한을 허용하지 않았습니다.';
        });
        return;
      }
    }

    // 로딩창 변수
    setState(() {
      isLoading = true;
    });

    //await Future.delayed(Duration(seconds: 2));

    // 위치 정보 가져오기
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best
    );

    setState(() {
      locationMessage = '위도 : ${position.latitude} \n 경도 : ${position.longitude}';
      latitude = position.latitude;
      longitude = position.latitude;
      locationResult = '위도 : ${position.latitude} \n 경도 : ${position.longitude}';
    });

    setState(() {
      isLoading = false;
    });
  }


  // 위치 자동 업데이트
  void _startLocationUpdates() {
    location.onLocationChanged.listen((LocationPackage.LocationData newLocation) {

      setState(() {
        locationResult = "위도 : ${newLocation.latitude} \n경도 : ${newLocation.longitude}";
        latitude = newLocation.latitude!;
        longitude = newLocation.longitude!;
        print("업데이트된 위치 : " + locationResult);
      });
    });
  }


  // 스캔 시작/정지 함수



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
        // bottomNavigationBar: BottomNavigationBar(
        //   onTap: (int index) {
        //     switch (index) {
        //       case 0:
        //         Navigator.pushNamed(context, '/');
        //         break;
        //       case 1:
        //         Navigator.pushNamed(context, '/Remote');
        //         break;
        //       default:
        //     }
        //   },
        //   items: const [
        //     BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Safer'),
        //     BottomNavigationBarItem(icon: Icon(Icons.settings_remote), label: 'Remote'),
        //   ],
        // ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 20, left: 30, right: 30),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      phoneNum = value;
                    });
                    print('입력된 전화번호 : ' + phoneNum);
                  }, decoration: InputDecoration(
                  labelText: '전화번호를 입력해 주세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10, bottom: 10, left:30, right: 30),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      Msg = value;
                      print("입력된 메세지 내용 : " + Msg);
                    });
                  },
                  decoration: InputDecoration(
                    labelText: '보내실 문자 내용을 작성',
                    border: OutlineInputBorder(
                      borderRadius:  BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
                    child: Text('문자 포함'),
                  ),
                  Container(
                    child: Switch(value: msgSwitch, onChanged: (value) {
                      setState(() {
                        msgSwitch = value;
                      });
                      print('문자 포함 여부 : ' + msgSwitch.toString());
                    },
                    ),
                  ),

                ],
              ), Row(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
                    child: Text('GPS 포함'),
                  ),
                  Container(
                    child: Switch(value: gpsSwitch, onChanged: (value) {
                      setState(() {
                        gpsSwitch = value;
                      });
                      print('GPS 포함 여부 : ' + gpsSwitch.toString());
                    },
                    ),
                  )
                ],
              ),
              ElevatedButton(onPressed: sendSMS, child: Text('문자 보내기')),
              if (isLoading)     // isLoading이 true일 때 로딩 창 표시
                CircularProgressIndicator()
              else               // isLoading이 false일 때 위치 정보 결과 표시
                Text(locationResult),
              ElevatedButton(
                onPressed: getLocation,
                child: Text('위치 정보 확인하기',),
              ),Container(
                  width: double.infinity,
                  height: 360,
                  color: Colors.amber,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: SpeedDial(
                      animatedIcon: AnimatedIcons.menu_close,
                      visible: true,
                      curve: Curves.bounceIn,
                      backgroundColor: Colors.indigo.shade900,
                      children: [
                        SpeedDialChild(
                          child: const Icon(Icons.settings_remote_outlined, color: Colors.white,),
                          label: '리모컨',
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          backgroundColor: Colors.indigo.shade900,
                          labelBackgroundColor: Colors.indigo.shade900,
                          onTap: () {},
                        ),
                      ],
                    ),
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
