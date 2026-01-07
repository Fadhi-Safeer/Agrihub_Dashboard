import 'package:agrihub_dashboard/services/settings_config_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_colors.dart';
import '../theme/text_styles.dart';
import '../widgets/navigation_sidebar.dart';
import '../widgets/monitoring_pages/top_bard.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const String _backendBaseUrl = "http://localhost:8001";

  late final ModelConfigService _configService =
      const ModelConfigService(baseUrl: _backendBaseUrl);

  // Local cache keys
  static const String _kDetectionPath = "model_path_detection";
  static const String _kGrowthPath = "model_path_growth";
  static const String _kHealthPath = "model_path_health";
  static const String _kDiseasePath = "model_path_disease";
  static const String _kPredictionPath = "model_path_prediction";

  static const String _kDetectionConf = "model_conf_detection";
  static const String _kGrowthConf = "model_conf_growth";
  static const String _kHealthConf = "model_conf_health";
  static const String _kDiseaseConf = "model_conf_disease";
  static const String _kPredictionConf = "model_conf_prediction";

  static const String _kImageFolderPath = "image_folder_path";

  // Alert Email IDs cache key
  static const String _kAlertEmails = "alert_email_ids";

  // ✅ NEW: Alert Times cache key
  static const String _kAlertTimes = "alert_times";

  // State
  String _detectionPath = r"backend\Models\LETTUCE_DETECTION_MODEL.pt";
  int _detectionConfPct = 65;

  String _growthPath = r"backend\Models\GROWTH_CLASSIFICATION_MODEL.pt";
  int _growthConfPct = 80;

  String _healthPath = r"backend\Models\HEALTH_CLASSIFICATION_MODEL.pt";
  int _healthConfPct = 85;

  String _diseasePath = r"backend\Models\DISEASE_CLASSIFICATION_MODEL.pt";
  int _diseaseConfPct = 85;

  String _predictionPath = r"backend\Models\lettuce_model.joblib";
  int _predictionConfPct = 75; // kept for backend + cache compatibility

  String _imageFolderPath = "backend/Images/";

  // Alert emails
  List<String> _alertEmails = [];

  // ✅ NEW: Alert times (e.g. ["09:00", "15:00"])
  List<String> _alertTimes = [];

  // Cache controller (stores comma separated string in SharedPreferences)
  final TextEditingController _alertEmailsCacheController =
      TextEditingController();

  // Better UI controllers
  final TextEditingController _emailInputController = TextEditingController();
  String? _emailInputError;

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  @override
  void dispose() {
    _alertEmailsCacheController.dispose();
    _emailInputController.dispose();
    super.dispose();
  }

  Future<void> _initLoad() async {
    await _loadSettings();
    await _fetchConfigFromBackend();
    await _fetchImageFolderFromBackend();
    await _fetchAlertEmailsFromBackend();
    // ✅ NEW: also fetch alert times from backend
    await _fetchAlertTimesFromBackend();
  }

  double _pctToDouble01(int pct) => pct.clamp(0, 100) / 100.0;
  int _double01ToPct(num v) => (v.toDouble() * 100).round().clamp(0, 100);

  // =========================
  // EMAIL HELPERS (UI)
  // =========================
  bool _isValidEmail(String email) {
    final re = RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$");
    return re.hasMatch(email.trim());
  }

  List<String> _parseEmails(String input) {
    final parts = input
        .split(RegExp(r"[,\n;]+"))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final seen = <String>{};
    final uniq = <String>[];
    for (final e in parts) {
      final lower = e.toLowerCase();
      if (!seen.contains(lower)) {
        seen.add(lower);
        uniq.add(e);
      }
    }
    return uniq;
  }

  String? _validateEmails(List<String> emails) {
    final invalid = emails.where((e) => !_isValidEmail(e)).toList();
    if (invalid.isNotEmpty) return "Invalid email(s): ${invalid.join(', ')}";
    return null;
  }

  void _syncEmailCacheText() {
    _alertEmailsCacheController.text = _alertEmails.join(", ");
  }

  void _addEmailFromInput() {
    final raw = _emailInputController.text.trim();
    if (raw.isEmpty) {
      setState(() => _emailInputError = "Enter an email first.");
      return;
    }
    if (!_isValidEmail(raw)) {
      setState(() => _emailInputError = "Invalid email format.");
      return;
    }

    final exists =
        _alertEmails.any((e) => e.toLowerCase() == raw.toLowerCase());
    if (exists) {
      setState(() => _emailInputError = "This email is already added.");
      return;
    }

    setState(() {
      _alertEmails.add(raw);
      _emailInputController.clear();
      _emailInputError = null;
      _syncEmailCacheText();
    });
  }

  void _removeEmail(String email) {
    setState(() {
      _alertEmails.removeWhere((e) => e.toLowerCase() == email.toLowerCase());
      _syncEmailCacheText();
    });
  }

  Future<void> _openBulkEmailDialog() async {
    final controller = TextEditingController(text: _alertEmails.join(", "));
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Multiple Emails"),
        content: TextField(
          controller: controller,
          minLines: 4,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: "Paste emails separated by comma / newline / semicolon",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text("Apply"),
          ),
        ],
      ),
    );

    if (result == null) return;

    final parsed = _parseEmails(result);
    final err = _validateEmails(parsed);
    if (err != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _alertEmails = parsed;
      _emailInputError = null;
      _syncEmailCacheText();
    });
  }

  // =========================
  // ALERT TIME HELPERS (UI)
  // =========================

  String _formatTimeOfDay(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  Future<void> _addAlertTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: now,
    );

    if (picked == null) return;

    final formatted = _formatTimeOfDay(picked);

    final exists = _alertTimes.contains(formatted);
    if (exists) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Time $formatted is already added."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _alertTimes.add(formatted);
      _alertTimes.sort(); // keep it neat
    });

    await _saveSettings();
  }

  void _removeAlertTime(String time) {
    setState(() {
      _alertTimes.remove(time);
    });
  }

  // =========================
  // BACKEND FETCH/SAVE
  // =========================
  Future<void> _fetchConfigFromBackend() async {
    try {
      final data = await _configService.fetchModelConfig();
      if (!mounted) return;

      setState(() {
        _detectionPath =
            (data["Detection"]?["path"] as String?) ?? _detectionPath;
        _detectionConfPct =
            _double01ToPct((data["Detection"]?["confidence"] as num?) ?? 0.65);

        _growthPath = (data["Growth"]?["path"] as String?) ?? _growthPath;
        _growthConfPct =
            _double01ToPct((data["Growth"]?["confidence"] as num?) ?? 0.80);

        _healthPath = (data["Health"]?["path"] as String?) ?? _healthPath;
        _healthConfPct =
            _double01ToPct((data["Health"]?["confidence"] as num?) ?? 0.85);

        _diseasePath = (data["Disease"]?["path"] as String?) ?? _diseasePath;
        _diseaseConfPct =
            _double01ToPct((data["Disease"]?["confidence"] as num?) ?? 0.85);

        _predictionPath =
            (data["Prediction"]?["path"] as String?) ?? _predictionPath;

        _predictionConfPct =
            _double01ToPct((data["Prediction"]?["confidence"] as num?) ?? 0.75);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Backend config load failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _fetchImageFolderFromBackend() async {
    try {
      final path = await _configService.fetchImageFolderPath();
      if (!mounted) return;
      setState(() => _imageFolderPath = path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Image folder load failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _fetchAlertEmailsFromBackend() async {
    try {
      final emails = await _configService.fetchAlertEmails();
      if (!mounted) return;

      final err = _validateEmails(emails);
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err), backgroundColor: Colors.orange),
        );
      }

      setState(() {
        _alertEmails = emails;
        _syncEmailCacheText();
      });

      await _saveSettings();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Alert emails load failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ✅ NEW: fetch alert times from backend
  Future<void> _fetchAlertTimesFromBackend() async {
    try {
      // You’ll need to implement these methods in ModelConfigService:
      // fetchAlertTimes() -> List<String>
      final times = await _configService.fetchAlertTimes();
      if (!mounted) return;

      setState(() {
        _alertTimes = List<String>.from(times);
        _alertTimes.sort();
      });

      await _saveSettings();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Alert times load failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveConfigToBackend() async {
    final payload = <String, dynamic>{
      "Detection": {
        "path": _detectionPath,
        "confidence": _pctToDouble01(_detectionConfPct),
      },
      "Growth": {
        "path": _growthPath,
        "confidence": _pctToDouble01(_growthConfPct),
      },
      "Health": {
        "path": _healthPath,
        "confidence": _pctToDouble01(_healthConfPct),
      },
      "Disease": {
        "path": _diseasePath,
        "confidence": _pctToDouble01(_diseaseConfPct),
      },
      "Prediction": {
        "path": _predictionPath,
        "confidence": _pctToDouble01(_predictionConfPct),
      },
    };

    await _configService.updateModelConfig(payload);
    await _configService.updateImageFolderPath(_imageFolderPath);
    await _configService.updateAlertEmails(_alertEmails);

    // ✅ NEW: push alert times to backend
    await _configService.updateAlertTimes(_alertTimes);
  }

  // =========================
  // LOCAL CACHE
  // =========================
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _detectionPath = prefs.getString(_kDetectionPath) ?? _detectionPath;
      _growthPath = prefs.getString(_kGrowthPath) ?? _growthPath;
      _healthPath = prefs.getString(_kHealthPath) ?? _healthPath;
      _diseasePath = prefs.getString(_kDiseasePath) ?? _diseasePath;
      _predictionPath = prefs.getString(_kPredictionPath) ?? _predictionPath;

      _detectionConfPct = prefs.getInt(_kDetectionConf) ?? _detectionConfPct;
      _growthConfPct = prefs.getInt(_kGrowthConf) ?? _growthConfPct;
      _healthConfPct = prefs.getInt(_kHealthConf) ?? _healthConfPct;
      _diseaseConfPct = prefs.getInt(_kDiseaseConf) ?? _diseaseConfPct;
      _predictionConfPct = prefs.getInt(_kPredictionConf) ?? _predictionConfPct;

      _imageFolderPath = prefs.getString(_kImageFolderPath) ?? _imageFolderPath;

      final savedEmails = prefs.getString(_kAlertEmails);
      if (savedEmails != null && savedEmails.trim().isNotEmpty) {
        _alertEmailsCacheController.text = savedEmails;
        _alertEmails = _parseEmails(savedEmails);
      } else {
        _alertEmailsCacheController.text = "";
        _alertEmails = [];
      }

      // ✅ NEW: load alert times from cache
      final savedTimes = prefs.getStringList(_kAlertTimes);
      if (savedTimes != null) {
        _alertTimes = List<String>.from(savedTimes);
        _alertTimes.sort();
      } else {
        _alertTimes = [];
      }
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_kDetectionPath, _detectionPath);
    await prefs.setString(_kGrowthPath, _growthPath);
    await prefs.setString(_kHealthPath, _healthPath);
    await prefs.setString(_kDiseasePath, _diseasePath);
    await prefs.setString(_kPredictionPath, _predictionPath);

    await prefs.setInt(_kDetectionConf, _detectionConfPct);
    await prefs.setInt(_kGrowthConf, _growthConfPct);
    await prefs.setInt(_kHealthConf, _healthConfPct);
    await prefs.setInt(_kDiseaseConf, _diseaseConfPct);
    await prefs.setInt(_kPredictionConf, _predictionConfPct);

    await prefs.setString(_kImageFolderPath, _imageFolderPath);

    // store as a simple comma-separated string
    await prefs.setString(_kAlertEmails, _alertEmails.join(", "));

    // ✅ NEW: store alert times as string list
    await prefs.setStringList(_kAlertTimes, _alertTimes);
  }

  // =========================
  // PICKERS
  // =========================
  Future<void> _pickImageFolder() async {
    if (kIsWeb) {
      final controller = TextEditingController(text: _imageFolderPath);

      final result = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Set Image Folder Path"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "e.g. backend/Images/",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text("Save"),
            ),
          ],
        ),
      );

      if (result != null && result.isNotEmpty) {
        setState(() => _imageFolderPath = result);
        await _saveSettings();
      }
      return;
    }

    final path = await FilePicker.platform.getDirectoryPath(
      dialogTitle: "Select Images Folder",
      lockParentWindow: true,
    );

    if (path != null && path.trim().isNotEmpty) {
      setState(() => _imageFolderPath = path);
      await _saveSettings();
    }
  }

  Future<void> _pickModelFile(
    String modelType,
    Future<void> Function(String) onPathSelected,
  ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select $modelType Model',
        type: FileType.custom,
        allowedExtensions: ['pt', 'h5', 'pkl', 'joblib', 'tflite', 'onnx'],
        withData: true,
        lockParentWindow: true,
      );

      if (result == null) return;
      final file = result.files.single;

      if (kIsWeb) {
        final bytes = file.bytes;
        if (bytes == null) {
          throw Exception(
              "On web, file bytes are null. Ensure withData: true.");
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Uploading: ${file.name} ..."),
              backgroundColor: Colors.blueGrey,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        final backendPath = await _configService.uploadModel(
          modelType: modelType,
          fileName: file.name,
          bytes: bytes,
        );

        await onPathSelected(backendPath);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Uploaded & Selected: ${file.name}"),
              backgroundColor: Colors.green,
            ),
          );
        }
        return;
      }

      final pickedPath = file.path;
      if (pickedPath != null) {
        await onPathSelected(pickedPath);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Loaded: ${file.name}"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception("File path is null on this platform.");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error picking/uploading file: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // =========================
  // BUILD
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.monitoring_pages_background,
      body: Row(
        children: [
          const NavigationSidebar(),
          Expanded(
            child: Column(
              children: [
                TopBar(
                  title: 'Settings',
                  textStyle: TextStyles.mainHeading.copyWith(
                    color: AppColors.sidebarGradientStart,
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(32.0),
                    children: [
                      _buildSectionHeader('Model Configuration'),

                      // Detection
                      _buildModelConfigCard(
                        title: "YOLO Detection Model",
                        type: "OBJECT DETECTION",
                        color: Colors.redAccent,
                        path: _detectionPath,
                        confidencePct: _detectionConfPct,
                        onConfChanged: (v) async {
                          setState(() => _detectionConfPct = v);
                          await _saveSettings();
                        },
                        onPathTap: () =>
                            _pickModelFile("Detection", (path) async {
                          setState(() => _detectionPath = path);
                          await _saveSettings();
                        }),
                      ),
                      const SizedBox(height: 15),

                      // Growth + Health row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildModelConfigCard(
                              title: "Growth Stage Classifier",
                              type: "CLASSIFICATION",
                              color: Colors.blue,
                              path: _growthPath,
                              confidencePct: _growthConfPct,
                              onConfChanged: (v) async {
                                setState(() => _growthConfPct = v);
                                await _saveSettings();
                              },
                              onPathTap: () =>
                                  _pickModelFile("Growth", (path) async {
                                setState(() => _growthPath = path);
                                await _saveSettings();
                              }),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildModelConfigCard(
                              title: "Health Status Classifier",
                              type: "CLASSIFICATION",
                              color: Colors.teal,
                              path: _healthPath,
                              confidencePct: _healthConfPct,
                              onConfChanged: (v) async {
                                setState(() => _healthConfPct = v);
                                await _saveSettings();
                              },
                              onPathTap: () =>
                                  _pickModelFile("Health", (path) async {
                                setState(() => _healthPath = path);
                                await _saveSettings();
                              }),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Disease
                      _buildModelConfigCard(
                        title: "Disease Type Classifier",
                        type: "CLASSIFICATION",
                        color: Colors.orange,
                        path: _diseasePath,
                        confidencePct: _diseaseConfPct,
                        onConfChanged: (v) async {
                          setState(() => _diseaseConfPct = v);
                          await _saveSettings();
                        },
                        onPathTap: () =>
                            _pickModelFile("Disease", (path) async {
                          setState(() => _diseasePath = path);
                          await _saveSettings();
                        }),
                      ),

                      // Alerts section
                      const SizedBox(height: 30),
                      _buildSectionHeader('Alerts'),
                      _buildAlertEmailsCardBetter(),
                      const SizedBox(height: 15),
                      // ✅ NEW: Alert Times card
                      _buildAlertTimesCard(),

                      const SizedBox(height: 15),

                      // Prediction
                      _buildModelConfigCard(
                        title: "Yield Prediction Model",
                        type: "REGRESSION / PREDICTION",
                        color: Colors.purple,
                        path: _predictionPath,
                        onPathTap: () =>
                            _pickModelFile("Prediction", (path) async {
                          setState(() => _predictionPath = path);
                          await _saveSettings();
                        }),
                      ),

                      const SizedBox(height: 30),

                      _buildSectionHeader('Image Storage'),
                      _buildFolderConfigCard(
                        title: "Images Folder",
                        type: "FOLDER PATH",
                        color: Colors.indigo,
                        path: _imageFolderPath,
                        onPathTap: _pickImageFolder,
                      ),

                      const SizedBox(height: 50),

                      Center(
                        child: SizedBox(
                          width: 300,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.sidebarGradientStart,
                              foregroundColor: Colors.white,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () async {
                              final err = _validateEmails(_alertEmails);
                              if (err != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(err),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              try {
                                await _saveConfigToBackend();
                                await _saveSettings();

                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text("Settings Saved Successfully"),
                                  ),
                                );
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Failed to save: $e"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: Text(
                              "SAVE CHANGES",
                              style:
                                  TextStyles.sidebarMenuItemSelected.copyWith(
                                fontSize: 20,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 50),
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

  // =========================
  // UI HELPERS
  // =========================
  Widget _buildModelConfigCard({
    required String title,
    required String type,
    required Color color,
    required String path,
    int? confidencePct,
    Function(int)? onConfChanged,
    required VoidCallback onPathTap,
  }) {
    return _buildContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyles.elevatedCardTitle
                          .copyWith(color: Colors.black87, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: color.withOpacity(0.45)),
                      ),
                      child: Text(
                        type,
                        style: TextStyles.modern.copyWith(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Text(
            "Model File Path",
            style: TextStyles.elevatedCardDescription
                .copyWith(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: onPathTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.folder_open, color: Colors.black87),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      path,
                      style: TextStyles.modern.copyWith(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.black45),
                ],
              ),
            ),
          ),
          if (confidencePct != null && onConfChanged != null) ...[
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Confidence Threshold",
                  style: TextStyles.elevatedCardDescription
                      .copyWith(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  "$confidencePct%",
                  style: TextStyles.modern.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: color,
                inactiveTrackColor: color.withOpacity(0.2),
                thumbColor: color,
                overlayColor: color.withOpacity(0.1),
              ),
              child: Slider(
                value: confidencePct.toDouble(),
                min: 0,
                max: 100,
                divisions: 100,
                label: "$confidencePct%",
                onChanged: (v) => onConfChanged(v.round()),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFolderConfigCard({
    required String title,
    required String type,
    required Color color,
    required String path,
    required VoidCallback onPathTap,
  }) {
    return _buildContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.folder, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyles.elevatedCardTitle
                          .copyWith(color: Colors.black87, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: color.withOpacity(0.45)),
                      ),
                      child: Text(
                        type,
                        style: TextStyles.modern.copyWith(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Text(
            "Folder Path",
            style: TextStyles.elevatedCardDescription
                .copyWith(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: onPathTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.folder_open, color: Colors.black87),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      path,
                      style: TextStyles.modern.copyWith(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.black45),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertEmailsCardBetter() {
    final listErr = _validateEmails(_alertEmails);

    return _buildContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active, color: Colors.deepOrange),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Disease Alert Recipients",
                  style: TextStyles.elevatedCardTitle
                      .copyWith(color: Colors.black87, fontSize: 16),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(999),
                  border:
                      Border.all(color: Colors.deepOrange.withOpacity(0.35)),
                ),
                child: Text(
                  "${_alertEmails.length} recipients",
                  style: TextStyles.modern.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "When disease is detected, you will receive an email alert to these addresses.",
            style: TextStyles.elevatedCardDescription
                .copyWith(fontSize: 12, color: Colors.grey),
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _emailInputController,
                  decoration: InputDecoration(
                    labelText: "Add email",
                    hintText: "example@gmail.com",
                    errorText: _emailInputError,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.alternate_email),
                  ),
                  onChanged: (_) {
                    if (_emailInputError != null) {
                      setState(() => _emailInputError = null);
                    }
                  },
                  onSubmitted: (_) => _addEmailFromInput(),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sidebarGradientStart,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    _addEmailFromInput();
                    await _saveSettings();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Add"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton.icon(
                onPressed: _openBulkEmailDialog,
                icon: const Icon(Icons.playlist_add),
                label: const Text("Bulk add"),
              ),
              const Spacer(),
              if (_alertEmails.isNotEmpty)
                TextButton.icon(
                  onPressed: () async {
                    setState(() {
                      _alertEmails.clear();
                      _syncEmailCacheText();
                      _emailInputError = null;
                    });
                    await _saveSettings();
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text("Clear all"),
                ),
            ],
          ),
          if (listErr != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.07),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      listErr,
                      style: TextStyles.modern.copyWith(
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          if (_alertEmails.isEmpty)
            Text(
              "No recipients added yet.",
              style: TextStyles.modern.copyWith(color: Colors.black54),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _alertEmails.map((e) {
                return Chip(
                  label: Text(e),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () async {
                    _removeEmail(e);
                    await _saveSettings();
                  },
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ✅ NEW: Alert Times card
  Widget _buildAlertTimesCard() {
    return _buildContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, color: Colors.blueGrey),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Alert Times",
                  style: TextStyles.elevatedCardTitle
                      .copyWith(color: Colors.black87, fontSize: 16),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.blueGrey.withOpacity(0.35)),
                ),
                child: Text(
                  "${_alertTimes.length} times",
                  style: TextStyles.modern.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Disease alerts will be sent at the configured times each day.",
            style: TextStyles.elevatedCardDescription
                .copyWith(fontSize: 12, color: Colors.grey),
          ),
          const Divider(height: 24),
          Row(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sidebarGradientStart,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _addAlertTime,
                icon: const Icon(Icons.add_alarm),
                label: const Text("Add alert time"),
              ),
              const Spacer(),
              if (_alertTimes.isNotEmpty)
                TextButton.icon(
                  onPressed: () async {
                    setState(() {
                      _alertTimes.clear();
                    });
                    await _saveSettings();
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text("Clear all"),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_alertTimes.isEmpty)
            Text(
              "No alert times configured.",
              style: TextStyles.modern.copyWith(color: Colors.black54),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _alertTimes.map((t) {
                return Chip(
                  label: Text(t),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () async {
                    _removeAlertTime(t);
                    await _saveSettings();
                  },
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyles.graphSectionTitle.copyWith(
          fontSize: 18,
          color: AppColors.sidebarGradientStart,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
