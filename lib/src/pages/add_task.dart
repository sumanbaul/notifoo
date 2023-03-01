import 'dart:async';

import 'package:flutter/material.dart';
import 'package:notifoo/src/model/tasks.dart';
import 'package:notifoo/src/pages/task_page.dart';

//import 'package:realm/realm.dart';
var _taskType = ["Growth", "Daily", "Projects", "Shopping", "Timer"];

final TextEditingController _taskNameController = TextEditingController();
final TextEditingController _repeatitionController = TextEditingController();
final Map<dynamic, dynamic> _task = {};

String _taskTypeText = "";

class AddTask extends StatelessWidget {
  final Function(String?) onChanged;
  //final Function() onSubmit;
  //final String value;
  const AddTask({key, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    void submit() {
      _task['id'] = int.parse(DateTime.now().day.toString() +
          DateTime.now().hour.toString() +
          DateTime.now().minute.toString());
      _task['title'] = _taskNameController.text;
      _task['repeatitions'] = int.parse(_repeatitionController.text);
      _task['isCompleted'] = int.parse("0");
      _task['taskType'] = _taskTypeText;
      _task['color'] = "";
      _task['createdDate'] = DateTime.now().toString();
      _task['modifiedDate'] = "";

      Map<String, dynamic> taskMap = Map<String, dynamic>.from(_task);

      // This will work because tasks is a list of Tasks objects
      List<Tasks> tasks = [Tasks.fromMap(taskMap)];
      //tasks.map((t) => t.title);
      //Tasks taskModel = Tasks.fromMap(taskMap);
      Navigator.of(context).pop(tasks);
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Add new task'),
          centerTitle: true,
          actions: <Widget>[
            Container(
              padding: EdgeInsets.only(right: 10.0),
              child: IconButton(
                icon: Icon(Icons.settings_input_antenna),
                onPressed: () async {
                  //  await _loadFromApi();
                },
              ),
            ),
            Container(
              padding: EdgeInsets.only(right: 10.0),
              child: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  //await _deleteData();
                },
              ),
            ),
          ],
        ),
        body: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: TextField(
                    controller: _taskNameController,
                    obscureText: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Task Name',
                      hintText: 'Enter Required Task',
                    ),
                    onChanged: ((value) => {taskPageState?.taskName = value}),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: TextField(
                    obscureText: false,
                    controller: _repeatitionController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Repeatitions',
                      hintText: 'Enter Number of times you need to repeat',
                    ),
                    onChanged: ((value) =>
                        {taskPageState?.repeatitions = int.parse(value)}),
                  ),
                ),
              ),
              // Padding(

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: double.infinity,
                  height: 50.0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 59, 43, 80),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(color: Colors.black54, blurRadius: 5)
                      ],
                      border: Border.all(
                          width: 2, color: Color.fromARGB(255, 91, 61, 119)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButton<String>(
                        focusColor: Colors.white,
                        value: _taskType.first,
                        elevation: 5,
                        style: TextStyle(
                            color: Color.fromARGB(255, 220, 195, 252)),
                        icon: Icon(Icons.arrow_drop_down), //icon of the button
                        iconSize: 36, //size of the icon
                        iconEnabledColor: Colors.white,
                        items: _taskType
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Container(
                              width: 100.0,
                              child: Text(
                                value,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        }).toList(),
                        hint: Text(
                          "Choose type of task",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                        onChanged: ((value) {
                          taskPageState?.taskType = value!;
                          _taskTypeText = value!;
                        }),
                        underline: Container(
                          height: 2,
                          color: Colors.transparent,
                        ), //underline of the button
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                child: ElevatedButton(
                  onPressed: () => submit(),
                  //onSubmit(),
                  child: Text('Save Task'),
                  clipBehavior: Clip.antiAlias,
                ),
              )
            ],
          ),
        ));
  }
}
