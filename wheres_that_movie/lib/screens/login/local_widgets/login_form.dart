// login_form.dart
// Author: Samuel Rudqvist
// Date Created: 08/31/2022

// Purpose:
//    A login form to be used on the login page


import 'package:streaming_service_lister/screens/logged_in/logged_in.dart';
import 'package:streaming_service_lister/widgets/my_container.dart';
import 'package:flutter/material.dart';

class MyLoginForm extends StatelessWidget {
  const MyLoginForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyContainer(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8.0),
            child: Text(
              "Log In", 
              style: TextStyle(
                color: Theme.of(context).secondaryHeaderColor,
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Theme(data: Theme.of(context).copyWith(primaryColor: Colors.red), child: 
          TextFormField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.alternate_email), 
              //prefixIconColor: Color.fromARGB(255, 255, 0, 0),
            hintText: "Email",
            ),
            autofocus: true,
          ),
          ),
          const SizedBox(
            height: 20.0,
          ),
          TextFormField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.lock_outline), 
              hintText: "Password",
            ),
            // Hide the input in the password field
            obscureText: true,
          ),
          const SizedBox(
            height: 20.0,
          ),
          ElevatedButton(  
            // style: ElevatedButton.styleFrom(
            //   primary: const Color.fromARGB(255, 255, 0, 0)
            // ),          
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 100),
              child: Text(
                "Log In", 
                style: TextStyle(
                  //color: Colors.white, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 20.0
                  ),
                ),
              ),
            onPressed: (){
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MyLoggedIn(),
                ),
              );
            }, // Do nothing for now            
          ),
          TextButton(
            child: const Text(
              "Don't have an account? Sign up here.", 
              style: TextStyle(
                color: Color.fromARGB(255, 255, 0, 0)
              ),
            ),
            onPressed: (){
              
            },
          ),
        ],
      ),
    );
  }
}