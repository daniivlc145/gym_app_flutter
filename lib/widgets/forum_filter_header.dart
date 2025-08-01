import 'package:flutter/material.dart';

class ForumFilterHeader extends StatefulWidget {
  final Function(String) onChanged;
  const ForumFilterHeader({Key? key, required this.onChanged}) : super(key: key);

  @override
  _ForumFilterHeaderState createState() => _ForumFilterHeaderState();
}

class _ForumFilterHeaderState extends State<ForumFilterHeader> {
  String selected = 'POPULAR';

  final List<String> options = ['POPULAR', 'LO ÚLTIMO'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: options.map((option) {
              final bool isSelected = selected == option;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selected = option;
                    widget.onChanged(option);
                  });
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 6),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[500],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Divider(
          thickness: 1,
          height: 0,
          color: Theme.of(context).dividerColor.withOpacity(0.6),
        ),
      ],
    );
  }
}
