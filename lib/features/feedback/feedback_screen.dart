import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/feedback_record.dart';
import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/widgets/error_retry_card.dart';
import 'package:gest_managment_app/core/widgets/loading_view.dart';
import 'package:gest_managment_app/features/feedback/feedback_detail_screen.dart';
import 'package:gest_managment_app/features/feedback/new_feedback_screen.dart';
import 'package:gest_managment_app/features/feedback/widgets/feedback_record_card.dart';
import 'package:gest_managment_app/features/feedback/widgets/feedback_summary_strip.dart';
import 'package:gest_managment_app/features/feedback/widgets/no_feedback_view.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  bool _loading = false;
  String? _error;
  List<FeedbackRecord> _records = <FeedbackRecord>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final records = await ApiService().getMyFeedback();
      if (!mounted) return;
      setState(() => _records = records);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load your feedback. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _openForm() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NewFeedbackScreen()),
    );
    if (!mounted) return;
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Feedback')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: LoadingView())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: ErrorRetryCard(
                        message: _error!,
                        onRetry: _load,
                      ),
                    ),
                  )
                : _records.isEmpty
                    ? NoFeedbackView(onAdd: _openForm)
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
                        itemCount: _records.length + 1,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return FeedbackSummaryStrip(records: _records);
                          }

                          final record = _records[index - 1];
                          return FeedbackRecordCard(
                            record: record,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FeedbackDetailScreen(record: record),
                                ),
                              );
                            },
                          );
                        },
                      ),
      ),
      floatingActionButton: _records.isEmpty || _loading || _error != null
          ? null
          : FloatingActionButton.extended(
              onPressed: _openForm,
              backgroundColor: AppColors.teal,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('New'),
            ),
    );
  }
}
