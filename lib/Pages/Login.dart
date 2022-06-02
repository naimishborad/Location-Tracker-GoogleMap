import 'package:flutter/material.dart';
import 'package:fluttergooglemaps/Authentication/auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:provider/provider.dart';


class LogIn extends StatefulWidget {
  LogIn({Key? key}) : super(key: key);

  @override
  State<LogIn> createState() => _LogInState();
}


class _LogInState extends State<LogIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text('Welcome To Tracker App',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 30),),
      ),
      backgroundColor:  Color.fromARGB(255, 56, 53, 87),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             
              
               SizedBox(height: 50,),
              Padding(
                padding: const EdgeInsets.only(left: 90),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.black
                  ),
                  onPressed: (){
                  final provider = Provider.of<Auth>(context,listen: false);
                  provider.signInWithGoogle();
                }, icon: Icon(FontAwesomeIcons.google,color: Colors.red,), 
                   label: Text('Sign With Google')),
              ),
              SizedBox(height: 100,),
              
            ],
          ),
        ),
      )
    );
  }
}