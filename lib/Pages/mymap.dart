import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

class MyMap extends StatefulWidget {
  final String user_id;
  MyMap(this.user_id);
  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  final TextEditingController _searchController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  final loc.Location location = loc.Location();
  late GoogleMapController _controller;
  bool _added = false;
  MapType mapType = MapType.normal;
  bool traffic = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          buttonSize: Size(30, 50),
          backgroundColor: Colors.white,
          foregroundColor: Color.fromARGB(255, 56, 53, 87),
          label: Text(
            'MapType',
            style: TextStyle(color: Color.fromARGB(255, 56, 53, 87)),
          ),
          children: [
            SpeedDialChild(
              onTap: () => setState(() {
                mapType = MapType.satellite;
              }),
              child:
                  Image(width: 30, image: AssetImage('assets/satellite.png')),
              label: 'Satellite',
              backgroundColor: Color.fromARGB(255, 56, 53, 87),
              labelStyle: TextStyle(
                  color: Color.fromARGB(255, 56, 53, 87),
                ),
            ),
            SpeedDialChild(
                labelStyle: TextStyle(
                  color: Color.fromARGB(255, 56, 53, 87),
                ),
                onTap: () => setState(() {
                      mapType = MapType.hybrid;
                    }),
                child: Image(image: AssetImage('assets/hybrid.png')),
                label: 'Hybrid',
                backgroundColor: Color.fromARGB(255, 56, 53, 87)),
            SpeedDialChild(
                onTap: () => setState(() {
                      mapType = MapType.terrain;
                    }),
                child: Image(width: 30, image: AssetImage('assets/normal.png')),
                label: 'Terrain',
                labelStyle: TextStyle(
                  color: Color.fromARGB(255, 56, 53, 87),
                ),
                backgroundColor: Color.fromARGB(255, 56, 53, 87)),
            SpeedDialChild(
                onTap: () => setState(() {
                      mapType = MapType.normal;
                    }),
                child: Image(width: 30, image: AssetImage('assets/normal.png')),
                label: 'Normal',
                labelStyle: TextStyle(
                  color: Color.fromARGB(255, 56, 53, 87),
                ),
                backgroundColor: Color.fromARGB(255, 56, 53, 87)),
            SpeedDialChild(
              onTap: ()=>setState(() {
                traffic = !traffic;
              }),
                label: 'Traffic',
                labelStyle: TextStyle(
                  color: Color.fromARGB(255, 56, 53, 87),
                ),
                backgroundColor: Color.fromARGB(255, 56, 53, 87),
                child: Icon(
                  Icons.traffic,
                  color: Colors.white,
                ))
          ],
        ),
        appBar: AppBar(
         
          elevation: 0,
          backgroundColor: Color.fromARGB(255, 56, 53, 87),
          title: Text('Live Location'),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection(user!.email.toString())
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (_added) {
              mymap(snapshot);
            }
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            return GoogleMap(
                compassEnabled: true,
                indoorViewEnabled: true,
                myLocationEnabled: true,
                trafficEnabled: traffic,
                zoomControlsEnabled: false,
                mapType: mapType,
                markers: {
                  Marker(
                      position: LatLng(
                        snapshot.data!.docs.singleWhere((element) =>
                            element.id == widget.user_id)['latitude'],
                        snapshot.data!.docs.singleWhere((element) =>
                            element.id == widget.user_id)['longitude'],
                      ),
                      markerId: MarkerId('id'),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed)),
                },
                initialCameraPosition: CameraPosition(
                    target: LatLng(
                      snapshot.data!.docs.singleWhere(
                          (element) => element.id == widget.user_id)['latitude'],
                      snapshot.data!.docs.singleWhere(
                          (element) => element.id == widget.user_id)['longitude'],
                    ),
                    zoom: 14.47),
                onMapCreated: (GoogleMapController controller) async {
                  setState(() {
                    _controller = controller;
                    _added = true;
                  });
                },
              );
          },
        ));
  }

  Future<void> mymap(AsyncSnapshot<QuerySnapshot> snapshot) async {
    await _controller
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(
              snapshot.data!.docs.singleWhere(
                  (element) => element.id == widget.user_id)['latitude'],
              snapshot.data!.docs.singleWhere(
                  (element) => element.id == widget.user_id)['longitude'],
            ),
            zoom: 14.47)));
  }
 
  }

