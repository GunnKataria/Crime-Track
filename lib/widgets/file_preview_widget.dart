import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;

class FilePreviewWidget extends StatelessWidget {
  final String? filePath;
  final String? fileType;
  final String? fileName;
  final double height;
  final double width;
  final VoidCallback? onTap;

  const FilePreviewWidget({
    Key? key,
    required this.filePath,
    this.fileType,
    this.fileName,
    this.height = 200,
    this.width = double.infinity,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (filePath == null || filePath!.isEmpty) {
      return _buildPlaceholder();
    }

    final extension = path.extension(filePath!).toLowerCase();
    final isImage = extension == '.jpg' || extension == '.jpeg' || 
                    extension == '.png' || extension == '.gif';
    final isPdf = extension == '.pdf';
    
    return GestureDetector(
      onTap: onTap ?? () => _openFile(context),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isImage)
              _buildImagePreview()
            else if (isPdf)
              _buildPdfPreview(context)
            else
              _buildGenericFilePreview(),
            
            if (fileName != null && fileName!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  fileName!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return SizedBox(
      height: height,
      width: width,
      child: Image.file(
        File(filePath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      ),
    );
  }

  Widget _buildPdfPreview(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[200],
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.picture_as_pdf,
            size: 64,
            color: Colors.red,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: const Text(
                'PDF Document',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenericFilePreview() {
    IconData iconData;
    Color iconColor;
    
    if (fileType == 'document') {
      iconData = Icons.description;
      iconColor = Colors.blue;
    } else if (fileType == 'audio') {
      iconData = Icons.audiotrack;
      iconColor = Colors.purple;
    } else if (fileType == 'video') {
      iconData = Icons.videocam;
      iconColor = Colors.red;
    } else {
      iconData = Icons.insert_drive_file;
      iconColor = Colors.orange;
    }
    
    return Container(
      height: height,
      width: width,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            size: 64,
            color: iconColor,
          ),
          const SizedBox(height: 8),
          Text(
            fileName ?? path.basename(filePath!),
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open File'),
            onPressed: () => _openFile(null),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[200],
      child: const Center(
        child: Text('No file available'),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[200],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 8),
            Text('Error loading file'),
          ],
        ),
      ),
    );
  }

  Future<void> _openFile(BuildContext? context) async {
    if (filePath == null || filePath!.isEmpty) return;
    
    try {
      final result = await OpenFile.open(filePath!);
      if (result.type != ResultType.done && context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open file: ${result.message}')),
        );
      }
    } catch (e) {
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening file: $e')),
        );
      }
    }
  }
}
