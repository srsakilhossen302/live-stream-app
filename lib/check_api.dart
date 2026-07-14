import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  try {
    final response = await http.get(Uri.parse('http://10.10.26.173:5007/api/v1/products?allowTrade=true'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List products = data['data'] ?? [];
      if (products.isNotEmpty) {
        final first = products.first;
        print(const JsonEncoder.withIndent('  ').convert(first));
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}
