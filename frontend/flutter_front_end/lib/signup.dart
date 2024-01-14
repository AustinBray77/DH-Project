import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_front_end/elements.dart';
import 'package:http/http.dart' as http;

class SignupPage extends StatefulWidget {
  const SignupPage({super.key, required this.finalizeLogin});

  final void Function(String, int) finalizeLogin;

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  var name = "";
  var password = "";
  var email = "";
  var role = -1;
  var signupFailed = false;

  final List<DropdownMenuItem<int>> roles = [
    const DropdownMenuItem(value: -1,child: Text("Select a role...")),
    const DropdownMenuItem(value: 0,child: Text("Reporter")),
    const DropdownMenuItem(value: 1,child: Text("Volunteer")),
    const DropdownMenuItem(value: 2,child: Text("Finder"))
  ];

  void submitForm() {
    if(_formKey.currentState!.validate()) {
      trySignup();
    }
  }

  void trySignup() async {
    http.Response response = await http.post(
      Uri.parse("http://127.0.0.1:8000/sign-up"), 
      headers: <String, String> {
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role
      })
    );

    if(response.statusCode == 200)
    {
      widget.finalizeLogin(name, role);
      Navigator.pushNamed(context, '/');
    } else {
      setState(() {
        signupFailed = true;
        password = "";
      });
    }
  }

  void openCreateAccount() {
    Navigator.of(context).pushNamed('/login');
  }

  void goBack() {
    Navigator.of(context).pop();
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column (
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if(signupFailed) (
              const Dialog(
                child: Padding(padding: EdgeInsets.all(20), child: Text('Sign Up Failed'))
              )
            ) ,
            BigCard(
            child: 
            Column(
                  mainAxisAlignment: MainAxisAlignment.start, 
                  children: [
                    ElevatedButton(onPressed: goBack, child: const Icon(Icons.arrow_back)),
                    Column(
                      children: [
                        Text(
                          "Sign Up to Kittenz.io",
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              InputField( 
                                value: name,
                                validator: (value) {
                                  if(value == null || value.isEmpty) {
                                    return "Please enter a value";
                                  }
                                  name = value;
                                  return null;
                                },
                                label: const Text("Name"),
                                icon: const Icon(Icons.person_4_rounded),
                                password: false,
                              ),
                              InputField( 
                                value: email,
                                validator: (value) {
                                  if(value == null || value.isEmpty) {
                                    return "Please enter a value";
                                  }
                                  if(!value.contains('@')) {
                                    return "Invalid email";
                                  }
                                  email = value;
                                  return null;
                                },
                                label: const Text("Email"),
                                icon: const Icon(Icons.email),
                                password: false,
                              ),
                              SizedBox(
                                width: 400.0,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                                  child: 
                                  DropdownButton<int>(
                                    icon: const Icon(Icons.rocket),
                                    value: role,
                                    items: roles, 
                                    onChanged: (value) {
                                      if(value == null) {
                                        return;
                                      }
                                      setState(() {
                                        role = value;
                                      });
                                    },
                                  )
                                )
                              ),
                              InputField( 
                                value: password,
                                validator: (value) {
                                  if(value == null || value.isEmpty) {
                                    return "Please enter a value";
                                  }
                                  password = value;
                                  return null;
                                },
                                label: const Text("Password"),
                                icon: const Icon(Icons.password),
                                password: true,
                              ),
                              Wrap(
                                children: [ 
                                  ElevatedButton(onPressed: submitForm, child: const Text("Submit")),
                                  ElevatedButton(onPressed: openCreateAccount, child: const Text("Login"))
                                  ]
                              )
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            )
          )]
        )
      )
    );
  }
}