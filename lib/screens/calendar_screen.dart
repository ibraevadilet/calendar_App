import 'package:calendar_app/provider/tasks_provider_sql.dart';
import 'package:calendar_app/screens/task_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

String dateForTitle = "";

class _MyHomePageState extends State<MyHomePage> {
  EventList<Event> _markedDateMap = new EventList<Event>(
    events: {},
  );

  List tasks = [];
  DateTime _currentDate2 = DateTime.now();

  @override
  void initState() {
    refreshTasks();
    super.initState();
  }

  Future refreshTasks() async {
    this.tasks = await TasksDatabase.instance.readAllTasks();
    for (int i = 0; i < tasks.length; i++) {
      _markedDateMap.add(
          new DateTime(tasks[i].year, tasks[i].month, tasks[i].day),
          new Event(
            date: new DateTime(tasks[i].year, tasks[i].month, tasks[i].day),
          ));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CalendarCarousel(
          markedDateMoreCustomTextStyle:
              TextStyle(color: Colors.white, fontSize: 8),
          todayBorderColor: Colors.red,
          onDayPressed: (DateTime date, List events) {
            this.setState(() => _currentDate2 = date);
            dateForTitle = DateFormat('dd.MM.yyyy').format(date);
            final int year = int.parse(DateFormat.y().format(date));
            final int month = int.parse(DateFormat.M().format(date));
            final int day = int.parse(DateFormat.d().format(date));

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TaskScreen(
                        date: dateForTitle,
                        year: year,
                        month: month,
                        day: day)));
          },
          daysHaveCircularBorder: false,
          markedDateMoreShowTotal: true,
          markedDateShowIcon: true,
          markedDatesMap: _markedDateMap,
          markedDateIconMaxShown: 0,
          locale: "ru",
          weekendTextStyle: TextStyle(
            color: Colors.red,
          ),
          thisMonthDayBorderColor: Colors.grey,
          weekFormat: false,
          firstDayOfWeek: 1,
          height: 420,
          selectedDateTime: _currentDate2,
          customGridViewPhysics: NeverScrollableScrollPhysics(),
          showHeader: true,
          todayTextStyle: TextStyle(
            color: Colors.blue,
          ),
          todayButtonColor: Colors.yellow,
          selectedDayTextStyle: TextStyle(
            color: Colors.yellow,
          ),
          prevDaysTextStyle: TextStyle(
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
