String amountFormatter(dynamic amount, [String currency = ""]) {
  double value = double.tryParse(amount.toString()) ?? 0.0;
  String formattedAmount = value.toStringAsFixed(2);
  List<String> parts = formattedAmount.split('.');
  RegExp pattern = RegExp(r'\B(?=(\d{3})+(?!\d))');
  parts[0] = parts[0].replaceAll(pattern, ',');
  return currency + parts.join('.');
}
