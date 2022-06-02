import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttergooglemaps/auth.dart';
import 'package:fluttergooglemaps/mymap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final user = FirebaseAuth.instance.currentUser;
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 56, 53, 87),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(onPressed: (){
            final provider = Provider.of<Auth>(context,listen: false);
              provider.signOut();
          }, icon:Icon(Icons.logout,color: Colors.white,))
        ],
        title: Text('Live Location Tracker',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
      ),
      
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 30, 0, 5),
              child: Text('Welcome ${user!.displayName.toString()}',style: TextStyle(color: Colors.white,fontSize: 25),),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Text('Email: ${user!.email.toString()}',style: TextStyle(color: Colors.white60),),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                 fixedSize: Size(200, 30),
                 onPrimary: Colors.black,
                primary: Colors.white
              ),
              icon: Icon(Icons.add), onPressed: _getLocation, label: Text('Add Live location')),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                fixedSize: Size(200, 30),
                onPrimary: Colors.black,
                primary: Colors.white
              ),
              icon: Icon(Icons.location_on), onPressed: _listenLocation, label: Text('Enable Live location')),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                 fixedSize: Size(200, 30),
                primary: Colors.white,
                onPrimary: Colors.black
              ),
              icon: Icon(Icons.location_off), onPressed: _stopListening, label: Text('Stop Live location')),
              SizedBox(height: 30,),    
             Expanded(
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection(user!.email.toString())
                          .snapshots(),
                      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }
                        return ListView.builder(
                            itemCount: snapshot.data?.docs.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(
                                    snapshot.data!.docs[index]['name'].toString(),
                                    style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontFamily: GoogleFonts.akronim.toString()),
                                    ),
                                subtitle: Row(
                                  children: [
                                    Text(snapshot.data!.docs[index]['latitude']
                                        .toString(),style: TextStyle(color: Colors.white54),),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(snapshot.data!.docs[index]['longitude']
                                        .toString(),style: TextStyle(color: Colors.white54)),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.directions,color: Colors.green[100]),
                                  onPressed: () {
                                    Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) =>
                                            MyMap(snapshot.data!.docs[index].id)));
                                  },
                                ),
                                leading: IconButton(
                                  icon: Icon(Icons.delete,color: Colors.redAccent,),
                                  onPressed: () {
                                    delete(snapshot.data!.docs[index]['name']);
                                  },
                                ),
                              );
                            });
                      })),
            
          ],
        ),
      ),
    );
  }

  delete(item) {
   final provider = Provider.of<Auth>(context,listen: false);
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection(user!.email.toString()).doc(item);

        documentReference.delete().whenComplete(() => print("deleted successfully"));
  }

   _getLocation() async {
    try {
      final loc.LocationData _locationResult = await location.getLocation();
      await FirebaseFirestore.instance.collection(user!.email.toString()).doc(user!.displayName).set({
        'latitude': _locationResult.latitude,
        'longitude': _locationResult.longitude,
        'name': user!.displayName.toString()
      }, SetOptions(merge: true));
    } catch (e) {
      print(e);
    }
  }

  Future<void> _listenLocation() async {
    _locationSubscription = location.onLocationChanged.handleError((onError) {
      print(onError);
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((loc.LocationData currentlocation) async {
      final provider = Provider.of<Auth>(context,listen: false);
      await FirebaseFirestore.instance.collection(user!.email.toString()).doc(user!.displayName).set({
        'latitude': currentlocation.latitude,
        'longitude': currentlocation.longitude,
        'name': user!.displayName.toString()
      }, SetOptions(merge: true));
    });
  }

  _stopListening() {
    _locationSubscription?.cancel();
    setState(() {
      _locationSubscription = null;
    });
  }

  _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print('done');
    } else if (status.isDenied) {
      _requestPermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }
}
