import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CodePlaygroundPage extends StatefulWidget {
  final String language;
  final String initialCode;

  const CodePlaygroundPage({
    super.key,
    required this.language,
    required this.initialCode,
  });

  @override
  State<CodePlaygroundPage> createState() => _CodePlaygroundPageState();
}

class _CodePlaygroundPageState extends State<CodePlaygroundPage> {
  late TextEditingController _codeController;
  String _output = "Run your code to see output...";
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.initialCode);
  }

  // Map display names to Piston API IDs
  String get _pistonLanguageId {
    switch (widget.language.toLowerCase()) {
      case 'java': return 'java';
      case 'python': return 'python';
      case 'c++': return 'cpp';
      case 'javascript': return 'javascript';
      case 'php': return 'php';
      case 'ruby': return 'ruby';
      case 'go': return 'go';
      case 'sql': return 'sqlite3'; // SQL is tricky, sqlite is closest for basic queries
      default: return 'python';
    }
  }

  Future<void> _runCode() async {
    setState(() {
      _isRunning = true;
      _output = "Running...";
    });

    try {
      final response = await http.post(
        Uri.parse('https://emkc.org/api/v2/piston/execute'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "language": _pistonLanguageId,
          "version": "*",
          "files": [
            {"content": _codeController.text}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _output = data['run']['output'] ?? "No Output";
        });
      } else {
        setState(() {
          _output = "Error: ${response.statusCode}\n${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _output = "Failed to connect to compiler: $e";
      });
    } finally {
      setState(() => _isRunning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Dark Theme
      appBar: AppBar(
        title: Text("${widget.language} Playground"),
        backgroundColor: const Color(0xFF2D2D2D),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: _isRunning 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
              : const Icon(Icons.play_arrow, color: Colors.greenAccent),
            onPressed: _isRunning ? null : _runCode,
          )
        ],
      ),
      body: Column(
        children: [
          // Code Editor Area
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF1E1E1E),
              child: TextField(
                controller: _codeController,
                maxLines: null,
                expands: true,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Color(0xFFD4D4D4),
                  fontSize: 14,
                ),
                decoration: const InputDecoration.collapsed(
                  hintText: "Write your code here...",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: Colors.white24),
          // Output Area
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF121212),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "OUTPUT:",
                      style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _output,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _runCode,
        backgroundColor: Colors.green,
        icon: const Icon(Icons.play_arrow),
        label: const Text("Run"),
      ),
    );
  }
}