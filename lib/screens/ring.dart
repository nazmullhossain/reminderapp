import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../utils/date_time_converter.dart';
import '../utils/local_storage.dart';

class AlarmRingScreen extends StatefulWidget {
  final AlarmSettings alarmSettings;
  const AlarmRingScreen({super.key, required this.alarmSettings});

  @override
  State<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends State<AlarmRingScreen> {
  late DateTime? originalDateTime;

  @override
  void initState() {
    onInit();
    powerButtonEventListen();
    super.initState();
  }

  Future<void> onInit() async {
    final String? dateTimeString = await getData(widget.alarmSettings.id.toString());
    if (dateTimeString != null) {
      originalDateTime = parseStringToDateTime(dateTimeString);
    }
  }

  Future<void> powerButtonEventListen()async{
    const MethodChannel channel = MethodChannel('com.wintep.notepad_alarm.powerButton');
    channel.setMethodCallHandler((call) async {
      if (call.method == 'powerButtonPressed') {
        debugPrint('Power button pressed');
        snoozeAlarm();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff2B2B2B),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Text(
            DateFormat('hh:mm:aa').format(widget.alarmSettings.dateTime),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500,color: Colors.white),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("🔔",
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 40,color: Colors.white)),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Text(
                        widget.alarmSettings.notificationBody.isNotEmpty
                            ? widget.alarmSettings.notificationBody
                            : "Alarm",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 40,color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 32, right: 32, bottom: 48),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RawMaterialButton(
              onPressed: snoozeAlarm,
              child: Text(
                "SNOOZE",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Theme.of(context).secondaryHeaderColor),
              ),
            ),
            RawMaterialButton(
              onPressed: stopAlarm,
              child: Text(
                "STOP",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Theme.of(context).secondaryHeaderColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void snoozeAlarm(){
    final now = DateTime.now();
    bool previousAlarmFound = false;
    final List<AlarmSettings> alarms = Alarm.getAlarms();

    for(int i=0; i<alarms.length; i++){
      if(alarms[i].dateTime.year == now.year &&
          alarms[i].dateTime.month == now.month &&
          alarms[i].dateTime.day == now.day &&
          alarms[i].dateTime.hour == now.hour &&
          alarms[i].dateTime.minute == now.minute){
        previousAlarmFound = true;
      }
    }
    if(previousAlarmFound == true){
      stopAlarm();
    }else{
      Alarm.set(
        alarmSettings: widget.alarmSettings.copyWith(
          dateTime: DateTime(
            now.year,
            now.month,
            now.day,
            now.hour,
            now.minute+5,
            0,
            0,
          ),
        ),
      ).then((_) => Navigator.pop(context));
    }
  }

  Future<void> stopAlarm()async{
    late DateTime dateTime;
    if (originalDateTime != null) {
      dateTime = DateTime(
        originalDateTime!.year,
        originalDateTime!.month,
        originalDateTime!.day,
        originalDateTime!.hour,
        originalDateTime!.minute,
        0,
        0,
      ).add(Duration(
          days: widget.alarmSettings.notificationBody.isEmpty
              ? 1
              : 365));
    } else {
      dateTime = DateTime(
        widget.alarmSettings.dateTime.year,
        widget.alarmSettings.dateTime.month,
        widget.alarmSettings.dateTime.day,
        widget.alarmSettings.dateTime.hour,
        widget.alarmSettings.dateTime.minute,
        0,
        0,
      ).add(Duration(
          days: widget.alarmSettings.notificationBody.isEmpty
              ? 1
              : 365));
    }
    Alarm.set(
      alarmSettings: widget.alarmSettings.copyWith(
        dateTime: dateTime,
        notificationTitle: DateFormat('dd MMM - hh:mm aa').format(dateTime)
      ),
    ).then((_) async {
      await setData(widget.alarmSettings.id.toString(),
          formatDateTimeWithLocalTimeZone(dateTime))
          .then((value) => Navigator.pop(context));
    });
  }
}
