import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_front_end/elements.dart';
import 'package:http/http.dart' as http;
class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.finalizeLogin});

  final void Function(String, int) finalizeLogin;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  var email = "";
  var password = "";
  var loginFailed = false;

  void submitForm() {
    if(_formKey.currentState!.validate()) {
      tryLogin();
    }
  }

  void tryLogin() async {
    // Makes request to server to try and login
    http.Response response = await http.post(
      Uri.parse("http://127.0.0.1:8000/login"), 
      headers: <String, String> {
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode({
        'email': email,
        'password': password
      })
    );
    
    var body = jsonDecode(response.body) as Map<String, dynamic>;

    if(response.statusCode == 200)
    {
      widget.finalizeLogin(body["name"], body["role"]);
    } else {
      setState(() {
        loginFailed = true;
        password = "";
      });
    }
  }

  void openCreateAccount() {
    Navigator.of(context).pushNamed('/signup');
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
            if(loginFailed) (
              const Dialog(
                child: Padding(padding: EdgeInsets.all(20), child: Text('Login Failed'))
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
                          "Login to Kittenz.io",
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
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
                                  ElevatedButton(onPressed: openCreateAccount, child: const Text("Create Account"))
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