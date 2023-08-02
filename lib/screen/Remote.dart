import 'package:example/public/menu_bottom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

void main() {
  runApp(Remote());
}

class Remote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RemoteControlScreen(),
    );
  }
}

class RemoteControlScreen extends StatefulWidget {
  @override
  _RemoteControlScreenState createState() => _RemoteControlScreenState();
}

class _RemoteControlScreenState extends State<RemoteControlScreen> with SingleTickerProviderStateMixin{
  int _fanSpeedLevel = 0;   // 팬 속도 1~3
  bool Power = false;     // 전원

  FlutterBlue flutterBlue = FlutterBlue.instance;   // 블루투스 인스턴스
  bool _isScanning = false;   // 블루투스 스캔 상태
  BluetoothDevice? _selectedDevice;    // 블루투스 기기 선택
  List<BluetoothDevice> _devicesList = [];    // 스캔된 블루투스 장치 리스트
  BluetoothCharacteristic? _characteristic;   // 블루투스의 기능?


  // 전원 on / off
  void _togglePower() {
    setState(() {
      Power = !Power;
      if(!Power){
        _fanSpeedLevel = 0;
      } else {
        _fanSpeedLevel = 1;
      }
    });
  }

  // 풍량 UP
  void _increaseFanSpeed() {
    if (_fanSpeedLevel < 3) {
      setState(() {
        _fanSpeedLevel++;
      });
    }
  }

  // 풍량 DOWN
  void _decreaseFanSpeed() {
    if (_fanSpeedLevel > 1) {
      setState(() {
        _fanSpeedLevel--;
      });
    }
  }

  // 블루투스 스캔 상태 함수
  void initBle() {
    flutterBlue.isScanning.listen((isScanning) {
      _isScanning = isScanning;
      setState(() {});
    });
  }

  // 블루투스 스캔 함수
  void _scanDevices() {
    if(!_isScanning) {
      _devicesList.clear(); // 기존에 스캔된 리스트 삭제
      flutterBlue.startScan(
          timeout: Duration(seconds: 4)); // 블루투스 스캔 시작(4초 동안 스캔)
      flutterBlue.scanResults.listen((results) {
        for (ScanResult result in results) {
          if (!_devicesList.contains(result.device)) { // 리스트에 중복되는 장치 추가 X
            setState(() {
              _devicesList.add(result.device);
            });
            break;
          }
        }
      });
    } else {
      flutterBlue.stopScan();
    }
  }

  // 선택한 블루투스 장치에 연결 함수
  void _connectToDevice() async {
    if(_selectedDevice != null) {
      await _selectedDevice!.connect();   // 저장된 블루투스 장치와 연결 시도
      List<BluetoothService> services = await _selectedDevice!.discoverServices();    // 연결된 장치에서 사용 가능한 불루투스 서비스들을 검색
      services.forEach((service) {
        service.characteristics.forEach((characteristic) {
          if (characteristic.uuid == BluetoothCharacteristic) {   // 블루투스 장치와 연결하여 통신하고 데이터를 주고받을 때, 원하는 기능을 수행하기 위해 특정 캐릭터리스틱을 찾기
                                      //BluetoothCharacteristic."00001800-0000-1000-8000-00805f9b34fb"
            _characteristic = characteristic;
          }
        });
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Remote Control'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top:50,right: 30),
                      child: IconButton (
                        onPressed: _togglePower,
                        icon: Icon(
                          Icons.power_settings_new,
                          color: Power? Colors.blue : Colors.black45,
                        ),
                        iconSize: 140,
                      ),
                    )
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '\n바람세기 조절',
                      style: TextStyle(fontSize: 23),
                    ),
                    Container(
                        margin: EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Power? Colors.blue : Colors.black45, width: 3),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Column(
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_drop_up),
                                onPressed: Power? _increaseFanSpeed : null,
                                iconSize: 50,
                              ),
                              Text(
                                '$_fanSpeedLevel',
                                style: TextStyle(fontSize: 40),
                              ),
                              IconButton(
                                icon: Icon(Icons.arrow_drop_down),
                                onPressed: Power? _decreaseFanSpeed : null,
                                iconSize: 50,
                              ),
                            ]
                        )
                    )
                  ],
                ),
              ],
            ),
            Container(
              child: Row(
                children: [
                  ElevatedButton(onPressed: _scanDevices, child: Text('블루투스 스캔')),
                  ElevatedButton(onPressed: _connectToDevice, child: Text('블루투스 연결')),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
