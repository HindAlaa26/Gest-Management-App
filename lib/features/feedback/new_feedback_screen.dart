import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/feedback_item.dart';
import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/feedback_labels.dart';
import 'package:gest_managment_app/core/utils/named_lookup.dart';
import 'package:gest_managment_app/core/widgets/category_option_tile.dart';
import 'package:gest_managment_app/core/widgets/loading_button.dart';
import 'package:gest_managment_app/core/widgets/segmented_toggle.dart';
import 'package:gest_managment_app/core/widgets/section_label.dart';
import 'package:gest_managment_app/features/feedback/feedback_sent_screen.dart';

class NewFeedbackScreen extends StatefulWidget {
  const NewFeedbackScreen({super.key});

  @override
  State<NewFeedbackScreen> createState() => _NewFeedbackScreenState();
}

class _NewFeedbackScreenState extends State<NewFeedbackScreen> {
  static const int maxMessageLength = 2000;
  static const int tilesPerRow = 4;

  final TextEditingController messageController = TextEditingController();

  String? selectedTypeCode;
  String? selectedCategoryCode;
  bool loading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadLookups();
  }

  Future<void> _loadLookups() async {
    await Future.wait([
      Lookups.feedbackTypes.ensureLoaded(),
      Lookups.feedbackCategories.ensureLoaded(),
    ]);
    if (mounted) setState(() {});
  }

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

  String get _typeCode =>
      selectedTypeCode ?? Lookups.feedbackTypes.options.first.code;

  String get _categoryCode =>
      selectedCategoryCode ?? Lookups.feedbackCategories.options.first.code;

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
      typeCode: _typeCode,
      categoryCode: _categoryCode,
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

  List<Widget> _categoryRows(List<LookupOption> categories) {
    final rows = <Widget>[];
    for (var start = 0; start < categories.length; start += tilesPerRow) {
      final cells = <Widget>[];
      for (var i = 0; i < tilesPerRow; i++) {
        if (i > 0) cells.add(const SizedBox(width: 10));
        final index = start + i;
        if (index >= categories.length) {
          cells.add(const Expanded(child: SizedBox.shrink()));
          continue;
        }
        final option = categories[index];
        cells.add(
          CategoryOptionTile(
            icon: feedbackCategoryIcon(option.code),
            label: option.name,
            selected: _categoryCode == option.code,
            onTap: () {
              setState(() {
                selectedCategoryCode = option.code;
                error = null;
              });
            },
          ),
        );
      }
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 10));
      rows.add(Row(children: cells));
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final messageLength = messageController.text.length;
    final types = Lookups.feedbackTypes.options;
    final categories = Lookups.feedbackCategories.options;
    final typeIndex = types.indexWhere((t) => t.code == _typeCode);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New message'),
      ),
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
                        labels: [for (final type in types) type.name],
                        selectedIndex: typeIndex < 0 ? 0 : typeIndex,
                        onChanged: (index) {
                          setState(() {
                            selectedTypeCode = types[index].code;
                            error = null;
                          });
                        },
                      ),
                      const SizedBox(height: 22),
                      const SectionLabel('Category'),
                      const SizedBox(height: 12),
                      Column(children: _categoryRows(categories)),
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
