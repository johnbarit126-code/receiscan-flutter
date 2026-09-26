import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/receipt_provider.dart';
import '../receipt_detail_screen.dart';

class ReceiptsTab extends StatefulWidget {
  const ReceiptsTab({Key? key}) : super(key: key);

  @override
  State<ReceiptsTab> createState() => _ReceiptsTabState();
}

class _ReceiptsTabState extends State<ReceiptsTab> {
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Food',
    'Transport',
    'Shopping',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipts'),
        elevation: 0,
      ),
      body: Consumer<ReceiptProvider>(
        builder: (context, receiptProvider, _) {
          final filteredReceipts = _selectedCategory == 'All'
              ? receiptProvider.receipts
              : receiptProvider.filterByCategory(_selectedCategory);

          return Column(
            children: [
              // Category Filter
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(category),
                        onSelected: (selected) =>
                            setState(() => _selectedCategory = category),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Receipts List
              Expanded(
                child: filteredReceipts.isEmpty
                    ? Center(
                        child: Text(
                          'No receipts found',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredReceipts.length,
                        itemBuilder: (context, index) {
                          final receipt = filteredReceipts[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ReceiptDetailScreen(receipt: receipt),
                                ),
                              ),
                              leading: receipt.imageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        receipt.imageUrl!,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF6366F1)
                                            .withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.receipt,
                                        color: Color(0xFF6366F1),
                                      ),
                                    ),
                              title: Text(receipt.vendor),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('MMM dd, yyyy')
                                        .format(receipt.date),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    receipt.category,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Text(
                                '₱${receipt.total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFF6366F1),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
