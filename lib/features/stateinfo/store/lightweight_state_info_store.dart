import 'package:flutter/material.dart';
import '../models/state_info_models.dart';
import '../data/static_data.dart';

/// Enhanced State Info Store with proper navigation support
class LightweightStateInfoStore extends ChangeNotifier {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Navigation State - Simple enums only
  MainPath _mainPath = MainPath.selection;
  PowerFlowStep _powerFlowStep = PowerFlowStep.generator;
  StateFlowStep _stateFlowStep = StateFlowStep.states;

  // Selection State - Simple strings only
  String _selectedGenerator = '';
  String _selectedTransmission = '';
  String _selectedDistribution = '';
  String _selectedState = '';
  String _selectedMandal = '';

  LightweightStateInfoStore();

  // Getters for current state
  MainPath get mainPath => _mainPath;
  PowerFlowStep get powerFlowStep => _powerFlowStep;
  StateFlowStep get stateFlowStep => _stateFlowStep;

  String get selectedGenerator => _selectedGenerator;
  String get selectedTransmission => _selectedTransmission;
  String get selectedDistribution => _selectedDistribution;
  String get selectedState => _selectedState;
  String get selectedMandal => _selectedMandal;

  // Data Getters - Direct access, no complex lookups
  List<PowerGenerator> get powerGenerators =>
      StateInfoStaticData.powerGenerators;
  List<TransmissionLine> get transmissionLines =>
      StateInfoStaticData.transmissionLines;
  List<DistributionCompany> get distributionCompanies =>
      StateInfoStaticData.distributionCompanies;
  List<IndianState> get indianStates => StateInfoStaticData.indianStates;

  // Selected Data Getters - Simple lookup without try-catch
  PowerGenerator? get selectedGeneratorData {
    for (final generator in powerGenerators) {
      if (generator.id == _selectedGenerator) return generator;
    }
    return null;
  }

  TransmissionLine? get selectedTransmissionData {
    for (final transmission in transmissionLines) {
      if (transmission.id == _selectedTransmission) return transmission;
    }
    return null;
  }

  DistributionCompany? get selectedDistributionData {
    for (final distribution in distributionCompanies) {
      if (distribution.id == _selectedDistribution) return distribution;
    }
    return null;
  }

  IndianState? get selectedStateData {
    for (final state in indianStates) {
      if (state.id == _selectedState) return state;
    }
    return null;
  }

  Mandal? get selectedMandalData {
    final state = selectedStateData;
    if (state == null) return null;

    for (final mandal in state.mandals) {
      if (mandal.id == _selectedMandal) return mandal;
    }
    return null;
  }

  // Navigation Actions with proper routing
  void selectPath(MainPath path) {
    _mainPath = path;
    if (path == MainPath.powerFlow) {
      _powerFlowStep = PowerFlowStep.generator;
      navigatorKey.currentState?.pushNamed('/power-flow');
    } else if (path == MainPath.stateFlow) {
      _stateFlowStep = StateFlowStep.states;
      navigatorKey.currentState?.pushNamed('/state-flow');
    }
    notifyListeners();
  }

  void navigateToGeneratorProfile(String generatorId) {
    _selectedGenerator = generatorId;
    _powerFlowStep = PowerFlowStep.generatorProfile;
    navigatorKey.currentState?.pushNamed('/generator-profile');
    notifyListeners();
  }

  void navigateToStateProfile(String stateId) {
    _selectedState = stateId;
    _stateFlowStep = StateFlowStep.stateDetail;
    navigatorKey.currentState?.pushNamed('/state-profile');
    notifyListeners();
  }

  void navigateToMandalProfile(String mandalId) {
    _selectedMandal = mandalId;
    _stateFlowStep = StateFlowStep.mandalDetail;
    navigatorKey.currentState?.pushNamed('/mandal-profile');
    notifyListeners();
  }

  void goBack() {
    navigatorKey.currentState?.pop();
  }

  void goHome() {
    resetToSelection();
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
  }

  void setPowerFlowStep(PowerFlowStep step) {
    _powerFlowStep = step;
    notifyListeners();
  }

  void setStateFlowStep(StateFlowStep step) {
    _stateFlowStep = step;
    notifyListeners();
  }

  // Selection Actions - Use navigation methods
  void selectGenerator(String generatorId) {
    navigateToGeneratorProfile(generatorId);
  }

  void selectTransmission(String transmissionId) {
    _selectedTransmission = transmissionId;
    _powerFlowStep = PowerFlowStep.transmissionProfile;
    notifyListeners();
  }

  void selectDistribution(String distributionId) {
    _selectedDistribution = distributionId;
    _powerFlowStep = PowerFlowStep.profile;
    notifyListeners();
  }

  void selectState(String stateId) {
    navigateToStateProfile(stateId);
  }

  void selectMandal(String mandalId) {
    navigateToMandalProfile(mandalId);
  }

  // Navigation Flow Actions - Simple logic
  void nextToPowerFlow() {
    switch (_powerFlowStep) {
      case PowerFlowStep.generator:
      case PowerFlowStep.generatorProfile:
        _powerFlowStep = PowerFlowStep.transmission;
        break;
      case PowerFlowStep.transmission:
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

  // Reset Actions - Simple state clearing
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

  // Progress Calculation - Simple switch
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

  // Helper methods for UI - Simple boolean checks
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

  // Title generation - Simple switch
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
}
