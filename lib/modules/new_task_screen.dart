

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:petcarereminder/Helpers/DBHelper.dart';
import 'package:petcarereminder/components/components.dart';
import 'package:petcarereminder/cubit/home_cubit.dart';
import 'package:petcarereminder/cubit/home_states.dart';
import 'package:petcarereminder/modules/home_screen.dart';

import '../Helpers/notification_helper.dart';
import '../components/constants.dart';
import 'animated_bubbles.dart';

class NewTaskScreen extends StatelessWidget {
  NewTaskScreen({super.key});
  TextEditingController descriptionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        title: Text('Add Reminder',
          style: TextStyle(
            fontSize: MediaQuery.of(context).textScaler.scale(25),
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [

          IconButton(
            onPressed: () async {
              // Ensure selectedTime is not null
              if (HomeCubit.get(context).selectedTime == null) {
                return;
              }

              DateTime scheduledTime = DateTime(
                HomeCubit.get(context).selectedDate.year,
                HomeCubit.get(context).selectedDate.month,
                HomeCubit.get(context).selectedDate.day,
                HomeCubit.get(context).selectedTime!.hour,
                HomeCubit.get(context).selectedTime!.minute,
              );

              try {
                int taskId = await DBHelper.insertTask({
                  "title": HomeCubit.get(context).selectedReminder,
                  "description": descriptionController.text,
                  "date": HomeCubit.get(context).selectedDate.toString(),
                  "time": HomeCubit.get(context).selectedTime.toString(),
                  "notification": HomeCubit.get(context).selectedNotificationOption,
                  "repeat": HomeCubit.get(context).isSwitched ? 1 : 0,
                  "repeatType": HomeCubit.get(context).selectedReminderOption,
                  "isCompleted": 0,
                });
                HomeCubit.get(context).getAllTasks();
                NotificationService().scheduleDailyNotification(scheduledTime,HomeCubit.get(context).selectedReminder,descriptionController.text);

                // Set Alarm
                HomeCubit.get(context).setAlarm(taskId, scheduledTime,HomeCubit.get(context).selectedReminder,descriptionController.text,);

                // Start multiple bubble animations
                for (int i = 0; i < 5; i++) {
                  showBubblesAnimation(context);
                }

                Future.delayed(const Duration(milliseconds: 800), () {
                  navigateWithAnimation(context, HomeScreen());
                });

              } catch (error) {
                print("Error adding task: $error");
              }
            },
            color: Colors.white,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
            ),
            icon: const Icon(Icons.done),
          )
        ],

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<HomeCubit,HomeStates>(
              builder: (context, state) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(5.0),
                  color: Colors.white, // Background color
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    value: HomeCubit.get(context).selectedReminder,
                    hint: const Text('Select a reminder'),
                    dropdownColor: Colors.white,
                    onChanged: (String? newValue) {
                      HomeCubit.get(context).changeDropDownListValue(
                        type: 'reminder',
                        value: newValue!,
                      );
                    },
                    items: HomeCubit.get(context).reminders.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: tasksBackgroundColors[0],
                              radius: 15,
                              child: Icon(
                                tasksBackgroundIcons[value],
                                color: Colors.black,
                                size: 15,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(value),
                          ],
                        ),
                      );
                    }).toList(),
                    isExpanded: true,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: height/30,
            ),
            Text("Description",
              style: TextStyle(
                fontSize: MediaQuery.of(context).textScaler.scale(20),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              height: height/60,
            ),
            defaultField(
                prefixIcon: Icons.description,
                hint: "Note Description",
                controller: descriptionController,
                validator: (value) {
                  if(value.isEmpty){
                    return "Please enter the description";
                  }
                  return null;
                },
                obscureText: false),
            divider(),

            Text("Reminder Time",
              style: TextStyle(
                fontSize: MediaQuery.of(context).textScaler.scale(20),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              height: height/60,
            ),
            BlocBuilder<HomeCubit,HomeStates>(
                builder: (context, state) {
                  return InkWell(
                    onTap: () async{
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: HomeCubit.get(context).selectedDate ,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              primaryColor: Colors.green,
                              colorScheme: const ColorScheme.light(
                                primary: Colors.green,
                                onPrimary: Colors.white,
                                onSurface: Colors.black,
                              ),
                              textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.green, // Button text color
                                ),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );

                      if (pickedDate != null && pickedDate != HomeCubit.get(context).selectedDate) {
                        HomeCubit.get(context).changeDateValue(pickedDate);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: height / 15,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border:
                          Border.all(color: Colors.grey.withValues(alpha: 0.4))),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today,size: height/40,),
                            const SizedBox(
                              width: 5,
                            ),
                            Text("Date",
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).textScaler.scale(18),
                              ),
                            ),
                            const Spacer(),
                            Text(HomeCubit.get(context).selectedDate.toString().substring(0,10),
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).textScaler.scale(18),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  );
                },
            ),
            SizedBox(
              height: height/50,
            ),
            BlocBuilder<HomeCubit,HomeStates>(
              builder: (context, state) => InkWell(
                onTap: () async{
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: HomeCubit.get(context).selectedTime ?? TimeOfDay.now(),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          primaryColor: Colors.green,
                          colorScheme: const ColorScheme.light(
                            primary: Colors.green,
                            onPrimary: Colors.white,
                            onSurface: Colors.black,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.green,
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (pickedTime != null && pickedTime != HomeCubit.get(context).selectedTime) {
                    HomeCubit.get(context).changeTimeValue(pickedTime);
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: height / 15,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border:
                      Border.all(color: Colors.grey.withValues(alpha: 0.4))),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Icon(FontAwesomeIcons.clock,size: height/40,),
                        const SizedBox(
                          width: 5,
                        ),
                        Text("Time",
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).textScaler.scale(18),
                          ),
                        ),
                        const Spacer(),
                        Text( HomeCubit.get(context).selectedTime!=null?
                        HomeCubit.get(context).selectedTime.toString().substring(10,15):"",
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).textScaler.scale(18),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: height/50,
            ),
            BlocBuilder<HomeCubit,HomeStates>(
              builder: (context, state) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(5.0),
                  color: Colors.white, // Background color
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    value:  HomeCubit.get(context).selectedNotificationOption,
                    hint: const Text('Select a reminder'),
                    dropdownColor: Colors.white,
                    onChanged: (String? newValue) {
                      HomeCubit.get(context).changeDropDownListValue(type: "notification", value: newValue!);
                    },
                    items:  HomeCubit.get(context).notificationOptions.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            Icon(value=="Remind with notification"?Icons.notifications_none:Icons.notifications_off_outlined),
                            const SizedBox(width: 8),
                            Text(value),
                          ],
                        ),
                      );
                    }).toList(),
                    isExpanded: true,
                  ),
                ),
              ),
            ),

            divider(),
            Text("Repeat",
              style: TextStyle(
                fontSize: MediaQuery.of(context).textScaler.scale(20),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              height: height/50,
            ),
            BlocBuilder<HomeCubit,HomeStates>(
              builder: (context, state) =>  Container(
                width: double.infinity,
                height: height / 15,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border:
                    Border.all(color: Colors.grey.withValues(alpha: 0.4))),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Icon(FontAwesomeIcons.repeat,size: height/40,),
                      const SizedBox(
                        width: 10,
                      ),
                      Text("Auto Repeat",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).textScaler.scale(18),
                        ),
                      ),
                      const Spacer(),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: HomeCubit.get(context).isSwitched,
                          activeColor: Colors.green,
                          onChanged: (value) {
                            HomeCubit.get(context).changeSwitchButtonValue(value);

                          },
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),

            SizedBox(
              height: height/50,
            ),
            BlocBuilder<HomeCubit,HomeStates>(
              builder: (context, state) =>   Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(5.0),
                  color: Colors.white, // Background color
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    value: HomeCubit.get(context).selectedReminderOption,
                    hint: const Text('Select a reminder'),
                    dropdownColor: Colors.white,
                    onChanged: (String? newValue) {
                      HomeCubit.get(context).changeDropDownListValue(type: "reminderOption", value: newValue!);
                    },
                    items:  HomeCubit.get(context).remindersOptions.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            Icon(value=="Daily"?FontAwesomeIcons.clock:FontAwesomeIcons.clockRotateLeft),
                            const SizedBox(width: 8),
                            Text(value),
                          ],
                        ),
                      );
                    }).toList(),
                    isExpanded: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

void navigateWithAnimation(BuildContext context, Widget page) {
  Navigator.of(context).pushReplacement(PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 600), // Animation duration
    pageBuilder: (context, animation, secondaryAnimation) {
      return FadeTransition(
        opacity: animation,
        child: page,
      );
    },
  ));
}