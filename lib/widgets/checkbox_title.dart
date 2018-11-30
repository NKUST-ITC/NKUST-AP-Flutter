import 'package:flutter/material.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;

class CheckboxTitle extends StatelessWidget {
  final String title;
  final bool checkboxValue;
  final ValueChanged<bool> valueChanged;

  CheckboxTitle(this.title, this.checkboxValue, this.valueChanged);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Checkbox(
              activeColor: Colors.blue,
              value: this.checkboxValue,
              onChanged: (value) => valueChanged,
            ),
            Text(title)
          ],
        ),
        onTap: () => checkboxValue);
  }
}
