import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../colors.dart';

class DropzoneWidget extends StatefulWidget {
  final Function(String path, String name, Uint8List? bytes) onFileSelected;
  final bool isProcessing;

  const DropzoneWidget({
    super.key,
    required this.onFileSelected,
    this.isProcessing = false,
  });

  @override
  State<DropzoneWidget> createState() => _DropzoneWidgetState();
}

class _DropzoneWidgetState extends State<DropzoneWidget> {
  bool _isDragging = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      widget.onFileSelected(
        file.path ?? '',
        file.name,
        file.bytes,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragEntered: (details) => setState(() => _isDragging = true),
      onDragExited: (details) => setState(() => _isDragging = false),
      onDragDone: (details) async {
        setState(() => _isDragging = false);
        if (details.files.isNotEmpty) {
          final file = details.files.first;
          final name = file.name;
          if (name.toLowerCase().endsWith('.pdf')) {
            final bytes = await file.readAsBytes();
            widget.onFileSelected(file.path, name, bytes);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Apenas arquivos PDF são aceitos para impressão.'),
                backgroundColor: AppColors.secondary,
              ),
            );
          }
        }
      },
      child: InkWell(
        onTap: widget.isProcessing ? null : _pickFile,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          decoration: BoxDecoration(
            color: _isDragging
                ? AppColors.primary.withValues(alpha: 0.12)
                : AppColors.dropzoneTint,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isDragging ? AppColors.primary : AppColors.tertiary,
              width: 2.5,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.upload_file_rounded,
                  size: 36,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Arraste seus arquivos PDF para cá',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'ou clique para selecionar do pendrive/pastas',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderTanLight),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.usb_rounded, size: 18, color: AppColors.secondary),
                    SizedBox(width: 8),
                    Text(
                      'Acessar Pendrive USB',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
