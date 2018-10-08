import 'package:flutter/material.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:flutter/cupertino.dart';

class BusPageRoute extends MaterialPageRoute {
  BusPageRoute() : super(builder: (BuildContext context) => new BusPage());

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return new FadeTransition(opacity: animation, child: new BusPage());
  }
}

class BusPage extends StatefulWidget {
  static const String routerName = "/bus";

  @override
  BusPageState createState() => new BusPageState();
}

class BusPageState extends State<BusPage> with SingleTickerProviderStateMixin {
  BusData busData;
  List<Widget> busTimeWeights = [];

  String selectStartStation = "JianGong";
  DateTime dateTime = DateTime.now();

  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    _getBusTimeTables();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _textStyle(BusTime busTime) => new TextStyle(
      color: busTime.getColorState(),
      fontSize: 18.0,
      decorationColor: Colors.grey);

  Widget _busTime(BusTime busTime) {
    String title = "預約", content = "確定要預定本次校車？";
    if (busTime.specialTrainRemark.length > 3) {
      title = busTime.specialTrainRemark.substring(0, 4);
      content = "${busTime.specialTrainRemark}\n$content";
    }
    return Column(
      children: <Widget>[
        FlatButton(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          onPressed: busTime.hasReserve()
              ? () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                            title: Text(title,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Resource.Colors.blue)),
                            content: Text(
                              content,
                              textAlign: TextAlign.center,
                            ),
                            actions: <Widget>[
                              FlatButton(
                                child: Text("取消"),
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop('dialog');
                                },
                              ),
                              FlatButton(
                                child: Text("預約"),
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop('dialog');
                                },
                              )
                            ],
                          ));
                }
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Icon(
                  Icons.directions_bus,
                  size: 20.0,
                  color: busTime.getColorState(),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  busTime.time,
                  textAlign: TextAlign.center,
                  style: _textStyle(busTime),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "${busTime.reserveCount}人",
                  textAlign: TextAlign.center,
                  style: _textStyle(busTime),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  busTime.specialTrainRemark.length > 3
                      ? busTime.specialTrainRemark.substring(0, 4)
                      : "",
                  textAlign: TextAlign.center,
                  style: _textStyle(busTime),
                ),
              ),
              Expanded(
                flex: 2,
                child: Icon(
                  Icons.access_time,
                  size: 20.0,
                  color: busTime.getColorState(),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  busTime.getReserveState(),
                  textAlign: TextAlign.center,
                  style: _textStyle(busTime),
                ),
              )
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Divider(
            color: Colors.grey,
            indent: 4.0,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      // Appbar
      appBar: new AppBar(
        // Title
        title: new Text(Resource.Strings.bus),
        backgroundColor: Resource.Colors.blue,
      ),
      body: Flex(
        direction: Axis.vertical,
        children: <Widget>[
          Expanded(
              flex: 2,
              child: Calendar(
                onDateSelected: (DateTime datetime) {
                  dateTime = datetime;
                  _getBusTimeTables();
                },
              )),
          Expanded(
              flex: 1,
              child: Container(
                  padding: EdgeInsets.all(8.0),
                  child: CupertinoSegmentedControl(
                    groupValue: selectStartStation,
                    children: {
                      "JianGong": Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 48.0),
                        child: Text("建工上車"),
                      ),
                      "YanChao": Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 48.0),
                        child: Text("燕巢上車"),
                      )
                    },
                    onValueChanged: (String text) {
                      selectStartStation = text;
                      _updateBusTimeTables();
                    },
                  ))),
          Expanded(
            flex: 10,
            child: isLoading
                ? Container(
                    child: CircularProgressIndicator(),
                    alignment: Alignment.center)
                : busTimeWeights.length == 0
                    ? FlatButton(
                        onPressed: _getBusTimeTables,
                        child: Center(
                          child: Flex(
                            mainAxisAlignment: MainAxisAlignment.center,
                            direction: Axis.vertical,
                            children: <Widget>[
                              SizedBox(
                                child: Icon(
                                  Icons.directions_bus,
                                  size: 150.0,
                                ),
                                width: 200.0,
                              ),
                              Text(
                                isError
                                    ? "發生錯誤，點擊重試"
                                    : "Oops！本日校車沒有上班喔～\n請選擇其他日期\uD83D\uDE0B",
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ))
                    : ListView(
                        children: busTimeWeights,
                      ),
          ),
        ],
      ),
    );
  }

  _getBusTimeTables() {
    isLoading = true;
    setState(() {});
    Helper.instance.getBusTimeTables(dateTime).then((response) {
      busData = BusData.fromJson(response.data);
      _updateBusTimeTables();
    });
  }

  _updateBusTimeTables() {
    busTimeWeights = [];
    if (busData != null) {
      for (var i in busData.timetable) {
        if (selectStartStation == "JianGong" && i.endStation == "燕巢")
          busTimeWeights.add(_busTime(i));
        else if (selectStartStation == "YanChao" && i.endStation == "建工")
          busTimeWeights.add(_busTime(i));
      }
      isLoading = false;
      setState(() {});
    }
  }
}
