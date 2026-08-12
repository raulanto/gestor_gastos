import 'dart:io';
import 'package:flutter/material.dart';

class TransactionReceiptViewer extends StatelessWidget {
  final String receiptImagePath;

  const TransactionReceiptViewer({super.key, required this.receiptImagePath});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text('Recibo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => Dialog(
                child: InteractiveViewer(
                  child: Image.file(File(receiptImagePath)),
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: FileImage(File(receiptImagePath)),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
