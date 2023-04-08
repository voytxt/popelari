import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
import 'package:popelari/api/strava.dart' as strava;
import 'package:popelari/common/storage.dart';
import 'package:popelari/screens/common/space.dart';

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
      appBar: AppBar(title: const Text('Popeláři ~ Strava ~ Log in')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: spaceBeforeEach(10, [
              _buildTextFormField(_canteenIdController, 'canteen number', isNumerical: true),
              _buildTextFormField(_usernameController, 'username'),
              _buildTextFormField(_passwordController, 'password', isPassword: true, isLast: true),
              CheckboxListTile(
                value: _rememberMe,
                onChanged: (value) => setState(() => _rememberMe = value!),
                title: const Text('Remember me'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(40)),
                onPressed: _handleLogIn,
                child: const Text('Log in'),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  TextFormField _buildTextFormField(
    TextEditingController controller,
    String label, {
    bool isNumerical = false,
    bool isPassword = false,
    bool isLast = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumerical ? TextInputType.number : null,
      inputFormatters: isNumerical ? [FilteringTextInputFormatter.digitsOnly] : null,
      obscureText: isPassword,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) => value == null || value.isEmpty ? 'Please enter your $label' : null,
      decoration: InputDecoration(border: const OutlineInputBorder(), labelText: toBeginningOfSentenceCase(label)),
      textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
    );
  }

  Future<void> _handleLogIn() async {
    if (!_formKey.currentState!.validate()) return;

    late strava.Food food;

    try {
      food = await strava.fetch(
        _canteenIdController.text,
        username: _usernameController.text,
        password: _passwordController.text,
      );
    } catch (_) {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Your credentials are incorrect'),
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
