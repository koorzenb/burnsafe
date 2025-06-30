import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/status_bar_service.dart';
import 'homescreen_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    HomescreenController.getOrPut.fetchCurrentStatus();
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
                child: GetBuilder<HomescreenController>(
                  builder: (homescreenController) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Halifax County Burn Status', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        if (homescreenController.isLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (homescreenController.currentStatus != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Status: ${HomescreenController.getOrPut.currentStatus!.status}', style: const TextStyle(fontSize: 18)),
                              const SizedBox(height: 8),
                              Text(
                                'Last Updated: ${HomescreenController.getOrPut.currentStatus!.lastUpdated.toLocal().toString().split('.')[0]}',
                                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                              ),
                            ],
                          )
                        else
                          const Text('Unable to fetch status. Please check your internet connection.', style: TextStyle(color: Colors.red)),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Notification Schedule', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    GetBuilder<HomescreenController>(
                      builder: (homeScreenController) {
                        return Text('• Next scheduled update:  ${homeScreenController.nextScheduledTime} ');
                      },
                    ),
                    const Text('• Automatic status checking'),
                    const Text('• Notifications for status changes'),
                    const SizedBox(height: 16),
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
          FloatingActionButton(
            onPressed: HomescreenController.getOrPut.fetchCurrentStatus,
            tooltip: 'Refresh Status',
            heroTag: 'refresh',
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}
