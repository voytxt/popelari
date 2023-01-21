import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
import 'package:popelari/api/strava.dart' as strava;
import 'package:popelari/common/storage.dart';

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
            _buildTextFormField(
              _canteenIdController,
              'canteen number',
              keyboard: TextInputType.number,
              filter: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 10.0),
            _buildTextFormField(
              _usernameController,
              'username',
            ),
            const SizedBox(height: 10.0),
            _buildTextFormField(
              _passwordController,
              'password',
              hideText: true,
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
              onPressed: _handlePress,
              child: const Text('Sign in'),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildTextFormField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboard,
    List<TextInputFormatter>? filter,
    bool hideText = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      inputFormatters: filter,
      obscureText: hideText,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: toBeginningOfSentenceCase(label),
      ),
      validator: (value) {
        return value == null || value.isEmpty ? 'Please enter your $label' : null;
      },
    );
  }

  void _handlePress() async {
    if (!_formKey.currentState!.validate()) return;

    late strava.Food food;

    try {
      food = await strava.fetch(
        _canteenIdController.text,
        username: _usernameController.text,
        password: _passwordController.text,
      );
    } catch (error) {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          titleTextStyle: TextStyle(color: Theme.of(context).errorColor),
          content: const Text('Your credentials are incorrect'),
          contentTextStyle: TextStyle(color: Theme.of(context).errorColor),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }

    if (_rememberMe) {
      await storage.write(key: 'username', value: _usernameController.text);
      await storage.write(key: 'password', value: _passwordController.text);
    }

    if (mounted) Navigator.pop(context, food);
  }
}
