import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';
import '../services/local_auth_service.dart';

class AlertItem {
  final String title;
  final String time;
  final bool isDanger;
  final String alertType;
  final DateTime timestamp;

  AlertItem({
    required this.title,
    required this.time,
    this.isDanger = false,
    required this.alertType,
    required this.timestamp,
  });

  factory AlertItem.fromFirestore(Map<String, dynamic> data) {
    final alertType = data['alertType'] ?? 'unknown';
    final isDanger = alertType == 'left_zone' || alertType == 'battery_low';

    DateTime timestamp = DateTime.now();
    if (data['timestamp'] is Timestamp) {
      timestamp = (data['timestamp'] as Timestamp).toDate();
    }

    String title = _getTitleForType(alertType, data['petName'] ?? 'Pet');
    String time = _formatTime(timestamp);

    return AlertItem(
      title: title,
      time: time,
      isDanger: isDanger,
      alertType: alertType,
      timestamp: timestamp,
    );
  }

  static String _getTitleForType(String type, String petName) {
    switch (type) {
      case 'left_zone':
        return '$petName has left the safe zone';
      case 'returned_to_zone':
        return '$petName has returned to the safe zone';
      case 'battery_low':
        return 'Battery low (15%)';
      case 'device_offline':
        return 'Device went offline';
      case 'device_online':
        return 'Device is back online';
      default:
        return 'New alert: $type';
    }
  }

  static String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) {
      return 'just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return 'Today, ${dt.hour}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour < 12 ? 'AM' : 'PM'}';
    } else if (diff.inDays == 1) {
      return 'Yesterday, ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${dt.month}/${dt.day}/${dt.year}';
    }
  }
}

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final LocalAuthService _authService = LocalAuthService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String? _currentPetKey;

  @override
  void initState() {
    super.initState();
    _loadCurrentPetKey();
  }

  Future<void> _loadCurrentPetKey() async {
    final user = await _authService.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentPetKey = user?['petName']?.toString().toLowerCase() ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paleBlueBg,
      appBar: AppBar(
        title: const Text('Alerts'),
        backgroundColor: AppColors.lightBlueBg,
        foregroundColor: AppColors.primaryBlue,
        elevation: 0,
      ),
      body: _currentPetKey == null || _currentPetKey!.isEmpty
          ? const Center(child: Text('No user logged in'))
          : StreamBuilder<QuerySnapshot>(
              stream: _db
                  .collection('alerts')
                  .where('petKey', isEqualTo: _currentPetKey)
                  .orderBy('timestamp', descending: true)
                  .limit(50)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading alerts: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No alerts yet'));
                }

                final alerts = snapshot.data!.docs
                    .map((doc) => AlertItem.fromFirestore(
                        doc.data() as Map<String, dynamic>))
                    .toList();

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: alerts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final alert = alerts[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: alert.isDanger
                                ? AppColors.dangerRedBg
                                : AppColors.actionBlueBg,
                            child: Icon(
                              alert.isDanger
                                  ? Icons.warning_amber_rounded
                                  : Icons.notifications,
                              color: alert.isDanger
                                  ? AppColors.dangerRed
                                  : AppColors.primaryBlue,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(alert.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                                const SizedBox(height: 2),
                                Text(alert.time,
                                    style: const TextStyle(
                                        color: AppColors.textGrey,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
