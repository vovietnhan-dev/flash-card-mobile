import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(userSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cài Đặt')),
      body: settingsAsync.when(
        data: (settings) => ListView(
          children: [
            _buildSection(
              context,
              title: 'Học Tập',
              children: [
                _buildListTile(
                  context,
                  icon: Icons.calendar_today,
                  title: 'Mục tiêu hàng ngày',
                  subtitle: '${settings.dailyGoal} thẻ',
                  onTap: () => _showDailyGoalDialog(context, ref, settings.dailyGoal),
                ),
                _buildListTile(
                  context,
                  icon: Icons.new_releases,
                  title: 'Thẻ mới mỗi ngày',
                  subtitle: '${settings.newCardsPerDay} thẻ',
                  onTap: () => _showNewCardsDialog(context, ref, settings.newCardsPerDay),
                ),
              ],
            ),
            _buildSection(
              context,
              title: 'Thuật Toán Lặp Lại',
              children: [_buildSpacedRepetitionTile(context, ref, settings.spacedRepetitionPreset)],
            ),
            _buildSection(
              context,
              title: 'Giao Diện',
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.lightbulb_outline),
                  title: const Text('Hiển thị gợi ý'),
                  subtitle: const Text('Cho phép xem gợi ý khi học'),
                  value: settings.showHints,
                  onChanged: (value) => _updateSettings(ref, showHints: value),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.volume_up),
                  title: const Text('Âm thanh'),
                  subtitle: const Text('Phát âm thanh trong ứng dụng'),
                  value: settings.enableSound,
                  onChanged: (value) => _updateSettings(ref, enableSound: value),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.play_circle_outline),
                  title: const Text('Tự động phát âm thanh'),
                  subtitle: const Text('Phát âm thanh khi lật thẻ'),
                  value: settings.autoPlayAudio,
                  onChanged: (value) => _updateSettings(ref, autoPlayAudio: value),
                ),
              ],
            ),
            _buildSection(
              context,
              title: 'Thông Báo',
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: const Text('Thông báo'),
                  subtitle: const Text('Nhận thông báo nhắc nhở học tập'),
                  value: settings.enableNotifications,
                  onChanged: (value) => _updateSettings(ref, enableNotifications: value),
                ),
              ],
            ),
            _buildSection(
              context,
              title: 'Tài Khoản',
              children: [
                _buildListTile(
                  context,
                  icon: Icons.logout,
                  title: 'Đăng xuất',
                  subtitle: 'Thoát khỏi tài khoản hiện tại',
                  onTap: () => _showLogoutDialog(context, ref),
                ),
              ],
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSpacedRepetitionTile(BuildContext context, WidgetRef ref, String currentPreset) {
    return ListTile(
      leading: const Icon(Icons.psychology),
      title: const Text('Độ khó lặp lại'),
      subtitle: Text(_getPresetDisplayName(currentPreset)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showSpacedRepetitionDialog(context, ref, currentPreset),
    );
  }

  String _getPresetDisplayName(String preset) {
    switch (preset) {
      case 'conservative':
        return 'Bảo thủ - Lặp lại nhiều hơn';
      case 'aggressive':
        return 'Tích cực - Lặp lại ít hơn';
      case 'normal':
      default:
        return 'Bình thường - Cân bằng';
    }
  }

  String _getPresetDescription(String preset) {
    switch (preset) {
      case 'conservative':
        return 'Khoảng cách lặp lại ngắn hơn, cần nhiều lần ôn tập hơn để đạt trạng thái "đã thuộc". Phù hợp với người muốn ghi nhớ chắc chắn.';
      case 'aggressive':
        return 'Khoảng cách lặp lại dài hơn, ít lần ôn tập hơn để đạt trạng thái "đã thuộc". Phù hợp với người học nhanh và có khả năng ghi nhớ tốt.';
      case 'normal':
      default:
        return 'Khoảng cách lặp lại tiêu chuẩn theo thuật toán SM-2. Phù hợp với hầu hết người học.';
    }
  }

  void _showSpacedRepetitionDialog(BuildContext context, WidgetRef ref, String currentPreset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn độ khó lặp lại'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPresetOption(
                context,
                ref,
                preset: 'conservative',
                title: 'Bảo thủ',
                description: _getPresetDescription('conservative'),
                isSelected: currentPreset == 'conservative',
              ),
              const Divider(),
              _buildPresetOption(
                context,
                ref,
                preset: 'normal',
                title: 'Bình thường',
                description: _getPresetDescription('normal'),
                isSelected: currentPreset == 'normal',
              ),
              const Divider(),
              _buildPresetOption(
                context,
                ref,
                preset: 'aggressive',
                title: 'Tích cực',
                description: _getPresetDescription('aggressive'),
                isSelected: currentPreset == 'aggressive',
              ),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Đóng'))],
      ),
    );
  }

  Widget _buildPresetOption(
    BuildContext context,
    WidgetRef ref, {
    required String preset,
    required String title,
    required String description,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        _updateSettings(ref, spacedRepetitionPreset: preset);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã chuyển sang chế độ $title')));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Radio<String>(value: preset, groupValue: isSelected ? preset : null, onChanged: (_) {}),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(description, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDailyGoalDialog(BuildContext context, WidgetRef ref, int currentGoal) {
    final controller = TextEditingController(text: currentGoal.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mục tiêu hàng ngày'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Số thẻ', helperText: 'Số thẻ bạn muốn học mỗi ngày'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              final newGoal = int.tryParse(controller.text);
              if (newGoal != null && newGoal > 0) {
                _updateSettings(ref, dailyGoal: newGoal);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showNewCardsDialog(BuildContext context, WidgetRef ref, int currentCount) {
    final controller = TextEditingController(text: currentCount.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thẻ mới mỗi ngày'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Số thẻ mới', helperText: 'Số thẻ mới bạn muốn học mỗi ngày'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              final newCount = int.tryParse(controller.text);
              if (newCount != null && newCount > 0) {
                _updateSettings(ref, newCardsPerDay: newCount);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _logout(context, ref);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.logout();

      // Clear current user
      ref.read(currentUserProvider.notifier).state = null;

      // Navigate to login - don't invalidate providers here
      // Providers will be invalidated after successful login with new token
      if (context.mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi đăng xuất: $e')));
      }
    }
  }

  Future<void> _updateSettings(
    WidgetRef ref, {
    int? dailyGoal,
    int? newCardsPerDay,
    bool? enableNotifications,
    bool? enableSound,
    bool? autoPlayAudio,
    bool? showHints,
    String? spacedRepetitionPreset,
  }) async {
    try {
      final repository = ref.read(statisticsRepositoryProvider);
      await repository.updateUserSettings(
        dailyGoal: dailyGoal,
        newCardsPerDay: newCardsPerDay,
        enableNotifications: enableNotifications,
        enableSound: enableSound,
        autoPlayAudio: autoPlayAudio,
        showHints: showHints,
        spacedRepetitionPreset: spacedRepetitionPreset,
      );
      ref.invalidate(userSettingsProvider);
    } catch (e) {
      debugPrint('Error updating settings: $e');
    }
  }
}
