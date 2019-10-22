import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/res/app_icon.dart';
import 'package:nkust_ap/res/assets.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/share_data_widget.dart';

class AboutUsPage extends StatefulWidget {
  static const String routerName = "/aboutUs";

  @override
  AboutUsPageState createState() => AboutUsPageState();
}

class AboutUsPageState extends State<AboutUsPage> {
  AppLocalizations app;

  @override
  void initState() {
    FA.setCurrentScreen("AboutUsPage", "about_us_page.dart");
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String get sectionImage {
    final department =
        ShareDataWidget.of(context).data.userInfo?.department ?? '';
    Random random = Random();
    bool halfSnapFingerChance = random.nextInt(2000) % 2 == 0;
    if (department.contains('建工') || department.contains('燕巢'))
      return halfSnapFingerChance
          ? ImageAssets.sectionJiangong
          : ImageAssets.sectionYanchao;
    else if (department.contains('第一'))
      return halfSnapFingerChance
          ? ImageAssets.sectionFirst1
          : ImageAssets.sectionFirst2;
    else if (department.contains('旗津') || department.contains('楠梓'))
      return halfSnapFingerChance
          ? ImageAssets.sectionQijin
          : ImageAssets.sectionNanzi;
    else
      return ImageAssets.kuasap2;
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    var expandedHeight = MediaQuery.of(context).size.height * 0.25;
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: expandedHeight,
              floating: false,
              pinned: true,
              title: Text(app.about),
              actions: <Widget>[
                IconButton(
                    icon: Icon(AppIcon.codeIcon),
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed(OpenSourcePage.routerName);
                      FA.logAction('open_source', 'click');
                    })
              ],
              backgroundColor: Resource.Colors.blue,
              flexibleSpace: FlexibleSpaceBar(
                background: Image.asset(
                  sectionImage,
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
                      ImageAssets.kuasITC,
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
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
                            icon: Image.asset(ImageAssets.fb),
                            onPressed: () {
                              if (kIsWeb)
                                Utils.launchUrl(
                                        'https://www.facebook.com/NKUST.ITC/')
                                    .catchError((onError) => Utils.showToast(
                                        context, app.platformError));
                              else if (Platform.isAndroid)
                                Utils.launchUrl('fb://page/735951703168873')
                                    .catchError((onError) => Utils.launchUrl(
                                        'https://www.facebook.com/NKUST.ITC/'));
                              else if (Platform.isIOS)
                                Utils.launchUrl('fb://profile/735951703168873')
                                    .catchError((onError) => Utils.launchUrl(
                                        'https://www.facebook.com/NKUST.ITC/'));
                              else
                                Utils.launchUrl(
                                        'https://www.facebook.com/NKUST.ITC/')
                                    .catchError((onError) => Utils.showToast(
                                        context, app.platformError));
                              FA.logAction('fb', 'click');
                            },
                            iconSize: 48.0,
                          ),
                          IconButton(
                            icon: Image.asset(ImageAssets.github),
                            onPressed: () {
                              if (kIsWeb)
                                Utils.launchUrl('https://github.com/NKUST-ITC')
                                    .catchError((onError) => Utils.showToast(
                                        context, app.platformError));
                              else if (Platform.isAndroid)
                                Utils.launchUrl(
                                        'github://organization/NKUST-ITC')
                                    .catchError((onError) => Utils.launchUrl(
                                        'https://github.com/NKUST-ITC'));
                              else if (Platform.isIOS)
                                Utils.launchUrl('https://github.com/NKUST-ITC');
                              else
                                Utils.launchUrl('https://github.com/NKUST-ITC')
                                    .catchError((onError) => Utils.showToast(
                                        context, app.platformError));
                              FA.logAction('github', 'click');
                            },
                            iconSize: 48.0,
                          ),
                          IconButton(
                            icon: Image.asset(ImageAssets.email),
                            onPressed: () {
                              Utils.launchUrl('mailto:abc873693@gmail.com')
                                  .catchError((onError) => Utils.showToast(
                                      context, app.platformError));
                              FA.logAction('email', 'click');
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
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
