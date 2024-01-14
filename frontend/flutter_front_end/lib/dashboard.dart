import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_front_end/elements.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.name, required this.role});

  final String name;
  final int role;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the 
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale 
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately. 
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  } 

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

class Reporter extends StatefulWidget {
  const Reporter({super.key});

  @override
  State<Reporter> createState() => _ReporterState();
}

class _ReporterState extends State<Reporter> {
  late GoogleMapController mapController;

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  LatLng? position;

  void sendReport(description, color) async {
    http.Response response = await http.post(
      Uri.parse("http://127.0.0.1:8000/app/report/"), 
      headers: <String, String> {
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: utf8.encode(jsonEncode({
        'description': description,
        'colour': color,
        'locationX': position!.longitude,
        'locationY': position!.latitude,
        'time': (DateTime.now().millisecondsSinceEpoch / 1000.0).round()
      }))
    );
  }

  void updatePosition() async {
    var result = await determinePosition();

    setState(() => position = LatLng(result.latitude, result.longitude));
  }

  @override
  Widget build(BuildContext context) {
    if(position == null) updatePosition();

    return Center(
          child: Column (
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BigCard(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ElevatedButton(onPressed: () => 
                        showDialog(
                          context: context, 
                          builder: (BuildContext c) => ReportCatDialog(sendReport: sendReport)), 
                        child: const Text("Report a cat")
                      )
                    ),
                    if (position != null) (
                      SizedBox(
                        width: 400,
                        height: 400,
                        child: GoogleMap(
                          onMapCreated: onMapCreated,
                          initialCameraPosition: CameraPosition(
                            target: position!,
                            zoom: 13.0,
                          ),
                        ),
                      )
                    ),    
                  ]
                )
              )
            ],
          ),
        );
}
}

class Volunteer extends StatefulWidget {
  const Volunteer({super.key});

  @override
  State<Volunteer> createState() => _VolunteerState();
}

class _VolunteerState extends State<Volunteer> {
  late GoogleMapController mapController;

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  LatLng? position;
  Set<Marker>? markers;
  var dateValue = 604800;

  void sendRespond(id) {

  }

  Set<Marker> assembleMarkers(cats) {
    Set<Marker> output = {};

    for(var i = 0; i < cats.length; i++) {
      output.add(
        Marker(
          markerId: MarkerId("Cat $i"),
          infoWindow: InfoWindow(
            title: "${cats[i].color} Cat found on ${DateFormat('yyyy-MM-dd').format(DateTime.fromMicrosecondsSinceEpoch(cats[i].date * 1000))}",
            snippet: cats[i].description
          ),
          position: LatLng(cats[i].locationY, cats[i].locationX)
        )
      );
    }

    return output;
  }

  void getMarkers() async {
    /* setState(() { 
      markers = assembleMarkers(
        ["This is a crazy cat", "This is a chill car"], 
        ["Blue", "Grey"], 
        [-79.921798, -79.918153], 
        [43.258538, 43.265364],
        [100000000000, 1093204808]);
    }
    ); */

    http.Response response = await http.post(
      Uri.parse("http://127.0.0.1:8000/app/update-map"), 
      headers: <String, String> {
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode({
        'date': (DateTime.now().microsecondsSinceEpoch / 1000.0).round(),
        'timeDiff': dateValue,
        'radius': radius,
        'locationX': position!.longitude,
        'locationY': position!.latitude
      })
    );

    var body = jsonDecode(response.body);

    if(response.statusCode == 200) {
      setState(() => markers = assembleMarkers(body.cats));
    }
  }

  void updatePosition() async {
    var result = await determinePosition();

    setState(() => position = LatLng(result.latitude, result.longitude));
  }

  final List<DropdownMenuItem<int>> dates = [
    const DropdownMenuItem(value: 3600,child: Text("Past Hour")),
    const DropdownMenuItem(value: 86400,child: Text("Past Day")),
    const DropdownMenuItem(value: 604800,child: Text("Past Week")),
    const DropdownMenuItem(value: 2592000,child: Text("Past Month")),
    const DropdownMenuItem(value: 31536000,child: Text("Past Year")),
    const DropdownMenuItem(value: 170523872,child: Text("All Time")),
  ];

  var radius = 1000.0;

  String formatLabel(value) {
    if(value >= 1000) {
      return (value / 1000).round().toString() + "km";
    } else {
      return value.round().toString() + "m";
    }
  }

  @override
  Widget build(BuildContext context) {
    if(position == null) updatePosition();
    if(markers == null) getMarkers();

    return Center(
          child: Column (
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BigCard(
                child: Column(
                  children: [
                    Form (
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(right: 20),
                                    child: Text("Show cats since"),
                                  ),
                                  DropdownButton<int> (
                                    value: dateValue,
                                    items: dates, 
                                    onChanged: (value) {
                                      if(value != null) {
                                        setState(() {
                                          dateValue = value;
                                        });
                                      }
                                    }
                                  ),
                                ],
                              ),
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(right: 20),
                                    child: Text("Show cats in distance"),
                                  ),
                                  SizedBox( 
                                    width: 300,
                                    child: Slider(
                                      value: radius,
                                      onChanged: (value) => {
                                        setState(() {
                                          radius = value;
                                        })
                                      },
                                      label: formatLabel(radius),
                                      divisions: 100,
                                      min: 100,
                                      max: 20000,
                                    )
                                  )
                                ],
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: ElevatedButton(
                              onPressed: () {
                                getMarkers();
                              }, 
                              child: const Text("Update")
                            ),
                          ),
                        ],
                      )
                    ),
                    if (position != null && markers != null) (
                      SizedBox(
                        width: 400,
                        height: 400,
                        child: GoogleMap(
                          onMapCreated: onMapCreated,
                          initialCameraPosition: CameraPosition(
                            target: position!,
                            zoom: 13.0,
                          ),
                          markers: markers!,
                        ),
                      )
                    ),    
                  ]
                )
              )
            ],
          ),
        );
}
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    Widget body = widget.role == 0 ? const Reporter() : const Volunteer();
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: Text(
          "Welcome back ${widget.name}!", 
          style: TextStyle(
            color: Theme.of(context).primaryColorLight
          ),
        ),
      ),
      body: body
    );
  }
}
