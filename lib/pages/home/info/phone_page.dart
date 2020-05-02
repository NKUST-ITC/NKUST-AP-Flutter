import 'package:ap_common/resources/ap_icon.dart';
import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/widgets/hint_content.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/utils/global.dart';

enum _State { loading, finish, error }

class PhonePage extends StatefulWidget {
  static const String routerName = "/info/phone";

  @override
  PhonePageState createState() => PhonePageState();
}

class PhonePageState extends State<PhonePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  _State state = _State.loading;

  AppLocalizations app;

  List<PhoneModel> phoneModelList = [];

  TextStyle get _textStyle => TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      );

  TextStyle get _textBlueStyle => TextStyle(
        color: ApTheme.of(context).blueText,
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      );

  TextStyle get _textGreyStyle => TextStyle(
        color: ApTheme.of(context).grey,
        fontSize: 14.0,
      );

  @override
  void initState() {
    FA.setCurrentScreen("PhonePage", "phone_page.dart");
    _getPhones();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    app = AppLocalizations.of(context);
    return _body();
  }

  Widget _body() {
    switch (state) {
      case _State.loading:
        return Center(
          child: CircularProgressIndicator(),
        );
      case _State.error:
        return HintContent(
          icon: ApIcon.assignment,
          content: app.clickToRetry,
        );
      default:
        return ListView.builder(
          itemCount: phoneModelList.length,
          itemBuilder: (context, index) {
            if (phoneModelList[index].number.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                child: Text(
                  phoneModelList[index].name,
                  style: _textBlueStyle,
                  textAlign: TextAlign.left,
                ),
              );
            } else
              return _phoneItem(phoneModelList[index]);
          },
        );
    }
  }

  Widget _phoneItem(PhoneModel phone) {
    return FlatButton(
      padding: EdgeInsets.all(0.0),
      child: Container(
        padding: EdgeInsets.all(16.0),
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey, width: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              phone.name ?? '',
              style: _textStyle,
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 8.0),
            Text(
              phone.number ?? '',
              style: _textGreyStyle,
              textAlign: TextAlign.left,
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

  _getPhones() async {
    setState(() {
      state = _State.loading;
    });
    phoneModelList
        .add(PhoneModel("校安中心\n分機號碼：建工1 楠梓2 第一3 燕巢4 旗津5", "0800-550995"));
    phoneModelList.add(PhoneModel("建工校區", ''));
    phoneModelList.add(PhoneModel("校安專線", "0916-507-506"));
    phoneModelList.add(PhoneModel("事務組", "(07) 381-4526 #2650"));
    phoneModelList.add(PhoneModel("營繕組", "(07) 381-4526 #2630"));
    phoneModelList.add(PhoneModel("課外活動組", "(07) 381-4526 #2525"));
    phoneModelList.add(PhoneModel("諮商輔導中心", "(07) 381-4526 #2541"));
    phoneModelList.add(PhoneModel("圖書館", "(07) 381-4526 #3100"));
    phoneModelList.add(PhoneModel("校外賃居服務中心", "(07) 381-4526 #3420"));
    phoneModelList.add(PhoneModel("燕巢校區", ''));
    phoneModelList.add(PhoneModel("校安專線", "0925-350-995"));
    phoneModelList.add(PhoneModel("校外賃居服務中心", "(07) 381-4526 #8615"));
    phoneModelList.add(PhoneModel("第一校區", ''));
    phoneModelList.add(PhoneModel("生輔組", "(07)601-1000 #31212"));
    phoneModelList.add(PhoneModel("總務處 總機", "(07)601-1000 #31316"));
    phoneModelList.add(PhoneModel("總務處 場地租借", "(07)601-1000 #31312"));
    phoneModelList.add(PhoneModel("總務處 高科大會館", "(07)601-1000 #31306"));
    phoneModelList.add(PhoneModel("總務處 學雜費相關(原事務組)", "(07)601-1000 #31340"));
    phoneModelList.add(PhoneModel("課外活動組", "(07)601-1000 #31211"));
    phoneModelList.add(PhoneModel("諮輔組", "(07)601-1000 #31241"));
    phoneModelList.add(PhoneModel("圖書館", "(07)6011000 #1599"));
    phoneModelList.add(PhoneModel("生輔組", "(07)6011000 #31212"));
    phoneModelList.add(PhoneModel("楠梓校區", ''));
    phoneModelList.add(PhoneModel("總機", "07-3617141"));
    phoneModelList.add(PhoneModel("課外活動組", "07-3617141 #22070"));
    phoneModelList.add(PhoneModel("旗津校區", ''));
    phoneModelList.add(PhoneModel("旗津校區", "07-8100888"));
    phoneModelList.add(PhoneModel("學生事務處", "07-3617141 #2052"));
    phoneModelList.add(PhoneModel("課外活動組", "07-8100888 #25065"));
    phoneModelList.add(PhoneModel("生活輔導組", "07-3617141 #23967"));
    setState(() {
      state = _State.finish;
    });
  }
}
