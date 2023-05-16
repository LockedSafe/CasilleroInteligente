import 'package:flutter/material.dart';

class BottomBar extends StatefulWidget {
  final List<BottomNavigationBarItem> items;
  final void Function(int) onTap;
  final int currentIndex;
  final bool disableItems;

  const BottomBar({
    Key? key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.disableItems = false,
  }) : super(key: key);

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BottomNavigationBar(
          backgroundColor: const Color.fromARGB(255, 29, 46, 133),
          items: widget.items,
          onTap: widget.onTap,
          currentIndex: widget.currentIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white60,
        ),
        if (widget.disableItems)
          Opacity(
            opacity: 0.5,
            child: IgnorePointer(
              child: Container(
                color: Colors.transparent,
                height: kBottomNavigationBarHeight,
              ),
            ),
          )
      ],
    );
  }
}
