// lib/app/presentation/screens/transaction/transaction_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'package:cemungut_app/app/models/pickup_order.dart';
import 'package:cemungut_app/app/services/firestore_service.dart';
import 'transaction_detail_screen.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> with SingleTickerProviderStateMixin {
  late Future<List<PickupOrder>> _ordersFuture;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<PickupOrder> _allOrders = [];
  List<PickupOrder> _filteredOrders = [];

  // Urutan Tab sesuai dengan enum PickupStatus yang mungkin Anda punya
  final List<String> _tabs = ['Semua', 'Menunggu', 'Selesai', 'Dibatalkan'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadOrders();

    // Listener untuk memfilter list saat tab atau search berubah
    _tabController.addListener(_filterOrders);
    _searchController.addListener(_filterOrders);
  }

  void _loadOrders() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _ordersFuture = FirestoreService.getPickupOrdersForUser(user.uid);
      // Isi list awal saat future selesai
      _ordersFuture.then((orders) {
        setState(() {
          _allOrders = orders;
          _filteredOrders = orders;
        });
      });
    } else {
      // Handle jika user tidak login
      _ordersFuture = Future.value([]);
    }
  }

  void _filterOrders() {
    final query = _searchController.text.toLowerCase();
    final tabIndex = _tabController.index;

    setState(() {
      List<PickupOrder> tempOrders = List.from(_allOrders);

      // 1. Filter berdasarkan Tab
      if (tabIndex != 0) { // Jika bukan tab 'Semua'
        final selectedStatus = _getStatusFromTabIndex(tabIndex);
        tempOrders = tempOrders.where((order) {
          if (selectedStatus.length == 1) {
            return order.status == selectedStatus.first;
          }
          // Untuk tab 'Menunggu' yang bisa punya beberapa status
          return selectedStatus.contains(order.status);
        }).toList();
      }

      // 2. Filter berdasarkan Search Query
      if (query.isNotEmpty) {
        tempOrders = tempOrders.where((order) {
          // Cari di nama item atau catatan
          final hasMatchingItem = order.items.any((item) => item.displayName.toLowerCase().contains(query));
          final hasMatchingNote = order.orderNote?.toLowerCase().contains(query) ?? false;
          return hasMatchingItem || hasMatchingNote;
        }).toList();
      }

      _filteredOrders = tempOrders;
    });
  }

  List<PickupStatus> _getStatusFromTabIndex(int index) {
    switch (index) {
      case 1: // Menunggu
        return [PickupStatus.pending, PickupStatus.confirmed, PickupStatus.in_progress];
      case 2: // Selesai
        return [PickupStatus.completed];
      case 3: // Dibatalkan
        return [PickupStatus.cancelled];
      default: // Semua
        return [];
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   // centerTitle: true,
        //   // title: Text(
        //   //     'Transaksi',
        //   //     style: TextStyle(
        //   //         fontSize: 28,
        //   //         fontWeight: FontWeight.bold,
        //   //         color: Theme.of(context).colorScheme.primary
        //   //     )
        //   // ),
        //   // elevation: 1,
        // ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari transaksi...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ),
            // Tab Bar
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: _tabs.map((label) => Tab(text: label)).toList(),
            ),
            // Transaction List
            Expanded(
              child: FutureBuilder<List<PickupOrder>>(
                future: _ordersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (_filteredOrders.isEmpty) {
                    return const Center(child: Text('Tidak ada transaksi ditemukan.'));
                  }
      
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = _filteredOrders[index];
                      return _TransactionCard(
                          order: order,
                          onRefresh:  _loadOrders,
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

class _TransactionCard extends StatelessWidget {
  final PickupOrder order;
  final VoidCallback onRefresh;

  const _TransactionCard({required this.order, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final totalItems = order.items.fold<int>(0, (sum, item) => sum + item.quantity);

    // Helper untuk ringkasan item
    String itemSummary = order.items.map((e) => e.displayName).join(', ');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        onTap: () async {
          // Navigasi ke halaman detail dan tunggu hasilnya
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionDetailScreen(order: order),
            ),
          );

          // Jika hasilnya 'true' (artinya ada perubahan), panggil refresh
          if (result == true) {
            onRefresh();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Tanggal & Status
              Row(
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 20, color: Colors.black54),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('d MMMM y / HH:mm', 'id_ID').format(order.pickupTime.toDate()),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  _StatusChip(status: order.status),
                ],
              ),
              const Divider(height: 24),
              // Body: Rincian Sampah
              Text(
                'Sampah: $itemSummary',
                style: TextStyle(color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              // Footer: Poin & Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('Total Poin '),
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(
                        ' ${order.estimatedPoints}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E824C)),
                      ),
                    ],
                  ),
                  Text('Total: $totalItems item', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      )

    );
  }
}

class _StatusChip extends StatelessWidget {
  final PickupStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color chipColor;
    String label;

    switch (status) {
      case PickupStatus.completed:
        chipColor = Colors.green;
        label = 'Selesai';
        break;
      case PickupStatus.cancelled:
        chipColor = Colors.red;
        label = 'Dibatalkan';
        break;
      default:
        chipColor = Colors.orange;
        label = 'Diproses';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: chipColor, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}