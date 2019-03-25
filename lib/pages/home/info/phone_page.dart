import 'package:flutter/material.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/hint_content.dart';

enum _State { loading, finish, error, empty }

class PhonePageRoute extends MaterialPageRoute {
  PhonePageRoute() : super(builder: (BuildContext context) => new PhonePage());

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return new FadeTransition(opacity: animation, child: new PhonePage());
  }
}

class PhonePage extends StatefulWidget {
  static const String routerName = "/info/phone";

  @override
  PhonePageState createState() => new PhonePageState();
}

class PhonePageState extends State<PhonePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Widget> phoneWeights = [];

  List<PhoneModel> phoneList = [];

  _State state = _State.loading;

  int page = 1;

  AppLocalizations app;

  @override
  void initState() {
    super.initState();
    FA.setCurrentScreen("PhonePage", "phone_page.dart");
    _getPhones();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _textBlueStyle() {
    return TextStyle(
        color: Resource.Colors.blue,
        fontSize: 18.0,
        fontWeight: FontWeight.bold);
  }

  _textGreyStyle() {
    return TextStyle(color: Resource.Colors.grey, fontSize: 14.0);
  }

  _textStyle() {
    return TextStyle(
        color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.bold);
  }

  Widget _phoneItem(PhoneModel phone) {
    return FlatButton(
      padding: EdgeInsets.all(0.0),
      child: Container(
        padding: EdgeInsets.all(16.0),
        width: double.infinity,
        decoration: new BoxDecoration(
          border: new Border(
            bottom: BorderSide(color: Colors.grey, width: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              phone.name ?? "",
              style: _textStyle(),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 8.0),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    phone.number ?? "",
                    style: _textGreyStyle(),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      onPressed: () {
        FA.logAction('call_phone', 'click');
        try {
          Utils.callPhone(phone.number);
          FA.logAction('call_phone', 'status', message: 'succes');
        } catch (e) {
          FA.logAction('call_phone', 'status', message: 'error');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return _body();
  }

  Widget _body() {
    switch (state) {
      case _State.loading:
        return Container(
            child: CircularProgressIndicator(), alignment: Alignment.center);
      case _State.error:
      case _State.empty:
        return HintContent(
          icon: Icons.assignment,
          content: state == _State.error ? app.clickToRetry : app.busEmpty,
        );
      default:
        return ListView(
          children: phoneWeights,
        );
    }
  }

  _getPhones() async {
    phoneWeights.clear();
    state = _State.loading;
    setState(() {});
    phoneList.add(PhoneModel("校安中心\n分機號碼：建工1 楠梓2 第一3 燕巢4 旗津5", "0800-550995"));
    phoneList.add(PhoneModel("建工校區", ""));
    phoneList.add(PhoneModel("校安專線", "0916-507-506"));
    phoneList.add(PhoneModel("事務組", "(07) 381-4526 #2650"));
    phoneList.add(PhoneModel("營繕組", "(07) 381-4526 #2630"));
    phoneList.add(PhoneModel("課外活動組", "(07) 381-4526 #2525"));
    phoneList.add(PhoneModel("諮商輔導中心", "(07) 381-4526 #2541"));
    phoneList.add(PhoneModel("圖書館", "(07) 381-4526 #3100"));
    phoneList.add(PhoneModel("校外賃居服務中心", "(07) 381-4526 #3420"));
    phoneList.add(PhoneModel("燕巢校區", ""));
    phoneList.add(PhoneModel("校安專線", "0925-350-995"));
    phoneList.add(PhoneModel("校外賃居服務中心", "(07) 381-4526 #8615"));
    phoneList.add(PhoneModel("第一校區", ""));
    phoneList.add(PhoneModel("生輔組", "(07)601-1000 #31212"));
    phoneList.add(PhoneModel("總務處 總機", "(07)601-1000 #31316"));
    phoneList.add(PhoneModel("總務處 場地租借", "(07)601-1000 #31312"));
    phoneList.add(PhoneModel("總務處 高科大會館", "(07)601-1000 #31306"));
    phoneList.add(PhoneModel("總務處 學雜費相關(原事務組)", "(07)601-1000 #31340"));
    phoneList.add(PhoneModel("課外活動組", "(07)601-1000 #31211"));
    phoneList.add(PhoneModel("諮輔組", "(07)601-1000 #31241"));
    phoneList.add(PhoneModel("圖書館", "(07)6011000 #1599"));
    phoneList.add(PhoneModel("生輔組", "(07)6011000 #31212"));
    phoneList.add(PhoneModel("楠梓校區", ""));
    phoneList.add(PhoneModel("總機", "07-3617141"));
    phoneList.add(PhoneModel("課外活動組", "07-3617141 #22070"));
    phoneList.add(PhoneModel("旗津校區", ""));
    phoneList.add(PhoneModel("旗津校區", "07-8100888"));
    phoneList.add(PhoneModel("學生事務處", "07-3617141 #2052"));
    phoneList.add(PhoneModel("課外活動組", "07-8100888 #25065"));
    phoneList.add(PhoneModel("生活輔導組", "07-3617141 #23967"));
    for (var i in phoneList) {
      if (i.number.isEmpty) {
        phoneWeights.add(Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(
            i.name,
            style: _textBlueStyle(),
            textAlign: TextAlign.left,
          ),
        ));
      } else
        phoneWeights.add(_phoneItem(i));
    }
    state = _State.finish;
    setState(() {});
  }
}
