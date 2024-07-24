import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDark = false;
  // getThemeMode()async{
  //   final savedThemeMode = await AdaptiveTheme.getThemeMode();
  //   if(savedThemeMode!.isDark){
  //     isDark = true;
  //   }
  //   else {
  //     isDark = false;
  //   }
  // }

  @override
  void initState() {
    // getThemeMode();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body:  Center(
        child: Card(
            child: SwitchListTile(
              title: Text('change theme'),
              secondary: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark? Colors.white : Colors.black,
                ),
                child: Icon(isDark? Icons.nightlight_round : Icons.wb_sunny_rounded,
                  color: isDark? Colors.black : Colors.white,),
              ),
              value: isDark, onChanged: (value) {
              isDark = value;
              if(value){
                setState(() {
                  AdaptiveTheme.of(context).setDark();
                });
              }
              else{
                setState(() {
                  AdaptiveTheme.of(context).setLight();
                });
              }
            },)
        ),
      ),
    );
  }
}
