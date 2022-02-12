import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:notifoo/helper/DatabaseHelper.dart';
import 'package:notifoo/model/Notifications.dart';
import 'package:notifoo/model/notification_lister_model.dart';

class NotificationListerPageLogic {
  final NotificationListerModel _model;
  NotificationListerPageLogic(this._model);

  String flagEntry;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    ReceivePort port = ReceivePort();
    NotificationsListener.initialize(callbackHandle: _callback);

    // this can fix restart<debug> can't handle error
    IsolateNameServer.removePortNameMapping("_notifoolistener_");
    IsolateNameServer.registerPortWithName(port.sendPort, "_notifoolistener_");

    //IsolateNameServer.registerPortWithName(port.sendPort, "insta");
    port.listen((message) => onData(message));

    // don't use the default receivePort
    // NotificationsListener.receivePort.listen((evt) => onData(evt));

    var isR = await NotificationsListener.isRunning;
    print("""Service is ${!isR ? "not " : ""}aleary running""");

    // setState(() {
    //   started = isR;
    // });

    //get apps code new

    // _apps = AppListHelper().appListData;
    _model.started = isR;
  }

  // we must use static method, to handle in background
  static void _callback(NotificationEvent evt) {
    // print(
    //   "send evt to ui: $evt",
    // );
    final SendPort send =
        IsolateNameServer.lookupPortByName("_notifoolistener_");
    if (send == null) print("can't find the sender");
    send?.send(evt);
  }

  void onData(NotificationEvent event) async {
    //await getCurrentAppWithIcon(event.packageName);
    print(event);

    //packageName = event.packageName.toString().split('.').last.capitalizeFirstofEach;
    if (event.packageName.contains("skydrive") ||
        (event.packageName.contains("service")) ||
        // (event.packageName.contains("android")) ||
        (event.packageName.contains("notifoo")) ||
        (event.packageName.contains("screenshot")) ||
        (event.title.contains("WhatsApp")) ||
        (event.packageName.contains("deskclock")) ||
        (event.packageName.contains("wellbeing")) ||
        (event.packageName.contains("weather2")) ||
        (event.packageName.contains("gallery"))) {
      //print(event.packageName);
    } else {
      // var xyz = currentApp as Application;
      //_currentApp = app.then((value) => value) as Application;

      //_currentApp = app as Application;
      _model.packageName = event.packageName;
      // print("Success Package Found: " + app.packageName);
      //var jsondata2 = json.decode(event.toString());
      Map<String, dynamic> jsonresponse = json.decode(event.toString());

      //var jsonData = json.decoder.convert(event.toString());
      _model.log.add(event);
      var createatday = event.createAt.day;
      print("Create AT Day: $createatday");
      var today = new DateTime.now().day;
      print('today: $today');
      //var xx = jsonresponse.containsKey('summaryText');
      if (!jsonresponse.containsKey('summaryText') &&
          event.createAt.day >= today) {
        //check
        bool redundancy;
        // redundantNotificationCheck(event).then((bool value) {
        //   redundancy = value;
        // });

        if ((event.text != flagEntry) && event.text != null) {
          DatabaseHelper.instance.insertNotification(
            Notifications(
              title: event.title,
              //appTitle: _currentApp.appName,
              // appIcon: _currentApp is ApplicationWithIcon
              //     ? Image.memory(_currentApp.icon)
              //     : null,
              text: event.text,
              message: event.message,
              packageName: event.packageName,
              timestamp: event.timestamp,
              createAt: event.createAt.millisecondsSinceEpoch.toString(),
              eventJson: event.toString(),
              createdDate: DateTime.now().millisecondsSinceEpoch.toString(),
              isDeleted: 0,
            ),
          );
        }
        flagEntry = event.text;
      } else {
        // # TODO fix here

        // var titleLength = jsonresponse["textLines"].length;

        DatabaseHelper.instance.insertNotification(
          Notifications(
              title: jsonresponse["textLines"] as String,
              text: event.text,
              message: event.message,
              packageName: event.packageName,
              timestamp: event.timestamp,
              createAt: event.createAt.toString(),
              eventJson: event.toString()),
        );
      }
    }

    // print("Print Notification: $event");
  }
}
