import 'package:carwingsflutter/safe_area_scaffold.dart';
import 'package:carwingsflutter/session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _DebugPageState extends State<DebugPage> {
  _copyAll() {
    String text = '';
    widget.session.nissanConnectNa.debugLog.forEach(
      (logEntry) => text += logEntry + '\n\n',
    );
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("All copied to Clipboard")));
  }

  @override
  Widget build(BuildContext context) {
    // Create a unified text view with all logs
    String allLogs = widget.session.nissanConnectNa.debugLog.reversed.join('\n\n');
    
    return SafeAreaScaffold(
      appBar: AppBar(
        title: Text("Debug log"),
        actions: [
          IconButton(icon: Icon(Icons.content_copy), onPressed: _copyAll),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
        child: SelectableText(
          allLogs.isEmpty ? 'No logs yet' : allLogs,
          style: TextStyle(
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }
}

class DebugPage extends StatefulWidget {
  DebugPage(this.session);

  final Session session;

  @override
  _DebugPageState createState() => _DebugPageState();
}
