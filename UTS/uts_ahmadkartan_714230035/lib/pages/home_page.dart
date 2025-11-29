import 'package:flutter/material.dart';
import 'contact_list_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("UTS Pemrograman IV"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Ahmad Karta Nugraha\n714230035\nD4 TI 3A",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 36),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ContactListPage()),
                );
              },
              icon: const Icon(Icons.contacts),
              label: const Text("Open Contact List"),
            ),
          ],
        ),
      ),
    );
  }
}
