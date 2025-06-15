import 'package:flutter/material.dart';

class RewardScreen extends StatelessWidget {
  const RewardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reward"),
        centerTitle: true,
        backgroundColor: Colors.green,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.history), // ikon histori
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPointsCard(context),
            const SizedBox(height: 16),
            _buildFilterChips(),
            const SizedBox(height: 16),
            Expanded(child: _buildRewardList()),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsCard(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.green[100],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("81 Poin",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("269 CemPoin menuju Gold",
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: 81 / 350,
              backgroundColor: Colors.grey[300],
              color: Colors.green[800],
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 6),
            const Text("Bonus 3% poin tiap transaksi",
                style: TextStyle(fontSize: 12, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Wrap(
      spacing: 8,
      children: [
        FilterChip(label: const Text("Semua"), selected: true, onSelected: (_) {}),
        FilterChip(label: const Text("Saldo"), selected: false, onSelected: (_) {}),
        FilterChip(label: const Text("Voucher"), selected: false, onSelected: (_) {}),
        FilterChip(label: const Text("Kupon"), selected: false, onSelected: (_) {}),
      ],
    );
  }

  Widget _buildRewardList() {
    final rewards = [
      {'name': 'Saldo Gopay Rp. 5000', 'point': 500},
      {'name': 'Saldo Gopay Rp. 10000', 'point': 900},
    ];

    return ListView.builder(
      itemCount: rewards.length,
      itemBuilder: (context, index) {
        final reward = rewards[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.lightBlue[100],
          child: ListTile(
            leading: const Icon(Icons.account_balance_wallet_rounded, size: 40),
            title: Text("${reward['name']}"),
            subtitle: Text("${reward['point']} Poin"),
            trailing: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Tukar"),
            ),
          ),
        );
      },
    );
  }
}
