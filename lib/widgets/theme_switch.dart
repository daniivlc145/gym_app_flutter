import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class ThemeSwitch extends StatelessWidget {
  const ThemeSwitch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: Provider.of<MyAppState>(context).isDarkMode,
      onChanged: (val) {
        Provider.of<MyAppState>(context, listen: false).toggleTheme();
      },
      thumbIcon: WidgetStateProperty.resolveWith<Icon>((states) {
        if (states.contains(WidgetState.selected)) {
          return const Icon(Icons.nightlight_round, color: Colors.white, size: 16);
        }
        return const Icon(Icons.wb_sunny, color: Colors.white, size: 16);
      }),
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
        return const Color(0xFF38434E);
      }),
    );
  }
}
