import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:nkust_ap/pages/page.dart';
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:nkust_ap/utils/utils.dart';

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
  AppLocalizations app;

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
    app = AppLocalizations.of(context);
    return new Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              title: new Text(app.about),
              actions: <Widget>[
                IconButton(
                    icon: Icon(Icons.code),
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed(OpenSourcePage.routerName);
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
          physics: const NeverScrollableScrollPhysics(),
          children: <Widget>[
            _item(app.aboutAuthorTitle, app.aboutAuthorContent),
            _item(app.about, app.aboutUsContent),
            _item(app.aboutRecruitTitle, app.aboutRecruitContent),
            Stack(
              children: <Widget>[
                _item(app.aboutItcTitle, app.aboutItcContent),
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 20.0, horizontal: 26.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Image.asset(
                      "assets/images/kuas_itc.png",
                      width: 64.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              ],
            ),
            Card(
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              elevation: 4.0,
              child: Container(
                padding: EdgeInsets.only(
                    top: 24.0, left: 16.0, bottom: 16.0, right: 16.0),
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      app.aboutContactUsTitle,
                      style: TextStyle(fontSize: 18.0),
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          IconButton(
                            icon: Image.asset("assets/images/ic_fb.png"),
                            onPressed: () {
                              if (Platform.isAndroid)
                                Utils.launchUrl('fb://page/735951703168873')
                                    .catchError((onError) => Utils.launchUrl(
                                        'https://www.facebook.com/NKUST.ITC/'));
                              else
                                Utils.launchUrl(
                                    'https://www.facebook.com/NKUST.ITC/');
                            },
                            iconSize: 48.0,
                          ),
                          IconButton(
                            icon: Image.asset("assets/images/ic_github.png"),
                            onPressed: () {
                              if (Platform.isAndroid)
                                Utils.launchUrl(
                                        'github://organization/NKUST-ITC')
                                    .catchError((onError) => Utils.launchUrl(
                                        'https://github.com/NKUST-ITC'));
                              else
                                Utils.launchUrl('https://github.com/NKUST-ITC');
                            },
                            iconSize: 48.0,
                          ),
                          IconButton(
                            icon: Image.asset("assets/images/ic_email.png"),
                            onPressed: () {
                              Utils.launchUrl('mailto:abc873693@gmail.com');
                            },
                            iconSize: 48.0,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
          padding:
              EdgeInsets.only(top: 24.0, left: 16.0, bottom: 16.0, right: 16.0),
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
