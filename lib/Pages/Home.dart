import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttergooglemaps/Authentication/auth.dart';
import 'package:fluttergooglemaps/Pages/mymap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

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
      backgroundColor: const Color.fromARGB(255, 56, 53, 87),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(onPressed: (){
            final provider = Provider.of<Auth>(context,listen: false);
              provider.signOut();
          }, icon:const Icon(Icons.logout,color: Colors.white,))
        ],
        title: const Text('Live Location Tracker',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
      ),
      
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 30, 0, 5),
              child: Text('Welcome ${user!.displayName.toString()}',style: const TextStyle(color: Colors.white,fontSize: 25),),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Text('Email: ${user!.email.toString()}',style: const TextStyle(color: Colors.white60),),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                 fixedSize: const Size(200, 30),
                 onPrimary: Colors.black,
                primary: Colors.white
              ),
              icon: const Icon(Icons.add), onPressed: _getLocation, label: const Text('Add Live location')),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                fixedSize: const Size(200, 30),
                onPrimary: Colors.black,
                primary: Colors.white
              ),
              icon: const Icon(Icons.location_on), onPressed: _listenLocation, label: const Text('Enable Live location')),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                 fixedSize: const Size(200, 30),
                primary: Colors.white,
                onPrimary: Colors.black
              ),
              icon: const Icon(Icons.location_off), onPressed: _stopListening, label: const Text('Stop Live location')),
              const SizedBox(height: 30,),    
             Expanded(
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection(user!.email.toString())
                          .snapshots(),
                      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
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
                                        .toString(),style: const TextStyle(color: Colors.white54),),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Text(snapshot.data!.docs[index]['longitude']
                                        .toString(),style: const TextStyle(color: Colors.white54)),
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
                                  icon: const Icon(Icons.delete,color: Colors.redAccent,),
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
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection(user!.email.toString()).doc(item);

        // ignore: avoid_print
        documentReference.delete().whenComplete(() => print("deleted successfully"));
  }

   _getLocation() async {
    try {
      final loc.LocationData locationResult = await location.getLocation();
      await FirebaseFirestore.instance.collection(user!.email.toString()).doc(user!.displayName).set({
        'latitude': locationResult.latitude,
        'longitude': locationResult.longitude,
        'name': user!.displayName.toString()
      }, SetOptions(merge: true));
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  Future<void> _listenLocation() async {
    _locationSubscription = location.onLocationChanged.handleError((onError) {
      // ignore: avoid_print
      print(onError);
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((loc.LocationData currentlocation) async {
      
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
      // ignore: avoid_print
      print('done');
    } else if (status.isDenied) {
      _requestPermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }
}
