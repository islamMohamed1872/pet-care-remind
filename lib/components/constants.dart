import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Map<int, String> monthMap = {
  1: "January",
  2: "February",
  3: "March",
  4: "April",
  5: "May",
  6: "June",
  7: "July",
  8: "August",
  9: "September",
  10: "October",
  11: "November",
  12: "December",
};
List tasksBackgroundColors = [
  const Color.fromRGBO(250,245,236, 1),
  const Color.fromRGBO(234,236,252, 1),
  const Color.fromRGBO(243,243,245, 1),
  const Color.fromRGBO(252,237,238, 1),

];
Map tasksBackgroundIcons = {
  "Shaving Time": Icons.cut,
  "Food Order":FontAwesomeIcons.shop,
  "Hangout":FontAwesomeIcons.clock,
  "Birthday":FontAwesomeIcons.cakeCandles,
  "Doctor Appointment":FontAwesomeIcons.stethoscope,
};