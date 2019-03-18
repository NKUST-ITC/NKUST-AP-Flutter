import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/global.dart';

enum _Status { loading, finish, error, empty }

class NewsContentPageRoute extends MaterialPageRoute {
  NewsContentPageRoute(this.news)
      : super(builder: (BuildContext context) => new NewsContentPage(news));

  final News news;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return new FadeTransition(
        opacity: animation, child: new NewsContentPage(news));
  }
}

class NewsContentPage extends StatefulWidget {
  static const String routerName = "/news/content";

  final News news;

  NewsContentPage(this.news);

  @override
  NewsContentPageState createState() => new NewsContentPageState(news);
}

class NewsContentPageState extends State<NewsContentPage>
    with SingleTickerProviderStateMixin {
  _Status state = _Status.finish;
  AppLocalizations app;

  final News news;

  NewsContentPageState(this.news);

  @override
  void initState() {
    super.initState();
    FA.setCurrentScreen("NewsContentPage", "news_content_page.dart");
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _homebody(Orientation orientation) {
    switch (state) {
      case _Status.loading:
        return Center(
          child: CircularProgressIndicator(),
        );
      case _Status.finish:
        return OrientationBuilder(builder: (_, orientation) {
          if (orientation == Orientation.portrait)
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: _renderContent(orientation),
            );
          else
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: _renderContent(orientation),
            );
        });
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return Scaffold(
      appBar: new AppBar(
        title: new Text(app.news),
        backgroundColor: Resource.Colors.blue,
      ),
      body: OrientationBuilder(builder: (_, orientation) {
        return _homebody(orientation);
      }),
    );
  }

  _renderContent(Orientation orientation) {
    List<Widget> list = <Widget>[
      AspectRatio(
        aspectRatio: orientation == Orientation.portrait ? 4 / 3 : 9 / 16,
        child: Hero(
          tag: news.hashCode,
          child: CachedNetworkImage(
            imageUrl: news.image,
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        ),
      ),
      SizedBox(
          height: orientation == Orientation.portrait ? 16.0 : 0.0,
          width: orientation == Orientation.portrait ? 0.0 : 32.0),
    ];
    List<Widget> listB = <Widget>[
      Hero(
        tag: Constants.TAG_NEWS_TITLE,
        child: Material(
          color: Colors.transparent,
          child: Text(
            news.title,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20.0,
                color: Resource.Colors.grey,
                fontWeight: FontWeight.w500),
          ),
        ),
      ),
      Hero(
        tag: Constants.TAG_NEWS_ICON,
        child: Icon(Icons.arrow_drop_down),
      ),
      Padding(
        padding: EdgeInsets.symmetric(
            horizontal: orientation == Orientation.portrait ? 16.0 : 0.0),
        child: Text(
          news.content,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.0, color: Resource.Colors.grey),
        ),
      ),
      SizedBox(height: 16.0),
      RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(30.0),
          ),
        ),
        onPressed: () {
          if (news.url.isNotEmpty) Utils.launchUrl(news.url);
        },
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 0.0),
        color: Resource.Colors.yellow,
        child: Icon(Icons.exit_to_app, color: Colors.white),
      )
    ];
    if (orientation == Orientation.portrait) {
      list.addAll(listB);
    } else {
      list.add(
          Column(mainAxisAlignment: MainAxisAlignment.center, children: listB));
    }
    return list;
  }
}
