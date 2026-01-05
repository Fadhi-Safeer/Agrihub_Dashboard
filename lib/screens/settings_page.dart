import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/model_config_service.dart';
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

  String _detectionPath = r"backend\Models\LETTUCE_DETECTION_MODEL.pt";
  int _detectionConfPct = 65;

  String _growthPath = r"backend\Models\GROWTH_CLASSIFICATION_MODEL.pt";
  int _growthConfPct = 80;

  String _healthPath = r"backend\Models\HEALTH_CLASSIFICATION_MODEL.pt";
  int _healthConfPct = 85;

  String _diseasePath = r"backend\Models\DISEASE_CLASSIFICATION_MODEL.pt";
  int _diseaseConfPct = 85;

  String _predictionPath = r"backend\Models\lettuce_model.joblib";
  int _predictionConfPct = 75;

  String _imageFolderPath = r"backend\Images\";

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  Future<void> _initLoad() async {
    await _loadSettings();
    await _fetchConfigFromBackend();
    await _fetchImageFolderFromBackend();
  }

  double _pctToDouble01(int pct) => pct.clamp(0, 100) / 100.0;
  int _double01ToPct(num v) => (v.toDouble() * 100).round().clamp(0, 100);

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
  }

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
  }

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
                      const SizedBox(height: 15),
                      _buildModelConfigCard(
                        title: "Yield Prediction Model",
                        type: "REGRESSION / PREDICTION",
                        color: Colors.purple,
                        path: _predictionPath,
                        confidencePct: _predictionConfPct,
                        onConfChanged: (v) async {
                          setState(() => _predictionConfPct = v);
                          await _saveSettings();
                        },
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

  Widget _buildModelConfigCard({
    required String title,
    required String type,
    required Color color,
    required String path,
    required int confidencePct,
    required Function(int) onConfChanged,
    required VoidCallback onPathTap,
  }) {
    return _buildContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyles.elevatedCardTitle
                        .copyWith(color: Colors.black87, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: color.withOpacity(0.5)),
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
                borderRadius: BorderRadius.circular(8),
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
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
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
                style: TextStyles.modern
                    .copyWith(fontWeight: FontWeight.bold, color: color),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyles.elevatedCardTitle
                        .copyWith(color: Colors.black87, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: color.withOpacity(0.5)),
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
                borderRadius: BorderRadius.circular(8),
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
                ],
              ),
            ),
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
