import 'dart:math';
import 'package:alarm/alarm.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_string.dart';
import '../model/saving_date_model.dart';
import '../utils/date_time_converter.dart';
import '../utils/local_storage.dart';

class AlarmEditScreen extends StatefulWidget {
  const AlarmEditScreen({super.key});

  @override
  State<AlarmEditScreen> createState() => _AlarmEditScreenState();
}

class _AlarmEditScreenState extends State<AlarmEditScreen> {
  final TextEditingController note = TextEditingController();
  late DateTime? selectedDate;
  late TimeOfDay? selectedTime;
  late bool loopAudio;
  late bool vibrate;
  late double? volume;
  late String assetAudio;
  late String title;
  late String body;
  final AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();
  List<SavingDateModel> savingDateList = [];

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now().add(const Duration(minutes: 1));
    selectedTime =
        TimeOfDay(hour: selectedDate!.hour, minute: selectedDate!.minute);
    loopAudio = true;
    vibrate = true;
    volume = 0.7;
    assetAudio = 'assets/mp3/alarm_2.mp3';
    title = DateFormat('dd MMM - hh:mm aa').format(selectedDate!);
    body = AppString.alarmBody;
    getSavingDateList();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> getSavingDateList()async{
    final loginResponseFromLocal = await getData(LocalStorageKey.savingDateKey);
    if (loginResponseFromLocal != null) {
      savingDateList = savingDateModelFromJson(loginResponseFromLocal);
    }
  }

  Future<void> pickTime() async {
    await showTimePicker(
      initialTime: TimeOfDay.fromDateTime(selectedDate ?? DateTime.now()),
      context: context,
    ).then((value) {
      if (value != null) {
        selectedTime = value;
      }
    });

    if (selectedTime != null) {
      setState(() {
        final DateTime date = selectedDate ?? DateTime.now();
        selectedDate = date.copyWith(
          hour: selectedTime!.hour,
          minute: selectedTime!.minute,
          second: 0,
          millisecond: 0,
          microsecond: 0,
        );
      });
    }
  }

  Future<void> pickDate() async {
    await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 1825)),
    ).then((value) => selectedDate = value ?? DateTime.now());

    if (selectedTime != null) {
      setState(() {
        final DateTime date = selectedDate ?? DateTime.now();
        selectedDate = date.copyWith(
          hour: selectedTime!.hour,
          minute: selectedTime!.minute,
          second: 0,
          millisecond: 0,
          microsecond: 0,
        );
      });
    }
  }

  Future<AlarmSettings?> buildAlarmSettings() async {

    final List<AlarmSettings> alarms = Alarm.getAlarms();

    for(int i=0; i<alarms.length; i++){
      if(alarms[i].dateTime.year == selectedDate!.year &&
          alarms[i].dateTime.month == selectedDate!.month &&
          alarms[i].dateTime.day == selectedDate!.day &&
          alarms[i].dateTime.hour == selectedDate!.hour &&
          alarms[i].dateTime.minute == selectedDate!.minute){
        showToast('You have already an Event with this date');
        return null;
      }
    }

    final int random = Random().nextInt(10000);
    final int id = DateTime.now().millisecondsSinceEpoch % 10000;
    final int uniqueId = id + random;
    final title = DateFormat('dd MMM - hh:mm aa').format(selectedDate!);

    final alarmSettings = AlarmSettings(
      id: uniqueId,
      dateTime: selectedDate!,
      loopAudio: loopAudio,
      vibrate: vibrate,
      volume: volume,
      assetAudioPath: assetAudio,
      notificationTitle: title,
      notificationBody: note.text,
    );
    savingDateList.add(SavingDateModel(
      id: uniqueId,
      savingDateTime: DateFormat('dd MMM - hh:mm aa').format(DateTime.now())
    ));

    await setData(uniqueId.toString(), formatDateTimeWithLocalTimeZone(selectedDate!));
    await setData(LocalStorageKey.savingDateKey, savingDateModelToJson(savingDateList));
    return alarmSettings;
  }

  Future<void> saveAlarm() async {
    final AlarmSettings? settings = await buildAlarmSettings();
    if(settings!=null){
      Alarm.set(alarmSettings: settings).then((res) {
        if (res) Navigator.pop(context, true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ///Save cancel button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  "Cancel",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: saveAlarm,
                child: Text(
                  "Save",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),

          TextField(
            controller: note,
            textCapitalization: TextCapitalization.words,
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(
                hintText: 'Write a note',
                hintStyle: TextStyle(
                    color: Colors.grey.shade400, fontWeight: FontWeight.w400)),
          ),

          Row(
            children: [
              Expanded(
                child: RawMaterialButton(
                  onPressed: pickDate,
                  fillColor: Theme.of(context).secondaryHeaderColor,
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    child: Text(
                      DateFormat('dd MMM, yy').format(selectedDate!),
                      style: Theme.of(context).textTheme.headlineSmall!,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RawMaterialButton(
                  onPressed: pickTime,
                  fillColor: Theme.of(context).secondaryHeaderColor,
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    child: Text(
                      TimeOfDay.fromDateTime(selectedDate!).format(context),
                      style: Theme.of(context).textTheme.headlineSmall!,
                    ),
                  ),
                ),
              ),
            ],
          ),

          ///Sound
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sound',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              StreamBuilder(
                stream: audioPlayer.isPlaying,
                builder: (context, snapshot) {
                  final isPlaying = snapshot.data ?? false;
                  return IconButton(
                      onPressed: () {
                        if (isPlaying) {
                          audioPlayer.stop();
                        } else {
                          audioPlayer.play();
                          audioPlayer.setVolume(volume ?? 0.7);
                        }
                      },
                      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow));
                },
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton(
                  value: assetAudio,
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'assets/mp3/alarm_2.mp3',
                      child: Text('Alarm 1'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'assets/mp3/alarm_3.mp3',
                      child: Text('Alarm 2'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'assets/mp3/alarm_4.mp3',
                      child: Text('Alarm 3'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'assets/mp3/alarm_1.mp3',
                      child: Text('Islamic'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'assets/mp3/blink.mp3',
                      child: Text('Blink'),
                    ),
                  ],
                  onChanged: (value) {
                    assetAudio = value!;
                    audioPlayer.open(Audio(assetAudio), autoStart: true);
                    audioPlayer.setVolume(volume ?? 0.7);
                    setState(() {});
                  },
                ),
              ),
            ],
          ),

          ///Repeat
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Repeat',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: loopAudio,
                onChanged: (value) => setState(() => loopAudio = value),
              ),
            ],
          ),

          ///Vibrate
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vibrate',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: vibrate,
                onChanged: (value) => setState(() => vibrate = value),
              ),
            ],
          ),

          ///Volume
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Volume',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: volume != null,
                onChanged: (value) =>
                    setState(() => volume = value ? 0.7 : null),
              ),
            ],
          ),
          SizedBox(
            height: 30,
            child: volume != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        volume! > 0.7
                            ? Icons.volume_up_rounded
                            : volume! > 0.1
                                ? Icons.volume_down_rounded
                                : Icons.volume_mute_rounded,
                      ),
                      Expanded(
                        child: Slider(
                          value: volume!,
                          onChanged: (value) {
                            setState(() => volume = value);
                          },
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),
          ),
          const SizedBox(),
        ],
      ),
    );
  }
}
