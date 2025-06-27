import 'package:flutter/material.dart';

import '../models/burn_status.dart';
import '../services/web_scraper_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BurnStatus? _currentStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentStatus();
  }

  Future<void> _fetchCurrentStatus() async {
    setState(() {
      _isLoading = true;
    });

    final status = await WebScraperService.fetchBurnStatus();
    setState(() {
      _currentStatus = status;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: const Text('BurnSafe Nova Scotia')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Halifax County Burn Status', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_currentStatus != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status: ${_currentStatus!.status}', style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 8),
                          Text(
                            'Last Updated: ${_currentStatus!.lastUpdated.toLocal().toString().split('.')[0]}',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
                      )
                    else
                      const Text('Unable to fetch status. Please check your internet connection.', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notification Schedule', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('• Daily notifications at 2:00 PM'),
                    Text('• Automatic status checking'),
                    Text('• Notifications for status changes'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(onPressed: StatusBarService.clearStatusBar, tooltip: 'Clear Notifications', heroTag: 'clear', child: const Icon(Icons.clear)),
          const SizedBox(height: 8),
          FloatingActionButton(onPressed: _fetchCurrentStatus, tooltip: 'Refresh Status', heroTag: 'refresh', child: const Icon(Icons.refresh)),
        ],
      ),
    );
  }
}
