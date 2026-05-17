import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdfx/pdfx.dart';
import 'package:drift/drift.dart' as drift;
import 'package:share_plus/share_plus.dart';
import '../providers/app_provider.dart';
import '../database/database.dart';
import 'package:intl/intl.dart';
import '../widgets/ui_helpers.dart';

class StorageScreen extends StatefulWidget {
  final int? initialFolderId;
  final String? folderName;

  const StorageScreen({super.key, this.initialFolderId, this.folderName});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  List<StorageFolder> _path = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().generateMissingThumbnails();
    });
  }

  int? get _currentFolderId => _path.isEmpty ? null : _path.last.id;

  void _onPathChanged() {
    context.read<AppProvider>().generateMissingThumbnails();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return PopScope(
      canPop: _path.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _path.isNotEmpty) {
          setState(() {
            _path.removeLast();
            _onPathChanged();
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Storage'),
          leading: _path.isNotEmpty 
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() {
                  _path.removeLast();
                  _onPathChanged();
                }),
              )
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
        ),
        body: Column(
          children: [
            _buildBreadcrumbs(),
            Expanded(
              child: StreamBuilder<List<StorageFolder>>(
                stream: provider.watchFolders(_currentFolderId),
                builder: (context, folderSnapshot) {
                  return StreamBuilder<List<StorageFile>>(
                    stream: provider.watchFiles(_currentFolderId),
                    builder: (context, fileSnapshot) {
                      if (folderSnapshot.connectionState == ConnectionState.waiting && !folderSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final folders = folderSnapshot.data ?? [];
                      final files = fileSnapshot.data ?? [];

                      if (folders.isEmpty && files.isEmpty) {
                        return const Center(child: Text("This folder is empty", style: TextStyle(color: Colors.grey)));
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 150,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: folders.length + files.length,
                        itemBuilder: (context, index) {
                          if (index < folders.length) {
                            return _buildFolderItem(context, folders[index]);
                          } else {
                            return _buildFileItem(context, files[index - folders.length]);
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'add_folder',
              onPressed: () => _showEditFolderDialog(context, provider, null),
              mini: true,
              child: const Icon(Icons.create_new_folder),
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              heroTag: 'add_file',
              onPressed: () => _pickAndAddFile(context, provider),
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumbs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      alignment: Alignment.centerLeft,
      color: Colors.black12,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            DragTarget<Object>(
              onWillAcceptWithDetails: (details) {
                final data = details.data;
                if (data is StorageFile) return data.folderId != null;
                if (data is StorageFolder) return data.parentId != null;
                return false;
              },
              onAcceptWithDetails: (details) {
                final data = details.data;
                if (data is StorageFile) {
                  context.read<AppProvider>().moveFileToFolder(data.id, null);
                } else if (data is StorageFolder) {
                  context.read<AppProvider>().moveFolderToFolder(data.id, null);
                }
                setState(() {
                  _onPathChanged();
                });
              },
              builder: (context, candidateData, rejectedData) {
                return GestureDetector(
                  onTap: () => setState(() {
                    _path.clear();
                    _onPathChanged();
                  }),
                  child: Text("Root", style: TextStyle(
                    color: candidateData.isNotEmpty ? Colors.white : const Color(0xFF80CBC4), 
                    fontWeight: FontWeight.bold
                  )),
                );
              },
            ),
            for (int i = 0; i < _path.length; i++) ...[
              const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
              DragTarget<Object>(
                onWillAcceptWithDetails: (details) {
                  final data = details.data;
                  if (data is StorageFile) return data.folderId != _path[i].id;
                  if (data is StorageFolder) return data.id != _path[i].id && data.parentId != _path[i].id;
                  return false;
                },
                onAcceptWithDetails: (details) {
                  final data = details.data;
                  if (data is StorageFile) {
                    context.read<AppProvider>().moveFileToFolder(data.id, _path[i].id);
                  } else if (data is StorageFolder) {
                    context.read<AppProvider>().moveFolderToFolder(data.id, _path[i].id);
                  }
                  setState(() {
                    _path = _path.sublist(0, i + 1);
                    _onPathChanged();
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  return GestureDetector(
                    onTap: () => setState(() {
                      _path = _path.sublist(0, i + 1);
                      _onPathChanged();
                    }),
                    child: Text(_path[i].name, style: TextStyle(
                      color: candidateData.isNotEmpty ? Colors.white : const Color(0xFF80CBC4), 
                      fontWeight: FontWeight.bold
                    )),
                  );
                },
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildFolderItem(BuildContext context, StorageFolder folder) {
    Color folderColor = folder.color != null ? Color(folder.color!) : const Color(0xFF80CBC4);

    Widget child = DragTarget<Object>(
      onWillAcceptWithDetails: (details) {
        final data = details.data;
        if (data is StorageFile) return data.folderId != folder.id;
        if (data is StorageFolder) return data.id != folder.id && data.parentId != folder.id;
        return false;
      },
      onAcceptWithDetails: (details) {
        final data = details.data;
        if (data is StorageFile) {
          context.read<AppProvider>().moveFileToFolder(data.id, folder.id);
        } else if (data is StorageFolder) {
          context.read<AppProvider>().moveFolderToFolder(data.id, folder.id);
        }
        setState(() {
          _onPathChanged();
        }); // Refresh view
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;
        
        return Stack(
          children: [
            InkWell(
              onTap: () => setState(() {
                _path.add(folder);
                _onPathChanged();
              }),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: isHovered ? folderColor.withAlpha(76) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isHovered ? Border.all(color: folderColor, width: 2) : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.folder, size: 64, color: folderColor),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        folder.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -4,
              right: -4,
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white70, size: 20),
                onSelected: (val) {
                  if (val == 'edit') _showEditFolderDialog(context, context.read<AppProvider>(), folder);
                  if (val == 'delete') _showDeleteFolderDialog(context, folder);
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit Folder')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                ],
              ),
            ),
          ],
        );
      }
    );

    return LongPressDraggable<StorageFolder>(
      data: folder,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2C).withAlpha(200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder, color: folderColor, size: 32),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(folder.name, style: const TextStyle(color: Colors.white, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.5, child: child),
      child: child,
    );
  }

  Widget _buildFileItem(BuildContext context, StorageFile file) {
    Widget child = Stack(
      children: [
        InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FileViewerScreen(file: file)),
          ),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: file.thumbnailPath != null 
                    ? Image.file(
                        File(file.thumbnailPath!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) => _buildFallbackPreview(file),
                      )
                    : _buildFallbackPreview(file),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  file.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white70, size: 20),
            onSelected: (val) {
              if (val == 'rename') _showRenameFileDialog(context, file);
              if (val == 'share') Share.shareXFiles([XFile(file.path)]);
              if (val == 'save') saveFileToDevice(context, file.path, file.name);
              if (val == 'delete') _showDeleteFileDialog(context, file);
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'rename', child: Text('Rename')),
              const PopupMenuItem(value: 'share', child: Text('Share')),
              const PopupMenuItem(value: 'save', child: Text('Save to device')),
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
            ],
          ),
        ),
      ],
    );

    return LongPressDraggable<StorageFile>(
      data: file,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2C).withAlpha(200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(file.type == 'pdf' ? Icons.picture_as_pdf : Icons.image, color: Colors.white, size: 32),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(file.name, style: const TextStyle(color: Colors.white, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.5, child: child),
      child: child,
    );
  }

  void _showRenameFileDialog(BuildContext context, StorageFile file) {
    final controller = TextEditingController(text: file.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Rename File"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "File Name"),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty && controller.text != file.name) {
                await context.read<AppProvider>().updateFile(file.copyWith(name: controller.text));
                if (context.mounted) Navigator.pop(context);
                setState(() {});
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showEditFolderDialog(BuildContext context, AppProvider provider, StorageFolder? folder) {
    final controller = TextEditingController(text: folder?.name ?? "");
    Color selectedColor = folder?.color != null ? Color(folder!.color!) : const Color(0xFF80CBC4);

    final List<Color> colorOptions = [
      const Color(0xFF80CBC4), // Default Teal
      Colors.redAccent,
      Colors.orangeAccent,
      Colors.yellowAccent,
      Colors.greenAccent,
      Colors.blueAccent,
      Colors.purpleAccent,
      Colors.pinkAccent,
      Colors.grey,
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateBuilder) => AlertDialog(
          title: Text(folder == null ? "New Folder" : "Edit Folder"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: "Folder Name"),
                autofocus: folder == null,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: colorOptions.map((color) => GestureDetector(
                  onTap: () => setStateBuilder(() => selectedColor = color),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: selectedColor == color ? Border.all(color: Colors.white, width: 3) : null,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  if (folder == null) {
                    await provider.addFolder(controller.text, _currentFolderId, selectedColor.value);
                  } else {
                    await provider.updateFolder(folder.copyWith(
                      name: controller.text,
                      color: drift.Value(selectedColor.value),
                    ));
                  }
                  if (context.mounted) Navigator.pop(context);
                  setState(() {});
                }
              },
              child: Text(folder == null ? "Create" : "Save"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndAddFile(BuildContext context, AppProvider provider) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      final file = result.files.single;
      final extension = file.extension?.toLowerCase();
      final type = (extension == 'pdf') ? 'pdf' : 'image';
      
      await provider.addFile(file.name, file.path!, type, _currentFolderId);
      setState(() {});
    }
  }

  void _showDeleteFolderDialog(BuildContext context, StorageFolder folder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Folder?"),
        content: Text("Are you sure you want to delete '${folder.name}' and all its contents?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              context.read<AppProvider>().deleteFolder(folder.id);
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteFileDialog(BuildContext context, StorageFile file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete File?"),
        content: Text("Are you sure you want to delete '${file.name}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              context.read<AppProvider>().deleteFile(file.id);
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackPreview(StorageFile file) {
    if (file.type == 'image') {
      return Image.file(
        File(file.path),
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 48, color: Colors.grey),
      );
    } else {
      return Container(
        color: Colors.white10,
        child: const Center(
          child: Icon(Icons.picture_as_pdf, size: 48, color: Colors.redAccent),
        ),
      );
    }
  }
}

class FileViewerScreen extends StatefulWidget {
  final StorageFile file;

  const FileViewerScreen({super.key, required this.file});

  @override
  State<FileViewerScreen> createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  final _commentController = TextEditingController();
  PdfControllerPinch? _pdfController;

  @override
  void initState() {
    super.initState();
    if (widget.file.type == 'pdf') {
      _pdfController = PdfControllerPinch(
        document: PdfDocument.openFile(widget.file.path),
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.file.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: "Save to device",
            onPressed: () {
              saveFileToDevice(context, widget.file.path, widget.file.name);
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.shareXFiles([XFile(widget.file.path)]);
            },
          ),
          if (widget.file.type == 'image')
            IconButton(
              icon: const Icon(Icons.fullscreen),
              tooltip: "Full Screen",
              onPressed: () {
                 Navigator.push(context, MaterialPageRoute(builder: (_) => ImageViewer(imagePath: widget.file.path)));
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.black,
              child: widget.file.type == 'pdf'
                  ? PdfViewPinch(
                      controller: _pdfController!,
                    )
                  : InteractiveViewer(
                      minScale: 0.1,
                      maxScale: 5.0,
                      child: Image.file(
                        File(widget.file.path),
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("Comments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: FutureBuilder<List<FileComment>>(
                    future: provider.getComments(widget.file.id),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final comments = snapshot.data!;
                      if (comments.isEmpty) return const Center(child: Text("No comments yet", style: TextStyle(color: Colors.grey)));

                      return ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return ListTile(
                            title: Text(comment.content),
                            subtitle: Text(DateFormat.yMMMd().add_Hm().format(comment.createdAt)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, size: 16),
                              onPressed: () async {
                                await provider.deleteComment(comment.id);
                                setState(() {});
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: "Add a comment...",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send, color: Color(0xFF80CBC4)),
                        onPressed: () async {
                          if (_commentController.text.isNotEmpty) {
                            await provider.addComment(widget.file.id, _commentController.text);
                            _commentController.clear();
                            setState(() {});
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
