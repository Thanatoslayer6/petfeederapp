import 'package:flutter/material.dart';

class Navigation extends StatefulWidget {
  // const Navigation({super.key});
  const Navigation({Key? key}) : super(key: key);

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> with TickerProviderStateMixin {
  // int _selectedIndex = 0;
  late TabController controller;

  @override
  void initState() {
    controller = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      // unselectedLabelColor: Colors.grey,
      // labelColor: Colors.blue,
      labelColor: const Color.fromARGB(255, 33, 31, 103),
      unselectedLabelColor: const Color.fromARGB(255, 204, 204, 204),

      // indicatorPadding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
      // indicator: BoxDecoration(
      //   border: Border.all(color: Colors.red),
      //   borderRadius: BorderRadius.circular(10),
      //   color: Colors.pinkAccent,
      // ),
      // indicatorWeight: 12,
      // This runs a custom indicator design
      indicator: const CustomTabIndicator(),
      labelPadding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
      onTap: (index) {},
      tabs: const [
        Tab(icon: Icon(Icons.home_filled), text: 'Homepage'),
        Tab(icon: Icon(Icons.camera), text: 'Camera'),
        Tab(icon: Icon(Icons.settings), text: 'Settings')
      ],
    );
  }
  /*
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_filled),
          label: 'Homepage',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera),
          label: 'Camera',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: const Color.fromARGB(255, 33, 31, 103),
      unselectedItemColor: const Color.fromARGB(255, 204, 204, 204),
      onTap: _onItemTapped,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  */
}

class CustomTabIndicator extends Decoration {
  final double radius;

  final Color color;

  final double indicatorHeight;

  const CustomTabIndicator({
    this.radius = 8,
    this.indicatorHeight = 8,
    this.color = Colors.blue,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CustomPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomPainter(
      this,
      onChanged,
      radius,
      color,
      indicatorHeight,
    );
  }
}

class _CustomPainter extends BoxPainter {
  final CustomTabIndicator decoration;
  final double radius;
  final Color color;
  final double indicatorHeight;

  _CustomPainter(
    this.decoration,
    VoidCallback? onChanged,
    this.radius,
    this.color,
    this.indicatorHeight,
  ) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);

    final Paint paint = Paint();
    double xAxisPos = offset.dx + configuration.size!.width / 2;
    double yAxisPos =
        offset.dy + configuration.size!.height - indicatorHeight / 2;
    paint.color = color;

    RRect fullRect = RRect.fromRectAndCorners(
      Rect.fromCenter(
        center: Offset(xAxisPos, yAxisPos),
        width: configuration.size!.width / 1.3,
        height: indicatorHeight,
      ),
      topLeft: Radius.circular(radius),
      topRight: Radius.circular(radius),
    );

    canvas.drawRRect(fullRect, paint);
  }
}
