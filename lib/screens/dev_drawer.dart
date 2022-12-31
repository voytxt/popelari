import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DevDrawer extends StatefulWidget {
  const DevDrawer({super.key});

  @override
  State<DevDrawer> createState() => _DevDrawerState();
}

class _DevDrawerState extends State<DevDrawer> {
  final _storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Text(
              'Popeláři',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ListTile(
            title: const Text('View storage'),
            onTap: () async {
              final content = await _storage.readAll();
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  content: Text(const JsonEncoder.withIndent('  ').convert(content)),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Clear storage'),
            onTap: () async {
              await _storage.deleteAll();
              showDialog(
                context: context,
                builder: (_) => const AlertDialog(
                  content: Text('Deleted'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
