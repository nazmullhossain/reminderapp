import 'dart:math';
import 'package:alarm/alarm.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_string.dart';
import '../model/saving_date_model.dart';
import '../utils/app_toast.dart';
import '../utils/formater.dart';
import '../utils/local_storage.dart';

class AlarmEditScreen extends StatefulWidget {
  const AlarmEditScreen({super.key});

  @override
  State<AlarmEditScreen> createState() => _AlarmEditScreenState();
}

class _AlarmEditScreenState extends State<AlarmEditScreen> {
  final TextEditingController note = TextEditingController();
  final FocusNode noteFocusNode = FocusNode();
  DateTime? selectedDate;
  late TimeOfDay? selectedTime;
  late bool loopAudio;
  late bool loopVideo;
  late bool vibrate;
  late double? volume;
  late String assetAudio;
  late String title;
  late String body;
  final AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();
  List<SavingDateModel> savingDateList = [];
  late bool isAlarm;

  @override
  void initState() {
    super.initState();
    noteFocusNode.requestFocus();
    final DateTime dateTime = DateTime.now().add(const Duration(minutes: 1));
    selectedTime = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
    loopAudio = true;
    vibrate = true;
    volume = 0.8;
    assetAudio = 'assets/mp3/alarm_2.mp3';
    title = '';
    body = AppString.alarmBody;
    audioPlayer.open(Audio(assetAudio), autoStart: false);
    getSavingDateList();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> getSavingDateList() async {
    final loginResponseFromLocal = await getData(LocalStorageKey.savingDateKey);
    if (loginResponseFromLocal != null) {
      savingDateList = savingDateModelFromJson(loginResponseFromLocal);
    }
  }

  Future<void> pickTime() async {
    noteFocusNode.unfocus();
    await showTimePicker(
      initialTime: TimeOfDay.fromDateTime(selectedDate ?? DateTime.now()),
      context: context,
    ).then((value) {
      if (value != null) {
        setState(() => selectedTime = value);
      }
    });
  }

  Future<void> pickDate() async {
    noteFocusNode.unfocus();
    await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 1825)),
    ).then((value) => setState(() => selectedDate = value));
  }

  Future<AlarmSettings?> buildAlarmSettings() async {
    DateTime date = selectedDate ?? DateTime.now();
    final DateTime currentDate = DateTime.now();

    // Add selected time
    if (selectedTime != null) {
      setState(() {
        date = date.copyWith(
          hour: selectedTime!.hour,
          minute: selectedTime!.minute,
          second: 0,
          millisecond: 0,
          microsecond: 0,
        );
      });
    }

    // Check previous alarm
    final List<AlarmSettings> alarms = Alarm.getAlarms();
    for (int i = 0; i < alarms.length; i++) {
      if (alarms[i].dateTime.year == date.year &&
          alarms[i].dateTime.month == date.month &&
          alarms[i].dateTime.day == date.day &&
          alarms[i].dateTime.hour == date.hour &&
          alarms[i].dateTime.minute == date.minute) {
        showToast('You have already an alarm of this date');
        return null;
      }
    }

    // If selected date isBefore of the current-date then the alarm added for the next day
    if (date.isBefore(currentDate)) {
      date = date.add(const Duration(days: 1));
    }

    // Check Alarm or not
    if (selectedDate == null) {
      isAlarm = true;
    } else {
      isAlarm = false;
    }

    if (isAlarm) {
      title = DateFormat('hh:mm aa').format(date);
    } else {
      title = DateFormat('hh:mm aa - dd MMM, yyyy').format(date);
    }

    debugPrint('title:::::::: $title');
    debugPrint('isAlarm:::::::: $isAlarm');

    // Create unique id
    final int random = Random().nextInt(10000);
    final int id = DateTime.now().millisecondsSinceEpoch % 10000;
    final int uniqueId = id + random;

    // Set alarm data
    final alarmSettings = AlarmSettings(
      id: uniqueId,
      dateTime: date,
      loopAudio: loopAudio,
      vibrate: vibrate,
      volume: volume,
      assetAudioPath: assetAudio,
      notificationTitle: title,
      notificationBody: note.text,
    );

    savingDateList.add(SavingDateModel(
        id: uniqueId,
        savingDateTime: DateFormat('dd MMM, yyyy').format(currentDate),
        isAlarm: isAlarm));

    // Save original date-time
    await setData(uniqueId.toString(), date.toIso8601String());

    // Save alarm date-time
    await setData(
        LocalStorageKey.savingDateKey, savingDateModelToJson(savingDateList));
    return alarmSettings;
  }

  Future<void> saveAlarm() async {
    if (note.text.isEmpty) {
      showToast('Write a note');
      return;
    }
    final AlarmSettings? settings = await buildAlarmSettings();
    if (settings != null) {
      await Alarm.set(alarmSettings: settings).then((res) {
        if (res) {
          Navigator.pop(context, true);
        }
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
            focusNode: noteFocusNode,
            textCapitalization: TextCapitalization.sentences,
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
                    child: FittedBox(
                      child: Text(
                        selectedDate != null
                            ? DateFormat('dd MMM, yy').format(selectedDate!)
                            : 'Select Date',
                        style: Theme.of(context).textTheme.headlineSmall!,
                      ),
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
                      formatTimeOfDay(selectedTime!),
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
                'Ringtone',
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
                          audioPlayer.setVolume(volume ?? 0.8);
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
                    audioPlayer.setVolume(volume ?? 0.8);
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
                'Repeat audio',
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
                    setState(() => volume = value ? 0.8 : null),
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
                        volume! > 0.8
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
