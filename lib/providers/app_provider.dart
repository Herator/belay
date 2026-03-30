import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../models/generated_plan.dart';
import '../services/storage_service.dart';
import '../services/claude_service.dart';

enum AppState { loading, onboarding, generating, ready, error }

class AppProvider extends ChangeNotifier {
  final _storage = StorageService();
  final _claude = ClaudeService();

  AppState _state = AppState.loading;
  UserProfile? _profile;
  GeneratedPlan? _plan;
  String? _errorMessage;
  int _currentTab = 0;

  AppState get state => _state;
  UserProfile? get profile => _profile;
  GeneratedPlan? get plan => _plan;
  String? get errorMessage => _errorMessage;
  int get currentTab => _currentTab;

  Future<void> initialize() async {
    final complete = await _storage.isOnboardingComplete();
    if (!complete) {
      _state = AppState.onboarding;
      notifyListeners();
      return;
    }
    _profile = await _storage.loadProfile();
    _plan = await _storage.loadPlan();
    _state = (_profile != null && _plan != null) ? AppState.ready : AppState.onboarding;
    notifyListeners();
  }

  Future<void> generatePlan(UserProfile profile) async {
    _state = AppState.generating;
    _errorMessage = null;
    _profile = profile;
    notifyListeners();

    try {
      await _storage.saveProfile(profile);
      final plan = await _claude.generatePlan(profile);
      await _storage.savePlan(plan);
      await _storage.setOnboardingComplete();
      _plan = plan;
      _state = AppState.ready;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _state = AppState.error;
    }
    notifyListeners();
  }

  Future<void> regeneratePlan() async {
    if (_profile == null) return;
    await generatePlan(_profile!);
  }

  void setTab(int tab) {
    _currentTab = tab;
    notifyListeners();
  }

  Future<void> resetApp() async {
    await _storage.clearAll();
    _profile = null;
    _plan = null;
    _state = AppState.onboarding;
    _currentTab = 0;
    notifyListeners();
  }
}
