import 'package:flutter/material.dart';

class Navigation extends StatefulWidget {
  // const Navigation({super.key});
  const Navigation({Key? key}) : super(key: key);

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> with TickerProviderStateMixin {
  late TabController controller;
  var activeColor = const Color.fromARGB(255, 33, 31, 103);
  var inactiveColor = const Color.fromARGB(255, 204, 204, 204);

  @override
  void initState() {
    controller = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      labelColor: activeColor,
      unselectedLabelColor: inactiveColor,
      splashFactory: NoSplash.splashFactory,
      labelStyle: const TextStyle(
          fontSize: 10, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
      // This runs a custom indicator design
      indicator: const CustomTabIndicator(radius: 8, indicatorHeight: 8),
      labelPadding: const EdgeInsets.only(bottom: 6),
      onTap: (index) {},
      tabs: const [
        Tab(icon: Icon(Icons.home_filled), text: 'Homepage'),
        Tab(icon: Icon(Icons.camera), text: 'Camera'),
        Tab(icon: Icon(Icons.settings), text: 'Settings')
      ],
    );
  }
}

class CustomTabIndicator extends Decoration {
  final double radius;

  final Color color;

  final double indicatorHeight;

  const CustomTabIndicator({
    required this.radius,
    required this.indicatorHeight,
    this.color = const Color.fromARGB(255, 33, 31, 103),
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
