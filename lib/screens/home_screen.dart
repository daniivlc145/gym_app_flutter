import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gym_app/screens/training_screen.dart';
import 'package:gym_app/screens/templates_screen.dart';
import 'package:gym_app/screens/profile_screen.dart';
import 'package:gym_app/screens/settings_screen.dart';
import 'package:gym_app/screens/forums_screen.dart';
import 'package:gym_app/screens/add_friends_screen.dart';
import 'package:gym_app/screens/affluence_screen.dart';
import 'package:gym_app/screens/social_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isMenuOpen = false;

  final List<Widget> _pages = [
    TrainingScreen(),
    TemplatesScreen(),
    SocialScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showPopupMenu(BuildContext context) {
    setState(() {
      _isMenuOpen = true;
    });

    showMenu(
      context: context,
      color: Colors.transparent,
      elevation: 0,
      position: RelativeRect.fromLTRB(1000, 80, 0, 0),
      items: [
        PopupMenuItem(
          value: 'settings',
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: Color(0xFFECF0F1),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Color(0xff38434E), width: 1),
            ),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 10),
                  Text('Ajustes')
                ],
              ),
            ),
          ),
        ),
        PopupMenuItem(
          value: 'forums',
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: Color(0xFFECF0F1),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Color(0xff38434E), width: 1),
            ),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.forum),
                  SizedBox(width: 10),
                  Text('Foros')
                ],
              ),
            ),
          ),
        ),
        PopupMenuItem(
          value: 'add_friends',
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: Color(0xFFECF0F1),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Color(0xff38434E), width: 1),
            ),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.person_add),
                  SizedBox(width: 10),
                  Text('Agregar amigos')
                ],
              ),
            ),
          ),
        ),
        PopupMenuItem(
          value: 'affluence',
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: Color(0xFFECF0F1),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Color(0xff38434E), width: 1),
            ),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.groups),
                  SizedBox(width: 10),
                  Text('Afluencia')
                ],
              ),
            ),
          ),
        ),
      ],
    ).then((value) {
      setState(() {
        _isMenuOpen = false;
      });

      switch (value) {
        case 'settings':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsScreen()),
          );
          break;
        case 'forums':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ForumsScreen()),
          );
          break;
        case 'add_friends':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddFriendScreen()),
          );
          break;
        case 'affluence':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AffluenceScreen()),
          );
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(''),
            actions: [
              IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => _showPopupMenu(context),
              ),
            ],
          ),
          body: _pages[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center),
                label: 'Entrenamiento',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt),
                label: 'Plantillas',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: 'Social',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Color(0xff1ABC9C),
            onTap: _onItemTapped,
          ),
        ),

        if (_isMenuOpen)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
      ],
    );
  }
}