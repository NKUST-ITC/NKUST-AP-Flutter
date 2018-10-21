import 'package:flutter/material.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:nkust_ap/pages/page.dart';
import 'package:nkust_ap/utils/app_localizations.dart';

class AboutUsPageRoute extends MaterialPageRoute {
  AboutUsPageRoute()
      : super(builder: (BuildContext context) => new AboutUsPage());

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return new FadeTransition(opacity: animation, child: new AboutUsPage());
  }
}

class AboutUsPage extends StatefulWidget {
  static const String routerName = "/aboutUs";

  @override
  AboutUsPageState createState() => new AboutUsPageState();
}

class AboutUsPageState extends State<AboutUsPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var app = AppLocalizations.of(context);
    return new Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              title: new Text(AppLocalizations.of(context).about),
              actions: <Widget>[
                IconButton(
                    icon: Icon(Icons.code),
                    onPressed: () {
                      Navigator.of(context).pushNamed(MyLicencePage.routerName);
                    })
              ],
              backgroundColor: Resource.Colors.blue,
              flexibleSpace: FlexibleSpaceBar(
                background: Image.asset(
                  "assets/images/kuasap3.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ];
        },
        body: ListView(
          children: <Widget>[
            _item(app.aboutAuthorTitle, app.aboutAuthorContent),
            _item(app.about, app.aboutUsContent),
            _item(app.aboutRecruitTitle, app.aboutRecruitContent),
            _item(app.aboutItcTitle, app.aboutItcContent),
            _item(app.aboutOpenSourceTitle, app.aboutOpenSourceContent),
          ],
        ),
      ),
    );
  }

  _item(String text, String subText) => Card(
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        elevation: 4.0,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                text,
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(
                height: 4.0,
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 14.0, color: Resource.Colors.grey),
                  text: subText,
                ),
              ),
            ],
          ),
        ),
      );
}
