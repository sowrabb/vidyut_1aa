import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/state_info_models.dart';
import '../data/static_data.dart';

class StateInfoStore extends ChangeNotifier {
  // Navigation State
  MainPath _mainPath = MainPath.selection;
  PowerFlowStep _powerFlowStep = PowerFlowStep.generator;
  StateFlowStep _stateFlowStep = StateFlowStep.states;

  // Selection State
  String _selectedGenerator = '';
  String _selectedTransmission = '';
  String _selectedDistribution = '';
  String _selectedState = '';
  String _selectedMandal = '';

  // Persistence keys
  static const String _keySelectedGenerator = 'state_info_selected_generator';
  static const String _keySelectedTransmission =
      'state_info_selected_transmission';
  static const String _keySelectedDistribution =
      'state_info_selected_distribution';
  static const String _keySelectedState = 'state_info_selected_state';
  static const String _keySelectedMandal = 'state_info_selected_mandal';
  static const String _keyMainPath = 'state_info_main_path';
  static const String _keyPowerFlowStep = 'state_info_power_flow_step';
  static const String _keyStateFlowStep = 'state_info_state_flow_step';

  StateInfoStore() {
    _loadPersistedState();
  }

  // Getters for current state
  MainPath get mainPath => _mainPath;
  PowerFlowStep get powerFlowStep => _powerFlowStep;
  StateFlowStep get stateFlowStep => _stateFlowStep;

  String get selectedGenerator => _selectedGenerator;
  String get selectedTransmission => _selectedTransmission;
  String get selectedDistribution => _selectedDistribution;
  String get selectedState => _selectedState;
  String get selectedMandal => _selectedMandal;

  // Derived State Getters
  PowerGenerator? get selectedGeneratorData {
    try {
      return StateInfoStaticData.powerGenerators.firstWhere(
        (g) => g.id == _selectedGenerator,
      );
    } catch (e) {
      return null;
    }
  }

  TransmissionLine? get selectedTransmissionData {
    try {
      return StateInfoStaticData.transmissionLines.firstWhere(
        (t) => t.id == _selectedTransmission,
      );
    } catch (e) {
      return null;
    }
  }

  DistributionCompany? get selectedDistributionData {
    try {
      return StateInfoStaticData.distributionCompanies.firstWhere(
        (d) => d.id == _selectedDistribution,
      );
    } catch (e) {
      return null;
    }
  }

  IndianState? get selectedStateData {
    try {
      return StateInfoStaticData.indianStates.firstWhere(
        (s) => s.id == _selectedState,
      );
    } catch (e) {
      return null;
    }
  }

  Mandal? get selectedMandalData {
    try {
      return selectedStateData?.mandals.firstWhere(
        (m) => m.id == _selectedMandal,
      );
    } catch (e) {
      return null;
    }
  }

  // Data Getters
  List<PowerGenerator> get powerGenerators =>
      StateInfoStaticData.powerGenerators;
  List<TransmissionLine> get transmissionLines =>
      StateInfoStaticData.transmissionLines;
  List<DistributionCompany> get distributionCompanies =>
      StateInfoStaticData.distributionCompanies;
  List<IndianState> get indianStates => StateInfoStaticData.indianStates;

  // Navigation Actions
  void selectPath(MainPath path) {
    _mainPath = path;
    if (path == MainPath.powerFlow) {
      _powerFlowStep = PowerFlowStep.generator;
    } else if (path == MainPath.stateFlow) {
      _stateFlowStep = StateFlowStep.states;
    }
    notifyListeners();
    _persistState().catchError((e) {
      // Log persistence errors but don't crash the app
      debugPrint('Failed to persist state: $e');
    });
  }

  void setPowerFlowStep(PowerFlowStep step) {
    _powerFlowStep = step;
    notifyListeners();
  }

  void setStateFlowStep(StateFlowStep step) {
    _stateFlowStep = step;
    notifyListeners();
  }

  // Selection Actions
  void selectGenerator(String generatorId) {
    _selectedGenerator = generatorId;
    _powerFlowStep = PowerFlowStep.generatorProfile;
    notifyListeners();
    _persistState().catchError((e) {
      // Log persistence errors but don't crash the app
      debugPrint('Failed to persist state: $e');
    });
  }

  void selectTransmission(String transmissionId) {
    _selectedTransmission = transmissionId;
    _powerFlowStep = PowerFlowStep.transmissionProfile;
    notifyListeners();
    _persistState().catchError((e) {
      // Log persistence errors but don't crash the app
      debugPrint('Failed to persist state: $e');
    });
  }

  void selectDistribution(String distributionId) {
    _selectedDistribution = distributionId;
    _powerFlowStep = PowerFlowStep.profile;
    notifyListeners();
    _persistState().catchError((e) {
      // Log persistence errors but don't crash the app
      debugPrint('Failed to persist state: $e');
    });
  }

  void selectState(String stateId) {
    _selectedState = stateId;
    _stateFlowStep = StateFlowStep.stateDetail;
    notifyListeners();
    _persistState().catchError((e) {
      // Log persistence errors but don't crash the app
      debugPrint('Failed to persist state: $e');
    });
  }

  void selectMandal(String mandalId) {
    _selectedMandal = mandalId;
    _stateFlowStep = StateFlowStep.mandalDetail;
    notifyListeners();
    _persistState().catchError((e) {
      // Log persistence errors but don't crash the app
      debugPrint('Failed to persist state: $e');
    });
  }

  // Navigation Flow Actions
  void nextToPowerFlow() {
    switch (_powerFlowStep) {
      case PowerFlowStep.generator:
        _powerFlowStep = PowerFlowStep.transmission;
        break;
      case PowerFlowStep.generatorProfile:
        _powerFlowStep = PowerFlowStep.transmission;
        break;
      case PowerFlowStep.transmission:
        _powerFlowStep = PowerFlowStep.distribution;
        break;
      case PowerFlowStep.transmissionProfile:
        _powerFlowStep = PowerFlowStep.distribution;
        break;
      case PowerFlowStep.distribution:
      case PowerFlowStep.profile:
        // Already at the end
        break;
    }
    notifyListeners();
  }

  void backToPowerFlow() {
    switch (_powerFlowStep) {
      case PowerFlowStep.generator:
        _mainPath = MainPath.selection;
        break;
      case PowerFlowStep.generatorProfile:
        _powerFlowStep = PowerFlowStep.generator;
        break;
      case PowerFlowStep.transmission:
        if (_selectedGenerator.isNotEmpty) {
          _powerFlowStep = PowerFlowStep.generatorProfile;
        } else {
          _powerFlowStep = PowerFlowStep.generator;
        }
        break;
      case PowerFlowStep.transmissionProfile:
        _powerFlowStep = PowerFlowStep.transmission;
        break;
      case PowerFlowStep.distribution:
        if (_selectedTransmission.isNotEmpty) {
          _powerFlowStep = PowerFlowStep.transmissionProfile;
        } else {
          _powerFlowStep = PowerFlowStep.transmission;
        }
        break;
      case PowerFlowStep.profile:
        _powerFlowStep = PowerFlowStep.distribution;
        break;
    }
    notifyListeners();
  }

  void backToStateFlow() {
    switch (_stateFlowStep) {
      case StateFlowStep.states:
        _mainPath = MainPath.selection;
        break;
      case StateFlowStep.stateDetail:
        _stateFlowStep = StateFlowStep.states;
        break;
      case StateFlowStep.mandalDetail:
        _stateFlowStep = StateFlowStep.stateDetail;
        break;
    }
    notifyListeners();
  }

  // Reset Actions
  void resetToSelection() {
    _mainPath = MainPath.selection;
    _powerFlowStep = PowerFlowStep.generator;
    _stateFlowStep = StateFlowStep.states;
    _selectedGenerator = '';
    _selectedTransmission = '';
    _selectedDistribution = '';
    _selectedState = '';
    _selectedMandal = '';
    notifyListeners();
    _persistState().catchError((e) {
      // Log persistence errors but don't crash the app
      debugPrint('Failed to persist state: $e');
    });
  }

  void resetPowerFlow() {
    _powerFlowStep = PowerFlowStep.generator;
    _selectedGenerator = '';
    _selectedTransmission = '';
    _selectedDistribution = '';
    notifyListeners();
  }

  void resetStateFlow() {
    _stateFlowStep = StateFlowStep.states;
    _selectedState = '';
    _selectedMandal = '';
    notifyListeners();
  }

  // Progress Calculation
  int get powerFlowProgress {
    switch (_powerFlowStep) {
      case PowerFlowStep.generator:
      case PowerFlowStep.generatorProfile:
        return 1;
      case PowerFlowStep.transmission:
      case PowerFlowStep.transmissionProfile:
        return 2;
      case PowerFlowStep.distribution:
      case PowerFlowStep.profile:
        return 3;
    }
  }

  int get stateFlowProgress {
    switch (_stateFlowStep) {
      case StateFlowStep.states:
        return 1;
      case StateFlowStep.stateDetail:
        return 2;
      case StateFlowStep.mandalDetail:
        return 3;
    }
  }

  // Helper methods for UI
  bool get canGoNext {
    if (_mainPath == MainPath.powerFlow) {
      return _powerFlowStep != PowerFlowStep.profile;
    } else if (_mainPath == MainPath.stateFlow) {
      return _stateFlowStep != StateFlowStep.mandalDetail;
    }
    return false;
  }

  bool get canGoBack {
    return _mainPath != MainPath.selection;
  }

  String get currentTitle {
    if (_mainPath == MainPath.selection) {
      return 'State Electricity Board Info';
    } else if (_mainPath == MainPath.powerFlow) {
      switch (_powerFlowStep) {
        case PowerFlowStep.generator:
          return 'Power Generators';
        case PowerFlowStep.generatorProfile:
          return selectedGeneratorData?.name ?? 'Generator Profile';
        case PowerFlowStep.transmission:
          return 'Transmission Lines';
        case PowerFlowStep.transmissionProfile:
          return selectedTransmissionData?.name ?? 'Transmission Profile';
        case PowerFlowStep.distribution:
          return 'Distribution Companies';
        case PowerFlowStep.profile:
          return selectedDistributionData?.name ?? 'Distribution Profile';
      }
    } else if (_mainPath == MainPath.stateFlow) {
      switch (_stateFlowStep) {
        case StateFlowStep.states:
          return 'Indian States';
        case StateFlowStep.stateDetail:
          return selectedStateData?.name ?? 'State Details';
        case StateFlowStep.mandalDetail:
          return selectedMandalData?.name ?? 'Mandal Details';
      }
    }
    return 'State Info';
  }

  // Persistence Methods
  Future<void> _loadPersistedState() async {
    try {
      // Check if we're in a test environment or web
      if (_isTestEnvironment() || _isWebEnvironment()) {
        return;
      }

      final prefs = await SharedPreferences.getInstance();

      _selectedGenerator = prefs.getString(_keySelectedGenerator) ?? '';
      _selectedTransmission = prefs.getString(_keySelectedTransmission) ?? '';
      _selectedDistribution = prefs.getString(_keySelectedDistribution) ?? '';
      _selectedState = prefs.getString(_keySelectedState) ?? '';
      _selectedMandal = prefs.getString(_keySelectedMandal) ?? '';

      final mainPathIndex = prefs.getInt(_keyMainPath);
      if (mainPathIndex != null) {
        _mainPath = MainPath.values[mainPathIndex];
      }

      final powerFlowStepIndex = prefs.getInt(_keyPowerFlowStep);
      if (powerFlowStepIndex != null) {
        _powerFlowStep = PowerFlowStep.values[powerFlowStepIndex];
      }

      final stateFlowStepIndex = prefs.getInt(_keyStateFlowStep);
      if (stateFlowStepIndex != null) {
        _stateFlowStep = StateFlowStep.values[stateFlowStepIndex];
      }

      notifyListeners();
    } catch (e) {
      // Ignore persistence errors, use defaults
    }
  }

  bool _isTestEnvironment() {
    // Check if we're running in a test environment
    try {
      // This will throw in test environment
      SharedPreferences.getInstance();
      return false;
    } catch (e) {
      return true;
    }
  }

  bool _isWebEnvironment() {
    // Use kIsWeb for proper web detection
    return kIsWeb;
  }

  Future<void> _persistState() async {
    try {
      // Check if we're in a test environment or web
      if (_isTestEnvironment() || _isWebEnvironment()) {
        return;
      }

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(_keySelectedGenerator, _selectedGenerator);
      await prefs.setString(_keySelectedTransmission, _selectedTransmission);
      await prefs.setString(_keySelectedDistribution, _selectedDistribution);
      await prefs.setString(_keySelectedState, _selectedState);
      await prefs.setString(_keySelectedMandal, _selectedMandal);

      await prefs.setInt(_keyMainPath, _mainPath.index);
      await prefs.setInt(_keyPowerFlowStep, _powerFlowStep.index);
      await prefs.setInt(_keyStateFlowStep, _stateFlowStep.index);
    } catch (e) {
      // Ignore persistence errors
    }
  }

  // Clear persisted state
  Future<void> clearPersistedState() async {
    try {
      // Check if we're in a test environment or web
      if (_isTestEnvironment() || _isWebEnvironment()) {
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keySelectedGenerator);
      await prefs.remove(_keySelectedTransmission);
      await prefs.remove(_keySelectedDistribution);
      await prefs.remove(_keySelectedState);
      await prefs.remove(_keySelectedMandal);
      await prefs.remove(_keyMainPath);
      await prefs.remove(_keyPowerFlowStep);
      await prefs.remove(_keyStateFlowStep);
    } catch (e) {
      // Ignore persistence errors
    }
  }
}
