import 'dart:io';
import 'dart:async';

import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link_text/link_text.dart';
import 'package:photo_view/photo_view.dart';
import 'package:uni_links_desktop/uni_links_desktop.dart';
import 'package:window_size/window_size.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(const Size(200, 500));
    setWindowFrame(Rect.fromLTWH(10, 10, 300, 900));
    setWindowMaxSize(Size.infinite);
  }
  if (Platform.isMacOS || Platform.isWindows) {
    enableUniLinksDesktop();
    if (Platform.isWindows) {
      registerProtocol('lanhuappview');
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          backgroundColor: Colors.transparent,
          sliderTheme: SliderThemeData(thumbShape: RoundSliderThumbShape(enabledThumbRadius: 60))
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key? key,
  }) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _initialLink;
  late StreamSubscription _sub;

  @override
  dispose() {
    _sub.cancel();
    super.dispose();
  }

  Future<Null> initUniLinks() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    UniLinksDesktop().getInitialLink().then((value){
      setState(() {
        _initialLink = value?.replaceFirst("lanhuappview://", "");

      });
    });
    try {
      _sub = UniLinksDesktop().linkStream.listen((String? link) {
        if (link != null) {
          print('Link: $link');
          setState(() {
            _initialLink = link.replaceFirst("lanhuappview://", "");
          });
        } else {
          print("link is null");
        }
      });

      // Parse the link and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
    } on PlatformException {
      // Handle exception by warning the user their action did not succeed
      // return?
      print("PlatformException");
    }
  }

  @override
  initState() {
    super.initState();
    initUniLinks();
  }

  double opacity = .7;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _initialLink?.isNotEmpty == true
          ? Container(
              width: double.infinity,
              color: Colors.transparent,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Opacity(
                    opacity: opacity,
                    child: PhotoView(imageProvider: NetworkImage(_initialLink ?? ""),tightMode: false,),
                  ),
                  Positioned(
                      left: 0,
                      right: 0,
                      bottom: 20,
                      child: Column(
                        children: [
                          CupertinoSlider(
                              value: opacity,
                              onChanged: (value) {
                                setState(() {
                                  opacity = value;
                                });
                              }),
                        ],
                      )),
                ],
              ),
            )
          : Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Center(
                  child: LinkText("https://greasyfork.org/zh-CN/scripts/442850-%E8%93%9D%E6%B9%96%E5%89%8D%E7%AB%AFui%E5%AF%B9%E6%AF%94"),
                ),
              ),
            ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
