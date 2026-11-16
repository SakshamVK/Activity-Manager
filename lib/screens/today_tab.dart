import 'package:activity_manager/providers/daily_record_provider.dart';
import 'package:flutter/material.dart';
import '../theme/styles.dart';
import '../models/quote.dart';
import '../services/quote_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/activity_section.dart';

class TodayTab extends ConsumerStatefulWidget {
  const TodayTab({super.key});

  @override
  ConsumerState<TodayTab> createState() => _TodayTabState();
}

class _TodayTabState extends ConsumerState<TodayTab> {
  late final Quote quote;
  late final TextEditingController notesController;

  @override
  void initState() {
    super.initState();

    quote = QuoteService.getQuoteOfTheDay();

    notesController = TextEditingController(
      text: ref.read(dailyRecordProvider).notes,
    );
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppStyle.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border(
                          left: BorderSide(color: AppStyle.gold, width: 2.0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 4.0,
                            decoration: BoxDecoration(color: AppStyle.goldDim),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '"${quote.text}"',
                                    softWrap: true,
                                    style: TextStyle(
                                      color: AppStyle.textDim,
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  Text(
                                    "— ${quote.author}",
                                    softWrap: true,
                                    style: TextStyle(
                                      color: AppStyle.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 14.0),
                  ActivitySection(categoryId: 1),

                  ActivitySection(categoryId: 2),

                  ActivitySection(categoryId: 3),

                  ActivitySection(categoryId: 4),
                  ActivitySection(categoryId: 5),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      "TODAY'S NOTES",
                      style: AppStyle.header.copyWith(
                        height: 1.5,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(height: 14.0),
                  TextField(
                    controller: notesController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Write your thoughts for today...',
                      filled: true,
                      fillColor: AppStyle.surface,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppStyle.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppStyle.border),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppStyle.border),
                      ),
                    ),
                    style: TextStyle(color: AppStyle.textDim),
                  ),
                  SizedBox(height: 14.0),
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(dailyRecordProvider.notifier)
                          .saveNotes(notesController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyle.blue.withValues(alpha: 0.08),
                      foregroundColor: AppStyle.blue,
                      side: const BorderSide(color: AppStyle.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Save', style: TextStyle(color: AppStyle.blue)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
