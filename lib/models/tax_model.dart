class Tax {
  final int rate;
  final double total;

  Tax({required this.rate, required this.total});

  factory Tax.fromJson(Map<String, dynamic> json) {
    int rate = 0;
    try {
      rate = int.parse(json['rate'].toString());
    } catch (_) {}
    double total = 0;
    try {
      total = double.parse(json['total'].toString());
    } catch (_) {}
    return Tax(rate: rate, total: total);
  }
}
