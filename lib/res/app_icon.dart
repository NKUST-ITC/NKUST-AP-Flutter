import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class AppIcon {
  static const String FILLED = 'filled';
  static const String OUTLINED = 'outlined';

  static String code = AppIcon.OUTLINED;

  static IconData get directionsBus {
    switch (AppIcon.code) {
      case AppIcon.FILLED:
        return Icons.directions_bus;
      case AppIcon.OUTLINED:
      default:
        return OMIcons.directionsBus;
    }
  }

  static IconData get classIcon {
    switch (AppIcon.code) {
      case AppIcon.FILLED:
        return Icons.class_;
      case AppIcon.OUTLINED:
      default:
        return OMIcons.classIcon;
    }
  }

  static IconData get assignment {
    switch (AppIcon.code) {
      case AppIcon.FILLED:
        return Icons.assignment;
      case AppIcon.OUTLINED:
      default:
        return OMIcons.assignment;
    }
  }

  static IconData get accountCircle {
    switch (AppIcon.code) {
      case AppIcon.FILLED:
        return Icons.account_circle;
      case AppIcon.OUTLINED:
      default:
        return OMIcons.accountCircle;
    }
  }

  static IconData get school {
    switch (AppIcon.code) {
      case AppIcon.FILLED:
        return Icons.school;
      case AppIcon.OUTLINED:
      default:
        return OMIcons.school;
    }
  }

  static IconData get apps {
    switch (AppIcon.code) {
      case AppIcon.FILLED:
        return Icons.apps;
      case AppIcon.OUTLINED:
      default:
        return OMIcons.apps;
    }
  }

  static IconData get calendarToday {
    switch (AppIcon.code) {
      case AppIcon.FILLED:
        return Icons.calendar_today;
      case AppIcon.OUTLINED:
      default:
        return OMIcons.calendarToday;
    }
  }

  static get edit {
    switch (AppIcon.code) {
      case AppIcon.FILLED:
        return Icons.edit;
      case AppIcon.OUTLINED:
      default:
        return OMIcons.edit;
    }
  }

  static get dateRange {
    switch (AppIcon.code) {
      case AppIcon.FILLED:
        return Icons.date_range;
      case AppIcon.OUTLINED:
      default:
        return OMIcons.dateRange;
    }
  }

  static get info {
    switch (AppIcon.code) {
      case AppIcon.FILLED:
        return Icons.info;
      case AppIcon.OUTLINED:
      default:
        return OMIcons.info;
    }
  }

  static get face {
    switch (AppIcon.code) {
      case AppIcon.FILLED:
        return Icons.face;
      case AppIcon.OUTLINED:
      default:
        return OMIcons.face;
    }
  }

  static get settings {
    switch (AppIcon.code) {
      case AppIcon.FILLED:
        return Icons.settings;
      case AppIcon.OUTLINED:
      default:
        return OMIcons.settings;
    }
  }

  static IconData get powerSettingsNew {
    switch (AppIcon.code) {
      case AppIcon.FILLED:
        return Icons.power_settings_new;
      case AppIcon.OUTLINED:
      default:
        return OMIcons.powerSettingsNew;
    }
  }

  static get permIdentity {
    switch (AppIcon.code) {
      case AppIcon.FILLED:
        return Icons.perm_identity;
      case AppIcon.OUTLINED:
      default:
        return OMIcons.permIdentity;
    }
  }

  static IconData get accessTime {
    switch (AppIcon.code) {
      case AppIcon.FILLED:
        return Icons.access_time;
      case AppIcon.OUTLINED:
      default:
        return OMIcons.accessTime;
    }
  }

  static IconData get keyboardArrowDown {
    switch (AppIcon.code) {
      case AppIcon.FILLED:
        return Icons.keyboard_arrow_down;
      case AppIcon.OUTLINED:
      default:
        return OMIcons.keyboardArrowDown;
    }
  }

  static get offlineBolt {
    switch (AppIcon.code) {
      case AppIcon.FILLED:
        return Icons.offline_bolt;
      case AppIcon.OUTLINED:
      default:
        return OMIcons.offlineBolt;
    }
  }

  static IconData get error {
    switch (AppIcon.code) {
      case AppIcon.FILLED:
        return Icons.error;
      case AppIcon.OUTLINED:
      default:
        return OMIcons.error;
    }
  }

  static IconData get fiberNew {
    switch (AppIcon.code) {
      case AppIcon.FILLED:
        return Icons.fiber_new;
      case AppIcon.OUTLINED:
      default:
        return OMIcons.fiberNew;
    }
  }

  static IconData get phone {
    switch (AppIcon.code) {
      case AppIcon.FILLED:
        return Icons.phone;
      case AppIcon.OUTLINED:
      default:
        return OMIcons.phone;
    }
  }

  static IconData get codeIcon {
    switch (AppIcon.code) {
      case AppIcon.FILLED:
        return Icons.code;
      case AppIcon.OUTLINED:
      default:
        return OMIcons.code;
    }
  }

  static IconData get cancel {
    switch (AppIcon.code) {
      case AppIcon.FILLED:
        return Icons.cancel;
      case AppIcon.OUTLINED:
      default:
        return OMIcons.cancel;
    }
  }

  static IconData get check {
    switch (AppIcon.code) {
      case AppIcon.FILLED:
        return Icons.check;
      case AppIcon.OUTLINED:
      default:
        return OMIcons.check;
    }
  }

  static IconData get arrowDropUp {
    switch (AppIcon.code) {
      case AppIcon.FILLED:
        return Icons.arrow_drop_up;
      case AppIcon.OUTLINED:
      default:
        return OMIcons.arrowDropUp;
    }
  }

  static IconData get arrowDropDown {
    switch (AppIcon.code) {
      case AppIcon.FILLED:
        return Icons.arrow_drop_down;
      case AppIcon.OUTLINED:
      default:
        return OMIcons.arrowDropDown;
    }
  }

  static IconData get chevronLeft {
    switch (AppIcon.code) {
      case AppIcon.FILLED:
        return Icons.chevron_left;
      case AppIcon.OUTLINED:
      default:
        return OMIcons.chevronLeft;
    }
  }

  static IconData get chevronRight {
    switch (AppIcon.code) {
      case AppIcon.FILLED:
        return Icons.chevron_right;
      case AppIcon.OUTLINED:
      default:
        return OMIcons.chevronRight;
    }
  }

  static IconData get person {
    switch (AppIcon.code) {
      case AppIcon.FILLED:
        return Icons.person;
      case AppIcon.OUTLINED:
      default:
        return OMIcons.person;
    }
  }

  static IconData get exitToApp {
    switch (AppIcon.code) {
      case AppIcon.FILLED:
        return Icons.exit_to_app;
      case AppIcon.OUTLINED:
      default:
        return OMIcons.exitToApp;
    }
  }

  static IconData get warning {
    switch (AppIcon.code) {
      case AppIcon.FILLED:
        return Icons.warning;
      case AppIcon.OUTLINED:
      default:
        return OMIcons.warning;
    }
  }

  static IconData get folder {
    switch (AppIcon.code) {
      case AppIcon.FILLED:
        return Icons.folder;
      case AppIcon.OUTLINED:
      default:
        return OMIcons.folder;
    }
  }
}
