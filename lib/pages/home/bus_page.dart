import 'package:flutter/material.dart';
import 'package:nkust_ap/res/resource.dart';
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

  String selectStartStation = "text";
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
    return Column(
      children: <Widget>[
        FlatButton(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          onPressed: busTime.hasReserve() ? () {} : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Icon(
                  Icons.directions_bus,
                  size: 20.0,
                  color: busTime.getColorState(),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  busTime.Time,
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
                flex: 2,
                child: Text(
                  busTime.SpecialTrainRemark,
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
          title: new Text(Strings.bus),
          backgroundColor: Colors.blue,
        ),
        body: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            Calendar(),
            Container(
                padding: EdgeInsets.all(8.0),
                child: CupertinoSegmentedControl(
                  groupValue: selectStartStation,
                  children: {
                    "text": Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 48.0),
                      child: Text("建工上車"),
                    ),
                    "texta": Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 48.0),
                      child: Text("燕巢上車"),
                    )
                  },
                  onValueChanged: (String text) {
                    selectStartStation = text;
                    setState(() {});
                  },
                )),
            RefreshIndicator(
                onRefresh: () => _getBusTimeTables(),
                child: isLoading
                    ? Container(
                        child: CircularProgressIndicator(),
                        alignment: Alignment.center)
                    : Flex(
                        direction: Axis.vertical,
                        children: busTimeWeights,
                      ))
          ],
        ));
  }

  _getBusTimeTables() {
    Helper.instance.getBusTimeTables(dateTime).then((response) {
      busData = BusData.fromJson(response.data);
      busTimeWeights.clear();
      for (var i in busData.timetable) busTimeWeights.add(_busTime(i));
      isLoading = false;
      setState(() {});
    });
  }
}
