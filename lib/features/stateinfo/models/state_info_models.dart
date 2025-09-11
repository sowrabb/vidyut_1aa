// Data models for State Electricity Board Information System
// Based on the React prototype documentation

class Post {
  final String id;
  final String title;
  final String content;
  final String author;
  final String time;
  final List<String> tags;
  final String? imageUrl;

  const Post({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.time,
    this.tags = const [],
    this.imageUrl,
  });
}

class PowerGenerator {
  final String id;
  final String name;
  final String type; // "Thermal", "Hydro", "Nuclear"
  final String capacity; // "65,810 MW"
  final String location;
  final String logo;
  final String established;
  final String founder;
  final String ceo;
  final String ceoPhoto;
  final String headquarters;
  final String phone;
  final String email;
  final String website;
  final String description;
  final int totalPlants;
  final String employees;
  final String revenue;
  final List<Post> posts;

  const PowerGenerator({
    required this.id,
    required this.name,
    required this.type,
    required this.capacity,
    required this.location,
    required this.logo,
    required this.established,
    required this.founder,
    required this.ceo,
    required this.ceoPhoto,
    required this.headquarters,
    required this.phone,
    required this.email,
    required this.website,
    required this.description,
    required this.totalPlants,
    required this.employees,
    required this.revenue,
    required this.posts,
  });
}

class TransmissionLine {
  final String id;
  final String name;
  final String voltage; // "765 kV"
  final String coverage; // "National"
  final String headquarters;
  final String logo;
  final String established;
  final String founder;
  final String ceo;
  final String ceoPhoto;
  final String address;
  final String phone;
  final String email;
  final String website;
  final String description;
  final int totalSubstations;
  final String employees;
  final String revenue;
  final List<Post> posts;

  const TransmissionLine({
    required this.id,
    required this.name,
    required this.voltage,
    required this.coverage,
    required this.headquarters,
    required this.logo,
    required this.established,
    required this.founder,
    required this.ceo,
    required this.ceoPhoto,
    required this.address,
    required this.phone,
    required this.email,
    required this.website,
    required this.description,
    required this.totalSubstations,
    required this.employees,
    required this.revenue,
    required this.posts,
  });
}

class DistributionCompany {
  final String id;
  final String name;
  final String logo;
  final String established;
  final String director;
  final String directorPhoto;
  final String address;
  final String phone;
  final String email;
  final String website;
  final String coverage;
  final String customers;
  final String capacity;
  final String description;
  final List<Post> posts;

  const DistributionCompany({
    required this.id,
    required this.name,
    required this.logo,
    required this.established,
    required this.director,
    required this.directorPhoto,
    required this.address,
    required this.phone,
    required this.email,
    required this.website,
    required this.coverage,
    required this.customers,
    required this.capacity,
    required this.description,
    required this.posts,
  });
}

class Mandal {
  final String id;
  final String name;
  final String population;
  final String powerDemand;
  final String? administrator;
  final String? divisionController;
  final String? controllerPhoto;
  final String? officeAddress;
  final String? phone;
  final String? email;
  final String? website;
  final String? helpline;
  final List<String>? discoms;
  final List<Post>? posts;

  const Mandal({
    required this.id,
    required this.name,
    required this.population,
    required this.powerDemand,
    this.administrator,
    this.divisionController,
    this.controllerPhoto,
    this.officeAddress,
    this.phone,
    this.email,
    this.website,
    this.helpline,
    this.discoms,
    this.posts,
  });
}

class EnergyMix {
  final int thermal;
  final int hydro;
  final int nuclear;
  final int renewable;

  const EnergyMix({
    required this.thermal,
    required this.hydro,
    required this.nuclear,
    required this.renewable,
  });
}

class IndianState {
  final String id;
  final String name;
  final String capital;
  final String powerCapacity;
  final int discoms;
  final String logo;
  final String address;
  final String website;
  final String email;
  final String helpline;
  final String chiefMinister;
  final String chiefMinisterPhoto;
  final String energyMinister;
  final String energyMinisterPhoto;
  final EnergyMix energyMix;
  final List<String> discomsList;
  final List<Post> posts;
  final List<Mandal> mandals;

  const IndianState({
    required this.id,
    required this.name,
    required this.capital,
    required this.powerCapacity,
    required this.discoms,
    required this.logo,
    required this.address,
    required this.website,
    required this.email,
    required this.helpline,
    required this.chiefMinister,
    required this.chiefMinisterPhoto,
    required this.energyMinister,
    required this.energyMinisterPhoto,
    required this.energyMix,
    required this.discomsList,
    required this.posts,
    required this.mandals,
  });
}

// Navigation and State Management
enum MainPath { selection, powerFlow, stateFlow }
enum PowerFlowStep { 
  generator, 
  transmission, 
  distribution, 
  profile, 
  generatorProfile, 
  transmissionProfile 
}
enum StateFlowStep { states, stateDetail, mandalDetail }

