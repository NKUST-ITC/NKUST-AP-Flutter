import 'package:ap_common/models/announcement_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/res/app_icon.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:nkust_ap/utils/utils.dart';
import 'package:intl/intl.dart' show DateFormat;

enum _State { loading, finish, error, empty, offline }
enum Mode { add, edit }

extension ParseDateTimes on DateTime {
  String parseToString() {
    DateFormat formatter = DateFormat('yyyy-MM-ddTHH:mm:ss');
    String text = formatter.format(this.subtract(this.timeZoneOffset));
    return '${text}Z';
  }
}

class NewsEditPage extends StatefulWidget {
  static const String routerName = "/news/edit";

  final Mode mode;
  final Announcement announcement;

  const NewsEditPage({
    Key key,
    @required this.mode,
    this.announcement,
  }) : super(key: key);

  @override
  _NewsEditPageState createState() => _NewsEditPageState();
}

class _NewsEditPageState extends State<NewsEditPage> {
  final _formKey = GlobalKey<FormState>();

  AppLocalizations app;

  _State state = _State.loading;

  Announcement announcements;

  var _title = TextEditingController();
  var _description = TextEditingController();
  var _imgUrl = TextEditingController();
  var _url = TextEditingController();
  var _weight = TextEditingController();

  var formatter = DateFormat('yyyy-MM-ddTHH:mm:ss');
  var dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  DateTime expireTime;

  final dividerHeight = 16.0;

  @override
  void initState() {
    if (widget.mode == Mode.edit) {
      announcements = widget.announcement;
      _title.text = announcements.title;
      _imgUrl.text = announcements.imgUrl;
      _url.text = announcements.url;
      _weight.text = announcements.weight.toString();
      if (announcements.expireTime != null)
        expireTime = formatter.parse(announcements.expireTime);
      _description.text = announcements.description;
    } else {
      announcements = Announcement();
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(app.news),
        backgroundColor: Resource.Colors.blue,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          children: <Widget>[
            SizedBox(height: dividerHeight),
            TextFormField(
              maxLines: 1,
              controller: _title,
              validator: (value) {
                if (value.isEmpty) {
                  return app.doNotEmpty;
                }
                return null;
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                fillColor: Resource.Colors.blueAccent,
                labelStyle: TextStyle(
                  color: Resource.Colors.grey,
                ),
                labelText: app.title,
              ),
            ),
            SizedBox(height: dividerHeight),
            TextFormField(
              maxLines: 1,
              controller: _weight,
              validator: (value) {
                if (value.isEmpty) {
                  return app.doNotEmpty;
                } else {
                  try {
                    int.parse(value);
                  } catch (e) {
                    return app.formatError;
                  }
                }
                return null;
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                fillColor: Resource.Colors.blueAccent,
                labelStyle: TextStyle(
                  color: Resource.Colors.grey,
                ),
                labelText: app.weight,
              ),
            ),
            SizedBox(height: dividerHeight),
            TextFormField(
              maxLines: 1,
              controller: _imgUrl,
              validator: (value) {
                if (value.isEmpty) {
                  return app.doNotEmpty;
                }
                return null;
              },
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                fillColor: Resource.Colors.blueAccent,
                labelStyle: TextStyle(
                  color: Resource.Colors.grey,
                ),
                labelText: app.imageUrl,
              ),
            ),
            SizedBox(height: dividerHeight),
            TextFormField(
              maxLines: 1,
              controller: _url,
              validator: (value) {
                return null;
              },
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                fillColor: Resource.Colors.blueAccent,
                labelStyle: TextStyle(
                  color: Resource.Colors.grey,
                ),
                labelText: app.url,
              ),
            ),
            SizedBox(height: dividerHeight),
            Container(color: Resource.Colors.grey, height: 1),
            SizedBox(height: 8.0),
            FractionallySizedBox(
              widthFactor: 0.3,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(30.0),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                color: Resource.Colors.blueAccent,
                onPressed: () async {
                  setState(() {
                    expireTime = null;
                  });
                },
                child: Text(
                  app.setNoExpireTime,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 8.0),
            ListTile(
              onTap: _pickStartDateTime,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 8,
              ),
              leading: Icon(
                AppIcon.accessTime,
                size: 30,
                color: Resource.Colors.grey,
              ),
              trailing: Icon(
                AppIcon.keyboardArrowDown,
                size: 30,
                color: Resource.Colors.grey,
              ),
              title: Text(
                app.expireTime,
                style: TextStyle(fontSize: 20),
              ),
              subtitle: Text(
                expireTime == null
                    ? app.newsExpireTimeHint
                    : dateFormat.format(expireTime),
                style: TextStyle(fontSize: 20),
              ),
            ),
            Container(color: Resource.Colors.grey, height: 1),
            SizedBox(height: dividerHeight),
            TextFormField(
              maxLines: 2,
              controller: _description,
              validator: (value) {
                if (value.isEmpty) {
                  return app.doNotEmpty;
                }
                return null;
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                fillColor: Resource.Colors.blueAccent,
                labelStyle: TextStyle(
                  color: Resource.Colors.grey,
                ),
                labelText: app.description,
              ),
            ),
            SizedBox(height: 36),
            FractionallySizedBox(
              widthFactor: 0.8,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(30.0),
                  ),
                ),
                padding: EdgeInsets.all(14.0),
                onPressed: () {
                  _announcementSubmit();
                },
                color: Resource.Colors.blueAccent,
                child: Text(
                  widget.mode == Mode.add ? app.submit : app.update,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
            SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Future _pickStartDateTime() async {
    DateTime dateTime =
        this.expireTime ?? DateTime.now().add(Duration(days: 7));
    DateTime picked = await showDatePicker(
      context: context,
      locale: AppLocalizations.locale,
      initialDate: dateTime ?? DateTime.now().add(Duration(days: 7)),
      firstDate: DateTime(1950),
      lastDate: DateTime(2099),
    );
    TimeOfDay timeOfDay =
        TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
    timeOfDay = await showTimePicker(context: context, initialTime: timeOfDay);
    if (picked != null && timeOfDay != null) {
      setState(
        () => this.expireTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          timeOfDay.hour,
          timeOfDay.minute,
        ),
      );
    }
  }

  void _announcementSubmit() async {
    if (_formKey.currentState.validate()) {
      Future<dynamic> instance;
      announcements.title = _title.text;
      announcements.description = _description.text;
      announcements.imgUrl = _imgUrl.text;
      announcements.url = _url.text;
      announcements.weight = int.parse(_weight.text);
      announcements.expireTime =
          (expireTime == null) ? null : expireTime.parseToString();
      switch (widget.mode) {
        case Mode.add:
          instance = Helper.instance.addAnnouncement(announcements);
          break;
        case Mode.edit:
          instance = Helper.instance.updateAnnouncement(announcements);
          break;
      }
      instance.then((response) {
        Navigator.of(context).pop(true);
        Utils.showToast(context, app.addSuccess);
      }).catchError((e) {
        Utils.showToast(context, app.somethingError);
      });
    }
  }
}
