import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:petcarereminder/Helpers/DBHelper.dart';
import 'package:petcarereminder/cubit/home_states.dart';
import 'package:sqflite/sqflite.dart';


class HomeCubit extends Cubit<HomeStates> {
  HomeCubit() : super(HomeInitialState()) {
    setDatabase();
  }
  static HomeCubit get(context)=>BlocProvider.of(context);

  late Database database;
  void setDatabase() async {
    await Future.delayed(Duration.zero); // Allows UI to build first
    database = await DBHelper.database;
    emit(DatabaseInitializedState());
    getAllTasks();
  }

  void setAlarm(int taskId, DateTime scheduledTime, String title, String description) {
    AndroidAlarmManager.oneShotAt(
      scheduledTime,
      taskId,
      alarmCallback,
      exact: true,
      wakeup: true,
      params: {"taskId": taskId, "title": title, "description": description},
    );
  }

  ///////////////////////////////New Reminder Screen//////////////////////////////

  bool isSwitched = false;
  String selectedReminder = 'Shaving Time';
  String selectedNotificationOption = 'Remind with notification';
  String selectedReminderOption = 'Daily';
  DateTime selectedDate = DateTime.now();
  TimeOfDay? selectedTime;
  final List<String> reminders = [
    'Shaving Time',
    'Food Order',
    'Hangout',
    'Birthday',
    'Doctor Appointment',
  ];
  final List<String> notificationOptions = [
    'Remind with notification',
    'Turn off notification',
  ];
  final List<String> remindersOptions = [
    'Daily',
    'Weekly',
  ];
  void changeDropDownListValue({
    required String type,
    required String value,
  }) {
    if (type == 'reminder') {
      selectedReminder = value;
    } else if (type == 'notification') {
      selectedNotificationOption = value;
    } else if (type == 'reminderOption') {
      selectedReminderOption = value;
    }
    emit(ChangeDropDownListState());
  }
  void changeDateValue(value){
    selectedDate = value;
    emit(ChangeDateState());
  }
  void changeTimeValue(value){
    selectedTime = value;
    emit(ChangeTimeState());
  }
  void changeSwitchButtonValue(value){
    isSwitched = value;
    emit(ChangeSwitchButtonState());
  }


///////////////////////////////Home Screen//////////////////////////////
  List allTasks = [];
  void getAllTasks(){
    emit(GetAllTasksLoadingState());
    DBHelper.getTasks().then((onValue){
    allTasks = onValue;
    emit(GetAllTasksSuccessState());
    }).catchError((onError){

      emit(GetAllTasksErrorState());
    });
  }
  void removeTask(int taskId) {
    DBHelper.deleteTask(taskId);

    // Convert to a new mutable list before modifying
    allTasks = List<Map<String, dynamic>>.from(allTasks);

    allTasks.removeWhere((task) => task['id'] == taskId);

    emit(HomeTasksUpdatedState());
  }
}

@pragma('vm:entry-point')
void alarmCallback(int taskId, Map<String, dynamic> params) {
  FlutterRingtonePlayer().play(
    android: AndroidSounds.alarm,
    ios: IosSounds.glass,
    looping: false,
    volume: 0.5,
    asAlarm: true,
  );
}