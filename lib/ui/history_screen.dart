import 'package:flutter/material.dart';
import 'package:conqueror/history/helpers/database_helper.dart';
import 'package:conqueror/history/helpers/file_helper.dart';
import 'package:conqueror/history/scan_ds.dart';
import 'dart:io';

import 'package:iconly/iconly.dart';
import 'package:conqueror/ui/abtus_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isDeleteMode = false;
  List<int> _selectedScans = [];

  void _toggleDeleteMode() {
    setState(() {
      _isDeleteMode = !_isDeleteMode;
      _selectedScans.clear(); // Clear selection when exiting delete mode
    });
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedScans.contains(id)) {
        _selectedScans.remove(id);
      } else {
        _selectedScans.add(id);
      }
    });
  }

  Future<void> _deleteSelectedScans() async {
    final dbHelper = DatabaseHelper();
    for (int id in _selectedScans) {
      await dbHelper.deleteScan(id);
    }
    setState(() {
      _selectedScans.clear();
      _isDeleteMode = false; // Exit delete mode after deletion
    });
  }

  Future<List<Scan>> _loadScanHistory() async {
    return await DatabaseHelper().getScans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        actions: [
          if (_isDeleteMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _selectedScans.isEmpty
                  ? null
                  : () async {
                await _deleteSelectedScans();
                setState(() {});
              },
            ),
          IconButton(
            icon: Icon(_isDeleteMode ? Icons.close : Icons.delete),
            onPressed: _toggleDeleteMode,
          ),
        ],
      ),
      body: FutureBuilder<List<Scan>>(
        future: _loadScanHistory(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final scan = snapshot.data![index];
              return ListTile(
                leading: Image.file(File(scan.thumbnailPath)),
                title: Text(
                  scan.textResult.split('\n').take(2).join('\n'),
                ),
                subtitle: Text(scan.dateTime),
                trailing: _isDeleteMode
                    ? Checkbox(
                  value: _selectedScans.contains(scan.id),
                  onChanged: (bool? value) {
                    _toggleSelection(scan.id!);
                  },
                )
                    : null,
                onTap: _isDeleteMode
                    ? () {
                  _toggleSelection(scan.id!);
                }
                    : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AboutUs(
                        imageFile: File(scan.thumbnailPath),
                        aboutText: scan.textResult,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
