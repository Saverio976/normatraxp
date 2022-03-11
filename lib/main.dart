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
            stdout.write("normatrix is installed and updated\n");
        }
    });
    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
    const MyApp({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
                title: 'NormatrAxPP',
                theme: ThemeData.dark(),
                home: const MyHomePage(title: 'NormatrAxPP'),
        );
    }
}

class MyHomePage extends StatefulWidget {
    const MyHomePage({Key? key, required this.title}) : super(key: key);

    final String title;

    @override
    State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
    String _hintText = "path to check";
    final _allWidget = <Widget>[];
    int status = 0;
    String _homedir = "unknow";

    void _setText(String text) {
        _hintText = text;
    }

    void _actionClickButton() {
        setState(() {
            if (status != 0) {
                _annalyzeDirectory();
                return;
            }
            status = 1;
            FilePicker.platform.getDirectoryPath().then((dir) {
                if (dir == null) {
                    status = 0;
                    return;
                }
                _setText(dir);
                _annalyzeDirectory();
            });
        });
    }

    void _annalyzeDirectory() {
        setState(() {
            if (_homedir == "unknow") {
                String? home = "";
                Map<String, String> envVars = Platform.environment;
                if (Platform.isMacOS) {
                    home = envVars['HOME'];
                } else if (Platform.isLinux) {
                    home = envVars['HOME'];
                } else if (Platform.isWindows) {
                    home = envVars['UserProfile'];
                }
                if (home != null) {
                    _homedir = home;
                    stdout.writeln("[info] found home dir here : $_homedir");
                }
            }
            var text = _hintText;
            if (text.contains("~") && _homedir != "unknow") {
                text = text.replaceAll(RegExp(r"\~"), _homedir);
            } else if (text.contains("~")) {
                stderr.writeln("[warning] cannot perform replacement of '~'");
                status = 0;
                return;
            } else {
                text = text;
            }
            var path = Uri.parse('.').resolveUri(Uri.file(text)).toFilePath();
            if (path == '') {
                path = '.';
            }
            _hintText = File(path).resolveSymbolicLinksSync();
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
                    status = 0;
                });
            });
            _allWidget.clear();
            _allWidget.add(Text("normatrix is launched for '$_hintText', you will get results soon"));
        });
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
                appBar: AppBar(
                        title: Text(widget.title),
                ),
                body: Center(
                        child: ListView.builder(
                                itemCount: _allWidget.length,
                                itemBuilder: (BuildContext context, int index) {
                                    return _allWidget[index];
                                }
                        )
                ),
                bottomNavigationBar: BottomAppBar(
                        child: TextField(
                                decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        hintText: _hintText,
                                ),
                                onChanged: (text) {
                                    if (status == 0 || status == 2) {
                                        _setText(text);
                                        status = 2;
                                    }
                                },
                        ),
                ),
        floatingActionButton: FloatingActionButton(
                onPressed: _actionClickButton,
                tooltip: 'search directory to check',
                child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        );
    }
}
