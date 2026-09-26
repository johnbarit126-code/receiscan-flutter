import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../providers/receipt_provider.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
      ),
      body: Consumer<ReceiptProvider>(
        builder: (context, receiptProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Spent Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF6366F1),
                        Color(0xFF8B5CF6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Spent',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₱${receiptProvider.totalSpent.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${receiptProvider.receipts.length} receipts',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Category Distribution
                Text(
                  'Spending by Category',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildCategoryChart(context, receiptProvider),
                const SizedBox(height: 32),

                // Recent Receipts
                Text(
                  'Recent Receipts',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                receiptProvider.receipts.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'No receipts yet. Start scanning!',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: receiptProvider.receipts.length > 5
                            ? 5
                            : receiptProvider.receipts.length,
                        itemBuilder: (context, index) {
                          final receipt = receiptProvider.receipts[index];
                          return _buildReceiptTile(context, receipt);
                        },
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChart(
      BuildContext context, ReceiptProvider receiptProvider) {
    final categories = <String, double>{};
    for (final receipt in receiptProvider.receipts) {
      categories[receipt.category] =
          (categories[receipt.category] ?? 0) + receipt.total;
    }

    if (categories.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No data',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: PieChart(
          PieChartData(
            sections: categories.entries
                .map(
                  (e) => PieChartSectionData(
                    value: e.value,
                    title: e.key,
                    radius: 50,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptTile(BuildContext context, dynamic receipt) {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF6366F1).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.receipt,
          color: Color(0xFF6366F1),
        ),
      ),
      title: Text(receipt.vendor),
      subtitle: Text(DateFormat('MMM dd, yyyy').format(receipt.date)),
      trailing: Text(
        '₱${receipt.total.toStringAsFixed(2)}',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF6366F1),
        ),
      ),
    );
  }
}
