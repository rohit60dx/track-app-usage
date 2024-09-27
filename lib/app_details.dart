import 'package:app_usage/app_usage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class AppDetails extends StatefulWidget {
  AppUsageInfo? appUsageInfo;

  AppDetails({
    this.appUsageInfo,
  });

  @override
  State<AppDetails> createState() => _AppDetailsState();
}

class _AppDetailsState extends State<AppDetails> {
  bool isClicked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Center(
              child: const Text(
            'App Details',
            style: TextStyle(color: Colors.white),
          )),
          backgroundColor: Colors.black,
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              Center(
                child: Container(
                  height: MediaQuery.of(context).size.height / 4,
                  child: Column(
                    children: [
                      _buildAppInfoWithPackageName(
                          widget.appUsageInfo!.packageName),
                      SizedBox(
                        height: 20,
                      ),
                      appName(widget.appUsageInfo!.packageName),
                      SizedBox(
                        height: 5,
                      ),
                      appVersion(widget.appUsageInfo!.packageName),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Divider(),
              SizedBox(
                height: 10,
              ),
              Text(
                  "Usage : ${formatTime(widget.appUsageInfo!.usage.toString())}",
                  overflow: TextOverflow.ellipsis),
              Text(
                  "App Start Date  : ${formatDate(widget.appUsageInfo!.startDate.toString())}",
                  overflow: TextOverflow.ellipsis),
              Text(
                  "Last Date of use : ${formatDate(widget.appUsageInfo!.endDate.toString())}",
                  overflow: TextOverflow.ellipsis),
              SizedBox(
                height: 10,
              ),
              isClicked ? appBuildLanguage(widget.appUsageInfo!.packageName)  : Container()
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.black,
          onPressed: () {
            setState(() {
              isClicked = true;
            });
          },
          label: const Text('Check Build Language',
              style: TextStyle(color: Colors.white)),
          icon: const Icon(Icons.settings, color: Colors.white, size: 25),
        ));
  }

  Widget _buildAppInfoWithPackageName(String packageName) {
    return FutureBuilder<AppInfo?>(
      future: InstalledApps.getAppInfo(packageName),
      builder: (BuildContext buildContext, AsyncSnapshot<AppInfo?> snapshot) {
        return snapshot.connectionState == ConnectionState.done
            ? snapshot.hasData && snapshot.data != null
                ? Container(
                    height: 100,
                    width: 100,
                    child: Image.memory(
                      snapshot.data!.icon!,
                      width: 100,
                      height: 100,
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
                ? Text(snapshot.data!.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                    overflow: TextOverflow.ellipsis)
                : Container()
            : Text("Loading...");
      },
    );
  }

  Widget appVersion(String packageName) {
    return FutureBuilder<AppInfo?>(
      future: InstalledApps.getAppInfo(packageName),
      builder: (BuildContext buildContext, AsyncSnapshot<AppInfo?> snapshot) {
        return snapshot.connectionState == ConnectionState.done
            ? snapshot.hasData && snapshot.data != null
                ? Text(
                    "Version ${snapshot.data!.versionName}+${snapshot.data!.versionCode}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                    overflow: TextOverflow.ellipsis)
                : Container()
            : Text("Loading...");
      },
    );
  }

  Widget appBuildLanguage(String packageName) {
    return FutureBuilder<AppInfo?>(
      future: InstalledApps.getAppInfo(packageName),
      builder: (BuildContext buildContext, AsyncSnapshot<AppInfo?> snapshot) {
        return snapshot.connectionState == ConnectionState.done
            ? snapshot.hasData && snapshot.data != null
                ? Text("${snapshot.data!.builtWith.toString().split(".")[1]}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                    overflow: TextOverflow.ellipsis)
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
