import 'package:carwingsflutter/safe_area_scaffold.dart';
import 'package:carwingsflutter/session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _DebugPageState extends State<DebugPage> {
  final TextEditingController _logController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateLogs();
  }

  void _updateLogs() {
    final logs = widget.session.nissanConnectNa.debugLog.reversed.join('\n\n');
    _logController.text = logs;
  }

  void _copyAll() {
    Clipboard.setData(ClipboardData(text: _logController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("All logs copied to Clipboard")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeAreaScaffold(
      appBar: AppBar(
        title: Text("Debug log"),
        actions: [
          IconButton(icon: Icon(Icons.content_copy), onPressed: _copyAll),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(15.0),
        child: TextField(
          controller: _logController,
          maxLines: null,
          expands: true,
          readOnly: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.black.withOpacity(0.05),
          ),
          style: TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _logController.dispose();
    super.dispose();
  }
}

class DebugPage extends StatefulWidget {
  DebugPage(this.session);

  final Session session;

  @override
  _DebugPageState createState() => _DebugPageState();
}
