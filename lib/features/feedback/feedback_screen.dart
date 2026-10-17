import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/feedback_item.dart';
import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/widgets/category_option_tile.dart';
import 'package:gest_managment_app/core/widgets/loading_button.dart';
import 'package:gest_managment_app/core/widgets/segmented_toggle.dart';
import 'package:gest_managment_app/core/widgets/section_label.dart';
import 'package:gest_managment_app/features/feedback/feedback_sent_screen.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  static const int maxMessageLength = 1000;

  final TextEditingController messageController = TextEditingController();

  int selectedTypeIndex = 0;
  FeedbackCategory selectedCategory = FeedbackCategory.room;
  bool loading = false;
  String? error;

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void clearError() {
    if (error != null) {
      setState(() {
        error = null;
      });
    }
  }

  Future<void> sendFeedback() async {
    final message = messageController.text.trim();
    if (message.isEmpty) {
      setState(() {
        error = 'Please write a message';
      });
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    final item = FeedbackItem(
      type: selectedTypeIndex == 0 ? FeedbackType.feedback : FeedbackType.complaint,
      category: selectedCategory,
      message: message,
    );

    try {
      final reference = await ApiService().sendFeedback(item);
      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FeedbackSentScreen(reference: reference),
        ),
      );

      if (!mounted) return;
      setState(() {
        messageController.clear();
        selectedTypeIndex = 0;
        selectedCategory = FeedbackCategory.room;
        error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        error = 'Could not send. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final messageLength = messageController.text.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SegmentedToggle(
                        labels: const ['Feedback', 'Complaint'],
                        selectedIndex: selectedTypeIndex,
                        onChanged: (index) {
                          setState(() {
                            selectedTypeIndex = index;
                            error = null;
                          });
                        },
                      ),
                      const SizedBox(height: 22),
                      const SectionLabel('Category'),
                      const SizedBox(height: 12),
                      
                      Row(
                       
                        children: [
                          CategoryOptionTile(
                            icon: Icons.bed_outlined,
                            label: 'Room',
                            selected: selectedCategory == FeedbackCategory.room,
                            onTap: () {
                              setState(() {
                                selectedCategory = FeedbackCategory.room;
                                error = null;
                              });
                            },
                          ),
                          const SizedBox(width: 10),
                          CategoryOptionTile(
                            icon: Icons.restaurant_outlined,
                            label: 'Food',
                            selected: selectedCategory == FeedbackCategory.food,
                            onTap: () {
                              setState(() {
                                selectedCategory = FeedbackCategory.food;
                                error = null;
                              });
                            },
                          ),
                          const SizedBox(width: 10),
                          CategoryOptionTile(
                            icon: Icons.person_outline,
                            label: 'Staff',
                            selected: selectedCategory == FeedbackCategory.staff,
                            onTap: () {
                              setState(() {
                                selectedCategory = FeedbackCategory.staff;
                                error = null;
                              });
                            },
                          ),
                          const SizedBox(width: 10),
                          CategoryOptionTile(
                            icon: Icons.more_horiz,
                            label: 'Other',
                            selected: selectedCategory == FeedbackCategory.other,
                            onTap: () {
                              setState(() {
                                selectedCategory = FeedbackCategory.other;
                                error = null;
                              });
                            },
                          ),
                        ],
                      ),
                     
                     
                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SectionLabel('Your message'),
                          Text(
                            '$messageLength / $maxMessageLength',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: messageController,
                        maxLength: maxMessageLength,
                        minLines: 5,
                        maxLines: 8,
                        onChanged: (_) {
                          clearError();
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          hintText: 'Write your message here',
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      LoadingButton(
                        label: 'Send',
                        loading: loading,
                        onPressed: loading ? null : sendFeedback,
                        trailingIcon: Icons.arrow_forward,
                      ),
                      if (error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          error!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
