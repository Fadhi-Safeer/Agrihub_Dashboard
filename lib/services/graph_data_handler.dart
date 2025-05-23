import 'api_service.dart';

class GraphDataHandler {
  final ApiService _apiService;

  GraphDataHandler(this._apiService);

  // Page 1: Growth Stage Visualizations
  Future<Map<String, dynamic>> fetchGrowthStageTimelineData() async {
    return await _apiService.fetchData('api/growth/timeline');
  }

  Future<Map<String, dynamic>> fetchGrowthEnvironmentalFactorsData() async {
    return await _apiService.fetchData('api/growth/environmental-factors');
  }

  Future<Map<String, dynamic>> fetchGrowthDistributionByCameraData() async {
    return await _apiService.fetchData('api/growth/distribution-by-location');
  }

  // Page 2: Disease Status Visualizations
  Future<Map<String, dynamic>> fetchDiseasePrevalenceData() async {
    return await _apiService.fetchData('api/disease/prevalence');
  }

  Future<Map<String, dynamic>> fetchDiseaseEnvironmentalTriggersData() async {
    return await _apiService.fetchData('api/disease/environmental-triggers');
  }

  Future<Map<String, dynamic>> fetchDiseaseHotspotData() async {
    return await _apiService.fetchData('api/disease/hotspots');
  }

  // Page 3: Plant Health Status Visualizations
  Future<Map<String, dynamic>> fetchNutrientDeficiencyTimelineData() async {
    return await _apiService.fetchData('api/health/deficiency-timeline');
  }

  Future<Map<String, dynamic>> fetchECpHNutrientCorrelationData() async {
    return await _apiService.fetchData('api/health/ec-ph-correlation');
  }

  Future<Map<String, dynamic>> fetchHealthStatusByGrowthStageData() async {
    return await _apiService.fetchData('api/health/status-by-growth');
  }
}
