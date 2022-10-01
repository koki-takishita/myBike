import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  print(firstCamera.runtimeType);

  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: Menu(camera: firstCamera)
        )
      ),
    ),
  );
}

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.center,
      // mainAxisSize: MainAxisSize.min,
      children: [
        // camera preview
        FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return CameraPreview(_controller);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        Container(
          // padding: const EdgeInsets.only(bottom: .0),
          // margin:  const EdgeInsets.only(bottom: 80),
          color: Colors.white70,
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                  child: Visibility(
                    visible: false,
                    child: Text('dumy'),
                  )
              ),
              Expanded(
                child: IconButton(
                    onPressed: () async {
                      print('押された');
                      try{
                        await _initializeControllerFuture;
                        final image = await _controller.takePicture();
                        if(!mounted) return;
                        showDialog<void>(
                          context: context,
                          builder: (_) {
                            return DialogExample(imagePath: image.path);
                          }
                        );
                      }catch(e) {
                        print(e);
                      }
                    },
                    iconSize: 85,
                    color: CupertinoColors.systemBlue,
                    icon: const Icon(Icons.radio_button_unchecked)
                ),
              ),
              Expanded(
                child: IconButton(
                    onPressed: () {
                      print('押された2');
                    },
                    iconSize: 60,
                    color: Colors.grey,
                    icon: const Icon(Icons.space_dashboard_outlined)
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DialogExample extends StatelessWidget {
  final String imagePath;
  const DialogExample({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // content: Text('画像をシェアする'),
      content: DisplayPictureScreen(imagePath: imagePath),
      actions: <Widget>[
        Center(
          child: TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('閉じる'),
          ),
        ),
      ],
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Image.file(
          File(imagePath),
        ),
        TextButton(
          onPressed: () async {
            try{
              await GallerySaver.saveImage(imagePath);
            }catch(e){
              print(e);
            }
          },
          child: const Text('保存する'),
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  print('押された4');
                },
                padding: EdgeInsets.all(0),
                iconSize: 80,
                color: Colors.grey,
                icon: const Icon(Icons.space_dashboard_outlined)
              ),
              IconButton(
                  onPressed: () {
                    print('押された5');
                  },
                  padding: EdgeInsets.all(0),
                  iconSize: 80,
                  color: Colors.grey,
                  icon: const Icon(Icons.space_dashboard_outlined)
              ),
              IconButton(
                  onPressed: () {
                    print('押された6');
                  },
                  padding: EdgeInsets.all(0),
                  iconSize: 80,
                  color: Colors.grey,
                  icon: const Icon(Icons.space_dashboard_outlined)
              ),
            ],
          ),
        ),
      ]
    );
  }
}

class Menu extends StatelessWidget {
  CameraDescription camera;
  Menu({super.key, required this.camera});

  static const btnTitles = ['ランキング', '撮影', 'プロフィール'];
  static const icons = <IconData>[CupertinoIcons.chart_bar, CupertinoIcons.camera, CupertinoIcons.person];

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        height: 65.0,
        items: <BottomNavigationBarItem>[
          for(var i = 0; i < 3; i++)
            BottomNavigationBarItem(
              // icon: Icon(CupertinoIcons.chart),
              icon: Icon(icons[i]),
              label: btnTitles[i],
            ),
        ],
      ),
      tabBuilder: (BuildContext context, int index){
        return CupertinoTabView(
          builder: (BuildContext context){
            return Center(
              // child: Text('Context of tab $index'),
              child: (index == 1)? CameraPageWrap(camera: camera) : Text('その他のページ')
            );
          },
        );
      }
    );
  }
}

class CameraPageWrap extends StatelessWidget {
  CameraDescription camera;
  CameraPageWrap({required this.camera});

  @override
  Widget build(BuildContext context){
    return TakePictureScreen(camera: camera);
  }
}