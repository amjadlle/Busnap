import 'dart:async';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:busnap/main.dart';

class AlarmSettingsScreen extends StatefulWidget {
  const AlarmSettingsScreen({super.key});

  @override
  State<AlarmSettingsScreen> createState() => _AlarmSettingsScreenState();
}

class _AlarmSettingsScreenState extends State<AlarmSettingsScreen> {
  String? _fileName;
  String? _filePath;
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  List<int> _alertDistances = [5, 2, 1];
  Timer? _playTimer;
  StreamSubscription? _completeSub;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _player.dispose();
    _playTimer?.cancel();
    _completeSub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _filePath = prefs.getString('alarm_file_path');
      _fileName = prefs.getString('alarm_file_name');
      final saved = prefs.getStringList('alert_distances')
          ?.map(int.tryParse).whereType<int>().where((km) => km > 0).toSet().toList();
      if (saved != null && saved.isNotEmpty) {
        saved.sort((a, b) => b.compareTo(a));
        _alertDistances = saved;
      }
    });
  }

  Future<void> _saveAlertDistances(List<int> distances) async {
    distances = distances.toSet().where((km) => km > 0).toList()
      ..sort((a, b) => b.compareTo(a));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('alert_distances', distances.map((km) => '$km').toList());
    if (mounted) setState(() => _alertDistances = distances);
  }

  Future<void> _addAlertDistance() async {
    final controller = TextEditingController();
    final value = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add an alert'),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          maxLength: 3,
          decoration: const InputDecoration(
            labelText: 'Distance',
            hintText: 'Example: 3',
            suffixText: 'km',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, int.tryParse(controller.text.trim())),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    // The route dismisses asynchronously; dispose only after EditableText unmounts.
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.dispose());
    if (value == null || value < 1 || value > 100 || _alertDistances.contains(value)) return;
    await _saveAlertDistances([..._alertDistances, value]);
  }

  Future<void> _setCustomAlertCount() async {
    final controller = TextEditingController();
    final count = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Number of alerts'),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          maxLength: 2,
          decoration: const InputDecoration(
            labelText: 'Alerts',
            hintText: 'Example: 5',
            suffixText: 'alerts',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, int.tryParse(controller.text.trim())),
            child: const Text('Set'),
          ),
        ],
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.dispose());
    if (count == null || count < 1 || count > 10) return;
    await _saveAlertDistances(List.generate(count, (index) => count - index));
  }

  Future<void> _pick() async {
    setState(() => _isLoading = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'ogg', 'm4a'],
      );
      if (result?.files.single.path != null) {
        final name = result!.files.single.name;
        final path = result.files.single.path!;
        final directory = await getApplicationDocumentsDirectory();
        final extension = name.contains('.') ? name.substring(name.lastIndexOf('.')) : '';
        final storedFile = File('${directory.path}/custom_alarm$extension');
        await File(path).copy(storedFile.path);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('alarm_file_path', storedFile.path);
        await prefs.setString('alarm_file_name', name);
        if (!mounted) return;
        setState(() {
          _fileName = name;
          _filePath = storedFile.path;
        });
        _snack('Custom alarm saved', success: true);
      }
    } catch (_) {
      _snack('Could not pick file', success: false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _remove() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('alarm_file_path');
    await prefs.remove('alarm_file_name');
    if (!mounted) return;
    setState(() {
      _filePath = null;
      _fileName = null;
      _isLoading = false;
    });
    _snack('Reverted to default alarm', success: true);
  }

  Future<void> _toggleTest() async {
    if (_isPlaying) {
      _stopTest();
      return;
    }
    setState(() => _isPlaying = true);
    _completeSub?.cancel();
    _completeSub = _player.onPlayerComplete.listen((_) {
      if (_isPlaying) _playOnce();
    });
    await _playOnce();
    _playTimer = Timer(const Duration(minutes: 1), _stopTest);
  }

  Future<void> _playOnce() async {
    try {
      if (_filePath != null) {
        await _player.play(DeviceFileSource(_filePath!));
      } else {
        await _player.play(AssetSource('alarm.mp3'));
      }
    } catch (_) {
      _stopTest();
    }
  }

  void _stopTest() {
    _player.stop();
    _playTimer?.cancel();
    _completeSub?.cancel();
    if (mounted) setState(() => _isPlaying = false);
  }

  void _snack(String msg, {required bool success}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? AppTheme.accent : AppTheme.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _glass({required Widget child, double radius = 16, EdgeInsets padding = const EdgeInsets.all(16)}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AppTheme.glassFill,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.transparent),
            boxShadow: const [
              BoxShadow(color: AppTheme.glassShadow, blurRadius: 24, offset: Offset(0, 12)),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.4),
                  radius: 1.2,
                  colors: [AppTheme.gradCentre, AppTheme.gradEdge],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 20, 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.ink),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Text('Alarm Sound',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                              color: AppTheme.ink, letterSpacing: -0.3)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildStatusCard(),
                      const SizedBox(height: 16),
                      _buildActionsCard(),
                      const SizedBox(height: 16),
                      _buildInfoCard(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final hasCustom = _fileName != null;
    return _glass(
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: hasCustom ? AppTheme.accentLight : AppTheme.glassBorder.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              hasCustom ? Icons.music_note_rounded : Icons.notifications_rounded,
              color: hasCustom ? AppTheme.accent : AppTheme.inkSecondary, size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hasCustom ? 'Custom Alarm' : 'Default Alarm',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                        color: AppTheme.ink)),
                const SizedBox(height: 2),
                Text(hasCustom ? _fileName! : 'Built-in alarm sound',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppTheme.inkSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard() {
    return _glass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Options', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
              color: AppTheme.inkMuted, letterSpacing: 0.8)),
          const SizedBox(height: 14),
          SizedBox(height: 50,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _toggleTest,
              icon: Icon(_isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded, size: 20),
              label: Text(_isPlaying ? 'Stop Preview' : 'Preview Alarm'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(height: 50,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _pick,
              icon: const Icon(Icons.folder_open_rounded, size: 18),
              label: const Text('Choose Custom Sound'),
            ),
          ),
          const SizedBox(height: 18),
          const Text('Alert distances', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Choose a count, then add or remove any whole-kilometre alert.',
              style: TextStyle(fontSize: 12, color: AppTheme.inkSecondary)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            ChoiceChip(
              label: const Text('2 alerts'),
              selected: _alertDistances.length == 2 && _alertDistances.contains(5) && _alertDistances.contains(1),
              onSelected: _isLoading ? null : (_) => _saveAlertDistances([5, 1]),
            ),
            ChoiceChip(
              label: const Text('3 alerts'),
              selected: _alertDistances.length == 3 && _alertDistances.contains(5) && _alertDistances.contains(2) && _alertDistances.contains(1),
              onSelected: _isLoading ? null : (_) => _saveAlertDistances([5, 2, 1]),
            ),
            ChoiceChip(
              label: const Text('4 alerts'),
              selected: _alertDistances.length == 4 && _alertDistances.contains(10) && _alertDistances.contains(5) && _alertDistances.contains(2) && _alertDistances.contains(1),
              onSelected: _isLoading ? null : (_) => _saveAlertDistances([10, 5, 2, 1]),
            ),
            ActionChip(
              avatar: const Icon(Icons.tune_rounded, size: 17),
              label: const Text('Custom count'),
              onPressed: _isLoading ? null : _setCustomAlertCount,
            ),
          ]),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            ..._alertDistances.map((km) => InputChip(
              label: Text('$km km'),
              onDeleted: _alertDistances.length == 1 || _isLoading
                  ? null
                  : () => _saveAlertDistances(_alertDistances.where((item) => item != km).toList()),
            )),
            ActionChip(
              avatar: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Custom'),
              onPressed: _isLoading ? null : _addAlertDistance,
            ),
          ]),
          if (_fileName != null) ...[
            const SizedBox(height: 10),
            SizedBox(height: 50,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _remove,
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppTheme.danger),
                label: const Text('Remove Custom Sound', style: TextStyle(color: AppTheme.danger)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.danger.withValues(alpha: 0.7), width: 1.5),
                  foregroundColor: AppTheme.danger,
                  backgroundColor: AppTheme.danger.withValues(alpha: 0.08),
                ),
              ),
            ),
          ],
          if (_isLoading) ...[
            const SizedBox(height: 16),
            const Center(child: SizedBox(width: 22, height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.ink))),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return _glass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Supported formats', style: TextStyle(fontSize: 11,
              fontWeight: FontWeight.w700, color: AppTheme.inkMuted, letterSpacing: 0.8)),
          const SizedBox(height: 10),
          Text(
            'MP3 · WAV · OGG · M4A\n\nYour alarm plays at 5 km, 2 km, and 1 km from the destination and loops for up to 1 minute.',
            style: TextStyle(fontSize: 13, color: AppTheme.inkSecondary, height: 1.6),
          ),
        ],
      ),
    );
  }
}
