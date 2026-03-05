import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

Future<void> saveFileToDevice(BuildContext context, String sourcePath, String fileName) async {
  try {
    final bytes = await File(sourcePath).readAsBytes();
    String? savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save File',
      fileName: fileName,
      bytes: bytes,
    );

    if (savePath != null) {
      // file_picker saveFile doesn't actually write the file on desktop platforms, it only returns the path
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        await File(savePath).writeAsBytes(bytes);
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File saved successfully!')),
        );
      }
    }
  } catch (e) {
    print("FilePicker saveFile error: $e");
    // Fallback for Android if SAF/picker fails
    if (Platform.isAndroid) {
      try {
        final dir = Directory('/storage/emulated/0/Download');
        if (await dir.exists()) {
          final destPath = '${dir.path}/$fileName';
          await File(sourcePath).copy(destPath);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Saved to Downloads folder')),
            );
          }
          return;
        }
      } catch (fallbackErr) {
        print("Fallback save error: $fallbackErr");
      }
    }
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save file: $e')),
      );
    }
  }
}

class ImageViewer extends StatelessWidget {
  final String imagePath;

  const ImageViewer({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.shareXFiles([XFile(imagePath)]);
            },
          ),
        ],
      ),
      body: Container(
        constraints: const BoxConstraints.expand(),
        child: InteractiveViewer(
          minScale: 0.1,
          maxScale: 5.0,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}

class StyledDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final String saveText;
  final String cancelText;

  const StyledDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onSave,
    required this.onCancel,
    this.saveText = 'Save',
    this.cancelText = 'Cancel',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(child: content),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: onCancel,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF333333), // Dark Grey for Cancel
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(cancelText, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: onSave,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF80CBC4), // Turquoise
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(saveText, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        )
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF80CBC4)),
      ),
    );
  }
}
