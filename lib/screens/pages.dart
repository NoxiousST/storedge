import 'package:flutter/material.dart';

class Page1 extends StatelessWidget {
  const Page1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            ElevatedButton(
              child: const Text('Page2'),
              onPressed: () => Navigator.push(
                  context,
                  PageRouteBuilder(
                      transitionDuration: const Duration(seconds: 2),
                      pageBuilder: (_, __, ___) => const Page2())),
            ),
            const Hero(tag: 'home', child: Icon(Icons.home))
          ],
        ),
      ),
    );
  }
}

class Page2 extends StatelessWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Hero(
          tag: 'home',
          child: Icon(
            Icons.home,
          ),
        ),
      );
  }
}

class Page3 extends StatelessWidget {
  const Page3({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class Page4 extends StatelessWidget {
  const Page4({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
