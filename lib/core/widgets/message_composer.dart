import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/theme/theme.dart';

class MessageComposer extends StatefulWidget {
  const MessageComposer({
    super.key,
    required this.onSend,
    this.maxLength = 1000,
  });

  final ValueChanged<String> onSend;
  final int maxLength;

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  final TextEditingController controller = TextEditingController();

  bool get canSend => controller.text.trim().isNotEmpty;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void send() {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    controller.clear();
    setState(() {});
    widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(
          top: BorderSide(color: AppColors.gold.withValues(alpha: 0.3)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                maxLength: widget.maxLength,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Type a message…',
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.ivory,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(color: AppColors.teal, width: 1.2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: canSend ? send : null,
              icon: const Icon(Icons.send_rounded),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.tealSoft,
                disabledForegroundColor: AppColors.muted,
                fixedSize: const Size(46, 46),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
