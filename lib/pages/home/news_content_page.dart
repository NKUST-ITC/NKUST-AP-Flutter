import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/announcements_data.dart';
import 'package:nkust_ap/res/app_icon.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/global.dart';

enum _Status { loading, finish, error, empty }

class NewsContentPage extends StatefulWidget {
  static const String routerName = "/news/content";

  final Announcements news;

  NewsContentPage(this.news);

  @override
  NewsContentPageState createState() => NewsContentPageState();
}

class NewsContentPageState extends State<NewsContentPage> {
  _Status state = _Status.finish;
  AppLocalizations app;

  @override
  void initState() {
    FA.setCurrentScreen("NewsContentPage", "widget.s_content_page.dart");
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
      body: _homebody(),
    );
  }

  Widget _homebody() {
    switch (state) {
      case _Status.loading:
        return Center(
          child: CircularProgressIndicator(),
        );
      case _Status.finish:
        return OrientationBuilder(
          builder: (_, orientation) {
            return Flex(
              direction: orientation == Orientation.portrait
                  ? Axis.vertical
                  : Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: _renderContent(orientation),
            );
          },
        );
      default:
        return Container();
    }
  }

  _renderContent(Orientation orientation) {
    final Widget image = AspectRatio(
      aspectRatio: orientation == Orientation.portrait ? 4 / 3 : 9 / 16,
      child: Hero(
        tag: widget.news.hashCode,
        child: (Platform.isIOS || Platform.isAndroid)
            ? CachedNetworkImage(
                imageUrl: widget.news.imgUrl,
                errorWidget: (context, url, error) => Icon(Icons.error),
              )
            : Image.network(widget.news.imgUrl),
      ),
    );
    final List<Widget> newsContent = <Widget>[
      Hero(
        tag: Constants.TAG_NEWS_TITLE,
        child: Material(
          color: Colors.transparent,
          child: Text(
            widget.news.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0,
              color: Resource.Colors.greyText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      Hero(
        tag: Constants.TAG_NEWS_ICON,
        child: Icon(AppIcon.arrowDropDown),
      ),
      Padding(
        padding: EdgeInsets.symmetric(
            horizontal: orientation == Orientation.portrait ? 16.0 : 0.0),
        child: Text(
          widget.news.description,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.0,
            color: Resource.Colors.greyText,
          ),
        ),
      ),
      if (widget.news.url.isNotEmpty) ...[
        SizedBox(height: 16.0),
        RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(30.0),
            ),
          ),
          onPressed: () {
            Utils.launchUrl(widget.news.url);
            String message = widget.news.description.length > 12
                ? widget.news.description
                : widget.news.description.substring(0, 12);
            FA.logAction('news_link', 'click', message: message);
          },
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 0.0),
          color: Resource.Colors.yellow,
          child: Icon(
            AppIcon.exitToApp,
            color: Colors.white,
          ),
        ),
      ],
    ];
    if (orientation == Orientation.portrait) {
      return <Widget>[
        image,
        SizedBox(height: 16.0),
        ...newsContent,
      ];
    } else {
      return <Widget>[
        Expanded(child: image),
        SizedBox(width: 32.0),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: newsContent,
          ),
        ),
      ];
    }
  }
}
