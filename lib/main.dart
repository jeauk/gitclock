import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(AlarmClockApp());
}

class AlarmClockApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alarm Clock',
      theme: ThemeData(primaryColor: Colors.orange),
      home: AlarmClockScreen(),
    );
  }
}

class AlarmClockScreen extends StatefulWidget {
  @override
  _AlarmClockScreenState createState() => _AlarmClockScreenState();
}

class _AlarmClockScreenState extends State<AlarmClockScreen> {
  List<DateTime> _alarms = [];
  bool _isAlarmTriggered = false;
  DateTime? _selectedTime;

  Timer? _alarmTimer;

  @override
  void dispose() {
    _alarmTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '알람 시계',
          style: TextStyle(color: Colors.orange),
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showTimePicker(
            context: context,
            initialTime: _selectedTime != null ? TimeOfDay.fromDateTime(_selectedTime!) : TimeOfDay.now(),
          ).then((selectedTime) {
            if (selectedTime != null) {
              setState(() {
                _selectedTime = DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                  selectedTime.hour,
                  selectedTime.minute,
                );
                _alarms.add(_selectedTime!);
              });
              _setAlarmTimer();
            }
          });
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.orange,
      ),
      bottomNavigationBar: _alarms.isNotEmpty
          ? BottomAppBar(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _alarms.length,
          itemBuilder: (context, index) {
            final alarmTime = _alarms[index];
            return ListTile(
              title: Row(
                children: [
                  Text(
                    _getFormattedHour(alarmTime),
                    style: TextStyle(fontSize: 18, color: Colors.orange),
                  ),
                  Text(
                    ':',
                    style: TextStyle(fontSize: 18, color: Colors.orange),
                  ),
                  Text(
                    _getFormattedMinute(alarmTime),
                    style: TextStyle(fontSize: 18, color: Colors.orange),
                  ),
                  Text(
                    _getAmPm(alarmTime),
                    style: TextStyle(fontSize: 18, color: Colors.orange),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _alarms.removeAt(index);
                    if (_alarms.isEmpty) {
                      _selectedTime = null;
                      _alarmTimer?.cancel();
                    }
                  });
                },
              ),
            );
          },
        ),
      )
          : null,
    );
  }

  void _setAlarmTimer() {
    _alarms.forEach((alarmTime) {
      final now = DateTime.now();
      final difference = alarmTime.difference(now);
      if (difference.isNegative) {
        final nextDay = now.add(Duration(days: 1));
        final nextAlarmTime = DateTime(
          nextDay.year,
          nextDay.month,
          nextDay.day,
          alarmTime.hour,
          alarmTime.minute,
        );
        _startTimer(nextAlarmTime);
      } else {
        _startTimer(alarmTime);
      }
    });
  }

  void _startTimer(DateTime alarmTime) {
    _alarmTimer = Timer(alarmTime.difference(DateTime.now()), () {
      setState(() {
        _isAlarmTriggered = true;
      });
      _showAlarmDialog();
    });
  }

  void _showAlarmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '알-람',
            style: TextStyle(color: Colors.orange),
          ),
          content: Text(
            '일어나!',
            style: TextStyle(color: Colors.orange),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                '확인',
                style: TextStyle(color: Colors.orange),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _getFormattedHour(DateTime time) {
    final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    return hour.toString().padLeft(2, '0');
  }

  String _getFormattedMinute(DateTime time) {
    final minute = time.minute.toString().padLeft(2, '0');
    return minute;
  }

  String _getAmPm(DateTime time) {
    final period = time.hour < 12 ? '오전' : '오후';
    return period;
  }
}
