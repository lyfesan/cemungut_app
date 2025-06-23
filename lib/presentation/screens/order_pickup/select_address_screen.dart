// lib/presentation/screens/order_pickup/select_address_screen.dart
import 'package:cemungut_app/app/models/address.dart';
import 'package:cemungut_app/app/services/firestore_service.dart';
import 'package:cemungut_app/presentation/screens/profile/add_edit_address_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SelectAddressScreen extends StatelessWidget {
  const SelectAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Alamat Penjemputan'),
      ),
      body: StreamBuilder<List<Address>>(
        stream: FirestoreService.getAddresses(userId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Anda belum memiliki alamat tersimpan.'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      // Navigate to add address and wait for result
                      await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const AddEditAddressScreen(),
                      ));
                      // The stream will rebuild automatically
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Alamat Baru'),
                  ),
                ],
              ),
            );
          }

          final addresses = snapshot.data!;

          return ListView.separated(
            itemCount: addresses.length + 1, // +1 for the "Add new" button
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              if (index == addresses.length) {
                // Last item is the button
                return ListTile(
                  leading: const Icon(Icons.add_location_alt_outlined),
                  title: const Text('Tambah Alamat Baru'),
                  onTap: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const AddEditAddressScreen(),
                    ));
                  },
                );
              }

              final address = addresses[index];
              return ListTile(
                leading: const Icon(Icons.location_city),
                title: Text(address.name),
                subtitle: Text(address.addressDetail),
                onTap: () {
                  // Return the selected address to the previous screen
                  Navigator.of(context).pop(address);
                },
              );
            },
          );
        },
      ),
    );
  }
}