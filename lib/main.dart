//import 'package:flutter/material.dart';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:images_picker/images_picker.dart';
import 'package:flutter_mrz_scanner/flutter_mrz_scanner.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var routes = <String, WidgetBuilder>{
      MyItemsPage.routeName: (BuildContext context) =>
          new MyItemsPage(title: "MyItemsPage"),
    };
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'KYC'),
      routes: routes,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? path;
  bool isParsed = false;
  MRZController? controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var button_Prendre_Imange = new ElevatedButton(
      child: Text('Prendre Imange'),
      onPressed: () async {
        _bottomSheet(context);
      },
    );
    var button_Scanner =
        new ElevatedButton(child: Text('Scanner'), onPressed: _onButtonPressed);

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[button_Scanner, button_Prendre_Imange],
      ),
    );
  }

  _bottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext c) {
          return Wrap(children: <Widget>[
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(""),
                  ),
                  ListTile(
                    leading: Icon(Icons.camera),
                    title: Text("Camera"),
                    onTap: () {
                      Navigator.of(context).pop(ImagesPicker.openCamera(
                        pickType: PickType.image,
                        quality: 0.8,
                        maxSize: 800,
                        maxTime: 15,
                      ));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.add_photo_alternate_sharp),
                    title: Text("importer"),
                    onTap: () {
                      Navigator.of(context).pop(ImagesPicker.pick(
                        count: 3,
                        pickType: PickType.all,
                        language: Language.System,
                        maxTime: 30,
                        cropOpt: CropOption(
                          cropType: CropType.circle,
                        ),
                      ));
                    },
                  ),
                ],
              ),
            ),
          ]);
        });
  }

  void _onButtonPressed() {
    Navigator.pushNamed(context, MyItemsPage.routeName);
  }
}

class MyItemsPage extends StatefulWidget {
  MyItemsPage({Key? key, required this.title}) : super(key: key);

  static const String routeName = "/MyItemsPage";

  final String title;

  @override
  _MyItemsPageState createState() => new _MyItemsPageState();
}

class _MyItemsPageState extends State<MyItemsPage> {
  bool isParsed = false;
  MRZController? controller;
  @override
  Widget build(BuildContext context) {
    var button = new IconButton(
        icon: new Icon(Icons.arrow_back), onPressed: _onButtonPressed);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
      ),
      body: MRZScanner(
        withOverlay: true,
        onControllerCreated: onControllerCreated,
      ),
    );
  }

  void _onFloatingActionButtonPressed() {}

  void _onButtonPressed() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    controller?.stopPreview();
    super.dispose();
  }

  void onControllerCreated(MRZController controller) {
    this.controller = controller;
    controller.onParsed = (result) async {
      if (isParsed) {
        return;
      }
      isParsed = true;

      await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
                  content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(result.toString()),
                  Text('Type De Document : ${result.documentType}'),
                  Text('Nationalite : ${result.countryCode}'),
                  Text('Nom de famille : ${result.surnames}'),
                  Text('Prenom : ${result.givenNames}'),
                  Text('Numbero du d ocument: ${result.documentNumber}'),
                  Text('Nationality code: ${result.nationalityCountryCode}'),
                  Text('Date de naissance : ${result.birthDate}'),
                  Text('Sex: ${result.sex}'),
                  Text('Date expiration : ${result.expiryDate}'),
                  Text('NNI : ${result.personalNumber}'),
                  ElevatedButton(
                    child: const Text('ok'),
                    onPressed: () {
                      isParsed = false;
                      return Navigator.pop(context, true);
                    },
                  ),
                ],
              )));
    };
    controller.onError = (error) => print(error);

    controller.startPreview();
  }
}
