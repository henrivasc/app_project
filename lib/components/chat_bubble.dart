import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final Color color;
  final String time;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final String? imageUrl;
  final String? fileUrl;
  final String? fileName;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.color,
    required this.time,
    required this.isFavorite,
    required this.onFavoriteToggle,
    this.imageUrl,
    this.fileUrl,
    this.fileName,
  }) : super(key: key);

  void _openFile(BuildContext context, String fileUrl, String? fileName) async {
    try {
      // Baixe o arquivo para o armazenamento local antes de abrir
      final http.Response response = await http.get(Uri.parse(fileUrl));
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath = '${tempDir.path}/$fileName';

      final File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // Abra o arquivo com open_file
      final result = await OpenFile.open(file.path);

      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível abrir o arquivo: ${result.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível abrir o arquivo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (imageUrl != null)
            GestureDetector(
              onTap: () => _showExpandedImage(context, imageUrl!),
              child: Image.network(
                imageUrl!,
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            )
          else if (fileUrl != null)
            GestureDetector(
              onTap: () => _openFile(context, fileUrl!, fileName),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.insert_drive_file, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fileName ?? 'File',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              message,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          const SizedBox(height: 5),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                time,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  color: isFavorite ? Colors.yellow : Colors.white70,
                ),
                onPressed: onFavoriteToggle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showExpandedImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(imageUrl),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        ),
      ),
    );
  }
}
