import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(Locale locale) {
    init(locale);
  }

  static init(Locale locale) {
    AppLocalizations.locale = locale;
  }

  static Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'NKUST AP',
      'update_note_title': 'Update Notes',
      'update_note_content': 'Welcome to NKUST AP\n'
          'This app backend comes from the backend application of KUAS AP\n'
          'In theory, it can only be used by Jan Gong and Yanchao Campus\n'
          'However, the recent school system data integration\n'
          'Students from other campuses are also welcome to try\n'
          'Welcome to contact the fans page if there is a problem with the use\n',
      'splash_content': '我們全都包了\n只剩下學校不包我們',
      'share': 'Share',
      'teacher_confirm_title': 'Are you a teacher?',
      'teacher_confirm_content': 'This App only for students!',
      'continue_to_use': 'Continue',
      'logout': 'Logout',
      'click_to_view': 'View',
      'login_success': 'Login success,\nclick menu to view.',
      'something_error': 'Error Occurred.',
      'timeout_message': 'Try again later, Connection Timeout',
      'login_first': 'Please login',
      'logout_check': 'Are you sure you want to log out?',
      'login': 'Login',
      'dot_ap': 'AP',
      'dot_leave': 'Leave',
      'dot_bus': 'Bus',
      'schedule': 'Events',
      'loading': 'Loading&#8230;',
      'id_hint': 'Student ID',
      'password_hint': 'Password',
      'remember_password': 'Remember',
      'auto_login': 'Auto login',
      'version': 'v.%s',
      'login_ing': 'Logging...',
      'call_phone_title': 'Call this number',
      'call_phone_content': 'Are you sure to call \"%s\"?',
      'call_phone': 'Call',
      'determine': 'Yes',
      'cancel': 'No',
      'add_cal_content': 'Are you sure to add \"%s\" to your calendar?',
      'click_to_retry': 'An error occurred, click to retry',
      'bus_pick_date': 'Chosen Date: %s',
      'bus_not_pick_date': 'Chosen Date',
      'bus_count" formatted="false': '(%s / %s)',
      'bus_jiangong_reservations': 'To YanChao, Scheduled date：',
      'bus_yanchao_reservations': 'To JianGong, Scheduled date：',
      'bus_jiangong': 'To YanChao, Departure time：',
      'bus_yanchao': 'To JianGong, Departure time：',
      'bus_jiangong_reserved': '√ To YanChao, Departure time：',
      'bus_yanchao_reserved': '√ To JianGong, Departure time：',
      'back': 'Back',
      'people': 'pl',
      'bus_reserve': 'Bus Reservation',
      'bus_reservations': 'Bus Record',
      'bus_cancel_reserve': 'Cancel Bus Reservation',
      'bus_reserve_confirm_title': 'Reserve this bus?',
      'bus_reserve_confirm_content" formatted="false':
          'Are you sure to reserve a seat from %s at %s ?',
      'bus_cancel_reserve_confirm_title': '<b>Cancel</b> this reservation?',
      'bus_cancel_reserve_confirm_content':
          'Are you sure to cancel a seat from %s at %s ?',
      'bus_cancel_reserve_confirm_content1':
          'Are you sure to cancel a seat from ',
      'bus_cancel_reserve_confirm_content2': ' to ',
      'bus_cancel_reserve_confirm_content3': ' ?',
      'bus_from_jiangong': 'JianGong to YanChao',
      'bus_from_yanchao': 'YanChao to JianGong',
      'bus_reserve_date': 'Date',
      'bus_reserve_location': 'Location',
      'bus_reserve_time': 'Time',
      'jiangong': 'JianGong',
      'yanchao': 'YanChao',
      'unknown': 'Unknown',
      'campus': ' campus',
      'reserve': 'Reserve',
      'reserved': 'Reserved',
      'can_not_reserve': 'Can\'t reserve',
      'special_bus': 'Special Bus',
      'trial_bus': 'Trial Bus',
      'bus_reserve_success': 'Successfully Reserved!',
      'bus_reserve_cancel_date': 'Date',
      'bus_reserve_cancel_location': 'Location',
      'bus_reserve_cancel_time': 'Time',
      'bus_cancel_reserve_success': 'Successfully Canceled!',
      'bus_cancel_reserve_fail': 'Fail Canceled',
      'bus_no_reservation':
          'Oops! You haven\'t reserved any bus~\n Ride public transport to save the Earth \uD83D\uDE0B',
      'bus_no_bus':
          'Oops! No bus today~\n Please choose another date \uD83D\uDE0B',
      'course_no_course':
          'Oops! No class for this semester~\n Please choose another semester \uD83D\uDE0B',
      'bus_reserve_fail_title': 'Oops Book Fail',
      'i_know': 'I know',
      'ok': 'OK',
      'course_dialog_messages" formatted="false':
          'Class：%s\nProfessor：%s\nLocation：%s\nTime：%s',
      'course_dialog_name': 'Class',
      'course_dialog_professor': 'Professor',
      'course_dialog_location': 'Location',
      'course_dialog_time': 'Time',
      'course_dialog_title': 'Class Info',
      'course_holiday': 'Rotate Screen to see weekend schedule %s',
      'no_internet': 'No internet connection',
      'setting_internet': 'Internet Settings',
      'score_no_score':
          'Oops! No record for this semester~\nPlease choose another semester \uD83D\uDE0B',
      'subject': 'Subject',
      'midterm': 'Midterm',
      'final': 'Final',
      'conduct_score': 'Conduct Score',
      'average': 'Average',
      'rank': 'You/Total Classmates',
      'percentage': 'Top % in Class',
      'leave_night':
          'Rotate screen to see night school absent record and day of week %s',
      'leave_no_leave':
          'Oops! No absent record for this semester~\nPlease choose another semester %s',
      'token_expired_title': 'Re-login Required',
      'token_expired_content': 'Cookie has expired, please re-login!',
      'update_content': 'Update available for KUAS AP!',
      'update_title': 'Updated',
      'update': 'Update',
      'function_not_open': 'Coming Soon~\nDonate to use this feature now!',
      'beta_function':
          'This is a beta version, please report a bug if an error occurred!',
      'bus_not_pick':
          'You have not chosen a date!\n Please choose a date first %s',
      'easter_egg_juke': 'This is not an easter egg',
      'skip': 'Skip',
      'share_to': 'Share to…',
      'send_from': 'Sent from KUAS AP Android',
      'donate_title': 'Donate',
      'donate_content': 'Help and support the programmer\nto use new features!',
      'donate_error':
          'Oops!Something went wrong :(\nGO to Google Play\n search for KUAS APDonate \n to support the author!',
      'bus_notify_hint':
          'Reminder will pop up 30 mins before reserved bus !\nIf you reserved or canceled the seat via website, please restart the app.',
      'bus_notify_content" formatted="false':
          'You\'ve got a bus departing at %s from %s!',
      'bus_notify_jiangong': 'JianGong',
      'bus_notify_yanchao': 'YanChao',
      'course_vibrate_hint':
          'Will turn on silent mode during class, turn back to normal mode after class!',
      'course_vibrate_permission': 'Need "Do Not Disturb access" to auto mute.',
      'course_notify_hint': 'Reminder will pop up 10mins before class starts!',
      'course_notify_content" formatted="false': 'Class %s will be at room %s!',
      'course_notify_unknown': 'Outerspace~',
      'calender_app_not_found': 'Can\'t found any calender apps.',
      'go_to_settings': 'Settings',
      'notifications': 'News',
      'phones': 'Tel no.',
      'events': 'Events',
      'education_system': 'Scheme',
      'department': 'Department',
      'student_class': 'Class',
      'student_id': 'Student ID',
      'student_name_cht': 'Name',
      'notification_item': 'Notification',
      'other_info': 'Other',
      'other_settings': 'Settings',
      'head_photo_setting': 'Show Photo',
      'course_notify': 'Class Reminder',
      'course_vibrate': 'Silent Mode During Class',
      'bus_notify': 'Bus Reservation Reminder',
      'feedback': 'Suggestions',
      'feedback_via_facebook': 'Message to Facebook Page',
      'app_version': 'App Version',
      'about_detail':
          'The best KUAS Campus App\nKUAS AP\n\nAre you afreshman?\nDon\'t know about school info, telephone numbers, or up coming events?\nBeenhere a few years?\nHave checking class schedule, report card and reserving bus seatsdrove you crazy?\n\nNo more, no more worries, anymore!\n\nKUAS AP lets no matter old or newfellow\nhave control over your life in KUAS!\n\nFrom checking class schedule, report card toyour absence records!\nPlus reserving/canceling bus seats with newest school feeds!\n\n\n\nMuch Simple, Many Convenient, Very instinct, wow!\n\n☆FABULOUS☆',
      'about_author_title': 'Made by',
      'about_author_content':
          '呂紹榕(Louie Lu), 姜尚德(JohnThunder), \nregisterAutumn, 詹濬鍵(Evans), \n陳建霖(HearSilent)',
      'about_us':
          '“Ask not why nobody is doing this. You are \'nobody\'.”\n\nWe did this cause no one did it.\nWe created KUAS Wifi Login, KUASAP and KUAS Gourmet, Course Selection Sim, etc&#8230;\nTo bring convenience to everyone\'s on campus!',
      'about_recruit_title': 'We Need You !',
      'about_recruit_content':
          'If you\'re experienced in Objective-C, Swift, Java or you\'re interested in Coding!\n\nMessage us at our Facebook fanpage!\nYour code might one day be operating in everyone\'s hands~',
      'about_itc_content':
          'In year 2014,\nwe founded KUAS Information Technology Club!\n\nIf you\'re enthusiastic or drawn to our projects, join our classes and talks or come by to chat!',
      'about_itc_title': 'KUAS IT Club',
      'about_contact_us': 'Contact Us',
      'about_open_source_title': 'Open Source License',
      'about_open_source_content':
          'https://github.com/abc873693/NKUST-AP-Flutter\n\nThis project is licensed under the terms of the MIT license:\nThe MIT License (MIT)\n\nCopyright &#169; 2018 Rainvisitor\n\nThis project is Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.',
      'open_drawer': 'Open Menu',
      'close_drawer': 'Close Menu',
      'news': 'News',
      'offline_course': 'Offline Class Schedule',
      'course': 'Class Schedule',
      'score': 'Report Card',
      'leave': 'Absent System',
      'bus': 'Bus Reservation',
      'simcourse': 'Course Selection Sim',
      'school_info': 'School Info',
      'user': 'Personal Info',
      'about': 'About Us',
      'settings': 'Settings',
      'guest': 'Guest',
      'tap_here_to_login': 'Tap to Login',
      'pick_semester': 'Choose Semester',
      'enter_username_hint': 'Please enter your ID',
      'enter_password_hint': 'Please enter your password',
      'check_login_hint': 'Check your username and password then retry',
      'from_jiangong': 'From JianGong',
      'from_yanchao': 'From YanChao',
      'lorem_title': 'Lorem ipsum',
      'lorem_sentence': 'Lorem ipsum dolor sit amet.',
      'lorem_paragraph':
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
      'lorem_number': '123',
      'lorem_date': '2015&#8211;09&#8211;06',
      'lorem_time': '09:20',
      'lorem_bus_count': '(1 / 999)',
      'lorem_phone': '(01) 234&#8211;5678',
      'lorem_semester': '104學年度第1學期',
      'mon': 'Mon.',
      'tue': 'Tue.',
      'wed': 'Wed.',
      'thu': 'Thu.',
      'fri': 'Fri.',
      'sat': 'Sat.',
      'sun': 'Sun.',
      'do_not_empty': 'Don\'t Empty',
      'login_fail': 'student id or password error',
      'bus_fail_infinity': 'Bus system perhaps broken!!!',
      'reserving': 'Reserving...',
      'canceling': 'Canceling...',
    },
    'zh': {
      'app_name': '高科校務通',
      'update_note_title': '更新日誌',
      'update_note_content':
          '\n歡迎使用高科校務通\n本APP後端來自於高應校務通的後端應用\n理論上僅可供建工與燕巢校區使用\n但近期校務系統資料陸續整合\n也歡迎其他校區的同學嘗試使用\n有任何問題歡迎私密粉專\n高科校務通作者敬上',
      'splash_content': '我們全都包了\n只剩下學校不包我們',
      'share': '分享',
      'teacher_confirm_title': '您是老師嗎？',
      'teacher_confirm_content': '本 App 僅有學生功能！',
      'continue_to_use': '繼續使用',
      'logout': '登出',
      'click_to_view': '立即前往',
      'login_success': '成功登入高科大校務系統\n點擊左側選單，開始瀏覽',
      'something_error': '發生錯誤',
      'timeout_message': '連線逾時，請稍候再試',
      'login_first': '請先登入',
      'logout_check': '是否要登出？',
      'login': '登入',
      'dot_ap': '校務',
      'dot_leave': '缺曠',
      'dot_bus': '校車',
      'schedule': '行事曆',
      'loading': 'Loading&#8230;',
      'id_hint': '學號',
      'password_hint': '密碼',
      'remember_password': '記住密碼',
      'auto_login': '自動登入',
      'version': 'v.%s',
      'login_ing': '登入中...',
      'call_phone_title': '撥出電話',
      'call_phone_content': '確定要撥給「%s」？',
      'call_phone': '撥出',
      'determine': '確定',
      'cancel': '取消',
      'add_cal_content': '確定要將「%s」新增至行事曆？',
      'click_to_retry': '發生錯誤，點擊重試',
      'bus_pick_date': '選擇乘車時間：%s',
      'bus_not_pick_date': '選擇乘車時間',
      'bus_count': '(%s / %s)',
      'bus_jiangong_reservations': '到燕巢，發車日期：',
      'bus_yanchao_reservations': '到建工，發車日期：',
      'bus_jiangong': '到燕巢，發車：',
      'bus_yanchao': '到建工，發車：',
      'bus_jiangong_reserved': '√ 到燕巢，發車：',
      'bus_yanchao_reserved': '√ 到建工，發車：',
      'back': '返回',
      'people': '人',
      'bus_reserve': '預定校車',
      'bus_reservations': '校車紀錄',
      'bus_cancel_reserve': '取消預定校車',
      'bus_reserve_confirm_title': '確定要預定本次校車？',
      'bus_reserve_confirm_content': '要預定從%s\n%s 的校車嗎？',
      'bus_cancel_reserve_confirm_title': '確定要<b>取消</b>本校車車次？',
      'bus_cancel_reserve_confirm_content': '要取消從%s\n%s 的校車嗎？',
      'bus_cancel_reserve_confirm_content1': '要取消從',
      'bus_cancel_reserve_confirm_content2': '到',
      'bus_cancel_reserve_confirm_content3': '的校車嗎？',
      'bus_from_jiangong': '建工到燕巢',
      'bus_from_yanchao': '燕巢到建工',
      'reserve': '預約',
      'bus_reserve_date': '預約日期',
      'bus_reserve_location': '上車地點',
      'bus_reserve_time': '預約班次',
      'jiangong': '建工',
      'yanchao': '燕巢',
      'unknown': '未知',
      'campus': '校區',
      'reserved': '已預約',
      'can_not_reserve': '無法預約',
      'special_bus': '特殊班次',
      'trial_bus': '試辦車次',
      'bus_reserve_success': '預約成功！',
      'bus_reserve_cancel_date': '取消日期',
      'bus_reserve_cancel_location': '上車地點',
      'bus_reserve_cancel_time': '取消班次',
      'bus_cancel_reserve_success': '取消預約成功！',
      'bus_cancel_reserve_fail': '取消預約失敗',
      'bus_no_reservation': 'Oops！您還沒有預約任何校車喔～\n多多搭乘大眾運輸，節能減碳救地球 \uD83D\uDE0B',
      'bus_reserve_fail_title': 'Oops 預約失敗',
      'i_know': '我知道了',
      'bus_no_bus': 'Oops！本日校車沒上班喔～\n請選擇其他日期 \uD83D\uDE0B',
      'course_no_course': 'Oops！本學期沒有任何課哦～\n請選擇其他學期 \uD83D\uDE0B',
      'ok': '好',
      'course_dialog_messages': '課程名稱：%s\n授課老師：%s\n教室位置：%s\n上課時間：%s',
      'course_dialog_name': '課程名稱',
      'course_dialog_professor': '授課老師',
      'course_dialog_location': '教室位置',
      'course_dialog_time': '上課時間',
      'course_dialog_title': '課程資訊',
      'course_holiday': '旋轉橫向即可查看周末課表 %s',
      'no_internet': '沒有網路連線，請檢查你的網路',
      'setting_internet': '設定網路',
      'score_no_score': 'Oops！本學期沒有任何成績資料哦～\n請選擇其他學期 \uD83D\uDE0B',
      'subject': '科目',
      'midterm': '期中成績',
      'final': '學期成績',
      'conduct_score': '操行成績',
      'average': '總平均',
      'rank': '班名次/班人數',
      'percentage': '班名次百分比',
      'leave_night': '旋轉橫向即可查看夜間缺曠以及星期幾 %s',
      'leave_no_leave': 'Oops！本學期沒有任何缺曠課紀錄哦～\n請選擇其他學期 %s',
      'token_expired_title': '重新登入',
      'token_expired_content': '登入資訊過期，請重新登入！',
      'update_content': '高科校務通 在 Google Play 有新版本喲！',
      'update_title': '版本更新',
      'update': '更新',
      'function_not_open': '功能尚未開放\n私密粉絲團 小編會告訴你何時開放！',
      'beta_function': '此功能為測試版本，如有問題請立即回報！',
      'bus_not_pick': '您尚未選擇日期！\n請先選擇日期 %s',
      'easter_egg_juke': '這不是彩蛋',
      'skip': '稍後再說',
      'share_to': '分享至…',
      'send_from': 'Send from 高科校務通 Android',
      'donate_title': 'Donate',
      'donate_content': '貢獻一點心力支持作者，\n可以提早使用未開放功能！',
      'donate_error':
          '哎呀！發生了點錯誤 :(\n不過沒關係到 Google Play\n搜尋「高科校務通Donate」\n一樣可以支持喔！',
      'bus_notify_hint': '校車預約將於發車前三十分鐘提醒！\n若在網頁預約或取消校車請重登入此App。',
      'bus_notify_content': '親，您有一班 %s 從%s出發的校車！',
      'bus_notify_jiangong': '建工',
      'bus_notify_yanchao': '燕巢',
      'course_vibrate_hint': '將於上課時轉為震動，下課時恢復！',
      'course_vibrate_permission': '需要「零打擾存取權」方能自動轉為震動。',
      'course_notify_hint': '將於上課前十分鐘提醒！',
      'course_notify_content': '親，%s 上課教室在 %s！',
      'course_notify_unknown': '外太空',
      'calender_app_not_found': '找不到支援的行事曆 Apps',
      'go_to_settings': '前往設定',
      'education_system': '學制',
      'department': '科系',
      'student_class': '班級',
      'student_id': '學號',
      'student_name_cht': '姓名',
      'notification_item': '通知項目',
      'other_info': '其他資訊',
      'other_settings': '其他設定',
      'head_photo_setting': '顯示大頭貼',
      'course_notify': '上課提醒',
      'course_vibrate': '上課震動',
      'bus_notify': '校車提醒',
      'feedback': '回饋意見',
      'feedback_via_facebook': '私訊給粉絲專頁',
      'app_version': 'App 版本',
      'about_author_title': '作者群',
      'about_author_content':
          '呂紹榕(Louie Lu), 姜尚德(JohnThunder), \nregisterAutumn, 詹濬鍵(Evans), \n陳建霖(HearSilent)',
      'about_us':
          '「不要問為何沒有人做這個，\n先承認你就是『沒有人』」。\n因為，「沒有人」是萬能的。\n\n因為沒有人做這些，所以我們跳下來做。\n先後完成了高應無線通、高應校務通，到後來的高應美食通、模擬選課等等.......\n無非是希望帶給大家更便利的校園生活！',
      'about_recruit_title': 'We Need You !',
      'about_recruit_content':
          '如果你是 Objective-C、Swift 高手，或是 Java 神手，又或是對 Coding充滿著熱誠！\n\n歡迎私訊我們粉絲專頁！\n你的程式碼將有機會出現在周遭同學的手中～',
      'about_itc_content':
          '在103學年度，\n我們也成立了高應大資訊研習社！\n\n如果你對資訊有熱誠或是對我們作品有興趣，歡迎來社課或是講座，也可以來找我們聊聊天。',
      'about_itc_title': '高科資研社',
      'about_contact_us': '聯繫我們',
      'about_open_source_title': '開放原始碼授權',
      'about_open_source_content':
          'https://github.com/abc873693/NKUST-AP-Flutter\n\n本專案採MIT 開放原始碼授權：\nThe MIT License (MIT)\n\nCopyright &#169; 2018 Rainvisitor\n\nThis project is Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.',
      'open_drawer': '打開功能表',
      'close_drawer': '關閉功能表',
      'news': '最新消息',
      'offline_course': '離線課表',
      'course': '學期課表',
      'score': '學期成績',
      'leave': '缺曠系統',
      'bus': '校車系統',
      'simcourse': '模擬選課',
      'school_info': '校園資訊',
      'notifications': '最新消息',
      'phones': '常用電話',
      'events': '行事曆',
      'user': '個人資訊',
      'about': '關於我們',
      'settings': '設定',
      'guest': '訪客',
      'tap_here_to_login': '點擊登入',
      'pick_semester': '選擇學期',
      'enter_username_hint': '請輸入帳號',
      'enter_password_hint': '請輸入密碼',
      'check_login_hint': '請檢查帳號密碼',
      'from_jiangong': '建工上車',
      'from_yanchao': '燕巢上車',
      'lorem_title': 'Lorem ipsum',
      'lorem_sentence': 'Lorem ipsum dolor sit amet.',
      'lorem_paragraph':
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
      'lorem_number': '123',
      'lorem_date': '2015&#8211;09&#8211;06',
      'lorem_time': '09:20',
      'lorem_bus_count': '(1 / 999)',
      'lorem_phone': '(01) 234&#8211;5678',
      'lorem_semester': '104學年度第1學期',
      'mon': ' 一 ',
      'tue': ' 二 ',
      'wed': ' 三 ',
      'thu': ' 四 ',
      'fri': ' 五 ',
      'sat': ' 六 ',
      'sun': ' 日 ',
      'do_not_empty': '請勿留空',
      'login_fail': '帳號或密碼錯誤',
      'bus_fail_infinity': '學校校車系統或許壞掉惹～',
      'reserving': '預約中...',
      'canceling': '取消中...',
    },
  };

  Map get _vocabularies {
    return _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  }

  Map get messages => {
        0: notifications,
        1: phones,
        2: events,
      };

  List<String> get weekdays => [
        mon,
        tue,
        wed,
        thu,
        fri,
        sat,
        sun,
      ];

  List<String> get busSegment => [
        fromJiangong,
        fromYanchao,
      ];

  String get appName => _vocabularies['app_name'];

  String get updateNoteTitle => _vocabularies['update_note_title'];

  String get updateNoteContent => _vocabularies['update_note_content'];

  String get ok => _vocabularies['ok'];

  String get somethingError => _vocabularies['something_error'];

  String get username => _vocabularies['id_hint'];

  String get password => _vocabularies['password_hint'];

  String get remember => _vocabularies['remember_password'];

  String get login => _vocabularies['login'];

  String get doNotEmpty => _vocabularies['do_not_empty'];

  String get loginFail => _vocabularies['login_fail'];

  String get bus => _vocabularies['bus'];

  String get course => _vocabularies['course'];

  String get score => _vocabularies['score'];

  String get logining => _vocabularies['login_ing'];

  String get schoolInfo => _vocabularies['school_info'];

  String get about => _vocabularies['about'];

  String get settings => _vocabularies['settings'];

  String get notifications => _vocabularies['notifications'];

  String get phones => _vocabularies['phones'];

  String get events => _vocabularies['events'];

  String get clickToRetry => _vocabularies['click_to_retry'];

  String get aboutAuthorTitle => _vocabularies['about_author_title'];

  String get aboutAuthorContent => _vocabularies['about_author_content'];

  String get aboutUsContent => _vocabularies['about_us'];

  String get aboutRecruitTitle => _vocabularies['about_recruit_title'];

  String get aboutRecruitContent => _vocabularies['about_recruit_content'];

  String get aboutItcTitle => _vocabularies['about_itc_title'];

  String get aboutItcContent => _vocabularies['about_itc_content'];

  String get aboutContactUsTitle => _vocabularies['about_contact_us'];

  String get aboutOpenSourceTitle => _vocabularies['about_open_source_title'];

  String get aboutOpenSourceContent =>
      _vocabularies['about_open_source_content'];

  String get back => _vocabularies['back'];

  String get people => _vocabularies['people'];

  String get busReserve => _vocabularies['bus_reserve'];

  String get busReservations => _vocabularies['bus_reservations'];

  String get determine => _vocabularies['determine'];

  String get jiangong => _vocabularies['jiangong'];

  String get yanchao => _vocabularies['yanchao'];

  String get unknown => _vocabularies['unknown'];

  String get campus => _vocabularies['campus'];

  String get reserve => _vocabularies['reserve'];

  String get reserved => _vocabularies['reserved'];

  String get canNotReserve => _vocabularies['can_not_reserve'];

  String get specialBus => _vocabularies['special_bus'];

  String get trialBus => _vocabularies['trial_bus'];

  String get cancel => _vocabularies['cancel'];

  String get busReserveSuccess => _vocabularies['bus_reserve_success'];

  String get busCancelReserve => _vocabularies['bus_cancel_reserve'];

  String get busCancelReserveSuccess =>
      _vocabularies['bus_cancel_reserve_success'];

  String get busCancelReserveFail => _vocabularies['bus_cancel_reserve_fail'];

  String get busReservationEmpty => _vocabularies['bus_no_reservation'];

  String get busEmpty => _vocabularies['bus_no_bus'];

  String get busReserveConfirmTitle =>
      _vocabularies['bus_reserve_confirm_title'];

  String get busReserveFailTitle => _vocabularies['bus_reserve_fail_title'];

  String get busReserveDate => _vocabularies['bus_reserve_date'];

  String get busReserveLocation => _vocabularies['bus_reserve_location'];

  String get busReserveTime => _vocabularies['bus_reserve_time'];

  String get iKnow => _vocabularies['i_know'];

  String get busCancelReserveConfirmContent1 =>
      _vocabularies['bus_cancel_reserve_confirm_content1'];

  String get busCancelReserveConfirmContent2 =>
      _vocabularies['bus_cancel_reserve_confirm_content2'];

  String get busCancelReserveConfirmContent3 =>
      _vocabularies['bus_cancel_reserve_confirm_content3'];

  String get busReserveCancelDate => _vocabularies['bus_reserve_cancel_date'];

  String get busReserveCancelLocation =>
      _vocabularies['bus_reserve_cancel_location'];

  String get busReserveCancelTime => _vocabularies['bus_reserve_cancel_time'];

  String get courseEmpty => _vocabularies['course_no_course'];

  String get picksSemester => _vocabularies['pick_semester'];

  String get courseDialogName => _vocabularies['course_dialog_name'];

  String get courseDialogProfessor => _vocabularies['course_dialog_professor'];

  String get courseDialogLocation => _vocabularies['course_dialog_location'];

  String get courseDialogTime => _vocabularies['course_dialog_time'];

  String get courseDialogTitle => _vocabularies['course_dialog_title'];

  String get mon => _vocabularies['mon'];

  String get tue => _vocabularies['tue'];

  String get wed => _vocabularies['wed'];

  String get thu => _vocabularies['thu'];

  String get fri => _vocabularies['fri'];

  String get sat => _vocabularies['sat'];

  String get sun => _vocabularies['sun'];

  String get fromJiangong => _vocabularies['from_jiangong'];

  String get fromYanchao => _vocabularies['from_yanchao'];

  String get scoreEmpty => _vocabularies['score_no_score'];

  String get subject => _vocabularies['subject'];

  String get midtermScore => _vocabularies['midterm'];

  String get finalScore => _vocabularies['final'];

  String get conductScore => _vocabularies['conduct_score'];

  String get average => _vocabularies['average'];

  String get rank => _vocabularies['rank'];

  String get percentage => _vocabularies['percentage'];

  String get educationSystem => _vocabularies['education_system'];

  String get department => _vocabularies['department'];

  String get studentClass => _vocabularies['student_class'];

  String get studentId => _vocabularies['student_id'];

  String get studentNameCht => _vocabularies['student_name_cht'];

  String get notificationItem => _vocabularies['notification_item'];

  String get otherInfo => _vocabularies['other_info'];

  String get otherSettings => _vocabularies['other_settings'];

  String get headPhotoSetting => _vocabularies['head_photo_setting'];

  String get courseNotify => _vocabularies['course_notify'];

  String get courseVibrate => _vocabularies['course_vibrate'];

  String get busNotify => _vocabularies['bus_notify'];

  String get feedback => _vocabularies['feedback'];

  String get feedbackViaFacebook => _vocabularies['feedback_via_facebook'];

  String get donateTitle => _vocabularies['donate_title'];

  String get donateContent => _vocabularies['donate_content'];

  String get donateError => _vocabularies['donate_error'];

  String get appVersion => _vocabularies['app_version'];

  String get updateContent => _vocabularies['update_content'];

  String get updateTitle => _vocabularies['update_title'];

  String get update => _vocabularies['update'];

  String get functionNotOpen => _vocabularies['function_not_open'];

  String get betaFunction => _vocabularies['beta_function'];

  String get easterEggJuke => _vocabularies['easter_egg_juke'];

  String get skip => _vocabularies['skip'];

  String get shareTo => _vocabularies['share_to'];

  String get sendFrom => _vocabularies['send_from'];

  String get timeoutMessage => _vocabularies['timeout_message'];

  String get noInternet => _vocabularies['no_internet'];

  String get tokenExpiredTitle => _vocabularies['token_expired_title'];

  String get tokenExpiredContent => _vocabularies['token_expired_content'];

  String get busFailInfinity => _vocabularies['bus_fail_infinity'];

  String get reserving => _vocabularies['reserving'];

  String get canceling => _vocabularies['canceling'];
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = new AppLocalizations(locale);

    print('Load ${locale.languageCode}');

    return localizations;
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
