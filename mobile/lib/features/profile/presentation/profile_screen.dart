import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 16),
        CircleAvatar(
          radius: 42,
          child: Text(user?.username.substring(0, 1).toUpperCase() ?? '?'),
        ),
        const SizedBox(height: 14),
        Text(
          user?.username ?? '',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(user?.email ?? '', textAlign: TextAlign.center),
        const SizedBox(height: 24),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('母语'),
                trailing: Text(user?.nativeLanguage ?? '未设置'),
              ),
              ListTile(
                leading: const Icon(Icons.verified_user_outlined),
                title: const Text('状态'),
                trailing: Text(user?.status ?? ''),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('加入时间'),
                trailing: Text(
                  user == null
                      ? ''
                      : user.createdAt.toLocal().toString().split(' ').first,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: auth.loading
              ? null
              : () => ref.read(authProvider.notifier).logout(),
          icon: const Icon(Icons.logout),
          label: const Text('退出登录'),
        ),
      ],
    );
  }
}
