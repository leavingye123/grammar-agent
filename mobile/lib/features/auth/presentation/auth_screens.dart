import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'auth_controller.dart';

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return '请输入邮箱';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) return '请输入有效邮箱';
  return null;
}

String? validatePassword(String? value, {bool registering = false}) {
  if (value == null || value.isEmpty) return '请输入密码';
  if (registering &&
      (value.length < 8 ||
          !RegExp(r'[A-Za-z]').hasMatch(value) ||
          !RegExp(r'\d').hasMatch(value))) {
    return '密码至少 8 位，且包含字母和数字';
  }
  return null;
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    await ref.read(authProvider.notifier).login(_email.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.school_rounded,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '欢迎回到 GrammarAgent',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      key: const Key('login-email'),
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      validator: validateEmail,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      key: const Key('login-password'),
                      controller: _password,
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      validator: validatePassword,
                      decoration: const InputDecoration(labelText: 'Password'),
                    ),
                    if (auth.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          auth.error!,
                          key: const Key('auth-error'),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    const SizedBox(height: 22),
                    FilledButton(
                      key: const Key('login-submit'),
                      onPressed: auth.loading ? null : _submit,
                      child: auth.loading
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('登录'),
                    ),
                    TextButton(
                      onPressed: auth.loading
                          ? null
                          : () => context.go('/register'),
                      child: const Text('没有账号？立即注册'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  @override
  void dispose() {
    _email.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    await ref
        .read(authProvider.notifier)
        .register(_email.text, _username.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('创建账号')),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _form,
            child: Column(
              children: [
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  validator: validateEmail,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _username,
                  validator: (v) =>
                      (v?.trim().length ?? 0) < 2 ? '用户名至少 2 个字符' : null,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  validator: (v) => validatePassword(v, registering: true),
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                if (auth.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      auth.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                const SizedBox(height: 22),
                FilledButton(
                  onPressed: auth.loading ? null : _submit,
                  child: auth.loading
                      ? const CircularProgressIndicator()
                      : const Text('注册并登录'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.school_rounded, size: 72),
          SizedBox(height: 18),
          Text('GrammarAgent'),
          SizedBox(height: 18),
          CircularProgressIndicator(),
        ],
      ),
    ),
  );
}
