import 'package:flutter/material.dart';

import '../services/prediction_service.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';
import '../widgets/navigation_sidebar.dart';
import '../widgets/monitoring_pages/top_bard.dart';

class PredictionPage extends StatefulWidget {
  const PredictionPage({super.key});

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  static const String _backendBaseUrl = "http://localhost:8001";
  late final PredictionService _service =
      const PredictionService(baseUrl: _backendBaseUrl);

  // Growth day
  int _growthDay = 0;
  final TextEditingController _growthDayCtrl = TextEditingController();

  // NPK
  int _n = 140;
  int _p = 50;
  int _k = 250;

  final TextEditingController _nCtrl = TextEditingController();
  final TextEditingController _pCtrl = TextEditingController();
  final TextEditingController _kCtrl = TextEditingController();

  bool _loading = false;
  double? _predictedG;

  @override
  void initState() {
    super.initState();
    _loadDefaults();
  }

  @override
  void dispose() {
    _growthDayCtrl.dispose();
    _nCtrl.dispose();
    _pCtrl.dispose();
    _kCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDefaults() async {
    setState(() => _loading = true);
    try {
      final data = await _service.fetchDefaults();

      final gd =
          (data["growth_day"] is num) ? (data["growth_day"] as num).toInt() : 0;
      final npk = (data["npk"] is Map) ? data["npk"] as Map : {};

      final nVal =
          (npk["Nitrogen"] is num) ? (npk["Nitrogen"] as num).toInt() : _n;
      final pVal =
          (npk["Phosphorus"] is num) ? (npk["Phosphorus"] as num).toInt() : _p;
      final kVal =
          (npk["Potassium"] is num) ? (npk["Potassium"] as num).toInt() : _k;

      if (!mounted) return;
      setState(() {
        _growthDay = gd.clamp(0, 9999);
        _n = nVal;
        _p = pVal;
        _k = kVal;

        _growthDayCtrl.text = _growthDay.toString();
        _nCtrl.text = _n.toString();
        _pCtrl.text = _p.toString();
        _kCtrl.text = _k.toString();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Failed to load defaults: $e"),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int? _parseInt(String s) {
    final v = int.tryParse(s.trim());
    return v;
  }

  void _syncGrowthDayFromText() {
    final v = _parseInt(_growthDayCtrl.text);
    if (v == null) return;
    setState(() => _growthDay = v.clamp(0, 9999));
  }

  void _syncGrowthDayFromSlider(int v) {
    setState(() {
      _growthDay = v;
      _growthDayCtrl.text = _growthDay.toString();
    });
  }

  bool _validateInputs({bool showSnack = true}) {
    final gd = _parseInt(_growthDayCtrl.text);
    final n = _parseInt(_nCtrl.text);
    final p = _parseInt(_pCtrl.text);
    final k = _parseInt(_kCtrl.text);

    String? err;
    if (gd == null || gd < 0)
      err = "Growth Day must be a valid non-negative integer.";
    else if (n == null || n < 0)
      err = "Nitrogen must be a valid non-negative integer.";
    else if (p == null || p < 0)
      err = "Phosphorus must be a valid non-negative integer.";
    else if (k == null || k < 0)
      err = "Potassium must be a valid non-negative integer.";

    if (err != null) {
      if (showSnack && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err), backgroundColor: Colors.red),
        );
      }
      return false;
    }

    setState(() {
      _growthDay = gd!;
      _n = n!;
      _p = p!;
      _k = k!;
    });
    return true;
  }

  Future<void> _predict() async {
    if (!_validateInputs()) return;

    setState(() {
      _loading = true;
      _predictedG = null;
    });

    try {
      final y = await _service.predictYield(
        growthDay: _growthDay,
        n: _n,
        p: _p,
        k: _k,
      );

      if (!mounted) return;
      setState(() => _predictedG = y);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Prediction failed: $e"),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveAsDefaults() async {
    if (!_validateInputs()) return;

    setState(() => _loading = true);
    try {
      await _service.updateDefaults(
        growthDay: _growthDay,
        n: _n,
        p: _p,
        k: _k,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saved defaults to Data.json")),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Save defaults failed: $e"),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
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
                  title: 'Yield Prediction',
                  textStyle: TextStyles.mainHeading.copyWith(
                    color: AppColors.sidebarGradientStart,
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(32.0),
                    children: [
                      _buildSectionHeader('Inputs'),
                      _buildContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Growth Day",
                              style: TextStyles.elevatedCardTitle.copyWith(
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // TextField for exact value
                            TextField(
                              controller: _growthDayCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: "Enter Growth Day (integer)",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onChanged: (_) => _syncGrowthDayFromText(),
                            ),

                            const SizedBox(height: 14),

                            // Slider for quick (0–60)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Quick Slider (0–60)",
                                    style: TextStyles.elevatedCardDescription
                                        .copyWith(
                                            fontSize: 12, color: Colors.grey)),
                                Text("${_growthDay.clamp(0, 60)}",
                                    style: TextStyles.modern.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.sidebarGradientStart,
                                    )),
                              ],
                            ),
                            Slider(
                              value: (_growthDay.clamp(0, 60)).toDouble(),
                              min: 0,
                              max: 60,
                              divisions: 60,
                              onChanged: _loading
                                  ? null
                                  : (v) => _syncGrowthDayFromSlider(v.round()),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "NPK Values",
                              style: TextStyles.elevatedCardTitle.copyWith(
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                    child: _npkField("Nitrogen (N)", _nCtrl)),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: _npkField("Phosphorus (P)", _pCtrl)),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: _npkField("Potassium (K)", _kCtrl)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeader('Output'),
                      _buildContainer(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Predicted Yield",
                              style: TextStyles.elevatedCardTitle.copyWith(
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _predictedG == null
                                  ? "-"
                                  : "${_predictedG!.toStringAsFixed(2)} g",
                              style: TextStyles.modern.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppColors.sidebarGradientStart,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 240,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.sidebarGradientStart,
                                foregroundColor: Colors.white,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: _loading ? null : _predict,
                              child: Text(
                                _loading ? "WORKING..." : "PREDICT",
                                style:
                                    TextStyles.sidebarMenuItemSelected.copyWith(
                                  fontSize: 18,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          SizedBox(
                            width: 240,
                            height: 52,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.sidebarGradientStart,
                                side: BorderSide(
                                    color: AppColors.sidebarGradientStart,
                                    width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: _loading ? null : _saveAsDefaults,
                              child: Text(
                                "SAVE AS DEFAULT",
                                style:
                                    TextStyles.sidebarMenuItemSelected.copyWith(
                                  fontSize: 16,
                                  color: AppColors.sidebarGradientStart,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
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

  Widget _npkField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyles.elevatedCardDescription
                .copyWith(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "0",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
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
