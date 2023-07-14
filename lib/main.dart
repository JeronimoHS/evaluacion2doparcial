import 'dart:async';
import 'dart:ffi';
import 'package:battery/battery.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wear/wear.dart';

void main() {
  runApp(const ClockApp());
}

class ClockApp extends StatelessWidget {
  const ClockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reloj',
      theme: ThemeData(
        fontFamily: 'AldoTheApache',
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.compact,
      ),
      home: const Scaffold(
        body: SafeArea(
          child: WatchScreen(),
        ),
      ),
    );
  }
}

class WatchScreen extends StatelessWidget {
  const WatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (context, shape, child) {
        return AmbientMode(
          builder: (context, mode, child) {
            return SysOs(mode);
          },
        );
      },
    );
  }
}


class SysOs extends StatefulWidget {

  final WearMode mode;

  const SysOs(this.mode, {super.key});

  @override
  _SysOsState createState() => _SysOsState();
}

class _SysOsState extends State<SysOs> {
  final battery = Battery();
  int batteryLevel= 100; 
  late Timer timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _updateTime();
    listenBatteryLevel();
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateTime.now().toUtc().subtract(const Duration(hours: 6)); 
    });

    Timer(
      const Duration(seconds: 1) - Duration(milliseconds: _currentTime.millisecond),
      _updateTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('hh:mm:ss a');
    final dateString = DateFormat('MMM dd, yyyy').format(_currentTime);
    final timeString = timeFormat.format(_currentTime);

    return Container(
      color: widget.mode == WearMode.active ? Colors.grey[800] : Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              timeString,
              style: TextStyle(
                color: widget.mode == WearMode.active ? Colors.white : Colors.blue[300],
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
             

            Text(
              dateString,
              style: TextStyle(
                color: widget.mode == WearMode.active ? Colors.white : Colors.blue[300],
                fontSize: 20,
              ),
            ),
            Text('Batt lvl: $batteryLevel%',style: TextStyle(
                color: widget.mode == WearMode.active ? Colors.white : Colors.blue[300],
                fontSize: 16,
              ),
              ),
          ],
        ),
      ),
    );
  }
  
  void listenBatteryLevel() {
    updateBateryLevel();
    timer = Timer.periodic(
      const Duration(seconds: 2),
      (_) async => updateBateryLevel(),
    );
  }

  Future updateBateryLevel() async{
    final batteryLevel = await battery.batteryLevel;

    setState(() => this.batteryLevel= batteryLevel);
  }

  @override
  void dispose(){
    timer.cancel();
    super.dispose();
  }
}
