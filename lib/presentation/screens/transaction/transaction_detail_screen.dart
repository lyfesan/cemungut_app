// lib/app/presentation/screens/transaction/transaction_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cemungut_app/app/models/pickup_order.dart';
import 'package:cemungut_app/app/services/firestore_service.dart';
import 'package:cemungut_app/app/models/waste_item.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class TransactionDetailScreen extends StatefulWidget {
  final PickupOrder order;

  const TransactionDetailScreen({super.key, required this.order});

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  bool _isLoading = false;

  Future<void> _updateOrderStatus(PickupStatus newStatus) async {
    // Tampilkan dialog konfirmasi
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Aksi'),
        content: Text(
            'Apakah Anda yakin ingin ${newStatus == PickupStatus.completed ? 'menyelesaikan' : 'membatalkan'} pesanan ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(newStatus == PickupStatus.completed ? 'Selesaikan' : 'Batalkan',
                  style: TextStyle(color: newStatus == PickupStatus.cancelled ? Colors.red : null))),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      // 1. Update status pesanan
      await FirestoreService.updatePickupOrderStatus(
        orderId: widget.order.id,
        status: newStatus,
      );

      // 2. Jika statusnya 'Selesai', tambahkan poin ke user
      if (newStatus == PickupStatus.completed) {
        // Panggil fungsi baru yang sudah menangani poin dan bonus
        await FirestoreService.completeTransactionAndAddPoints(
          userId: widget.order.userId,
          basePoints: widget.order.totalPoints,
          orderId: widget.order.id,
        );
      } else {
        // Jika hanya membatalkan, panggil fungsi update status biasa
        await FirestoreService.updatePickupOrderStatus(
          orderId: widget.order.id,
          status: newStatus,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status pesanan berhasil diperbarui!')),
      );

      // Kembali ke halaman sebelumnya dan kirim sinyal bahwa data berubah
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui status: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openMap(double latitude, double longitude) async {
    final Uri googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      // Tampilkan pesan error jika tidak bisa membuka Google Maps
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka aplikasi peta.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Transaksi')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Info Pesanan'),
                _buildInfoCard([
                  _buildDetailRow('ID Pesanan', widget.order.id),
                  _buildDetailRow('Nama Pemesan', widget.order.userName),
                  _buildDetailRow('Tanggal Jemput', DateFormat('d MMMM y, HH:mm', 'id_ID').format(widget.order.pickupTime.toDate())),
                  _buildDetailRow('Status', widget.order.status.name, status: widget.order.status),
                ]),
                const SizedBox(height: 20),
                // --- TAMBAHKAN KARTU ALAMAT DI SINI ---
                _buildSectionTitle('Lokasi Penjemputan'),
                _buildAddressCard(widget.order.address, widget.order.pickupLocation),
                const SizedBox(height: 20),
                // --- END ---
                _buildSectionTitle('Rincian Sampah'),
                _buildItemsCard(widget.order.items),
                if (widget.order.orderNote != null && widget.order.orderNote!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildSectionTitle('Catatan'),
                  _buildInfoCard([
                    Text(widget.order.orderNote!, style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic))
                  ]),
                ],
                const SizedBox(height: 20), // Beri spasi tambahan di bawah
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomNavigationBar: _buildActionButtons(),
    );
  }

  Widget _buildActionButtons() {
    // Hanya tampilkan tombol jika status belum selesai atau dibatalkan
    if (widget.order.status != PickupStatus.completed && widget.order.status != PickupStatus.cancelled) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Batalkan'),
                onPressed: () => _updateOrderStatus(PickupStatus.cancelled),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Selesaikan'),
                onPressed: () => _updateOrderStatus(PickupStatus.completed),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink(); // Kembalikan widget kosong jika tidak ada aksi
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildItemsCard(List<WasteItem> items) {
    final totalItems = items.fold(0, (sum, item) => sum + item.quantity);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ...items.map((item) => _buildDetailRow(
                item.displayName, 'x${item.quantity}')),
            const Divider(height: 24),
            _buildDetailRow('Total Item', '$totalItems', isBold: true),
            _buildDetailRow('Estimasi Poin', '+${widget.order.totalPoints}', isBold: true, valueColor: Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color? valueColor, PickupStatus? status}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          if (status != null)
            _StatusChip(status: status)
          else
            Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: valueColor,
                fontSize: 16,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(String address, GeoPoint location) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on_outlined, color: Colors.black54),
                const SizedBox(width: 8),
                Text(
                  'Alamat Penjemputan',
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              address,
              style: const TextStyle(fontSize: 16),
            ),
            const Divider(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.map_outlined),
                label: const Text('Buka di Peta'),
                onPressed: () => _openMap(location.latitude, location.longitude),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                  side: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
          ],
        ),
      ),
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