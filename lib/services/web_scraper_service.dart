import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

import '../models/burn_status.dart';

class WebScraperService {
  static const String _baseUrl = 'https://novascotia.ca/burnsafe';

  static Future<BurnStatus> fetchBurnStatus() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl), headers: {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'});

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);
        final halifaxRow = document.querySelector('tr#Halifax-County');

        if (halifaxRow != null) {
          final statusCell = halifaxRow.querySelector('td');
          if (statusCell != null) {
            final statusString = statusCell.attributes['class']?.trim() ?? 'status-no-burn';
            debugPrint('Fetched burn status string: $statusString');
            final statusType = _parseStatusFromString(statusString);
            return BurnStatus(statusType: statusType, lastUpdated: DateTime.now());
          }
        }
      }
    } catch (e) {
      print('Error fetching burn status: $e');
    }
    return BurnStatus(statusType: BurnStatusType.unknown, lastUpdated: DateTime.now());
  }

  /// Parses the raw string from the website into a BurnStatusType enum.
  /// This logic is now correctly encapsulated within the service.
  static BurnStatusType _parseStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'status-burn':
        return BurnStatusType.burn;
      case 'status-restricted':
        return BurnStatusType.restricted;
      case 'status-no-burn':
        return BurnStatusType.noBurn;
      default:
        return BurnStatusType.unknown;
    }
  }
}
