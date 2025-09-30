import 'package:flutter/foundation.dart';
import '../models/state_info_models.dart';
import '../data/static_data.dart';
import '../data/profile_posts_data.dart';

/// Store for managing StateInfo data with CRUD operations
class StateInfoEditStore extends ChangeNotifier {
  // Current data - initialized with static data
  List<IndianState> _indianStates = StateInfoStaticData.indianStates;
  List<PowerGenerator> _powerGenerators = StateInfoStaticData.powerGenerators;
  List<TransmissionLine> _transmissionLines =
      StateInfoStaticData.transmissionLines;
  List<DistributionCompany> _distributionCompanies =
      StateInfoStaticData.distributionCompanies;

  // Custom fields per-entity persistence
  final Map<String, List<CustomFieldData>> _entityCustomFields = {};

  // Getters
  List<IndianState> get indianStates => _indianStates;
  List<PowerGenerator> get powerGenerators => _powerGenerators;
  List<TransmissionLine> get transmissionLines => _transmissionLines;
  List<DistributionCompany> get distributionCompanies => _distributionCompanies;

  // Custom fields API
  List<CustomFieldData> getCustomFieldsForEntity(String entityId) {
    return List<CustomFieldData>.from(
        _entityCustomFields[entityId] ?? const <CustomFieldData>[]);
  }

  void setCustomFieldsForEntity(String entityId, List<CustomFieldData> fields) {
    _entityCustomFields[entityId] = List<CustomFieldData>.from(fields);
    notifyListeners();
  }

  // Power Generator CRUD Operations
  void addPowerGenerator(PowerGenerator generator) {
    _powerGenerators.add(generator);
    notifyListeners();
  }

  void updatePowerGenerator(PowerGenerator updatedGenerator) {
    final index =
        _powerGenerators.indexWhere((g) => g.id == updatedGenerator.id);
    if (index != -1) {
      _powerGenerators[index] = updatedGenerator;
      notifyListeners();
    }
  }

  void deletePowerGenerator(String generatorId) {
    _powerGenerators.removeWhere((g) => g.id == generatorId);
    notifyListeners();
  }

  PowerGenerator? getPowerGeneratorById(String id) {
    try {
      return _powerGenerators.firstWhere((g) => g.id == id);
    } catch (e) {
      return null;
    }
  }

  // Indian State CRUD Operations
  void addIndianState(IndianState state) {
    _indianStates.add(state);
    notifyListeners();
  }

  void updateIndianState(IndianState updatedState) {
    final index = _indianStates.indexWhere((s) => s.id == updatedState.id);
    if (index != -1) {
      _indianStates[index] = updatedState;
      notifyListeners();
    }
  }

  void deleteIndianState(String stateId) {
    _indianStates.removeWhere((s) => s.id == stateId);
    notifyListeners();
  }

  IndianState? getIndianStateById(String id) {
    try {
      return _indianStates.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  // Mandal CRUD Operations
  void addMandalToState(String stateId, Mandal mandal) {
    final stateIndex = _indianStates.indexWhere((s) => s.id == stateId);
    if (stateIndex != -1) {
      final updatedMandals =
          List<Mandal>.from(_indianStates[stateIndex].mandals)..add(mandal);
      _indianStates[stateIndex] = IndianState(
        id: _indianStates[stateIndex].id,
        name: _indianStates[stateIndex].name,
        capital: _indianStates[stateIndex].capital,
        powerCapacity: _indianStates[stateIndex].powerCapacity,
        discoms: _indianStates[stateIndex].discoms,
        logo: _indianStates[stateIndex].logo,
        address: _indianStates[stateIndex].address,
        website: _indianStates[stateIndex].website,
        email: _indianStates[stateIndex].email,
        helpline: _indianStates[stateIndex].helpline,
        chiefMinister: _indianStates[stateIndex].chiefMinister,
        chiefMinisterPhoto: _indianStates[stateIndex].chiefMinisterPhoto,
        energyMinister: _indianStates[stateIndex].energyMinister,
        energyMinisterPhoto: _indianStates[stateIndex].energyMinisterPhoto,
        energyMix: _indianStates[stateIndex].energyMix,
        discomsList: _indianStates[stateIndex].discomsList,
        posts: _indianStates[stateIndex].posts,
        mandals: updatedMandals,
        productDesigns: _indianStates[stateIndex].productDesigns,
      );
      notifyListeners();
    }
  }

  void updateMandalInState(String stateId, Mandal updatedMandal) {
    final stateIndex = _indianStates.indexWhere((s) => s.id == stateId);
    if (stateIndex != -1) {
      final mandals = List<Mandal>.from(_indianStates[stateIndex].mandals);
      final mandalIndex = mandals.indexWhere((m) => m.id == updatedMandal.id);
      if (mandalIndex != -1) {
        mandals[mandalIndex] = updatedMandal;
        _indianStates[stateIndex] = IndianState(
          id: _indianStates[stateIndex].id,
          name: _indianStates[stateIndex].name,
          capital: _indianStates[stateIndex].capital,
          powerCapacity: _indianStates[stateIndex].powerCapacity,
          discoms: _indianStates[stateIndex].discoms,
          logo: _indianStates[stateIndex].logo,
          address: _indianStates[stateIndex].address,
          website: _indianStates[stateIndex].website,
          email: _indianStates[stateIndex].email,
          helpline: _indianStates[stateIndex].helpline,
          chiefMinister: _indianStates[stateIndex].chiefMinister,
          chiefMinisterPhoto: _indianStates[stateIndex].chiefMinisterPhoto,
          energyMinister: _indianStates[stateIndex].energyMinister,
          energyMinisterPhoto: _indianStates[stateIndex].energyMinisterPhoto,
          energyMix: _indianStates[stateIndex].energyMix,
          discomsList: _indianStates[stateIndex].discomsList,
          posts: _indianStates[stateIndex].posts,
          mandals: mandals,
          productDesigns: _indianStates[stateIndex].productDesigns,
        );
        notifyListeners();
      }
    }
  }

  void deleteMandalFromState(String stateId, String mandalId) {
    final stateIndex = _indianStates.indexWhere((s) => s.id == stateId);
    if (stateIndex != -1) {
      final updatedMandals = _indianStates[stateIndex]
          .mandals
          .where((m) => m.id != mandalId)
          .toList();
      _indianStates[stateIndex] = IndianState(
        id: _indianStates[stateIndex].id,
        name: _indianStates[stateIndex].name,
        capital: _indianStates[stateIndex].capital,
        powerCapacity: _indianStates[stateIndex].powerCapacity,
        discoms: _indianStates[stateIndex].discoms,
        logo: _indianStates[stateIndex].logo,
        address: _indianStates[stateIndex].address,
        website: _indianStates[stateIndex].website,
        email: _indianStates[stateIndex].email,
        helpline: _indianStates[stateIndex].helpline,
        chiefMinister: _indianStates[stateIndex].chiefMinister,
        chiefMinisterPhoto: _indianStates[stateIndex].chiefMinisterPhoto,
        energyMinister: _indianStates[stateIndex].energyMinister,
        energyMinisterPhoto: _indianStates[stateIndex].energyMinisterPhoto,
        energyMix: _indianStates[stateIndex].energyMix,
        discomsList: _indianStates[stateIndex].discomsList,
        posts: _indianStates[stateIndex].posts,
        mandals: updatedMandals,
        productDesigns: _indianStates[stateIndex].productDesigns,
      );
      notifyListeners();
    }
  }

  // Distribution Company CRUD Operations
  void addDistributionCompany(DistributionCompany company) {
    _distributionCompanies.add(company);
    notifyListeners();
  }

  void updateDistributionCompany(DistributionCompany updatedCompany) {
    final index =
        _distributionCompanies.indexWhere((c) => c.id == updatedCompany.id);
    if (index != -1) {
      _distributionCompanies[index] = updatedCompany;
      notifyListeners();
    }
  }

  void deleteDistributionCompany(String companyId) {
    _distributionCompanies.removeWhere((c) => c.id == companyId);
    notifyListeners();
  }

  DistributionCompany? getDistributionCompanyById(String id) {
    try {
      return _distributionCompanies.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // Transmission Line CRUD Operations
  void addTransmissionLine(TransmissionLine line) {
    _transmissionLines.add(line);
    notifyListeners();
  }

  void updateTransmissionLine(TransmissionLine updatedLine) {
    final index = _transmissionLines.indexWhere((l) => l.id == updatedLine.id);
    if (index != -1) {
      _transmissionLines[index] = updatedLine;
      notifyListeners();
    }
  }

  void deleteTransmissionLine(String lineId) {
    _transmissionLines.removeWhere((l) => l.id == lineId);
    notifyListeners();
  }

  TransmissionLine? getTransmissionLineById(String id) {
    try {
      return _transmissionLines.firstWhere((l) => l.id == id);
    } catch (e) {
      return null;
    }
  }

  // Utility methods
  List<Mandal> getMandalsForState(String stateId) {
    final state = getIndianStateById(stateId);
    return state?.mandals ?? [];
  }

  List<String> getDiscomsForMandal(String stateId, String mandalId) {
    final state = getIndianStateById(stateId);
    if (state != null) {
      final mandal = state.mandals.firstWhere(
        (m) => m.id == mandalId,
        orElse: () => const Mandal(
          id: '',
          name: '',
          population: '',
          powerDemand: '',
        ),
      );
      return mandal.discoms ?? [];
    }
    return [];
  }

  // Generate unique IDs
  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  void resetToDefault() {
    _indianStates = StateInfoStaticData.indianStates;
    _powerGenerators = StateInfoStaticData.powerGenerators;
    _transmissionLines = StateInfoStaticData.transmissionLines;
    _distributionCompanies = StateInfoStaticData.distributionCompanies;
    notifyListeners();
  }

  // Add mandal to the list
  void addMandal(Mandal mandal) {
    // For now, we'll add it to the first state as a simple implementation
    // In a real app, you'd want to associate it with the correct state
    if (_indianStates.isNotEmpty) {
      final firstState = _indianStates.first;
      final updatedMandals = List<Mandal>.from(firstState.mandals)..add(mandal);
      _indianStates[0] = IndianState(
        id: firstState.id,
        name: firstState.name,
        capital: firstState.capital,
        powerCapacity: firstState.powerCapacity,
        discoms: firstState.discoms,
        logo: firstState.logo,
        address: firstState.address,
        website: firstState.website,
        email: firstState.email,
        helpline: firstState.helpline,
        chiefMinister: firstState.chiefMinister,
        chiefMinisterPhoto: firstState.chiefMinisterPhoto,
        energyMinister: firstState.energyMinister,
        energyMinisterPhoto: firstState.energyMinisterPhoto,
        energyMix: firstState.energyMix,
        discomsList: firstState.discomsList,
        posts: firstState.posts,
        mandals: updatedMandals,
        productDesigns: firstState.productDesigns,
      );
      notifyListeners();
    }
  }

  // Post Management Methods
  void addPostToEntity(String entityId, ProfilePost post) {
    // Convert ProfilePost to Post for storage
    final postForStorage = Post(
      id: post.id,
      title: post.title,
      content: post.content,
      author: post.author,
      time: post.publishDate.toIso8601String(),
      tags: post.tags,
      imageUrl: post.imageUrl,
      imageUrls: post.imageUrls,
      pdfUrls: post.pdfUrls,
    );
    // Add to power generators
    final generatorIndex = _powerGenerators.indexWhere((g) => g.id == entityId);
    if (generatorIndex != -1) {
      final generator = _powerGenerators[generatorIndex];
      final updatedPosts = List<Post>.from(generator.posts)
        ..add(postForStorage);
      _powerGenerators[generatorIndex] = PowerGenerator(
        id: generator.id,
        name: generator.name,
        type: generator.type,
        capacity: generator.capacity,
        location: generator.location,
        logo: generator.logo,
        established: generator.established,
        founder: generator.founder,
        ceo: generator.ceo,
        ceoPhoto: generator.ceoPhoto,
        headquarters: generator.headquarters,
        phone: generator.phone,
        email: generator.email,
        website: generator.website,
        description: generator.description,
        totalPlants: generator.totalPlants,
        employees: generator.employees,
        revenue: generator.revenue,
        posts: updatedPosts,
        productDesigns: generator.productDesigns,
      );
      notifyListeners();
      return;
    }

    // Add to transmission lines
    final transmissionIndex =
        _transmissionLines.indexWhere((t) => t.id == entityId);
    if (transmissionIndex != -1) {
      final transmission = _transmissionLines[transmissionIndex];
      final updatedPosts = List<Post>.from(transmission.posts)
        ..add(postForStorage);
      _transmissionLines[transmissionIndex] = TransmissionLine(
        id: transmission.id,
        name: transmission.name,
        voltage: transmission.voltage,
        coverage: transmission.coverage,
        headquarters: transmission.headquarters,
        logo: transmission.logo,
        established: transmission.established,
        founder: transmission.founder,
        ceo: transmission.ceo,
        ceoPhoto: transmission.ceoPhoto,
        address: transmission.address,
        phone: transmission.phone,
        email: transmission.email,
        website: transmission.website,
        description: transmission.description,
        totalSubstations: transmission.totalSubstations,
        employees: transmission.employees,
        revenue: transmission.revenue,
        posts: updatedPosts,
        productDesigns: transmission.productDesigns,
      );
      notifyListeners();
      return;
    }

    // Add to distribution companies
    final distributionIndex =
        _distributionCompanies.indexWhere((d) => d.id == entityId);
    if (distributionIndex != -1) {
      final distribution = _distributionCompanies[distributionIndex];
      final updatedPosts = List<Post>.from(distribution.posts)
        ..add(postForStorage);
      _distributionCompanies[distributionIndex] = DistributionCompany(
        id: distribution.id,
        name: distribution.name,
        logo: distribution.logo,
        established: distribution.established,
        director: distribution.director,
        directorPhoto: distribution.directorPhoto,
        address: distribution.address,
        phone: distribution.phone,
        email: distribution.email,
        website: distribution.website,
        coverage: distribution.coverage,
        customers: distribution.customers,
        capacity: distribution.capacity,
        description: distribution.description,
        posts: updatedPosts,
        productDesigns: distribution.productDesigns,
      );
      notifyListeners();
      return;
    }

    // Add to states
    final stateIndex = _indianStates.indexWhere((s) => s.id == entityId);
    if (stateIndex != -1) {
      final state = _indianStates[stateIndex];
      final updatedPosts = List<Post>.from(state.posts)..add(postForStorage);
      _indianStates[stateIndex] = IndianState(
        id: state.id,
        name: state.name,
        capital: state.capital,
        powerCapacity: state.powerCapacity,
        discoms: state.discoms,
        logo: state.logo,
        address: state.address,
        website: state.website,
        email: state.email,
        helpline: state.helpline,
        chiefMinister: state.chiefMinister,
        chiefMinisterPhoto: state.chiefMinisterPhoto,
        energyMinister: state.energyMinister,
        energyMinisterPhoto: state.energyMinisterPhoto,
        energyMix: state.energyMix,
        discomsList: state.discomsList,
        posts: updatedPosts,
        mandals: state.mandals,
        productDesigns: state.productDesigns,
      );
      notifyListeners();
      return;
    }
  }

  void updatePostInEntity(String entityId, ProfilePost updatedPost) {
    // Convert ProfilePost to Post for storage
    final postForStorage = Post(
      id: updatedPost.id,
      title: updatedPost.title,
      content: updatedPost.content,
      author: updatedPost.author,
      time: updatedPost.publishDate.toIso8601String(),
      tags: updatedPost.tags,
      imageUrl: updatedPost.imageUrl,
      imageUrls: updatedPost.imageUrls,
      pdfUrls: updatedPost.pdfUrls,
    );

    // Update in power generators
    final generatorIndex = _powerGenerators.indexWhere((g) => g.id == entityId);
    if (generatorIndex != -1) {
      final generator = _powerGenerators[generatorIndex];
      final updatedPosts = generator.posts
          .map((p) => p.id == updatedPost.id ? postForStorage : p)
          .toList();
      _powerGenerators[generatorIndex] = PowerGenerator(
        id: generator.id,
        name: generator.name,
        type: generator.type,
        capacity: generator.capacity,
        location: generator.location,
        logo: generator.logo,
        established: generator.established,
        founder: generator.founder,
        ceo: generator.ceo,
        ceoPhoto: generator.ceoPhoto,
        headquarters: generator.headquarters,
        phone: generator.phone,
        email: generator.email,
        website: generator.website,
        description: generator.description,
        totalPlants: generator.totalPlants,
        employees: generator.employees,
        revenue: generator.revenue,
        posts: updatedPosts,
        productDesigns: generator.productDesigns,
      );
      notifyListeners();
      return;
    }

    // Update in transmission lines
    final transmissionIndex =
        _transmissionLines.indexWhere((t) => t.id == entityId);
    if (transmissionIndex != -1) {
      final transmission = _transmissionLines[transmissionIndex];
      final updatedPosts = transmission.posts
          .map((p) => p.id == updatedPost.id ? postForStorage : p)
          .toList();
      _transmissionLines[transmissionIndex] = TransmissionLine(
        id: transmission.id,
        name: transmission.name,
        voltage: transmission.voltage,
        coverage: transmission.coverage,
        headquarters: transmission.headquarters,
        logo: transmission.logo,
        established: transmission.established,
        founder: transmission.founder,
        ceo: transmission.ceo,
        ceoPhoto: transmission.ceoPhoto,
        address: transmission.address,
        phone: transmission.phone,
        email: transmission.email,
        website: transmission.website,
        description: transmission.description,
        totalSubstations: transmission.totalSubstations,
        employees: transmission.employees,
        revenue: transmission.revenue,
        posts: updatedPosts,
        productDesigns: transmission.productDesigns,
      );
      notifyListeners();
      return;
    }

    // Update in distribution companies
    final distributionIndex =
        _distributionCompanies.indexWhere((d) => d.id == entityId);
    if (distributionIndex != -1) {
      final distribution = _distributionCompanies[distributionIndex];
      final updatedPosts = distribution.posts
          .map((p) => p.id == updatedPost.id ? postForStorage : p)
          .toList();
      _distributionCompanies[distributionIndex] = DistributionCompany(
        id: distribution.id,
        name: distribution.name,
        logo: distribution.logo,
        established: distribution.established,
        director: distribution.director,
        directorPhoto: distribution.directorPhoto,
        address: distribution.address,
        phone: distribution.phone,
        email: distribution.email,
        website: distribution.website,
        coverage: distribution.coverage,
        customers: distribution.customers,
        capacity: distribution.capacity,
        description: distribution.description,
        posts: updatedPosts,
        productDesigns: distribution.productDesigns,
      );
      notifyListeners();
      return;
    }

    // Update in states
    final stateIndex = _indianStates.indexWhere((s) => s.id == entityId);
    if (stateIndex != -1) {
      final state = _indianStates[stateIndex];
      final updatedPosts = state.posts
          .map((p) => p.id == updatedPost.id ? postForStorage : p)
          .toList();
      _indianStates[stateIndex] = IndianState(
        id: state.id,
        name: state.name,
        capital: state.capital,
        powerCapacity: state.powerCapacity,
        discoms: state.discoms,
        logo: state.logo,
        address: state.address,
        website: state.website,
        email: state.email,
        helpline: state.helpline,
        chiefMinister: state.chiefMinister,
        chiefMinisterPhoto: state.chiefMinisterPhoto,
        energyMinister: state.energyMinister,
        energyMinisterPhoto: state.energyMinisterPhoto,
        energyMix: state.energyMix,
        discomsList: state.discomsList,
        posts: updatedPosts,
        mandals: state.mandals,
        productDesigns: state.productDesigns,
      );
      notifyListeners();
      return;
    }
  }

  void deleteProfilePostFromEntity(String entityId, String postId) {
    // Delete from power generators
    final generatorIndex = _powerGenerators.indexWhere((g) => g.id == entityId);
    if (generatorIndex != -1) {
      final generator = _powerGenerators[generatorIndex];
      final updatedPosts =
          generator.posts.where((p) => p.id != postId).toList();
      _powerGenerators[generatorIndex] = PowerGenerator(
        id: generator.id,
        name: generator.name,
        type: generator.type,
        capacity: generator.capacity,
        location: generator.location,
        logo: generator.logo,
        established: generator.established,
        founder: generator.founder,
        ceo: generator.ceo,
        ceoPhoto: generator.ceoPhoto,
        headquarters: generator.headquarters,
        phone: generator.phone,
        email: generator.email,
        website: generator.website,
        description: generator.description,
        totalPlants: generator.totalPlants,
        employees: generator.employees,
        revenue: generator.revenue,
        posts: updatedPosts,
        productDesigns: generator.productDesigns,
      );
      notifyListeners();
      return;
    }

    // Delete from transmission lines
    final transmissionIndex =
        _transmissionLines.indexWhere((t) => t.id == entityId);
    if (transmissionIndex != -1) {
      final transmission = _transmissionLines[transmissionIndex];
      final updatedPosts =
          transmission.posts.where((p) => p.id != postId).toList();
      _transmissionLines[transmissionIndex] = TransmissionLine(
        id: transmission.id,
        name: transmission.name,
        voltage: transmission.voltage,
        coverage: transmission.coverage,
        headquarters: transmission.headquarters,
        logo: transmission.logo,
        established: transmission.established,
        founder: transmission.founder,
        ceo: transmission.ceo,
        ceoPhoto: transmission.ceoPhoto,
        address: transmission.address,
        phone: transmission.phone,
        email: transmission.email,
        website: transmission.website,
        description: transmission.description,
        totalSubstations: transmission.totalSubstations,
        employees: transmission.employees,
        revenue: transmission.revenue,
        posts: updatedPosts,
        productDesigns: transmission.productDesigns,
      );
      notifyListeners();
      return;
    }

    // Delete from distribution companies
    final distributionIndex =
        _distributionCompanies.indexWhere((d) => d.id == entityId);
    if (distributionIndex != -1) {
      final distribution = _distributionCompanies[distributionIndex];
      final updatedPosts =
          distribution.posts.where((p) => p.id != postId).toList();
      _distributionCompanies[distributionIndex] = DistributionCompany(
        id: distribution.id,
        name: distribution.name,
        logo: distribution.logo,
        established: distribution.established,
        director: distribution.director,
        directorPhoto: distribution.directorPhoto,
        address: distribution.address,
        phone: distribution.phone,
        email: distribution.email,
        website: distribution.website,
        coverage: distribution.coverage,
        customers: distribution.customers,
        capacity: distribution.capacity,
        description: distribution.description,
        posts: updatedPosts,
        productDesigns: distribution.productDesigns,
      );
      notifyListeners();
      return;
    }

    // Delete from states
    final stateIndex = _indianStates.indexWhere((s) => s.id == entityId);
    if (stateIndex != -1) {
      final state = _indianStates[stateIndex];
      final updatedPosts = state.posts.where((p) => p.id != postId).toList();
      _indianStates[stateIndex] = IndianState(
        id: state.id,
        name: state.name,
        capital: state.capital,
        powerCapacity: state.powerCapacity,
        discoms: state.discoms,
        logo: state.logo,
        address: state.address,
        website: state.website,
        email: state.email,
        helpline: state.helpline,
        chiefMinister: state.chiefMinister,
        chiefMinisterPhoto: state.chiefMinisterPhoto,
        energyMinister: state.energyMinister,
        energyMinisterPhoto: state.energyMinisterPhoto,
        energyMix: state.energyMix,
        discomsList: state.discomsList,
        posts: updatedPosts,
        mandals: state.mandals,
        productDesigns: state.productDesigns,
      );
      notifyListeners();
      return;
    }
  }

  // Get posts for an entity
  List<ProfilePost> getPostsForEntity(String entityId) {
    try {
      // Check power generators
      final generatorIndex =
          _powerGenerators.indexWhere((g) => g.id == entityId);
      if (generatorIndex != -1) {
        return _powerGenerators[generatorIndex]
            .posts
            .map((post) => ProfilePost(
                  id: post.id,
                  title: post.title,
                  content: post.content,
                  imageUrl: post.imageUrl ?? 'https://via.placeholder.com/400',
                  imageUrls: post.imageUrls,
                  pdfUrls: post.pdfUrls,
                  category: PostCategory.update, // Default category
                  tags: post.tags,
                  author: post.author,
                  publishDate: DateTime.tryParse(post.time) ?? DateTime.now(),
                  likes: 0, // Default values
                  comments: 0,
                ))
            .toList();
      }

      // Check transmission lines
      final transmissionIndex =
          _transmissionLines.indexWhere((t) => t.id == entityId);
      if (transmissionIndex != -1) {
        return _transmissionLines[transmissionIndex]
            .posts
            .map((post) => ProfilePost(
                  id: post.id,
                  title: post.title,
                  content: post.content,
                  imageUrl: post.imageUrl ?? 'https://via.placeholder.com/400',
                  imageUrls: post.imageUrls,
                  pdfUrls: post.pdfUrls,
                  category: PostCategory.update, // Default category
                  tags: post.tags,
                  author: post.author,
                  publishDate: DateTime.tryParse(post.time) ?? DateTime.now(),
                  likes: 0, // Default values
                  comments: 0,
                ))
            .toList();
      }

      // Check distribution companies
      final distributionIndex =
          _distributionCompanies.indexWhere((d) => d.id == entityId);
      if (distributionIndex != -1) {
        return _distributionCompanies[distributionIndex]
            .posts
            .map((post) => ProfilePost(
                  id: post.id,
                  title: post.title,
                  content: post.content,
                  imageUrl: post.imageUrl ?? 'https://via.placeholder.com/400',
                  imageUrls: post.imageUrls,
                  pdfUrls: post.pdfUrls,
                  category: PostCategory.update, // Default category
                  tags: post.tags,
                  author: post.author,
                  publishDate: DateTime.tryParse(post.time) ?? DateTime.now(),
                  likes: 0, // Default values
                  comments: 0,
                ))
            .toList();
      }

      // Check states
      final stateIndex = _indianStates.indexWhere((s) => s.id == entityId);
      if (stateIndex != -1) {
        return _indianStates[stateIndex]
            .posts
            .map((post) => ProfilePost(
                  id: post.id,
                  title: post.title,
                  content: post.content,
                  imageUrl: post.imageUrl ?? 'https://via.placeholder.com/400',
                  imageUrls: post.imageUrls,
                  pdfUrls: post.pdfUrls,
                  category: PostCategory.update, // Default category
                  tags: post.tags,
                  author: post.author,
                  publishDate: DateTime.tryParse(post.time) ?? DateTime.now(),
                  likes: 0, // Default values
                  comments: 0,
                ))
            .toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }
}

// Lightweight custom field data model for persistence
class CustomFieldData {
  final String id;
  final String name;
  final String type;
  final String value;
  final String? description;

  const CustomFieldData({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    this.description,
  });
}
