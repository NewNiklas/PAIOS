import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class Dictionary {
  List languages = [];
  bool systemLanguage = false;
  Map dictionary = {};
  String locale = "en";

  Dictionary._internal();
  factory Dictionary(){
    return Dictionary._internal();
  }

  decideLanguage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey("language")){
      locale = await prefs.getString("language")??"en";
    }else{
      setSystemLanguage();
    }
  }
  setSystemLanguage() async {
    String deviceLocale = Platform.localeName.split("_")[0];
    for(int a = 0; a < languages.length;a++){
      if(languages[a]["id"] == deviceLocale){
        locale = deviceLocale;
      }
    }
  }
  saveLanguage(String variant) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    for(int a = 0; a < languages.length;a++){
      if(languages[a]["id"] == variant){
        prefs.setString("language", variant);
      }
    }
  }
  setup() async {
    await rootBundle.loadString('assets/translations/languages.json').then((langlist) async {
      languages = jsonDecode(langlist);
      await decideLanguage();
      for(int i=0; i < languages.length; i++){
        await rootBundle.loadString('assets/translations/${languages[i]["id"]}.json').then((langentry) async {
          dictionary[languages[i]["id"]] = jsonDecode(langentry);
        });
      }
    });
  }

  String value (String entry){
    if(!dictionary.containsKey(locale)){
      return "Localisation engine FAILED [Default locale not initialized]";
    }
    if(!dictionary[locale].containsKey(entry)){
      return "!${dictionary["en"][entry].toString()}!";
    }
    return dictionary[locale][entry].toString();
  }
}
