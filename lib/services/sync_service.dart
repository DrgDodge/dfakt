import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:bonsoir/bonsoir.dart';
import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class DiscoveredDevice {
  final String name;
  final String host;
  final int port;
  final String id;

  DiscoveredDevice({required this.name, required this.host, required this.port, required this.id});
  
  @override
  bool operator ==(Object other) => other is DiscoveredDevice && other.id == id;
  
  @override
  int get hashCode => id.hashCode;
}

class SyncService extends ChangeNotifier {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  BonsoirBroadcast? _broadcast;
  BonsoirDiscovery? _discovery;
  HttpServer? _server;
  
  final List<DiscoveredDevice> _devices = [];
  List<DiscoveredDevice> get devices => List.unmodifiable(_devices);

  bool _isBroadcasting = false;
  bool _isDiscovering = false;
  String _myDeviceName = "Unknown Device";
  String get myDeviceName => _myDeviceName;

  bool get isBroadcasting => _isBroadcasting;
  bool get isDiscovering => _isDiscovering;

  Future<void> init() async {
    _myDeviceName = await _getDeviceName();
    notifyListeners();
  }

  Future<String> _getDeviceName() async {
    if (kIsWeb) return "Web Client";
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.model;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.name;
    } else if (Platform.isLinux) {
      final linuxInfo = await deviceInfo.linuxInfo;
      return linuxInfo.name;
    } else if (Platform.isMacOS) {
      final macInfo = await deviceInfo.macOsInfo;
      return macInfo.computerName;
    } else if (Platform.isWindows) {
      final windowsInfo = await deviceInfo.windowsInfo;
      return windowsInfo.computerName;
    }
    return "DragonFakt Device";
  }

  // --- Server & Broadcast ---

  Future<void> startServerAndBroadcast() async {
    if (kIsWeb || _isBroadcasting) return;

    try {
      // 1. Start HTTP Server
      final app = Router();
      
      app.get('/db', (Request request) async {
        final dbFolder = await getApplicationDocumentsDirectory();
        final file = File(p.join(dbFolder.path, 'dragonfakt.sqlite'));
        if (await file.exists()) {
           return Response.ok(file.openRead(), headers: {
             'Content-Type': 'application/octet-stream',
             'Content-Disposition': 'attachment; filename="dragonfakt.sqlite"'
           });
        }
        return Response.notFound('Database not found');
      });

      app.get('/status', (Request request) {
        return Response.ok(jsonEncode({'name': _myDeviceName, 'status': 'ready'}));
      });

      // Bind to any available port on any interface
      _server = await shelf_io.serve(app, InternetAddress.anyIPv4, 0);
      print('Serving at http://${_server!.address.host}:${_server!.port}');

      // 2. Start Bonjour Broadcast
      final service = BonsoirService(
        name: 'DragonFakt-$_myDeviceName-${DateTime.now().millisecondsSinceEpoch}', // Unique name
        type: '_dragonfakt._tcp',
        port: _server!.port,
        attributes: {'name': _myDeviceName},
      );

      _broadcast = BonsoirBroadcast(service: service);
      // await (_broadcast! as dynamic).ready; // Failed
      // Try initialize() directly if it exists on the platform interface wrapper
      try {
        await (_broadcast! as dynamic).initialize(); 
      } catch (e) {
         print("Initialize failed or not found: $e");
      }
      await _broadcast!.start();
      
      _isBroadcasting = true;
      notifyListeners();

    } catch (e) {
      print("Error starting sync server: $e");
      stopServerAndBroadcast(); // Cleanup
    }
  }

  Future<void> stopServerAndBroadcast() async {
    if (_broadcast != null) {
      await _broadcast!.stop();
      _broadcast = null;
    }
    if (_server != null) {
      await _server!.close();
      _server = null;
    }
    _isBroadcasting = false;
    notifyListeners();
  }

  // --- Discovery ---

  Future<void> startDiscovery() async {
    if (_isDiscovering) return;
    
    _devices.clear();
    
    // Check connectivity first (optional but good)
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      print("No network connection");
      return;
    }

    try {
      _discovery = BonsoirDiscovery(type: '_dragonfakt._tcp');
      try {
        await (_discovery! as dynamic).initialize();
      } catch (e) {
         print("Initialize failed or not found: $e");
      }
      
      _discovery!.eventStream!.listen((event) {
        if (event is BonsoirDiscoveryServiceFoundEvent) {
           event.service!.resolve(_discovery!.serviceResolver);
        } else if (event is BonsoirDiscoveryServiceResolvedEvent) {
           final service = event.service as dynamic;
           final attributes = service.attributes ?? {};
           final name = attributes['name'] ?? service.name;
           
           // Ensure host is an IP address
           // Bonsoir might return a hostname. We need an IP.
           final host = service.host ?? 'unknown';
           
           // Simple duplicate check
           final newDevice = DiscoveredDevice(
             name: name,
             host: host,
             port: service.port,
             id: service.name // Unique service name from broadcast
           );
           
           if (!_devices.contains(newDevice) && newDevice.name != _myDeviceName) {
             _devices.add(newDevice);
             notifyListeners();
           }
        } else if (event is BonsoirDiscoveryServiceLostEvent) {
           final service = event.service;
           if (service != null) {
             _devices.removeWhere((d) => d.id == service.name);
             notifyListeners();
           }
        }
      });

      await _discovery!.start();
      _isDiscovering = true;
      notifyListeners();

    } catch (e) {
      print("Error starting discovery: $e");
    }
  }

  Future<void> stopDiscovery() async {
    if (_discovery != null) {
      await _discovery!.stop();
      _discovery = null;
    }
    _isDiscovering = false;
    _devices.clear();
    notifyListeners();
  }

  // --- Sync Action ---

  Future<List<int>?> pullDatabaseBytes(DiscoveredDevice device) async {
    try {
      final url = Uri.parse('http://${device.host}:${device.port}/db');
      print("Pulling DB from $url");
      
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print("Failed to download DB: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Sync error: $e");
      return null;
    }
  }
}
