import 'dart:developer';

import 'package:app_usage_example/app_details.dart';
import 'package:flutter/material.dart';
import 'package:app_usage/app_usage.dart';
import 'package:flutter/services.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<AppUsageInfo> _infos = [];

  @override
  void initState() {
    super.initState();
  }

  AppInfo? appIcon;

  getIcons(String packageName) async {
    appIcon = await InstalledApps.getAppInfo(packageName);
    // print(appIcon!.icon);
    return appIcon;
  }

  void getUsageStats() async {
    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(Duration(hours: 1));
      List<AppUsageInfo> infoList =
          await AppUsage().getAppUsage(startDate, endDate);
      setState(() => _infos = infoList);

      for (var info in infoList) {
        log(info.toString());
      }
    } on AppUsageException catch (exception) {
      print(exception);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Center(
              child: const Text(
            'Apps Usage',
            style: TextStyle(color: Colors.white),
          )),
          backgroundColor: Colors.black,
        ),
        body: ListView.builder(
            itemCount: _infos.length,
            itemBuilder: (context, index) {
              // getIcons(_infos[index].packageName);
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AppDetails(
                          appUsageInfo: _infos[index],
                        ),
                      ));
                },
                child: Card(
                  color: Colors.white.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAppInfoWithPackageName(_infos[index].packageName),
                        SizedBox(
                          width: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            appName(_infos[index].packageName),

                            Text(
                                "Usage : ${formatTime(_infos[index].usage.toString())}",
                                overflow: TextOverflow.ellipsis),
                            // Text(
                            //     "Start Date : ${formatDate(_infos[index].startDate.toString())}",
                            //     overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.black,
            onPressed: getUsageStats,
            child: Icon(
              Icons.file_download,
              color: Colors.white,
            )),
      ),
    );
  }

  Widget _buildAppInfoWithPackageName(String packageName) {
    return FutureBuilder<AppInfo?>(
      future: InstalledApps.getAppInfo(packageName),
      builder: (BuildContext buildContext, AsyncSnapshot<AppInfo?> snapshot) {
        return snapshot.connectionState == ConnectionState.done
            ? snapshot.hasData && snapshot.data != null
                ? Container(
                    height: 64,
                    width: 64,
                    child: Image.memory(
                      snapshot.data!.icon!,
                      width: 64,
                    ),
                  )
                : Container()
            : Shimmer.fromColors(
                enabled: true,
                baseColor: Colors.black12,
                highlightColor: Colors.white,
                child: Container(
                  height: 64,
                  width: 64,
                ),
              );
      },
    );
  }

  Widget appName(String packageName) {
    return FutureBuilder<AppInfo?>(
      future: InstalledApps.getAppInfo(packageName),
      builder: (BuildContext buildContext, AsyncSnapshot<AppInfo?> snapshot) {
        return snapshot.connectionState == ConnectionState.done
            ? snapshot.hasData && snapshot.data != null
                ? SizedBox(
                    width: 230,
                    child: Text("App Name : ${snapshot.data!.name!}",
                        overflow: TextOverflow.ellipsis),
                  )
                : Container()
            : Text("Loading...");
      },
    );
  }

  String formatTime(String time) {
    String timeWithoutMilliseconds = time.split('.').first;
    List<String> timeParts = timeWithoutMilliseconds.split(':');
    int hours = int.parse(timeParts[0]);
    int minutes = int.parse(timeParts[1]);
    int seconds = int.parse(timeParts[2]);
    if (hours == 0 && minutes == 0 && seconds < 60) {
      return "less than 1 min";
    } else if (hours == 0) {
      return "$minutes min";
    } else {
      return "${hours}h ${minutes}m";
    }
  }

  String formatDate(String date) {
    String dateTimeWithMilliseconds = date;
    DateTime dateTime = DateTime.parse(dateTimeWithMilliseconds);
    String formattedDateTime = DateFormat('yyyy-MM-dd hh:mm').format(dateTime);
    return formattedDateTime;
    print(formattedDateTime);
  }
}
