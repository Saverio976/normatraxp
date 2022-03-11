import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

void main() {
    Process.run("python3", ["-m", "pip", "install", "-U", "normatrix"]).then((result) {
        if (result.exitCode != 0) {
            stdout.write("Can't install normatrix requirements\n");
            stdout.write("you need python3 and pip installed on your OS\n");
            return;
        } else {
            stdout.write("normatrix is installed\n");
        }
    });
    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
    const MyApp({Key? key}) : super(key: key);

    // This widget is the root of your application.
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
                title: 'NormatrAxPP',
                theme: ThemeData.dark(),
                // This is the theme of your application.
                //
                // Try running your application with "flutter run". You'll see the
                // application has a blue toolbar. Then, without quitting the app, try
                // changing the primarySwatch below to Colors.green and then invoke
                // "hot reload" (press "r" in the console where you ran "flutter run",
                // or simply save your changes to "hot reload" in a Flutter IDE).
                // Notice that the counter didn't reset back to zero; the application
                // is not restarted.
                home: const MyHomePage(title: 'NormatrAxPP'),
        );
    }
}

class MyHomePage extends StatefulWidget {
    const MyHomePage({Key? key, required this.title}) : super(key: key);

    // This widget is the home page of your application. It is stateful, meaning
    // that it has a State object (defined below) that contains fields that affect
    // how it looks.

    // This class is the configuration for the state. It holds the values (in this
    // case the title) provided by the parent (in this case the App widget) and
    // used by the build method of the State. Fields in a Widget subclass are
    // always marked "final".

    final String title;

    @override
    State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
    String _hintText = ".";
    final _allWidget = <Widget>[];
    String? selectedDirectory = "";
    int status = 0;

    void _setText(String text) {
        final dir = Directory(text);
        _hintText = dir.absolute.path.toString();
    }

    void _actionClickButton() {
        FilePicker.platform.getDirectoryPath().then((dir) {
            if (dir == null) {
                return;
            }
            _setText(dir);
            _annalyzeDirectory();
        });
    }

    void _annalyzeDirectory() {
        setState(() {
            // This call to setState tells the Flutter framework that something has
            // changed in this State, which causes it to rerun the build method below
            // so that the display can reflect the updated values. If we changed
            // _counter without calling setState(), then the build method would not be
            // called again, and so nothing would appear to happen.
            Process.run("python3", ["-m", "normatrix", _hintText, "--only-error"]).then((result) {
                setState(() {
                    String stdoutStr = result.stdout.toString();
                    final String stderrStr = result.stderr.toString();
                    stderr.write(stderrStr);
                    _allWidget.clear();
                    stdoutStr = stdoutStr.replaceAll(RegExp(r"\[.*?m"), "");
                    final listStr = stdoutStr.split(RegExp(r"\n"));
                    for (String elem in listStr) {
                        _allWidget.add(Text(elem));
                    }
                });
            });
            _allWidget.clear();
            _allWidget.add(Text("normatrix is launched for '$_hintText', you will get results soon"));
        });
    }

    @override
    Widget build(BuildContext context) {
        // by the _annalyzeDirectory method above.
        return Scaffold(
                appBar: AppBar(
                        // Here we take the value from the MyHomePage object that was created by
                        // the App.build method, and use it to set our appbar title.
                        title: Text(widget.title),
                ),
                body: Center(
                        // Center is a layout widget. It takes a single child and positions it
                        // in the middle of the parent.
                        child: Column(
                                // Column is also a layout widget. It takes a list of children and
                                // arranges them vertically. By default, it sizes itself to fit its
                                // children horizontally, and tries to be as tall as its parent.
                                //
                                // Invoke "debug painting" (press "p" in the console, choose the
                                // "Toggle Debug Paint" action from the Flutter Inspector in Android
                                // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
                                // to see the wireframe for each widget.
                                //
                                // Column has various properties to control how it sizes itself and
                                // how it positions its children. Here we use mainAxisAlignment to
                                // center the children vertically; the main axis here is the vertical
                                // axis because Columns are vertical (the cross axis would be
                                // horizontal).
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: _allWidget
                        ),
        ),
                floatingActionButton: FloatingActionButton(
                        onPressed: _actionClickButton,
                        tooltip: 'search directory to check',
                        child: const Icon(Icons.add),
                ), // This trailing comma makes auto-formatting nicer for build methods.
                );
    }
}
