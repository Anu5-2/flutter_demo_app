import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants.dart';
import '../services/local_auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = LocalAuthService();
  Map<String, dynamic>? _currentUser;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _authService.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _currentUser = user;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final petName =
        (_currentUser?['petName'] as String?)?.trim() ?? 'Pet Owner';

    final items = [
      _SettingItem(Icons.pets, 'Pet Profile', 'Manage your pet\'s details',
          petName: petName),
      const _SettingItem(
          Icons.watch, 'Device Settings', 'Manage connected collar'),
      const _SettingItem(Icons.notifications_none, 'Notification Preferences',
          'Alerts & sounds'),
      const _SettingItem(
          Icons.lock_outline, 'Privacy & Security', 'Account & data controls'),
      const _SettingItem(Icons.info_outline, 'About', 'App version & support'),
    ];

    return Scaffold(
      backgroundColor: AppColors.paleBlueBg,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.lightBlueBg,
        foregroundColor: AppColors.primaryBlue,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children:
                  items.map((item) => _settingsTile(context, item)).toList(),
            ),
    );
  }

  Widget _settingsTile(BuildContext context, _SettingItem item) {
    return InkWell(
      onTap: () {
        final detailWidget = item.title == 'Pet Profile'
            ? PetProfileDetailScreen(
                petName: item.petName ?? 'Pet Owner',
              )
            : item.title == 'Privacy & Security'
                ? const PrivacySecurityScreen()
                : item.title == 'About'
                    ? const AboutScreen()
                    : item.title == 'Device Settings'
                        ? const DeviceSettingsScreen()
                        : item.title == 'Notification Preferences'
                            ? const NotificationPreferencesScreen()
                            : SettingsDetailScreen(
                                title: item.title,
                                subtitle: item.subtitle,
                              );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => detailWidget),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.actionBlueBg,
              child: Icon(item.icon, color: AppColors.primaryBlue, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(item.subtitle,
                      style: const TextStyle(
                          color: AppColors.textGrey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }
}

class SettingsDetailScreen extends StatelessWidget {
  final String title;
  final String subtitle;

  const SettingsDetailScreen({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paleBlueBg,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.lightBlueBg,
        foregroundColor: AppColors.primaryBlue,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$title Details',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DeviceSettingsScreen extends StatefulWidget {
  const DeviceSettingsScreen({super.key});

  @override
  State<DeviceSettingsScreen> createState() => _DeviceSettingsScreenState();
}

class _DeviceSettingsScreenState extends State<DeviceSettingsScreen> {
  final _deviceNameController =
      TextEditingController(text: AppStrings.deviceName);
  Timer? _connectionTimer;
  bool _isOnline = true;
  final double _batteryLevel = 0.85;
  double _geofenceRadius = 200;
  String _gpsInterval = '10s';

  @override
  void initState() {
    super.initState();
    _connectionTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted && _isOnline) setState(() {});
    });
  }

  @override
  void dispose() {
    _connectionTimer?.cancel();
    _deviceNameController.dispose();
    super.dispose();
  }

  void _disconnect() {
    setState(() => _isOnline = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Device disconnected')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final batteryPercent = (_batteryLevel * 100).round();
    return Scaffold(
      backgroundColor: AppColors.paleBlueBg,
      appBar: AppBar(
        title: const Text('Device Settings'),
        backgroundColor: AppColors.lightBlueBg,
        foregroundColor: AppColors.primaryBlue,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            controller: _deviceNameController,
            decoration: const InputDecoration(
              labelText: 'Device Name',
              filled: true,
            ),
          ),
          const SizedBox(height: 16),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Device ID / MAC Address'),
            subtitle: Text('PET-COLLAR-001', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Connection Status'),
            subtitle: Row(
              children: [
                _StatusDot(isOnline: _isOnline),
                const SizedBox(width: 8),
                Text(_isOnline ? 'Online' : 'Offline'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text('Battery Level: $batteryPercent%',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: _batteryLevel, minHeight: 10),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            initialValue: _gpsInterval,
            decoration: const InputDecoration(
              labelText: 'GPS Update Interval',
              filled: true,
            ),
            items: ['5s', '10s', '30s']
                .map((interval) => DropdownMenuItem(
                      value: interval,
                      child: Text(interval),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _gpsInterval = value ?? '10s'),
          ),
          const SizedBox(height: 24),
          Text('Geofence Radius: ${_geofenceRadius.round()} m',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Slider(
            min: 50,
            max: 1000,
            divisions: 19,
            value: _geofenceRadius,
            label: '${_geofenceRadius.round()} m',
            onChanged: (value) => setState(() => _geofenceRadius = value),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _isOnline ? _disconnect : null,
            style: FilledButton.styleFrom(backgroundColor: AppColors.dangerRed),
            icon: const Icon(Icons.bluetooth_disabled),
            label: const Text('Disconnect Device'),
          ),
        ],
      ),
    );
  }
}

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  final _authService = LocalAuthService();
  final _preferenceKeys = const [
    'geofence_breach_alert',
    'safe_zone_return_alert',
    'low_battery_alert',
    'device_offline_alert',
  ];
  final _preferenceLabels = const [
    'Geofence Breach Alert',
    'Pet Returns to Safe Zone',
    'Low Battery Alert',
    'Device Offline Alert',
  ];
  List<bool> _preferences = [true, true, true, true];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final values = await Future.wait(
      _preferenceKeys.map(_authService.getNotificationPreference),
    );
    if (!mounted) return;
    setState(() => _preferences = values.cast<bool>());
  }

  Future<void> _updatePreference(int index, bool value) async {
    setState(() => _preferences[index] = value);
    await _authService.setNotificationPreference(_preferenceKeys[index], value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paleBlueBg,
      appBar: AppBar(
        title: const Text('Notification Preferences'),
        backgroundColor: AppColors.lightBlueBg,
        foregroundColor: AppColors.primaryBlue,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: _preferenceLabels.length,
        separatorBuilder: (_, index) => const Divider(height: 1),
        itemBuilder: (context, index) => SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(_preferenceLabels[index]),
          value: _preferences[index],
          onChanged: (value) => _updatePreference(index, value),
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final bool isOnline;

  const _StatusDot({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: isOnline ? AppColors.safeGreen : AppColors.dangerRed,
        shape: BoxShape.circle,
      ),
    );
  }
}

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  final _authService = LocalAuthService();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _sharingLocation = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final sharing = await _authService.getLocationSharing();
    if (!mounted) return;
    setState(() => _sharingLocation = sharing);
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveSecurity() async {
    final current = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmation = _confirmPasswordController.text;
    if (newPassword.isNotEmpty ||
        confirmation.isNotEmpty ||
        current.isNotEmpty) {
      if (newPassword != confirmation) {
        _showMessage('New passwords do not match');
        return;
      }
      final error = await _authService.changePassword(
        currentPassword: current,
        newPassword: newPassword,
      );
      if (error != null) {
        _showMessage(error);
        return;
      }
    }
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    _showMessage('Security settings saved');
  }

  Future<void> _deleteHistory() async {
    final confirmed = await _confirm('Delete Location History',
        'This will permanently remove all saved location history.');
    if (confirmed) {
      await _authService.deleteLocationHistory();
      _showMessage('Location history deleted');
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await _confirm('Delete Account',
        'This permanently deletes your account and cannot be undone.');
    if (!confirmed) return;
    await _authService.deleteCurrentAccount();
    if (mounted) Navigator.pop(context);
  }

  Future<bool> _confirm(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Confirm')),
            ],
          ),
        ) ??
        false;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paleBlueBg,
      appBar: AppBar(title: const Text('Privacy & Security')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _securityField('Current Password', _currentPasswordController,
              obscureText: true),
          const SizedBox(height: 12),
          _securityField('New Password', _newPasswordController,
              obscureText: true),
          const SizedBox(height: 12),
          _securityField('Confirm New Password', _confirmPasswordController,
              obscureText: true),
          const SizedBox(height: 12),
          const SizedBox(height: 4),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Location Data Sharing'),
            value: _sharingLocation,
            onChanged: (value) async {
              setState(() => _sharingLocation = value);
              await _authService.setLocationSharing(value);
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _deleteHistory,
            icon: const Icon(Icons.delete_sweep_outlined),
            label: const Text('Delete Location History'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: AppColors.dangerRed),
            onPressed: _deleteAccount,
            icon: const Icon(Icons.delete_forever_outlined),
            label: const Text('Delete Account'),
          ),
          const SizedBox(height: 24),
          FilledButton(
              onPressed: _saveSecurity,
              child: const Text('Save Security Settings')),
        ],
      ),
    );
  }

  Widget _securityField(String label, TextEditingController controller,
      {bool obscureText = false, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label, filled: true),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const details = {
      'App Name': 'PET ZONE',
      'Version': '1.0.0',
      'Developer': 'PetZone Development Team',
      'College': 'Your College Name',
      'Contact Email': 'petzone@example.com',
      'Project Type': 'IoT Final Year Project',
    };
    return Scaffold(
      backgroundColor: AppColors.paleBlueBg,
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: details.entries
            .map((entry) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(entry.key,
                      style: const TextStyle(color: AppColors.textGrey)),
                  subtitle:
                      Text(entry.value, style: const TextStyle(fontSize: 16)),
                ))
            .toList(),
      ),
    );
  }
}

class PetProfileDetailScreen extends StatefulWidget {
  final String petName;

  const PetProfileDetailScreen({
    super.key,
    required this.petName,
  });

  @override
  State<PetProfileDetailScreen> createState() => _PetProfileDetailScreenState();
}

class _PetProfileDetailScreenState extends State<PetProfileDetailScreen> {
  final _authService = LocalAuthService();
  final _formKey = GlobalKey<FormState>();
  final _petNameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _imagePicker = ImagePicker();
  String _petType = 'Dog';
  String? _photoPath;
  Uint8List? _photoBytes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _petNameController.text = widget.petName;
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = await _authService.getCurrentUser();
    if (!mounted || user == null) return;
    final photoPath = user['petPhotoPath'] as String?;
    Uint8List? photoBytes;
    if (photoPath != null) {
      try {
        photoBytes = await XFile(photoPath).readAsBytes();
      } catch (_) {
        photoBytes = null;
      }
    }
    if (!mounted) return;
    setState(() {
      _petNameController.text = (user['petName'] as String?) ?? widget.petName;
      _breedController.text = (user['breed'] as String?) ?? '';
      _ageController.text = (user['age'] as String?) ?? '';
      _weightController.text = (user['weight'] as String?) ?? '';
      _petType = (user['petType'] as String?) ?? 'Dog';
      _photoPath = photoPath;
      _photoBytes = photoBytes;
    });
  }

  @override
  void dispose() {
    _petNameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final file = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      _photoPath = file.path;
      _photoBytes = bytes;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await _authService.updateCurrentPetProfile(
      petName: _petNameController.text,
      petType: _petType,
      breed: _breedController.text,
      age: _ageController.text,
      weight: _weightController.text,
      photoPath: _photoPath,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pet profile saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paleBlueBg,
      appBar: AppBar(
        title: const Text('Pet Profile'),
        backgroundColor: AppColors.lightBlueBg,
        foregroundColor: AppColors.primaryBlue,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.actionBlueBg,
                  backgroundImage:
                      _photoBytes == null ? null : MemoryImage(_photoBytes!),
                  child: _photoBytes == null
                      ? const Icon(Icons.add_a_photo,
                          size: 32, color: AppColors.primaryBlue)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
                child: Text('Pet Photo',
                    style: TextStyle(color: AppColors.textGrey))),
            const SizedBox(height: 24),
            _field('Pet Name', _petNameController),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _petType,
              decoration:
                  const InputDecoration(labelText: 'Pet Type', filled: true),
              items: ['Dog', 'Cat', 'Other']
                  .map((type) =>
                      DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) => setState(() => _petType = value ?? 'Dog'),
            ),
            const SizedBox(height: 16),
            _field('Breed', _breedController),
            const SizedBox(height: 16),
            _field('Age', _ageController, keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _field('Weight', _weightController,
                keyboardType: TextInputType.number),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController controller,
      {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label, filled: true),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Required';
        if (keyboardType == TextInputType.number &&
            num.tryParse(value) == null) {
          return 'Enter a number';
        }
        return null;
      },
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? petName;

  const _SettingItem(
    this.icon,
    this.title,
    this.subtitle, {
    this.petName,
  });
}
