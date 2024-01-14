import 'package:flutter/material.dart';
import 'package:flutter_front_end/elements.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  void openLogin() {
    Navigator.of(context).pushNamed('/login');
  }

  void openCreateAccount() {
    Navigator.of(context).pushNamed('/signup');
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            BigCard(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to Kittnz.io',
                    style: Theme.of(context).textTheme.headlineLarge
                  ),
                  Image(
                      image: Image.network("https://imgs.search.brave.com/HBSmjZWons7K4gvGmTR1ztvwpcVwPhFWJR-X5QFgy-M/rs:fit:860:0:0/g:ce/aHR0cHM6Ly93d3cu/cmQuY29tL3dwLWNv/bnRlbnQvdXBsb2Fk/cy8yMDIxLzA0L0dl/dHR5SW1hZ2VzLTkz/NjE3NjU0Ni5qcGc").image,
                      height: 200,
                      width: 400,
                    ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Wrap(children: [
                      ElevatedButton(onPressed: openLogin, child: const Text( "Login" )),
                      ElevatedButton(onPressed: openCreateAccount, child: const Text("Create Account"))
                    ]),
                  ),
                 
                ],
              ),
            ),
            
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}