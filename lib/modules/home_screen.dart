import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:petcarereminder/components/components.dart';
import 'package:petcarereminder/components/constants.dart';
import 'package:petcarereminder/cubit/home_cubit.dart';
import 'package:petcarereminder/cubit/home_states.dart';

import '../Helpers/DBHelper.dart';
import 'new_task_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return BlocConsumer<HomeCubit,HomeStates>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 4,
              shadowColor: Colors.black.withValues(alpha: 0.3),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'assets/images/appbar_icon.json',
                    height: height/20
                  ),
                  SizedBox(width: width / 70),
                  Text(
                    "Flaffy",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).textScaler.scale(30),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  EasyDateTimeLine(
                      initialDate: DateTime.now(),
                      onDateChange: (selectedDate) {},
                      headerProps: const EasyHeaderProps(
                        monthPickerType: MonthPickerType.switcher,
                        dateFormatter: DateFormatter.fullDateDMY(),
                      ),
                      dayProps: const EasyDayProps(
                        dayStructure: DayStructure.dayStrDayNum,
                        activeDayStyle: DayStyle(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                      )),
                  divider(),
                  Row(
                    children: [
                      Text(
                        "Reminders",
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).textScaler.scale(20),
                            fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          navigateTo(context, NewTaskScreen());
                        },
                        child: Container(
                          width: width / 3,
                          height: height / 25,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  color: Colors.grey.withValues(alpha: 0.4))),
                          child: Center(
                            child: Text(
                              "New Reminder",
                              style: TextStyle(
                                  fontSize:
                                  MediaQuery.of(context).textScaler.scale(18),
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  divider(),
            BlocConsumer<HomeCubit, HomeStates>(
              builder: (context, state) {
                HomeCubit cubit = HomeCubit.get(context);
                return ConditionalBuilder(
                    condition: cubit.allTasks.isNotEmpty,
                    builder: (context) => Expanded(
                      child: ListView.separated(
                        itemBuilder: (context, index) {
                          var task = cubit.allTasks[index];

                          return Dismissible(
                            key: Key(task['id'].toString()), // Unique key for each task
                            direction: DismissDirection.endToStart, // Swipe from right to left
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) {
                              var removedTask = cubit.allTasks[index];
                              cubit.removeTask(removedTask['id']);
                              DBHelper.deleteTask(task['id']);
                            },
                            child: Container(
                              width: double.infinity,
                              height: height / 10,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: Colors.grey.withOpacity(0.4)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: tasksBackgroundColors[index % 4],
                                      radius: 25,
                                      child: Icon(
                                        tasksBackgroundIcons[task['title']],
                                        color: Colors.black,
                                        size: 17,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task['title'],
                                          style: TextStyle(
                                            fontSize: MediaQuery.of(context).textScaler.scale(18),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          task['description'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: MediaQuery.of(context).textScaler.scale(13),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              task['date'].toString().substring(0, 10),
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context).textScaler.scale(15),
                                              ),
                                            ),
                                            SizedBox(width: width / 50),
                                            const Icon(
                                              FontAwesomeIcons.solidCircle,
                                              size: 7,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(width: width / 50),
                                            Text(
                                              task['time'].toString().substring(10, 15),
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context).textScaler.scale(15),
                                              ),
                                            ),
                                            SizedBox(
                                              width: width/30,
                                            ),
                                            Icon(Icons.repeat,
                                              size: width/20,
                                            ),
                                            Text(task['repeatType'],
                                              style: TextStyle(
                                                  fontSize: MediaQuery.of(context).textScaler.scale(12)
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => SizedBox(height: height / 50),
                        itemCount: cubit.allTasks.length,
                      ),
                    ),
                    fallback: (context) => Column(
                      children: [
                        Lottie.asset("assets/images/empty_reminders.json"),
                        Text("You don't have reminders yet",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).textScaler.scale(22),
                          fontWeight: FontWeight.w500
                        ),
                        ),
                        Text("Easily create reminders for one or more pets in"
                            " one place and let us remind you at the times you choose",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).textScaler.scale(17),
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          height: height/50,
                        ),
                        MaterialButton(
                            onPressed: () {
                              navigateTo(context, NewTaskScreen());
                            },
                        color: Colors.green,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add,
                                color: Colors.white,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text("New Reminder",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: MediaQuery.of(context).textScaler.scale(15)
                              ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),);
              },
              listener: (context, state) {},
            ),
                ],
              ),
            ),
          );
        }, listener: (context, state) {

        },);
  }
}
