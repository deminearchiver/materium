import 'package:flutter/material.dart';

import 'package:screen_corners_ffi/screen_corners_ffi.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Screen corners",
      themeMode: ThemeMode.system,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // @override
  // void initState() {
  //   super.initState();
  //   SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
  //     setState(() {});
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final textTheme = TextTheme.of(context);
    final screenCorners = ScreenCorners.maybeOf(context);
    // final screenCorners = null;
    debugPrint("$screenCorners ${MediaQuery.maybeDevicePixelRatioOf(context)}");
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainer,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              elevation: 0.0,
              scrolledUnderElevation: 0.0,
              surfaceTintColor: Colors.transparent,
              backgroundColor: colorScheme.surfaceContainer,
              title: Text("Screen corners"),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              fillOverscroll: false,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Material(
                  animationDuration: Duration.zero,
                  clipBehavior: Clip.antiAlias,
                  color: colorScheme.primaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        screenCorners?.toBorderRadius() ??
                        BorderRadius.all(Radius.circular(9999.0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        FilledButton(
                          onPressed: () {
                            setState(() {});
                          },
                          child: const Text("Rebuild"),
                        ),
                        Text(
                          "$screenCorners",
                          style: textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
