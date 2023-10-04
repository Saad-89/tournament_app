// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class Event {
//   final String name;
//   final double latitude;
//   final double longitude;

//   Event({
//     required this.name,
//     required this.latitude,
//     required this.longitude,
//   });
// }

// class TournamentsAroundYou extends StatefulWidget {
//   @override
//   _TournamentsAroundYouState createState() => _TournamentsAroundYouState();
// }

// class _TournamentsAroundYouState extends State<TournamentsAroundYou> {
//   Location _location = Location();
//   List<Event> events = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadEvents();
//   }

//   void _loadEvents() async {
//     QuerySnapshot snapshot =
//         await FirebaseFirestore.instance.collection('events').get();
//     setState(() {
//       events = snapshot.docs.map((doc) {
//         double latitude = doc['lat'];
//         double longitude = doc['lng'];

//         return Event(
//           name: doc['name'] ?? 'Unknown',
//           latitude: latitude,
//           longitude: longitude,
//         );
//       }).toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           Container(
//             height: 120,
//             decoration: BoxDecoration(
//               color: Colors.deepPurpleAccent,
//               borderRadius: BorderRadius.only(
//                 bottomLeft: Radius.circular(10),
//                 bottomRight: Radius.circular(10),
//               ),
//             ),
//             child: Center(
//               child: Text(
//                 'Map',
//                 style: TextStyle(
//                   fontFamily: 'karla',
//                   color: Colors.white,
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(height: 10),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Align(
//               alignment: Alignment.center,
//               child: Text(
//                 'Tournament Location',
//                 style: TextStyle(
//                   fontFamily: 'karla',
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(height: 10),
//           Expanded(
//             child: ListView.builder(
//               itemCount: events.length,
//               itemBuilder: (context, index) {
//                 Event event = events[index];
//                 return Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: Container(
//                     decoration: BoxDecoration(
//                         color: Colors.deepPurpleAccent,
//                         borderRadius: BorderRadius.circular(10)),

//                     height: 350, // Adjust the height as needed
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 10, horizontal: 10),
//                       child: Column(
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.symmetric(
//                               vertical: 10,
//                             ),
//                             child: Text(
//                               event.name,
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                           Container(
//                             child: Expanded(
//                               child: GoogleMap(
//                                 initialCameraPosition: CameraPosition(
//                                   target:
//                                       LatLng(event.latitude, event.longitude),
//                                   zoom: 15,
//                                 ),
//                                 markers: {
//                                   Marker(
//                                     markerId: MarkerId(
//                                         'marker_${event.latitude}_${event.longitude}'),
//                                     position:
//                                         LatLng(event.latitude, event.longitude),
//                                     icon: BitmapDescriptor.defaultMarkerWithHue(
//                                         BitmapDescriptor.hueRed),
//                                     infoWindow: InfoWindow(title: event.name),
//                                   ),
//                                 },
//                                 mapType: MapType.normal,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:url_launcher/url_launcher.dart';

// class Event {
//   final String name;
//   final double latitude;
//   final double longitude;

//   Event({
//     required this.name,
//     required this.latitude,
//     required this.longitude,
//   });
// }

// class TournamentsAroundYou extends StatefulWidget {
//   @override
//   _TournamentsAroundYouState createState() => _TournamentsAroundYouState();
// }

// class _TournamentsAroundYouState extends State<TournamentsAroundYou> {
//   Location _location = Location();
//   LatLng? _currentLocation;
//   List<Event> events = [];

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//     _loadEvents();
//   }

//   void _loadEvents() async {
//     QuerySnapshot snapshot =
//         await FirebaseFirestore.instance.collection('events').get();
//     setState(() {
//       events = snapshot.docs.map((doc) {
//         double latitude = doc['lat'];
//         double longitude = doc['lng'];

//         return Event(
//           name: doc['name'] ?? 'Unknown',
//           latitude: latitude,
//           longitude: longitude,
//         );
//       }).toList();
//     });
//   }

//   void _getCurrentLocation() async {
//     var locationData = await _location.getLocation();
//     setState(() {
//       _currentLocation =
//           LatLng(locationData.latitude!, locationData.longitude!);
//     });
//   }

//   // double _calculateDistance(LatLng eventLocation) {
//   //   double distance = _location(
//   //     _currentLocation!.latitude,
//   //     _currentLocation!.longitude,
//   //     eventLocation.latitude,
//   //     eventLocation.longitude,
//   //   );
//   //   return distance / 1000; // Convert to km
//   // }
//   void _launchURL(LatLng destination) async {
//     final url =
//         'https://www.google.com/maps/dir/?api=1&origin=${_currentLocation!.latitude},${_currentLocation!.longitude}&destination=${destination.latitude},${destination.longitude}&travelmode=driving';

//     if (await canLaunch(url)) {
//       await launch(url);
//     } else {
//       throw 'Could not launch $url';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Container(
//               height: 120,
//               decoration: BoxDecoration(
//                 color: Colors.deepPurpleAccent,
//                 borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(10),
//                   bottomRight: Radius.circular(10),
//                 ),
//               ),
//               child: Center(
//                 child: Text(
//                   'Map',
//                   style: TextStyle(
//                     fontFamily: 'karla',
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 10),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Align(
//                 alignment: Alignment.center,
//                 child: Text(
//                   'Tournament Location',
//                   style: TextStyle(
//                     fontFamily: 'karla',
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 10),
//             if (events.isEmpty)
//               Center(child: Text('No tournaments available.'))
//             else
//               ...events.map((event) => _buildEventCard(event)).toList(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEventCard(Event event) {
//     return Padding(
//       padding: const EdgeInsets.all(10.0),
//       child: Container(
//         decoration: BoxDecoration(
//             color: Colors.deepPurpleAccent,
//             borderRadius: BorderRadius.circular(10)),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: List.generate(
//                   4,
//                   (index) => CircleAvatar(
//                     backgroundColor: Colors.white,
//                     child: Icon(Icons.star,
//                         color: Colors
//                             .deepPurpleAccent), // Change the icon as required
//                   ),
//                 ),
//               ),
//               SizedBox(height: 10),
//               Container(
//                 height: 250,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: Colors.white, width: 2),
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(10),
//                   child: GoogleMap(
//                     initialCameraPosition: CameraPosition(
//                       target: LatLng(event.latitude, event.longitude),
//                       zoom: 15,
//                     ),
//                     markers: {
//                       Marker(
//                         markerId: MarkerId(
//                             'marker_${event.latitude}_${event.longitude}'),
//                         position: LatLng(event.latitude, event.longitude),
//                         icon: BitmapDescriptor.defaultMarkerWithHue(
//                             BitmapDescriptor.hueRed),
//                         infoWindow: InfoWindow(title: event.name),
//                       ),
//                     },
//                     mapType: MapType.normal,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 10),
//               ElevatedButton(
//                 style: ButtonStyle(
//                     backgroundColor:
//                         MaterialStatePropertyAll(Color(0xffFEAF3E))),
//                 onPressed: () {
//                   _launchURL(LatLng(event.latitude, event.longitude));
//                 },
//                 child: Text(
//                   'Open Map',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String name;
  final double latitude;
  final double longitude;

  Event({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

class TournamentsAroundYou extends StatefulWidget {
  @override
  _TournamentsAroundYouState createState() => _TournamentsAroundYouState();
}

class _TournamentsAroundYouState extends State<TournamentsAroundYou> {
  Completer<GoogleMapController> _mapControllerCompleter = Completer();
  Location _location = Location();
  LatLng? _currentLocation;
  List<Event> events = [];
  Map<MarkerId, Marker> markers = {}; // Map of markers
  late BitmapDescriptor markerIcon; // Custom marker icon

  @override
  void initState() {
    super.initState();
    _createMarkerIcon(); // Create the custom marker icon
    _getCurrentLocation();
    _loadEvents();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapControllerCompleter.complete(controller);
  }

  void _getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    LocationData locationData = await _location.getLocation();
    setState(() {
      _currentLocation =
          LatLng(locationData.latitude!, locationData.longitude!);
    });

    if (_currentLocation != null) {
      final GoogleMapController controller =
          await _mapControllerCompleter.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentLocation!,
            zoom: 15,
          ),
        ),
      );
    }
  }

  void _loadEvents() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('events').get();
      setState(() {
        events = snapshot.docs.map((doc) {
          double latitude;
          double longitude;
          try {
            latitude = double.parse(doc['lat'].toString());
            longitude = double.parse(doc['lng'].toString());
          } catch (e) {
            latitude = 0.0;
            longitude = 0.0;
          }

          // Add the marker using the fetched latitude and longitude
          _addMarker(doc['name'], doc['venue'], latitude, longitude);

          return Event(
            name: doc['name'] ?? 'Unknown',
            latitude: latitude,
            longitude: longitude,
          );
        }).toList();
      });
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  void _createMarkerIcon() {
    // Create a custom marker icon
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(48, 48)),
      'assets/images/ic_launcher.png',
    ).then((icon) {
      setState(() {
        markerIcon = icon;
      });
    });
  }

  void _addMarker(
      String eventName, String venue, double latitude, double longitude) {
    var markerIdVal = 'marker_${latitude}_${longitude}';
    final MarkerId markerId = MarkerId(markerIdVal);

    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(latitude, longitude),
      icon: markerIcon,
      infoWindow: InfoWindow(
        title: eventName,
      ),
      onTap: () {
        _showEventDetails(eventName, venue);
      },
    );

    setState(() {
      markers[markerId] = marker;
    });
  }

  void _showEventDetails(String eventName, String venue) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Event Details',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'karla', fontWeight: FontWeight.bold),
          ),
          content: Container(
            height: 100,
            child: Column(
              children: [
                Text(
                  '$eventName',
                  style: TextStyle(
                      fontFamily: 'karla',
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Venue Name: $venue',
                  style: TextStyle(
                      fontFamily: 'karla', fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   leading: IconButton(
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //     icon: Icon(
      //       Icons.arrow_back_ios,
      //       size: 18,
      //     ),
      //   ),
      //   backgroundColor: Colors.deepPurpleAccent,
      //   title: Text(
      //     'Tournaments around you',
      //     style: TextStyle(fontFamily: 'karla'),
      //   ),
      // ),
      body: _currentLocation == null
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurpleAccent,
              ),
            )
          : Column(
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Map',
                      style: TextStyle(
                        fontFamily: 'karla',
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _currentLocation!,
                      zoom: 20,
                    ),
                    myLocationEnabled: true,
                    mapType: MapType.normal,
                    markers: Set<Marker>.of(markers.values),
                  ),
                ),
              ],
            ),
    );
  }
}

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class Event {
//   final String name;
//   final double latitude;
//   final double longitude;

//   Event({
//     required this.name,
//     required this.latitude,
//     required this.longitude,
//   });
// }

// class TournamentsAroundYou extends StatefulWidget {
//   @override
//   _TournamentsAroundYouState createState() => _TournamentsAroundYouState();
// }

// class _TournamentsAroundYouState extends State<TournamentsAroundYou> {
//   Completer<GoogleMapController> _mapControllerCompleter = Completer();
//   Location _location = Location();
//   LatLng? _currentLocation;
//   List<Event> events = [];

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }

//   void _onMapCreated(GoogleMapController controller) {
//     _mapControllerCompleter.complete(controller);
//   }

//   void _getCurrentLocation() async {
//     bool serviceEnabled;
//     PermissionStatus permissionGranted;

//     serviceEnabled = await _location.serviceEnabled();
//     if (!serviceEnabled) {
//       serviceEnabled = await _location.requestService();
//       if (!serviceEnabled) {
//         return;
//       }
//     }

//     permissionGranted = await _location.hasPermission();
//     if (permissionGranted == PermissionStatus.denied) {
//       permissionGranted = await _location.requestPermission();
//       if (permissionGranted != PermissionStatus.granted) {
//         return;
//       }
//     }

//     LocationData locationData = await _location.getLocation();
//     setState(() {
//       _currentLocation =
//           LatLng(locationData.latitude!, locationData.longitude!);
//     });

//     if (_currentLocation != null) {
//       final GoogleMapController controller =
//           await _mapControllerCompleter.future;
//       controller.animateCamera(
//         CameraUpdate.newCameraPosition(
//           CameraPosition(
//             target: _currentLocation!,
//             zoom: 15,
//           ),
//         ),
//       );

//       // Load events after getting current location
//       _loadEvents();
//     }
//   }

//   void _loadEvents() async {
//     try {
//       QuerySnapshot snapshot =
//           await FirebaseFirestore.instance.collection('events').get();
//       setState(() {
//         events = snapshot.docs.map((doc) {
//           double latitude =
//               doc['lat'] is double ? doc['lat'] : double.parse(doc['lat']);
//           double longitude =
//               doc['lng'] is double ? doc['lng'] : double.parse(doc['lng']);

//           // Print fetched lat and lng on the console
//           print('Event: ${doc['name']}, Lat: $latitude, Lng: $longitude');

//           return Event(
//             name: doc['name'] ?? 'Unknown',
//             latitude: latitude,
//             longitude: longitude,
//           );
//         }).toList();
//       });
//     } catch (e) {
//       print('Error fetching events: $e');
//     }
//   }

//   Set<Marker> _createMarkers() {
//     return events.map((event) {
//       return Marker(
//         markerId: MarkerId(event.name),
//         position: LatLng(event.latitude, event.longitude),
//         icon: BitmapDescriptor.defaultMarker,
//         infoWindow: InfoWindow(title: event.name),
//         onTap: () {
//           _showEventDetails(event);
//         },
//       );
//     }).toSet();
//   }

//   void _showEventDetails(Event event) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(event.name),
//           content: Text('Venue: ${event.latitude}, ${event.longitude}'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: Text('Close'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Tournaments around you'),
//       ),
//       body: _currentLocation == null
//           ? Center(
//               child: CircularProgressIndicator(),
//             )
//           : GoogleMap(
//               onMapCreated: _onMapCreated,
//               initialCameraPosition: CameraPosition(
//                 target: _currentLocation!,
//                 zoom: 15,
//               ),
//               myLocationEnabled: true,
//               mapType: MapType.normal,
//               markers: _createMarkers(),
//             ),
//     );
//   }
// }
