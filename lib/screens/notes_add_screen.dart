import 'package:calendar_app/model/task_model.dart';
import 'package:calendar_app/provider/tasks_provider_sql.dart';
import 'package:calendar_app/screens/task_screen.dart';
import 'package:flutter/material.dart';

enum TaskMode { Editing, Adding }

class TasksAdd extends StatefulWidget {
  final String date;
  final Task? task;
  final TaskMode taskMode;
  final int index;
  final int year;
  final int month;
  final int day;
  TasksAdd(
      {Key? key,
      required this.date,
      this.task,
      required this.taskMode,
      required this.index,
      required this.year,
      required this.month,
      required this.day})
      : super(key: key);

  @override
  _TasksAddState createState() => _TasksAddState();
}

class _TasksAddState extends State<TasksAdd> {
  TextEditingController titleController = TextEditingController();

  TextEditingController textConroller = TextEditingController();
  late Task task;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshTask();
  }

  Future refreshTask() async {
    setState(() => isLoading = true);
    if (widget.taskMode == TaskMode.Editing) {
      this.task = await TasksDatabase.instance.readTask(widget.index);
      titleController.text = task.title;
      textConroller.text = task.description;
      dropdownValue = task.createdTime;
    }
    setState(() => isLoading = false);
  }

  String dropdownValue = 'Выберите время выпролнения';
  List<String> values = [
    'Выберите время выпролнения',
    '30 мин',
    '1 час',
    '1 час 30 мин',
    '2 часа',
    '2 часа 30 мин'
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskMode == TaskMode.Adding
            ? "Добавление записей"
            : "Редактирование записей"),
      ),
      body: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            TextFormField(
              maxLines: 1,
              decoration: InputDecoration(
                hintText: "Название задания",
                contentPadding: new EdgeInsets.all(10),
                border: OutlineInputBorder(),
              ),
              controller: titleController,
            ),
            SizedBox(
              height: 30,
            ),
            TextFormField(
              maxLines: 10,
              controller: textConroller,
              decoration: InputDecoration(
                  hintText: "Описание задания",
                  contentPadding: new EdgeInsets.all(10),
                  border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 30,
            ),
            DropdownButton<String>(
              icon: const Icon(Icons.timer),
              isExpanded: false,
              value: dropdownValue,
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(color: Colors.deepPurple),
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                });
              },
              items: values.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Buttons(
                  text: "Сохранить",
                  color: Colors.blue,
                  onPressed: () async {
                    final title = titleController.text;
                    final text = textConroller.text;

                    if (widget.taskMode == TaskMode.Adding) {
                      final tasks = Task(
                          isImportant: true,
                          date: widget.date,
                          title: title,
                          description: text,
                          createdTime: dropdownValue,
                          year: widget.year,
                          month: widget.month,
                          day: widget.day);

                      await TasksDatabase.instance.create(tasks);
                    } else {
                      final tasks = task.copy(
                        title: title,
                        description: text,
                        createdTime: dropdownValue,
                      );

                      await TasksDatabase.instance.update(tasks);
                    }
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TaskScreen(
                                date: widget.date,
                                year: widget.year,
                                month: widget.month,
                                day: widget.day)),
                        (route) => false);
                  },
                ),
                widget.taskMode == TaskMode.Editing
                    ? Buttons(
                        text: "Удалить",
                        color: Colors.red,
                        onPressed: () async {
                          await TasksDatabase.instance.delete(widget.index);
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TaskScreen(
                                        date: widget.date,
                                        year: widget.year,
                                        month: widget.month,
                                        day: widget.day,
                                      )),
                              (route) => false);
                        },
                      )
                    : Container()
              ],
            )
          ],
        ),
      ),
    );
  }
}

class Buttons extends StatelessWidget {
  final String text;
  final color;
  final Function() onPressed;
  const Buttons(
      {Key? key,
      required this.text,
      required this.color,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(color: Colors.white),
      ),
      color: color,
    );
  }
}
