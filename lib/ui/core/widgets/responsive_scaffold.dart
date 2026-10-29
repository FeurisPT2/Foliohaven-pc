import 'package:flutter/material.dart';

const double kLargeScreenBreakpoint = 768.0;

class ResponsiveScaffold extends StatelessWidget {
  final Widget sidebar;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  const ResponsiveScaffold({
    super.key,
    required this.sidebar,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.sizeOf(context).width > kLargeScreenBreakpoint;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > kLargeScreenBreakpoint;

        if (isDesktop) {
          // Large Screen Layout (Windows PC / Tablet)
          return Scaffold(
            appBar: appBar,
            body: Row(
              children: [
                SizedBox(
                  width: 240,
                  child: sidebar,
                ),
                Container(
                  width: 1,
                  color: const Color(0xFF292524),
                ),
                Expanded(
                  child: body,
                ),
              ],
            ),
          );
        } else {
          // Small Screen Layout (Mobile Phones)
          return Scaffold(
            appBar: appBar,
            drawer: Drawer(
              backgroundColor: const Color(0xFF171514),
              child: sidebar,
            ),
            body: body,
            bottomNavigationBar: bottomNavigationBar,
            floatingActionButton: floatingActionButton,
          );
        }
      },
    );
  }
}
