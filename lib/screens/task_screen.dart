import 'package:calendar_app/model/task_model.dart';
import 'package:calendar_app/provider/tasks_provider_sql.dart';
import 'package:calendar_app/screens/calendar_screen.dart';
import 'package:calendar_app/screens/notes_add_screen.dart';
import 'package:flutter/material.dart';

class TaskScreen extends StatefulWidget {
  final String date;
  final int year;
  final int month;
  final int day;
  TaskScreen(
      {Key? key,
      required this.date,
      required this.year,
      required this.month,
      required this.day})
      : super(key: key);

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late List<Task> tasks;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    refreshTasks();
  }

  Future refreshTasks() async {
    setState(() => isLoading = true);

    this.tasks = await TasksDatabase.instance.readAllTasks();
    tasks.removeWhere((element) => element.date != widget.date);

    setState(() => isLoading = false);
  }

  Future<bool> _onWillPop() async {
    await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
        (route) => false);
    return true;
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            leading: new IconButton(
                icon: new Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage()),
                    (route) => false)),
            title: Text(
              widget.date,
              style: TextStyle(
                fontSize: 24,
              ),
            ),
          ),
          body: Center(
            child: isLoading
                ? CircularProgressIndicator()
                : tasks.isEmpty
                    ? Text(
                        "На эту дату у вас нет задач",
                        style: TextStyle(color: Colors.black, fontSize: 24),
                      )
                    : ListView.builder(
                        itemCount: tasks.isEmpty ? 1 : tasks.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () async {
                              await Navigator.of(context)
                                  .push(MaterialPageRoute(
                                builder: (context) => TasksAdd(
                                  date: widget.date,
                                  year: widget.year,
                                  month: widget.month,
                                  day: widget.day,
                                  taskMode: TaskMode.Editing,
                                  index: tasks[index].id!,
                                ),
                              ));

                              refreshTasks();
                            },
                            child: Dismissible(
                              key: Key(tasks[index].id.toString()),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                color: Colors.red,
                                child: Icon(Icons.cancel),
                              ),
                              onDismissed: (dicection) async {
                                await TasksDatabase.instance
                                    .delete(tasks[index].id!);
                                tasks.removeAt(index);

                                setState(() {});
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 30,
                                        bottom: 30,
                                        left: 13,
                                        right: 22),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TaskTitle(
                                            text: tasks[index].title,
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          TaskText(
                                            text: tasks[index].description,
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Text(
                                              "Время на выполнение - ${tasks[index].createdTime}")
                                        ]),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.black,
            child: Icon(Icons.add),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => TasksAdd(
                          date: widget.date,
                          year: widget.year,
                          month: widget.month,
                          day: widget.day,
                          taskMode: TaskMode.Adding,
                          index: 100000000,
                        )),
              );

              refreshTasks();
            },
          ),
        ),
      );
}

class TaskTitle extends StatelessWidget {
  final String text;
  const TaskTitle({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
    );
  }
}

class TaskText extends StatelessWidget {
  final String text;
  const TaskText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: Colors.grey),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
