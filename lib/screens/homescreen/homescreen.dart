import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'homescreen_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomescreenController>();

    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: const Text('BurnSafe Nova Scotia')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => Card(
                child: Container(
                  decoration: BoxDecoration(color: controller.backgroundColor.value, borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halifax County Burn Status',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: controller.textColor.value),
                        ),
                        const SizedBox(height: 16),
                        if (controller.isLoading.value)
                          const Center(child: CircularProgressIndicator())
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Status: ${controller.isBurningAllowedText.value}', style: const TextStyle(fontSize: 18)),
                              const SizedBox(height: 8),
                              if (controller.currentStatus.value != null)
                                Text(
                                  'Last Updated: ${controller.currentStatus.value!.lastUpdated.toLocal().toString().split('.')[0]}',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
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
                    Obx(() => Text('• Next scheduled update:  ${controller.nextScheduledTime.value}')),
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
          // Refresh button now calls the instance method
          FloatingActionButton(onPressed: controller.fetchAndSaveStatus, tooltip: 'Refresh Status', heroTag: 'refresh', child: const Icon(Icons.refresh)),
        ],
      ),
    );
  }
}
