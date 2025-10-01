/// Firebase-backed state info providers for Indian electrical standards
/// Provides state-specific data, electricity boards, and wiring regulations
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/firebase_providers.dart';

part 'firebase_state_info_providers.g.dart';

/// Model for Indian state information
class StateInfo {
  final String id;
  final String stateName;
  final String stateCode; // MH, DL, KA, etc.
  final List<ElectricityBoard> electricityBoards;
  final WiringStandards wiringStandards;
  final Map<String, dynamic> regulations;
  final DateTime updatedAt;

  StateInfo({
    required this.id,
    required this.stateName,
    required this.stateCode,
    required this.electricityBoards,
    required this.wiringStandards,
    required this.regulations,
    required this.updatedAt,
  });

  factory StateInfo.fromJson(Map<String, dynamic> json) {
    return StateInfo(
      id: json['id'] as String,
      stateName: json['state_name'] as String,
      stateCode: json['state_code'] as String,
      electricityBoards: (json['electricity_boards'] as List?)
          ?.map((e) => ElectricityBoard.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      wiringStandards: WiringStandards.fromJson(
        json['wiring_standards'] as Map<String, dynamic>? ?? {},
      ),
      regulations: Map<String, dynamic>.from(json['regulations'] ?? {}),
      updatedAt: (json['updated_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'state_name': stateName,
    'state_code': stateCode,
    'electricity_boards': electricityBoards.map((e) => e.toJson()).toList(),
    'wiring_standards': wiringStandards.toJson(),
    'regulations': regulations,
    'updated_at': Timestamp.fromDate(updatedAt),
  };
}

/// Model for electricity board
class ElectricityBoard {
  final String name;
  final String shortName;
  final String website;
  final String contactNumber;
  final List<String> coverageAreas;

  ElectricityBoard({
    required this.name,
    required this.shortName,
    required this.website,
    required this.contactNumber,
    required this.coverageAreas,
  });

  factory ElectricityBoard.fromJson(Map<String, dynamic> json) {
    return ElectricityBoard(
      name: json['name'] as String,
      shortName: json['short_name'] as String,
      website: json['website'] as String? ?? '',
      contactNumber: json['contact_number'] as String? ?? '',
      coverageAreas: List<String>.from(json['coverage_areas'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'short_name': shortName,
    'website': website,
    'contact_number': contactNumber,
    'coverage_areas': coverageAreas,
  };
}

/// Model for wiring standards
class WiringStandards {
  final String voltageStandard; // 230V/400V
  final String frequency; // 50Hz
  final String plugType; // Type D/Type M
  final Map<String, String> cableColors; // Live, Neutral, Earth
  final List<String> requiredCertifications; // BIS, ISI, etc.

  WiringStandards({
    required this.voltageStandard,
    required this.frequency,
    required this.plugType,
    required this.cableColors,
    required this.requiredCertifications,
  });

  factory WiringStandards.fromJson(Map<String, dynamic> json) {
    return WiringStandards(
      voltageStandard: json['voltage_standard'] as String? ?? '230V/400V',
      frequency: json['frequency'] as String? ?? '50Hz',
      plugType: json['plug_type'] as String? ?? 'Type D',
      cableColors: Map<String, String>.from(json['cable_colors'] ?? {
        'live': 'Red/Brown',
        'neutral': 'Black/Blue',
        'earth': 'Green/Yellow',
      }),
      requiredCertifications: List<String>.from(
        json['required_certifications'] ?? ['BIS', 'ISI'],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'voltage_standard': voltageStandard,
    'frequency': frequency,
    'plug_type': plugType,
    'cable_colors': cableColors,
    'required_certifications': requiredCertifications,
  };
}

/// Stream all Indian states with electrical info
@riverpod
Stream<List<StateInfo>> firebaseAllStates(FirebaseAllStatesRef ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  return firestore
      .collection('state_info')
      .orderBy('state_name')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return StateInfo.fromJson({...data, 'id': doc.id});
    }).toList();
  });
}

/// Get a single state by ID
@riverpod
Stream<StateInfo?> firebaseStateInfo(
  FirebaseStateInfoRef ref,
  String stateId,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  return firestore
      .collection('state_info')
      .doc(stateId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    final data = doc.data()!;
    return StateInfo.fromJson({...data, 'id': doc.id});
  });
}

/// Get state by state code (e.g., "MH" for Maharashtra)
@riverpod
Stream<StateInfo?> firebaseStateByCode(
  FirebaseStateByCodeRef ref,
  String stateCode,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  return firestore
      .collection('state_info')
      .where('state_code', isEqualTo: stateCode.toUpperCase())
      .limit(1)
      .snapshots()
      .map((snapshot) {
    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    final data = doc.data();
    return StateInfo.fromJson({...data, 'id': doc.id});
  });
}

/// Search states by name
@riverpod
Stream<List<StateInfo>> firebaseSearchStates(
  FirebaseSearchStatesRef ref,
  String searchQuery,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);

  // Firestore doesn't support case-insensitive search directly
  // For production, use Algolia or Elasticsearch
  // For now, we'll get all and filter client-side
  return firestore
      .collection('state_info')
      .orderBy('state_name')
      .snapshots()
      .map((snapshot) {
    final allStates = snapshot.docs.map((doc) {
      final data = doc.data();
      return StateInfo.fromJson({...data, 'id': doc.id});
    }).toList();

    if (searchQuery.isEmpty) return allStates;

    final query = searchQuery.toLowerCase();
    return allStates.where((state) {
      return state.stateName.toLowerCase().contains(query) ||
             state.stateCode.toLowerCase().contains(query);
    }).toList();
  });
}

/// Service for state info operations
@riverpod
StateInfoService stateInfoService(StateInfoServiceRef ref) {
  return StateInfoService(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
}

/// State info service class (admin operations)
class StateInfoService {
  final FirebaseFirestore firestore;

  StateInfoService({required this.firestore});

  /// Create or update state info (admin only)
  Future<void> setStateInfo({
    required String stateId,
    required String stateName,
    required String stateCode,
    required List<ElectricityBoard> electricityBoards,
    required WiringStandards wiringStandards,
    Map<String, dynamic>? regulations,
  }) async {
    final stateData = {
      'state_name': stateName,
      'state_code': stateCode.toUpperCase(),
      'electricity_boards': electricityBoards.map((e) => e.toJson()).toList(),
      'wiring_standards': wiringStandards.toJson(),
      'regulations': regulations ?? {},
      'updated_at': FieldValue.serverTimestamp(),
    };

    await firestore
        .collection('state_info')
        .doc(stateId)
        .set(stateData, SetOptions(merge: true));
  }

  /// Delete state info (admin only)
  Future<void> deleteStateInfo(String stateId) async {
    await firestore.collection('state_info').doc(stateId).delete();
  }

  /// Get electricity boards for a state
  Future<List<ElectricityBoard>> getElectricityBoards(String stateId) async {
    final doc = await firestore.collection('state_info').doc(stateId).get();
    if (!doc.exists) return [];

    final data = doc.data()!;
    final boards = data['electricity_boards'] as List?;
    if (boards == null) return [];

    return boards
        .map((e) => ElectricityBoard.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get wiring standards for a state
  Future<WiringStandards?> getWiringStandards(String stateId) async {
    final doc = await firestore.collection('state_info').doc(stateId).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    final standards = data['wiring_standards'] as Map<String, dynamic>?;
    if (standards == null) return null;

    return WiringStandards.fromJson(standards);
  }

  /// Initialize default Indian states (one-time setup)
  Future<void> initializeDefaultStates() async {
    final defaultStates = [
      {
        'id': 'maharashtra',
        'state_name': 'Maharashtra',
        'state_code': 'MH',
        'electricity_boards': [
          {
            'name': 'Maharashtra State Electricity Distribution Co. Ltd.',
            'short_name': 'MSEDCL',
            'website': 'https://www.mahadiscom.in',
            'contact_number': '1912',
            'coverage_areas': ['Mumbai', 'Pune', 'Nagpur', 'Nashik'],
          },
        ],
        'wiring_standards': {
          'voltage_standard': '230V/400V',
          'frequency': '50Hz',
          'plug_type': 'Type D',
          'cable_colors': {
            'live': 'Red/Brown',
            'neutral': 'Black/Blue',
            'earth': 'Green/Yellow',
          },
          'required_certifications': ['BIS', 'ISI'],
        },
        'regulations': {
          'requires_permit': true,
          'inspection_mandatory': true,
          'max_load_residential': '10kW',
        },
      },
      {
        'id': 'delhi',
        'state_name': 'Delhi',
        'state_code': 'DL',
        'electricity_boards': [
          {
            'name': 'BSES Rajdhani Power Limited',
            'short_name': 'BRPL',
            'website': 'https://www.bsesdelhi.com',
            'contact_number': '19123',
            'coverage_areas': ['South Delhi', 'West Delhi'],
          },
          {
            'name': 'BSES Yamuna Power Limited',
            'short_name': 'BYPL',
            'website': 'https://www.bsesdelhi.com',
            'contact_number': '19122',
            'coverage_areas': ['East Delhi', 'Central Delhi'],
          },
        ],
        'wiring_standards': {
          'voltage_standard': '230V/400V',
          'frequency': '50Hz',
          'plug_type': 'Type D',
          'cable_colors': {
            'live': 'Red',
            'neutral': 'Black',
            'earth': 'Green',
          },
          'required_certifications': ['BIS', 'ISI'],
        },
        'regulations': {
          'requires_permit': true,
          'inspection_mandatory': true,
          'max_load_residential': '12kW',
        },
      },
      {
        'id': 'karnataka',
        'state_name': 'Karnataka',
        'state_code': 'KA',
        'electricity_boards': [
          {
            'name': 'Bangalore Electricity Supply Company',
            'short_name': 'BESCOM',
            'website': 'https://bescom.org',
            'contact_number': '1912',
            'coverage_areas': ['Bangalore', 'Bangalore Rural'],
          },
        ],
        'wiring_standards': {
          'voltage_standard': '230V/400V',
          'frequency': '50Hz',
          'plug_type': 'Type D',
          'cable_colors': {
            'live': 'Red',
            'neutral': 'Black',
            'earth': 'Green/Yellow',
          },
          'required_certifications': ['BIS', 'ISI'],
        },
        'regulations': {
          'requires_permit': true,
          'inspection_mandatory': true,
          'max_load_residential': '10kW',
        },
      },
    ];

    final batch = firestore.batch();
    for (final stateData in defaultStates) {
      final docRef = firestore.collection('state_info').doc(stateData['id'] as String);
      batch.set(docRef, {
        ...stateData,
        'updated_at': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  /// Get all state codes and names (for dropdowns)
  Future<Map<String, String>> getStateCodeMap() async {
    final snapshot = await firestore
        .collection('state_info')
        .orderBy('state_name')
        .get();

    final stateMap = <String, String>{};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      stateMap[data['state_code'] as String] = data['state_name'] as String;
    }

    return stateMap;
  }
}




