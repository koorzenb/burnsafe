import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

import '../models/burn_status.dart';

class WebScraperService {
  static const String _baseUrl = 'https://novascotia.ca/burnsafe';

  static Future<BurnStatus?> fetchBurnStatus() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl), headers: {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'});

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);

        // Find the Halifax County row and get the status
        final halifaxRow = document.querySelector('tr#Halifax-County');
        if (halifaxRow != null) {
          final statusCell = halifaxRow.querySelector('td');
          if (statusCell != null) {
            final status = statusCell.text.trim();
            return BurnStatus(status: status, lastUpdated: DateTime.now());
          }
        }
      }
    } catch (e) {
      print('Error fetching burn status: $e');
    }
    return null;
  }
}
