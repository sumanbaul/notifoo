import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notifoo/src/components/monthly_summary_heatmap.dart';
import 'package:notifoo/src/helper/datetime/date_time.dart';
import 'package:notifoo/src/helper/habit_database.dart';
import 'package:notifoo/src/pages/task_page.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../components/floating_action_btn.dart';
import '../components/habit_navigator_material_button.dart';
import '../components/habit_tile.dart';
import '../components/monthly_summary_simpleheatmap.dart';
import '../components/my_alert_box.dart';

class HabitTracker extends StatefulWidget {
  const HabitTracker({Key? key}) : super(key: key);

  @override
  State<HabitTracker> createState() => _HabitTrackerState();
}

class _HabitTrackerState extends State<HabitTracker> {
  HabitDatabase db = HabitDatabase();
  Icon? chosenIcon;
  final _myBox = Hive.box("Habit_Database");
  DateTime _selectedDate = DateTime.now();
  ConfettiController confettiController =
      ConfettiController(duration: const Duration(seconds: 1));
  @override
  void initState() {
    // if there is no current habit list, then this is the first time opening the app
    //then create default data
    if (_myBox.get("CURRENT_HABIT_LIST") == null) {
      // _selectedDate = DateTime.now();
      db.createDefaultData();
      // _selectedDate = DateTime.now();
    }

    // there already exists data, this is not the first time
    else {
      db.loadData();
      //_selectedDate = _selectedDate = DateTime.now();
    }

    db.updateDatabase(_selectedDate);

    super.initState();
  }

  //check box was tapped
  void checkBoxTapped(bool? value, int index) {
    setState(() {
      db.todaysHabitList[index][1] = value!;
    });

    db.updateDatabase(_selectedDate);
  }

  //create a new habit
  final _newHabitController = TextEditingController();
  void createNewHabit() {
    //show alert dialog for the user to add a habit
    showDialog(
        context: context,
        builder: (context) {
          return MyAlertBox(
            habitTextController: _newHabitController,
            onSave: saveNewHabit,
            onCancel: cancelDialog,
            hintText: "Enter a new habit",
            onSelectIcon: pickIcon,
            selectedIcon: chosenIcon ?? Icon(Icons.abc),
          );
        });
  }

  pickIcon() async {
    IconData? icon = await FlutterIconPicker.showIconPicker(
      context,
      iconPackModes: [IconPack.lineAwesomeIcons],
      showTooltips: true,
      searchClearIcon: Icon(Icons.clear_outlined),
      //adaptiveDialog: true,
      iconColor: Colors.deepOrangeAccent[300],
    );

    setState(() {
      chosenIcon = Icon(icon);
    });

    debugPrint('Picked Icon:  $icon');
  }

  //save new habit
  void saveNewHabit() {
    //add new habit to todays list
    setState(() {
      db.todaysHabitList.add([_newHabitController.text, false]);
    });

    //clear text field
    _newHabitController.clear();

    //pop dialog box(use the below code to pop without popping root page)
    Navigator.of(context, rootNavigator: true).pop();
    db.updateDatabase(_selectedDate);
  }

  //load data when clicked on list navigation arrow
  void Function()? navigateToData(bool? increment) {
    if (_selectedDate.toString() != "" && increment!) {
      loadPreviousData(_selectedDate.add(Duration(days: 1)));
    } else {
      loadPreviousData(_selectedDate.subtract(Duration(days: 1)));
    }

    return null;
  }

  //load previous/current data when clicked on date from Heatmap
  void loadPreviousData(DateTime dateTime) {
    db.loadPreviousData(dateTime);
    var _newHabitList = db.todaysHabitList;
    setState(() {
      _selectedDate = dateTime;
      if (_newHabitList.length > 0) {
        db.todaysHabitList = _newHabitList;
        // db.updateDatabase(dateTime);
      } else {
        db.todaysHabitList = [];
      }
    });

    // for the time snackbar is not needed, but keeping the code to reuse else where
    // ScaffoldMessenger.of(context)
    //     .showSnackBar(SnackBar(content: Text(dateTime.toString())));
  }

  //settings clicked
  void openHabitSettings(int index) {
    showDialog(
        context: context,
        builder: (context) {
          return MyAlertBox(
            habitTextController: _newHabitController,
            onSave: () => saveExistingHabit(index),
            onCancel: cancelDialog,
            hintText: db.todaysHabitList[index][0],
            onSelectIcon: pickIcon,
            selectedIcon: chosenIcon!,
          );
        });
  }

  habitsTapped(int index, bool? habitCompleted) {
    // todo calculations later on
    checkBoxTapped(habitCompleted, index);
    if (habitCompleted ?? false) {
      confettiController.play();
    }
  }

  void saveExistingHabit(int index) {
    setState(() {
      db.todaysHabitList[index][0] = _newHabitController.text;
    });

    Navigator.of(context, rootNavigator: true).pop();
    db.updateDatabase(_selectedDate);
  }

  //cancel new habit
  void cancelDialog() {
    //clear text field
    _newHabitController.clear();
    //pop dialog box(use the below code to pop without popping root page)
    Navigator.of(context, rootNavigator: true).pop();
  }

  //on delete
  void deleteHabit(int? index) {
    //Implement Alert Dialog for asking before delete

    setState(() {
      db.todaysHabitList.removeAt(index!);
    });
    db.updateDatabase(_selectedDate);
  }

  void runConfetti() {
    final ConfettiController confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
  }

  // List<Widget> getHabitNavigatorButtons() {
  //   List<Widget> _widgetList = <Widget>[];

  //   if (_selectedDate == DateTime.now()) {
  //     _widgetList.add(HabitNavigatorMaterialButton(
  //       materialButtonOnPressed: (() {
  //         if (_selectedDate == DateTime.now()) {
  //           loadPreviousData(_selectedDate.subtract(Duration(days: 1)));
  //         } else {
  //           loadPreviousData(_selectedDate.subtract(Duration(days: 1)));
  //         }
  //       }),
  //       materialButtonIcon: Icon(Icons.arrow_circle_left_rounded),
  //       materialButtonText: "",
  //     ));

  //     _widgetList.add(HabitNavigatorMaterialButton(
  //       materialButtonOnPressed: (() {
  //         if (_selectedDate == DateTime.now()) {
  //           loadPreviousData(_selectedDate.subtract(Duration(days: 1)));
  //         } else {
  //           loadPreviousData(_selectedDate.subtract(Duration(days: 1)));
  //         }
  //       }),
  //       materialButtonIcon: Icon(Icons.arrow_circle_left_rounded),
  //       materialButtonText: "",
  //     ));
  //   } else {
  //     _widgetList.add(HabitNavigatorMaterialButton(
  //       materialButtonOnPressed: (() {
  //         loadPreviousData(DateTime.now());
  //       }),
  //       materialButtonIcon: Icon(Icons.arrow_circle_left_rounded),
  //       materialButtonText: "Today",
  //     ));

  //     _widgetList.add(HabitNavigatorMaterialButton(
  //       materialButtonOnPressed: (() {
  //         if (_selectedDate == DateTime.now()) {
  //           loadPreviousData(_selectedDate.subtract(Duration(days: 1)));
  //         } else {
  //           loadPreviousData(_selectedDate.subtract(Duration(days: 1)));
  //         }
  //       }),
  //       materialButtonIcon: Icon(Icons.arrow_circle_left_rounded),
  //       materialButtonText: "",
  //     ));

  //     _widgetList.add(HabitNavigatorMaterialButton(
  //       materialButtonOnPressed: (() {
  //         if (_selectedDate == DateTime.now()) {
  //           loadPreviousData(_selectedDate.subtract(Duration(days: 1)));
  //         } else {
  //           loadPreviousData(_selectedDate.subtract(Duration(days: 1)));
  //         }
  //       }),
  //       materialButtonIcon: Icon(Icons.arrow_circle_left_rounded),
  //       materialButtonText: "",
  //     ));
  //   }

  //   return _widgetList;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      floatingActionButton: FloatingActionBtn(
        onPressed: createNewHabit,
      ),
      body: ListView(
        //padding: EdgeInsets.only(top: 40, bottom: 15),
        physics: PageScrollPhysics(),

        children: [
          //TOP ROW
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // welcome container
                  Container(
                    padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                    child: Text(
                      "WELCOME",
                      style: GoogleFonts.barlowCondensed(
                        color: Color.fromARGB(255, 20, 20, 20),
                        fontSize: 45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // user name
                  Container(
                    padding: EdgeInsets.only(top: 0, left: 20, right: 20),
                    child: Text(
                      "SUMAN, Good Day!",
                      style: GoogleFonts.barlowCondensed(
                        color: Color.fromARGB(255, 20, 20, 20),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              //Profile container
              Container(
                padding:
                    EdgeInsets.only(top: 25, left: 20, right: 20, bottom: 0),
                child: CircleAvatar(
                  // Set the radius of the circle
                  radius: 20,
                  // Set the background color of the circle
                  backgroundColor: Color.fromARGB(195, 88, 77, 151),
                  // Set the foreground color of the text
                  foregroundColor: Colors.white,
                  // Set the text to display inside the circle
                  child: Text('SB'),
                ),
              ),
            ],
          ),
          //Percent complete container
          Container(
            height: 30,
            padding: EdgeInsets.only(top: 20, bottom: 0, left: 20, right: 20),
            child: LinearPercentIndicator(
              //width: 300,
              lineHeight: 14.0,
              percent: db.getHabitPercentages(_selectedDate),
              //backgroundColor: Colors.grey[200],
              //progressColor: Color.fromARGB(255, 89, 208, 230),
              barRadius: Radius.circular(10),
              animateFromLastPercent: true,
              animation: true,
              animationDuration: 300,
              linearGradient: LinearGradient(colors: [
                // Color.fromARGB(255, 108, 89, 230),
                Color.fromARGB(255, 154, 97, 218),

                Color.fromARGB(255, 115, 222, 240),
                Color.fromARGB(255, 254, 131, 146),
              ]),
              padding: EdgeInsets.zero,
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 0),
            child: Text(
              'Progress of the day',
              style: TextStyle(
                  color: Colors.blueGrey, fontWeight: FontWeight.bold),
            ),
          ),

          //monthly sumary heatmap
          MonthlySummaryHeatmap(
            datasets: db.heatMapDataSet,
            startDate: _myBox.get("START_DATE"),
            heatMapOnClick: (value1) => loadPreviousData(value1!),
          ),

          //Center Date with navigator
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                child: Text(
                  formatDateForView(_selectedDate),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20, bottom: 0, right: 20),
                padding: EdgeInsets.only(right: 0.0, top: 0, bottom: 0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      HabitNavigatorMaterialButton(
                        materialButtonOnPressed: (() {
                          if (_selectedDate == DateTime.now()) {
                            loadPreviousData(
                                _selectedDate.subtract(Duration(days: 1)));
                          } else {
                            loadPreviousData(
                                _selectedDate.subtract(Duration(days: 1)));
                          }
                        }),
                        materialButtonIcon:
                            Icon(Icons.arrow_circle_left_rounded),
                        materialButtonText: "",
                      ),
                      HabitNavigatorMaterialButton(
                        materialButtonOnPressed:
                            _selectedDate.isAfter(DateTime.now())
                                ? null
                                : () {
                                    if (_selectedDate == DateTime.now()) {
                                    } else {
                                      loadPreviousData(
                                          _selectedDate.add(Duration(days: 1)));
                                    }
                                  },
                        materialButtonIcon:
                            Icon(Icons.arrow_circle_right_rounded),
                        materialButtonText: "",
                      ),
                    ]),
              )
            ],
          ),
          //List of habits
          db.todaysHabitList.length == 0
              ? Padding(
                  padding:
                      const EdgeInsets.only(top: 0, left: 20.0, right: 20.0),
                  child: Text(
                    _selectedDate.isAfter(DateTime.now())
                        ? "Come back tomorrow."
                        : "No Habits to display. Start a Habit NOW!",
                    style: TextStyle(
                      color: Color.fromARGB(255, 145, 145, 145),
                      fontSize: 20,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: db.todaysHabitList.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: ((context, index) {
                    return HabitTile(
                      habitName: db.todaysHabitList[index][0],
                      habitCompleted: db.todaysHabitList[index][1],
                      onChanged: (value) => checkBoxTapped(value, index),
                      settingsTapped: (context) => openHabitSettings(index),
                      deleteTapped: (context) => deleteHabit(index),
                      habitsTapped: (context, habitCompleted) =>
                          habitsTapped(index, habitCompleted),
                      confettiController: confettiController,
                    );
                  }),
                ),

          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}
