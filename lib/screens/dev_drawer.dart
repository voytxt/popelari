import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:popelari/common/storage.dart';

class DevDrawer extends StatefulWidget {
  const DevDrawer({super.key});

  @override
  State<DevDrawer> createState() => _DevDrawerState();
}

class _DevDrawerState extends State<DevDrawer> {
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
              final content = await storage.readAll();

              if (!mounted) return;
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
              await storage.deleteAll();

              if (!mounted) return;
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
