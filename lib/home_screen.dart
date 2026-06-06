import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _firestore = FirebaseFirestore.instance;

  final _namaMenuController = TextEditingController();
  final _hargaController = TextEditingController();
  final _kategoriController = TextEditingController();
  final _deskripsiController = TextEditingController();

  void _addMenu() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null &&
        _namaMenuController.text.isNotEmpty &&
        _hargaController.text.isNotEmpty) {
      await _firestore.collection('menu_cafe').add({
        'namaMenu': _namaMenuController.text,
        'harga': _hargaController.text,
        'kategori': _kategoriController.text,
        'deskripsi': _deskripsiController.text,
        'createdAt': Timestamp.now(),
        'userId': user.uid,
      });

      _namaMenuController.clear();
      _hargaController.clear();
      _kategoriController.clear();
      _deskripsiController.clear();
    }
  }

  void _deleteMenu(String docId) async {
    await _firestore.collection('menu_cafe').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 243, 192, 224),
        title: const Text('Menu Cafe'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Silahkan Masukkan Data Menu',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _namaMenuController,
              decoration: const InputDecoration(
                labelText: 'Nama Menu',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _hargaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Harga',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _kategoriController,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _deskripsiController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: _addMenu,
              child: const Text('Simpan Menu'),
            ),

            const SizedBox(height: 20),

            const Text(
              'Daftar Menu Cafe',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('menu_cafe')
                    .where('userId', isEqualTo: user?.uid)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('Belum ada menu'),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data =
                          docs[index].data() as Map<String, dynamic>;

                      return Card(
                        child: ListTile(
                          title: Text(data['namaMenu']),
                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text('Harga : Rp ${data['harga']}'),
                              Text('Kategori : ${data['kategori']}'),
                              Text(
                                  'Deskripsi : ${data['deskripsi']}'),
                            ],
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              _deleteMenu(docs[index].id);
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}