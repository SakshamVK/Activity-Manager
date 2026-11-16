import '../constants/quotes.dart';
import '../models/quote.dart';

class QuoteService {
  static Quote getQuoteOfTheDay() {
    final now = DateTime.now();

    final dayNumber = now.difference(DateTime(2025, 1, 1)).inDays;

    return quotes[dayNumber % quotes.length];
  }
}
