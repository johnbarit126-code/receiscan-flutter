import 'package:cloud_firestore/cloud_firestore.dart';

class Receipt {
  final String id;
  final String userId;
  final String vendor;
  final double total;
  final List<String> items;
  final DateTime date;
  final String? imageUrl;
  final String category;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Receipt({
    required this.id,
    required this.userId,
    required this.vendor,
    required this.total,
    required this.items,
    required this.date,
    this.imageUrl,
    required this.category,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Receipt.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Receipt(
      id: doc.id,
      userId: data['userId'] ?? '',
      vendor: data['vendor'] ?? '',
      total: (data['total'] ?? 0).toDouble(),
      items: List<String>.from(data['items'] ?? []),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: data['imageUrl'],
      category: data['category'] ?? 'Other',
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'vendor': vendor,
      'total': total,
      'items': items,
      'date': Timestamp.fromDate(date),
      'imageUrl': imageUrl,
      'category': category,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
