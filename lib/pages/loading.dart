import 'package:flutter/material.dart';

void main() {
  runApp(const Loading());
}

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoadingState();
  }
}

class _LoadingState extends State<Loading> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlueAccent,
          elevation: 0,
          title: const Text('Scan QR Code'),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.menu_sharp,
              ),
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/pic1.png'), // Path to your image
              fit: BoxFit.cover, // Adjust how the image fills the container
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 300.0, 16.0, 16.0),
            child: Center(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 70.0,
                  child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.popAndPushNamed(context, '/scan');
                      },
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Scan by camera',
                          style: TextStyle(fontSize: 20.0))),
                ),
                const SizedBox(
                  height: 50.0,
                ),
                SizedBox(
                  height: 70.0,
                  child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.popAndPushNamed(context, '/scan_gallery');
                      },
                      icon: const Icon(Icons.photo),
                      label: const Text('Scan from gallery',
                          style: TextStyle(fontSize: 20.0))),
                )
              ],
            )),
          ),
        ),
      ),
    ));
  }
}
