import 'dart:isolate';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:notifoo/helper/DatabaseHelper.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:device_apps/device_apps.dart';
import 'package:notifoo/extensions/textFormat.dart';
import 'package:notifoo/model/Notifications.dart';

class NotificationsLog extends StatefulWidget {
  @override
  _NotificationsLogState createState() => _NotificationsLogState();
}

class _NotificationsLogState extends State<NotificationsLog> {
  List<NotificationEvent> _log = [];
  bool started = false;
  bool _loading = false;
  String packageName = "";

  ReceivePort port = ReceivePort();

  @override
  void initState() {
    initPlatformState();
    super.initState();
  }

  // we must use static method, to handle in background
  static void _callback(NotificationEvent evt) {
    print("send evt to ui: $evt");
    final SendPort send = IsolateNameServer.lookupPortByName("_listener_");
    if (send == null) print("can't find the sender");
    send?.send(evt);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    NotificationsListener.initialize(callbackHandle: _callback);

    // this can fix restart<debug> can't handle error
    IsolateNameServer.removePortNameMapping("_listener_");
    IsolateNameServer.registerPortWithName(port.sendPort, "_listener_");
    //IsolateNameServer.registerPortWithName(port.sendPort, "insta");
    port.listen((message) => onData(message));

    // don't use the default receivePort
    // NotificationsListener.receivePort.listen((evt) => onData(evt));

    var isR = await NotificationsListener.isRunning;
    print("""Service is ${!isR ? "not " : ""}aleary running""");
    GetListOfApps();
    setState(() {
      started = isR;
    });
  }

  void onData(NotificationEvent event) {
    setState(() {
      // if (!event.packageName.contains("example") ||
      //     !event.packageName.contains("discover") ||
      //     !event.packageName.contains("service")) {
      //   _log.add(event);
      // }

      packageName =
          event.packageName.toString().split('.').last.capitalizeFirstofEach;
      if (event.packageName.contains("skydrive") ||
          (event.packageName.contains("service")) ||
          (event.packageName.contains("android")) ||
          (event.packageName.contains("notifoo")) ||
          (event.packageName.contains("screenshot")) ||
          (event.packageName.contains("gallery"))) {
        print(event.packageName);
      } else {
        _log.add(event);

        DatabaseHelper.instance.insertNotification(Notifications(
            title: event.title,
            infoText: event.text,
            showWhen: true,
            subText: event.text,
            timestamp: event.timestamp,
            package_name: event.packageName,
            text: event.text,
            summaryText: event.text));
      }
    });
    // if (!event.packageName.contains("example") ||
    //     !event.packageName.contains("skydrive") ||
    //     !event.packageName.contains("skydrive") ||
    //     !event.packageName.contains("xiaomi")) {
    //   // TODO: fix bug
    //   // NotificationsListener.promoteToForeground("");
    // }
    print(event.toString());
  }

  void startListening() async {
    print("start listening");
    setState(() {
      _loading = true;
    });
    var hasPermission = await NotificationsListener.hasPermission;
    if (!hasPermission) {
      print("no permission, so open settings");
      NotificationsListener.openPermissionSettings();
      return;
    }

    var isR = await NotificationsListener.isRunning;

    if (!isR) {
      await NotificationsListener.startService(
          title: "Notifoo listening",
          description: "Let's scrape the notifactions...");
    }

    setState(() {
      started = true;
      _loading = false;
    });
  }

  void stopListening() async {
    print("stop listening");

    setState(() {
      _loading = true;
    });

    await NotificationsListener.stopService();

    setState(() {
      started = false;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifoo'),
      ),
      body: FutureBuilder<List<Notifications>>(
        future: DatabaseHelper.instance.getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print(snapshot.data);
            return StickyGroupedListView<NotificationEvent, String>(
              elements: _log,
              order: StickyGroupedListOrder.DESC,
              groupBy: (NotificationEvent element) =>
                  element.packageName.toString(),
              groupComparator: (String value1, String value2) =>
                  value2.compareTo(value1),
              itemComparator:
                  (NotificationEvent element1, NotificationEvent element2) =>
                      element1.packageName.compareTo(element2.packageName),
              floatingHeader: true,
              groupSeparatorBuilder: (NotificationEvent element) => Container(
                height: 50,
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.blue[300],
                      border: Border.all(
                        color: Colors.blue[300],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${element.packageName.toString().split('.').last.capitalizeFirstofEach}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              itemBuilder: (_, NotificationEvent element) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  elevation: 8.0,
                  margin:
                      new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  child: Container(
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      leading: Icon(Icons.notifications),
                      title: Text(element.title ?? packageName),
                      subtitle: Text(element.text.toString()),
                      //trailing: Text(element.text.toString()),
                      trailing:
                          //  Text(entry.packageName.toString().split('.').last),
                          Icon(Icons.keyboard_arrow_right),
                      onTap: () {
                        final _packageName =
                            SnackBar(content: Text(packageName));

                        print(element.packageName.toString().split('.').last);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(_packageName);
                      },
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text("Oops!");
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: started ? stopListening : startListening,
        tooltip: 'Start/Stop sensing',
        child: _loading
            ? Icon(Icons.close)
            : (started ? Icon(Icons.stop) : Icon(Icons.play_arrow)),
      ),
    );
  }
}

Future<String> GetListOfApps() async {
  List _apps = await DeviceApps.getInstalledApplications(
      onlyAppsWithLaunchIntent: true,
      includeAppIcons: true,
      includeSystemApps: true);

  print(_apps);
}