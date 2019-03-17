import 'package:flutter/material.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/global.dart';

class BusRulePageRoute extends MaterialPageRoute {
  BusRulePageRoute()
      : super(builder: (BuildContext context) => new BusRulePage());

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return new FadeTransition(opacity: animation, child: new BusRulePage());
  }
}

class BusRulePage extends StatefulWidget {
  static const String routerName = "/bus/rule";

  BusRulePage();

  @override
  BusRulePageState createState() => new BusRulePageState();
}

class BusRulePageState extends State<BusRulePage>
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
    ;
    return new Scaffold(
      appBar: AppBar(
        title: Text(app.busRule),
        backgroundColor: Resource.Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: RichText(
          textAlign: TextAlign.left,
          text: TextSpan(
              style: TextStyle(
                  color: Resource.Colors.grey, height: 1.3, fontSize: 16.0),
              children: [
                TextSpan(
                  text: '預約校車\n',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
                ),
                TextSpan(
                  text: "• 請上 http://bus.kuas.edu.tw/ 校車預約系統預約校車\n" +
                      "• 可預約14天以內的校車班次\n" +
                      "• 為配合總務處派車需求預約時間\n",
                ),
                TextSpan(
                  text: '■ 9點以前的班次：請於發車前15個小時預約\n'
                      '■ 9點以後的班次：請於發車前5個小時預約\n',
                  style: TextStyle(color: Resource.Colors.red),
                ),
                TextSpan(
                  text: '• 取消預約時間\n',
                ),
                TextSpan(
                  text: '■ 9點以前的班次：請於發車前15個小時預約\n'
                      '■ 9點以後的班次：請於發車前5個小時預約\n',
                  style: TextStyle(color: Resource.Colors.red),
                ),
                TextSpan(
                  text: "• 請全校師生及職員依規定預約校車，若因未預約校車而無法到課或上班者，請自行負責\n",
                ),
                TextSpan(
                  text: '上車\n',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
                ),
                TextSpan(
                  text: "• 每次上車繳款20元",
                ),
                TextSpan(
                  text: '（未發卡前先以投幣繳費，請自備20元銅板投幣）\n',
                  style: TextStyle(color: Resource.Colors.blue),
                ),
                TextSpan(
                  text: "• 請持學生證或教職員證(未發卡前先採用身分證識別)上車\n",
                ),
                TextSpan(
                  text: '• 未攜帶證件者請排後補區\n',
                  style: TextStyle(
                      color: Resource.Colors.red, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      "• 請依預約的班次時間搭乘(例如：8:20與9:30視為不同班次），未依規定者不得上車，並計違規點數一點\n",
                  style: TextStyle(color: Resource.Colors.red),
                ),
                TextSpan(
                  text: "• 逾時或未預約搭乘者請至候補車道排隊候補上車。\n" +
                      "候補上車\n" +
                      "• 在正常車道上車時未通過驗證者(ex.未預約該班次)，請改至候補車道排隊候補上車。\n" +
                      "• 候補者需等待預約該班次的人全部上車之後才依序遞補上車\n",
                ),
                TextSpan(
                  text: '候補上車\n',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
                ),
                TextSpan(
                  text: "• 未依預約的班次搭乘者，視為違規，計違規點數一次(例如：8:20與9:30視為不同班次）\n" +
                      "• 因教師臨時請假、臨時調課致使需提前或延後搭車，得向開課系所提出申請，並由系所之交通車系統管理者註銷違規紀錄。\n",
                ),
                TextSpan(
                  text: '罰款\n',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Resource.Colors.red,
                      fontSize: 24.0),
                ),
                TextSpan(
                  text: "• 違規罰款金額計算，違規前三次不計點，從第四次開始違規記點，每點應繳納等同車資之罰款\n" +
                      "• 違規點數統計至學期末為止(上學期學期末1/31，下學期8/31)，新學期違規點數重新計算。當學期罰款未繳清者，次學期停止預約權限至罰款繳清為止\n" +
                      "• 罰款請自行列印違規明細後至自動繳費機或總務處出納組繳費，繳費後憑收據至總務處事務組銷帳(當天開列之收據須於當天銷帳)，銷帳完後隔天凌晨4點後才可預約當天9點後的校車。\n" +
                      "• 罰款點數如有疑義，請於違規發生日起10日內(含星期例假日)逕向總務處事務組確認。\n",
                  style: TextStyle(color: Resource.Colors.red),
                ),
              ]),
        ),
      ),
    );
  }
}
