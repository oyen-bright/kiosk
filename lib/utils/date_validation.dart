bool validateDateFormat(String input) {
  RegExp regex = RegExp(r'^((20[2-3][0-9]|204[0-9]|205[0-5])-'
      r'(0[1-9]|1[0-2])-'
      r'(0[1-9]|[12][0-9]|3[01]))$');
  return regex.hasMatch(input);
}
