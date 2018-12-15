import 'package:flutter/material.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/models/models.dart';
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

  Widget _homebody() {
    switch (state) {
      case _Status.loading:
        return Center(
          child: CircularProgressIndicator(),
        );
      case _Status.finish:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.network(news.image),
            ),
            SizedBox(height: 16.0),
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
            /*
            "高應大文創系畢業展《繫》\n"
                  "一縷輕煙，再厚重的煩悶終究會飄散\n"
                  "一條絲線，釐清了與我交纏共生的信念\n"
                  "一回展覽，好久不見/未曾相見\n"
                  "你 想遇到誰？\n"
            */
            Text(
              news.content,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0, color: Resource.Colors.grey),
            ),
            SizedBox(height: 16.0),
            RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(30.0),
                ),
              ),
              onPressed: () {
                Utils.launchUrl(news.url);
              },
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 0.0),
              color: Resource.Colors.yellow,
              child: Icon(Icons.exit_to_app, color: Colors.white),
            )
          ],
        );
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
      body: _homebody(),
    );
  }
}
