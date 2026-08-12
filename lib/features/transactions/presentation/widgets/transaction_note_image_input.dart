import 'dart:io';
import 'package:flutter/material.dart';

class TransactionNoteImageInput extends StatelessWidget {
  final TextEditingController noteController;
  final ValueChanged<String> onNoteChanged;
  final File? receiptImage;
  final VoidCallback onPickImage;
  final VoidCallback onClearImage;

  const TransactionNoteImageInput({
    super.key,
    required this.noteController,
    required this.onNoteChanged,
    required this.receiptImage,
    required this.onPickImage,
    required this.onClearImage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: noteController,
            decoration: const InputDecoration(
              labelText: 'Nota (opcional)',
              border: OutlineInputBorder(),
            ),
            onChanged: onNoteChanged,
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          icon: Icon(receiptImage != null ? Icons.image : Icons.camera_alt),
          onPressed: onPickImage,
        ),
        if (receiptImage != null)
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.red),
            onPressed: onClearImage,
          ),
      ],
    );
  }
}
