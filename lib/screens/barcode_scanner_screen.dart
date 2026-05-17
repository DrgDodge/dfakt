import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../database/database.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    
    final String? code = barcodes.first.rawValue;
    if (code == null) return;

    setState(() => _isProcessing = true);
    
    final provider = context.read<AppProvider>();
    final foodItem = await provider.getFoodByBarcode(code);

    if (!mounted) return;

    if (foodItem != null) {
      _showLogServingSheet(foodItem);
    } else {
      _showNewFoodSheet(code);
    }
  }

  void _showLogServingSheet(FoodItem food) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => LogServingSheet(food: food),
    ).then((_) => setState(() => _isProcessing = false));
  }

  void _showNewFoodSheet(String barcode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => NewFoodSheet(barcode: barcode),
    ).then((_) => setState(() => _isProcessing = false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        actions: [
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder<MobileScannerState>(
              valueListenable: cameraController,
              builder: (context, state, child) {
                switch (state.torchState) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                  default:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                }
              },
            ),
            iconSize: 24.0,
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder<MobileScannerState>(
              valueListenable: cameraController,
              builder: (context, state, child) {
                switch (state.cameraDirection) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                  case CameraFacing.external:
                    return const Icon(Icons.camera);
                  default:
                    return const Icon(Icons.camera_alt);
                }
              },
            ),
            iconSize: 24.0,
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          // Overlay to make it look like a scanner
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF80CBC4), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Align barcode within the frame",
                style: TextStyle(color: Colors.white, backgroundColor: Colors.black54),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class LogServingSheet extends StatefulWidget {
  final FoodItem food;
  const LogServingSheet({super.key, required this.food});

  @override
  State<LogServingSheet> createState() => _LogServingSheetState();
}

class _LogServingSheetState extends State<LogServingSheet> {
  late double _grams;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _grams = widget.food.lastPortion;
    _textController.text = _grams.round().toString();
  }

  void _updateGrams(String val) {
    final d = double.tryParse(val);
    if (d != null && d > 0) {
      setState(() => _grams = d);
    }
  }

  @override
  Widget build(BuildContext context) {
    final calories = (widget.food.caloriesPer100g * _grams / 100).round();
    final protein = (widget.food.proteinPer100g * _grams / 100).round();
    final carbs = (widget.food.carbsPer100g * _grams / 100).round();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.food.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF80CBC4))),
          const SizedBox(height: 8),
          Text("Nutritional info per 100g: ${widget.food.caloriesPer100g.round()} kcal, P: ${widget.food.proteinPer100g.round()}g, C: ${widget.food.carbsPer100g.round()}g", 
               style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Serving Size (g)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _textController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF80CBC4)),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  onChanged: _updateGrams,
                ),
              ),
            ],
          ),
          Slider(
            value: _grams.clamp(1.0, 500.0),
            min: 1,
            max: 500,
            divisions: 499,
            activeColor: const Color(0xFF80CBC4),
            onChanged: (val) {
              setState(() {
                _grams = val;
                _textController.text = val.round().toString();
              });
            },
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacroInfo("Calories", "$calories", Colors.white),
                _buildMacroInfo("Protein", "${protein}g", Colors.blueAccent),
                _buildMacroInfo("Carbs", "${carbs}g", Colors.orangeAccent),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF80CBC4),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final provider = context.read<AppProvider>();
              await provider.updateLastPortion(widget.food.id, _grams);
              await provider.addNutritionLog(
                calories, protein, carbs, 
                provider.selectedNutritionDate,
                foodName: widget.food.name
              );
              if (mounted) {
                Navigator.pop(context); // Close sheet
                Navigator.pop(context); // Close scanner
              }
            },
            child: const Text("Log Serving", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMacroInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

class NewFoodSheet extends StatefulWidget {
  final String barcode;
  const NewFoodSheet({super.key, required this.barcode});

  @override
  State<NewFoodSheet> createState() => _NewFoodSheetState();
}

class _NewFoodSheetState extends State<NewFoodSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _kcalController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("New Food Item", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF80CBC4))),
              const SizedBox(height: 4),
              Text("Barcode: ${widget.barcode}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Product Name (e.g. Greek Yogurt)"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              const Text("Nutritional Info per 100g", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _kcalController,
                      decoration: const InputDecoration(labelText: "Kcal", isDense: true),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _proteinController,
                      decoration: const InputDecoration(labelText: "Protein (g)", isDense: true),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _carbsController,
                      decoration: const InputDecoration(labelText: "Carbs (g)", isDense: true),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF80CBC4),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await context.read<AppProvider>().addFoodItem(
                      barcode: widget.barcode,
                      name: _nameController.text,
                      caloriesPer100g: double.parse(_kcalController.text),
                      proteinPer100g: double.parse(_proteinController.text),
                      carbsPer100g: double.parse(_carbsController.text),
                    );
                    
                    final food = await context.read<AppProvider>().getFoodByBarcode(widget.barcode);
                    if (mounted && food != null) {
                      Navigator.pop(context); // Close new food sheet
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: const Color(0xFF1E1E1E),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (context) => LogServingSheet(food: food),
                      );
                    }
                  }
                },
                child: const Text("Save & Continue", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
