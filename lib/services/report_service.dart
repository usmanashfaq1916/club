class ReportService {
  // Report generation methods - structure for future implementation
  // Uses pdf and excel packages imported via pubspec.yaml

  static String sanitizeForExport(String text) {
    return text.replaceAll(RegExp(r'[,\n\r]'), ' ');
  }

  static String formatCurrency(double amount) {
    return 'Rs. ${amount.toStringAsFixed(2)}';
  }
}
