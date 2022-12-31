import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:popelari/api/strava.dart' as strava;

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  final _formKey = GlobalKey<FormState>();

  final _canteenIdController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = false;

  @override
  void dispose() {
    _canteenIdController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validate(String? value, String name) {
    if (value == null || value.isEmpty) {
      return 'Please enter your $name';
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log in to Strava'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: _canteenIdController,
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Canteen number'),
              validator: (value) => _validate(value, 'canteen number'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 10.0),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Username'),
              validator: (value) => _validate(value, 'username'),
            ),
            const SizedBox(height: 10.0),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Password'),
              validator: (value) => _validate(value, 'password'),
              obscureText: true,
            ),
            const SizedBox(height: 10.0),
            CheckboxListTile(
              title: const Text('Remember me'),
              value: _rememberMe,
              onChanged: (value) => setState(() => _rememberMe = value!),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 30.0)),
              child: const Text('Sign in'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    final food = await strava.fetch(
                      _canteenIdController.text,
                      username: _usernameController.text,
                      password: _passwordController.text,
                    );

                    if (_rememberMe) {
                      const storage = FlutterSecureStorage();
                      await storage.write(key: 'username', value: _usernameController.text);
                      await storage.write(key: 'password', value: _passwordController.text);
                    }

                    if (mounted) Navigator.pop(context, food);
                  } catch (error) {
                    log('Oops, wrong credentials', name: 'STRAVA');

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          'Error',
                          style: TextStyle(color: Theme.of(context).errorColor),
                        ),
                        content: Text(
                          'Your credentials are incorrect',
                          style: TextStyle(color: Theme.of(context).errorColor),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
            ),
          ]),
        ),
      ),
    );
  }
}
