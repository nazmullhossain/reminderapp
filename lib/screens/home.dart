import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:parsed_readmore/parsed_readmore.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/app_color.dart';
import '../constants/app_string.dart';
import '../model/saving_date_model.dart';
import '../utils/local_storage.dart';
import 'edit_alarm.dart';
import 'ring.dart';

class AlarmHomeScreen extends StatefulWidget {
  const AlarmHomeScreen({super.key});

  @override
  State<AlarmHomeScreen> createState() => _AlarmHomeScreenState();
}

class _AlarmHomeScreenState extends State<AlarmHomeScreen> {
  late List<AlarmSettings> alarms;
  static StreamSubscription<AlarmSettings>? subscription;

  List<int> selectedItems = [];
  bool selectMode = false;

  List<SavingDateModel> savingDateList = [];

  @override
  void initState() {
    super.initState();
    if (Alarm.android) {
      checkAndroidNotificationPermission();
    }
    loadAlarms();
    getSavingDateList();
    subscription ??= Alarm.ringStream.stream.listen(
      (alarmSettings) => navigateToRingScreen(alarmSettings),
    );
  }

  void loadAlarms() {
    setState(() {
      alarms = Alarm.getAlarms();
      alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
    });
  }

  Future<void> getSavingDateList()async{
    final loginResponseFromLocal = await getData(LocalStorageKey.savingDateKey);
    if (loginResponseFromLocal != null) {
      savingDateList = savingDateModelFromJson(loginResponseFromLocal);
    }
    setState(() {});
  }

  Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlarmRingScreen(alarmSettings: alarmSettings),
      ),
    );
    loadAlarms();
  }

  Future<void> navigateToAlarmScreen(AlarmSettings? settings) async {
    final res = await showModalBottomSheet<bool?>(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (context) {
          return const FractionallySizedBox(
            heightFactor: 0.75,
            child: AlarmEditScreen(),
          );
        });

    if (res != null && res == true){
      loadAlarms();
      getSavingDateList();
    }
  }

  Future<void> checkAndroidNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      alarmPrint('Requesting notification permission...');
      final res = await Permission.notification.request();
      alarmPrint(
        'Notification permission ${res.isGranted ? '' : 'not '}granted.',
      );
    }
  }

  void deleteSelectedAlarm() {
    for (int id in selectedItems) {
      //delete saving time with id
      for(int i=0; i<savingDateList.length; i++){
        if(savingDateList[i].id==id){
          savingDateList.removeWhere((element) => element.id==id);
        }
      }
      removeData(id.toString());
      Alarm.stop(id);
      setData(LocalStorageKey.savingDateKey, savingDateModelToJson(savingDateList));
    }
    selectedItems = [];
    selectMode = false;
    loadAlarms();
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppString.appName),
        centerTitle: true,
        actions: [
          if (selectMode == true)
            IconButton(
                onPressed: deleteSelectedAlarm,
                icon: const Icon(Icons.delete_outline, color: Colors.red))
        ],
      ),
      body: _bodyUI(),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(10),
        child: FloatingActionButton(
          backgroundColor: AppColor.primaryColor,
          elevation: 0.0,
          onPressed: () => navigateToAlarmScreen(null),
          child: const Icon(Icons.add, color: Colors.white, size: 40),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _bodyUI() => alarms.isNotEmpty
      ? ListView.separated(
          padding:
              const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 64),
          itemCount: alarms.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              onTap: () {
                if (selectMode == true) {
                  selectDeselectAlarmItem(alarms[index].id);
                }
              },
              onLongPress: () {
                selectMode = true;
                selectedItems.add(alarms[index].id);
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 12),
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.all(Radius.circular(8))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    selectMode == true
                        ? Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: alarmItemLeadingIcon(alarms[index].id),
                        )
                        : const SizedBox.shrink(),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ParsedReadMore(
                            alarms[index].notificationBody.isNotEmpty
                                ? alarms[index].notificationBody
                                : 'Alarm',
                            trimLength: 100,
                            trimCollapsedText: 'more',
                            trimExpandedText: 'less',
                            moreStyle: const TextStyle(color: AppColor.primaryColor, fontSize: 16),
                            lessStyle: const TextStyle(color: AppColor.primaryColor, fontSize: 16),
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade800,
                                overflow: TextOverflow.ellipsis),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                getSavingDate(alarms[index].id),
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey),
                              ),
                              Text(
                                alarms[index].notificationTitle,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        )
      : Center(
          child: Text(
            "No alarms set yet",
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Colors.grey),
          ),
        );

  void selectDeselectAlarmItem(int id) {
    if (selectedItems.contains(id)) {
      selectedItems.remove(id);
    } else {
      selectedItems.add(id);
    }
    if (selectedItems.isEmpty) {
      selectMode = false;
    }
    setState(() {});
  }

  Widget alarmItemLeadingIcon(int alarmId) {
    if (selectedItems.contains(alarmId)) {
      return Icon(Icons.check_circle_outline_outlined,
          color: Theme.of(context).primaryColor);
    } else {
      return const Icon(Icons.circle_outlined, color: Colors.grey);
    }
  }

  String getSavingDate(int alarmId){
    String savingDate = 'N/A';
    for(int i=0; i<savingDateList.length; i++){
      if(savingDateList[i].id==alarmId){
        savingDate = savingDateList[i].savingDateTime??'N/A';
        break;
      }
    }
    return savingDate;
  }
}
