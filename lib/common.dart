export 'package:sqflite/sqflite.dart';
export 'dart:async';

export 'package:flutter/material.dart';
export 'package:http/http.dart';
export 'package:html/parser.dart' show parse;
export 'package:panovel_app/utils/Tools.dart';
export 'package:panovel_app/utils/MyCustomRoute.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';

EventBus eventBus = new EventBus();

ThemeData buildTheme(Brightness brightness) {
  return brightness == Brightness.dark
      ? ThemeData.dark().copyWith(
          textTheme: ThemeData.dark().textTheme.apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
                fontFamily: 'Basier',
              ),
          backgroundColor: Colors.black)
      : ThemeData.light().copyWith(
          textTheme: ThemeData.light().textTheme.apply(
                bodyColor: Colors.black,
                displayColor: Colors.black,
                fontFamily: 'Basier',
              ),
          backgroundColor: Colors.white,
          primaryColor: Colors.green);
}

void changeBrightness(context) {
  DynamicTheme.of(context).setBrightness(
      Theme.of(context).brightness == Brightness.dark ? Brightness.light : Brightness.dark);
}
