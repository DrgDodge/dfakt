import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/sync_service.dart';
import '../providers/app_provider.dart';
import '../widgets/ui_helpers.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  @override
  void initState() {
    super.initState();
    final syncService = Provider.of<SyncService>(context, listen: false);
    syncService.init().then((_) {
      syncService.startDiscovery();
      syncService.startServerAndBroadcast();
    });
  }

  @override
  void dispose() {
    // Note: We might want to keep the server running if the user leaves the screen?
    // For now, let's stop it to save resources and avoid conflicts.
    // Or we could move the lifecycle to the AppProvider or main.dart.
    // Given the request, "access a cloud sync page ... and start syncing",
    // it implies the process happens here.
    final syncService = Provider.of<SyncService>(context, listen: false);
    syncService.stopDiscovery();
    syncService.stopServerAndBroadcast();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Device Sync')),
      body: Consumer<SyncService>(
        builder: (context, syncService, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Status
              Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFF2C2C2C),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "This Device: ${syncService.myDeviceName}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.circle, size: 12, color: syncService.isBroadcasting ? Colors.greenAccent : Colors.redAccent),
                        const SizedBox(width: 8),
                        Text(syncService.isBroadcasting ? "Broadcasting & Server Active" : "Offline", style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const SizedBox(width: 20),
                        if (syncService.isDiscovering) 
                           const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))
                        else
                           Icon(Icons.search, size: 12, color: syncService.isDiscovering ? Colors.greenAccent : Colors.grey),
                        const SizedBox(width: 8),
                        Text(syncService.isDiscovering ? "Scanning for devices..." : "Scan stopped", style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text("Available Devices", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF80CBC4))),
              ),
              const SizedBox(height: 10),
              
              Expanded(
                child: syncService.devices.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.wifi_tethering_off, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text("No devices found", style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 8),
                            TextButton.icon(
                                onPressed: syncService.startDiscovery, 
                                icon: const Icon(Icons.refresh), 
                                label: const Text("Retry Scan")
                            )
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: syncService.devices.length,
                        itemBuilder: (context, index) {
                          final device = syncService.devices[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: const Icon(Icons.devices, color: Color(0xFF80CBC4)),
                              title: Text(device.name),
                              subtitle: Text(device.host),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF80CBC4),
                                  foregroundColor: Colors.black,
                                ),
                                onPressed: () => _confirmSync(context, syncService, device),
                                child: const Text("Sync From"),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmSync(BuildContext context, SyncService service, DiscoveredDevice device) {
    showDialog(
      context: context, 
      builder: (ctx) => StyledDialog(
        title: "Sync from ${device.name}?",
        content: const Text(
          "This will OVERWRITE all data on this device with the data from the selected device.\n\nThis action cannot be undone.",
          style: TextStyle(color: Colors.redAccent),
        ),
        onCancel: () => Navigator.pop(ctx),
        onSave: () async {
          Navigator.pop(ctx);
          _performSync(context, service, device);
        },
        saveText: "Overwrite & Sync",
      )
    );
  }

  Future<void> _performSync(BuildContext context, SyncService service, DiscoveredDevice device) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    final bytes = await service.pullDatabaseBytes(device);
    
    if (bytes != null) {
      if (context.mounted) {
        // Reload App Data safely via AppProvider
        await Provider.of<AppProvider>(context, listen: false).replaceDatabase(bytes);
        
        // Close loading dialog
        if (context.mounted) Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sync successful! Data updated.")));
        Navigator.pop(context); // Go back to settings
      } else {
         if (context.mounted) Navigator.pop(context); // close loading
      }
    } else {
      // Close loading dialog
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sync failed. Check connection.")));
      }
    }
  }
}
