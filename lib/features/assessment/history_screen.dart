import 'package:flutter/material.dart';
import 'package:khel_mitra/features/assessment/data/attempts_repository.dart';
import 'package:khel_mitra/features/assessment/models/attempt_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final AttemptsRepository _attemptsRepo = AttemptsRepository();
  List<AttemptModel> _attempts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttempts();
  }

  Future<void> _loadAttempts() async {
    final attempts = await _attemptsRepo.getAttempts();
    setState(() {
      _attempts = attempts.reversed.toList(); // Most recent first
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Jump History"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _attempts.isEmpty
              ? _buildEmptyState()
              : _buildAttemptsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey.shade600),
          const SizedBox(height: 16),
          Text(
            "No attempts yet",
            style: TextStyle(fontSize: 18, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 8),
          Text(
            "Complete a jump test to see your history",
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildAttemptsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _attempts.length,
      itemBuilder: (context, index) {
        final attempt = _attempts[index];
        return _buildAttemptCard(attempt, index);
      },
    );
  }

  Widget _buildAttemptCard(AttemptModel attempt, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // Rank/Number
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getRankColor(index),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "${index + 1}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(attempt.timestamp),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(
                  _formatTime(attempt.timestamp),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
          // Jump Height
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                attempt.jumpHeightCm.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "cm",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int index) {
    if (index == 0) return Colors.amber;
    if (index == 1) return Colors.grey.shade400;
    if (index == 2) return Colors.orange.shade700;
    return Colors.blueGrey;
  }

  String _formatDate(DateTime timestamp) {
    final now = DateTime.now();
    if (timestamp.day == now.day && timestamp.month == now.month && timestamp.year == now.year) {
      return "Today";
    }
    return "${timestamp.day}/${timestamp.month}/${timestamp.year}";
  }

  String _formatTime(DateTime timestamp) {
    return "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}";
  }
}
