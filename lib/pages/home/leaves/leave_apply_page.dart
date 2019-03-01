import 'package:flutter/material.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/hint_content.dart';

enum _State { loading, finish, error, empty }

class LeaveApplyPageRoute extends MaterialPageRoute {
  LeaveApplyPageRoute()
      : super(builder: (BuildContext context) => new LeaveApplyPage());

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return new FadeTransition(opacity: animation, child: new LeaveApplyPage());
  }
}

class LeaveApplyPage extends StatefulWidget {
  static const String routerName = "/leaves/reservations";

  @override
  LeaveApplyPageState createState() => new LeaveApplyPageState();
}

class LeaveApplyPageState extends State<LeaveApplyPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  _State state = _State.empty;
  BusReservationsData busReservationsData;
  List<Widget> busReservationWeights = [];
  DateTime dateTime = DateTime.now();

  AppLocalizations app;

  @override
  void initState() {
    super.initState();
    FA.setCurrentScreen("LeaveApplyPage", "leave_apply_page.dart");
  }

  @override
  void dispose() {
    super.dispose();
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
        return FlatButton(
          onPressed: null,
          child: HintContent(
            icon: Icons.perm_identity,
            content: state == _State.error
                ? app.functionNotOpen
                : app.functionNotOpen,
          ),
        );
      default:
        return Container();
    }
  }
}
