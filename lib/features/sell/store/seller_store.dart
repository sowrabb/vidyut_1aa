import 'package:flutter/foundation.dart';
import '../models.dart';

class SellerStore extends ChangeNotifier {
  List<Product> _products = [];
  List<CustomFieldDef> _profileFields = [];
  List<Lead> _leads = [];
  String _bannerUrl = '';
  List<String> _profileMaterials = [];
  List<AdCampaign> _ads = [];

  // Analytics (demo, in-memory)
  int _profileViews = 0;
  int _sellerContactCalls = 0;
  int _sellerContactWhatsapps = 0;
  final Map<String, int> _productViews = <String, int>{};
  final Map<String, int> _productContactCalls = <String, int>{};
  final Map<String, int> _productContactWhatsapps = <String, int>{};

  // Getters
  List<Product> get products => List.unmodifiable(_products);
  List<CustomFieldDef> get profileFields => List.unmodifiable(_profileFields);
  List<Lead> get leads => List.unmodifiable(_leads);
  String get bannerUrl => _bannerUrl;
  List<String> get profileMaterials => List.unmodifiable(_profileMaterials);
  List<AdCampaign> get ads => List.unmodifiable(_ads);

  // Analytics getters
  int get profileViews => _profileViews;
  int get sellerContactCalls => _sellerContactCalls;
  int get sellerContactWhatsapps => _sellerContactWhatsapps;
  int get totalSellerContacts => _sellerContactCalls + _sellerContactWhatsapps;
  int productViewsOf(String productId) => _productViews[productId] ?? 0;
  int productContactCallsOf(String productId) => _productContactCalls[productId] ?? 0;
  int productContactWhatsappsOf(String productId) => _productContactWhatsapps[productId] ?? 0;
  int get totalProductViews => _productViews.values.fold(0, (a, b) => a + b);
  int get totalProductContacts => _productContactCalls.values.fold(0, (a, b) => a + b) + _productContactWhatsapps.values.fold(0, (a, b) => a + b);
  List<Product> get topViewedProducts {
    final byViews = [..._products];
    byViews.sort((a, b) => (productViewsOf(b.id)).compareTo(productViewsOf(a.id)));
    return byViews.take(10).toList();
  }

  SellerStore() {
    _seedDemoData();
  }


  // Banner management
  void setBannerUrl(String url) {
    _bannerUrl = url;
    notifyListeners();
    // TODO(firebase): sync to backend
  }

  void setProfileMaterials(List<String> materials) {
    _profileMaterials = List.of(materials);
    notifyListeners();
    // TODO(firebase): sync to backend
  }

  // Ads management (max 3 campaigns)
  void upsertAd(AdCampaign ad) {
    final i = _ads.indexWhere((a) => a.id == ad.id);
    if (i == -1) {
      if (_ads.length >= 3) return; // cap at 3
      _ads.add(ad);
    } else {
      _ads[i] = ad;
    }
    notifyListeners();
  }

  void deleteAd(String id) {
    _ads.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  // Analytics mutators
  void incrementProfileView() {
    _profileViews += 1;
    notifyListeners();
  }

  void recordSellerContactCall() {
    _sellerContactCalls += 1;
    notifyListeners();
  }

  void recordSellerContactWhatsapp() {
    _sellerContactWhatsapps += 1;
    notifyListeners();
  }

  void recordProductView(String productId) {
    _productViews[productId] = (_productViews[productId] ?? 0) + 1;
    notifyListeners();
  }

  void recordProductContactCall(String productId) {
    _productContactCalls[productId] = (_productContactCalls[productId] ?? 0) + 1;
    notifyListeners();
  }

  void recordProductContactWhatsapp(String productId) {
    _productContactWhatsapps[productId] = (_productContactWhatsapps[productId] ?? 0) + 1;
    notifyListeners();
  }

  void _seedDemoData() {
    // Seed demo products with 25 products across 5 categories
    _products = [
      // Cables & Wires (5 products)
      Product(
        id: '1',
        title: 'Copper Cable 1.5sqmm',
        brand: 'Finolex',
        category: 'Cables & Wires',
        subtitle: 'PVC | 1.5 sqmm | 1100V',
        description: 'High-quality copper cable suitable for electrical wiring in residential and commercial buildings.',
        images: [
          'assets/demo-images/wires-cables/wire01.jpeg',
          'assets/demo-images/wires-cables/wire02.jpeg',
          'assets/demo-images/wires-cables/wire03.jpeg',
          'assets/demo-images/wires-cables/wire04.jpeg',
          'assets/demo-images/wires-cables/wire05.jpeg',
        ],
        price: 499.0,
        moq: 100,
        gstRate: 18.0,
        materials: ['Copper', 'PVC'],
        customValues: {'color': 'Red', 'length': '100m'},
        rating: 4.2,
      ),
      Product(
        id: '2',
        title: 'Aluminum Wire 2.5sqmm',
        brand: 'Polycab',
        category: 'Cables & Wires',
        subtitle: 'XLPE | 2.5 sqmm | 1100V',
        description: 'Durable aluminum wire with XLPE insulation for industrial applications.',
        images: [
          'assets/demo-images/wires-cables/wire06.jpeg',
          'assets/demo-images/wires-cables/wire07.jpeg',
          'assets/demo-images/wires-cables/wire08.jpeg',
          'assets/demo-images/wires-cables/wire09.jpeg',
          'assets/demo-images/wires-cables/wire01.jpeg',
        ],
        price: 299.0,
        moq: 50,
        gstRate: 18.0,
        materials: ['Aluminum', 'XLPE'],
        customValues: {'color': 'Black', 'length': '50m'},
        rating: 4.0,
      ),
      Product(
        id: '3',
        title: 'Multi-Core Cable 4sqmm',
        brand: 'Havells',
        category: 'Cables & Wires',
        subtitle: 'PVC | 4 sqmm | 3 Core',
        description: 'Multi-core copper cable for three-phase electrical installations.',
        images: [
          'assets/demo-images/wires-cables/wire02.jpeg',
          'assets/demo-images/wires-cables/wire03.jpeg',
          'assets/demo-images/wires-cables/wire04.jpeg',
          'assets/demo-images/wires-cables/wire05.jpeg',
          'assets/demo-images/wires-cables/wire06.jpeg',
        ],
        price: 799.0,
        moq: 25,
        gstRate: 18.0,
        materials: ['Copper', 'PVC'],
        customValues: {'cores': '3', 'rating': '4 sqmm'},
        rating: 4.5,
      ),
      Product(
        id: '4',
        title: 'Control Cable 1.5sqmm',
        brand: 'RR Kabel',
        category: 'Cables & Wires',
        subtitle: 'FR | 1.5 sqmm | 12 Core',
        description: 'Control cable for automation and control panel wiring.',
        images: [
          'assets/demo-images/wires-cables/wire07.jpeg',
          'assets/demo-images/wires-cables/wire08.jpeg',
          'assets/demo-images/wires-cables/wire09.jpeg',
          'assets/demo-images/wires-cables/wire01.jpeg',
          'assets/demo-images/wires-cables/wire02.jpeg',
        ],
        price: 1299.0,
        moq: 10,
        gstRate: 18.0,
        materials: ['Copper', 'FR'],
        customValues: {'cores': '12', 'type': 'Control'},
        rating: 4.3,
      ),
      Product(
        id: '5',
        title: 'Armored Cable 6sqmm',
        brand: 'KEI',
        category: 'Cables & Wires',
        subtitle: 'XLPE | 6 sqmm | Armored',
        description: 'Armored cable for underground and outdoor installations.',
        images: [
          'assets/demo-images/wires-cables/wire03.jpeg',
          'assets/demo-images/wires-cables/wire04.jpeg',
          'assets/demo-images/wires-cables/wire05.jpeg',
          'assets/demo-images/wires-cables/wire06.jpeg',
          'assets/demo-images/wires-cables/wire07.jpeg',
        ],
        price: 1899.0,
        moq: 5,
        gstRate: 18.0,
        materials: ['Copper', 'XLPE', 'Steel'],
        customValues: {'armor': 'Steel', 'rating': '6 sqmm'},
        rating: 4.7,
      ),

      // Switchgear (5 products)
      Product(
        id: '6',
        title: 'MCB 32A Single Pole',
        brand: 'Schneider',
        category: 'Switchgear',
        subtitle: '32A | Single Pole | DIN Rail',
        description: 'Miniature Circuit Breaker for electrical protection in distribution boards.',
        images: [
          'assets/demo-images/circuit-breakers/breaker01.jpeg',
          'assets/demo-images/circuit-breakers/breaker02.jpeg',
          'assets/demo-images/circuit-breakers/breaker03.jpeg',
          'assets/demo-images/circuit-breakers/breaker04.jpeg',
          'assets/demo-images/circuit-breakers/breaker05.jpeg',
        ],
        price: 899.0,
        moq: 10,
        gstRate: 18.0,
        materials: ['Plastic', 'Metal'],
        customValues: {'rating': '32A', 'type': 'Single Pole'},
        rating: 4.4,
      ),
      Product(
        id: '7',
        title: 'RCCB 40A 30mA',
        brand: 'Legrand',
        category: 'Switchgear',
        subtitle: '40A | 30mA | 2 Pole',
        description: 'Residual Current Circuit Breaker for earth fault protection.',
        images: [
          'assets/demo-images/circuit-breakers/breaker06.jpeg',
          'assets/demo-images/circuit-breakers/breaker07.jpeg',
          'assets/demo-images/circuit-breakers/breaker08.jpeg',
          'assets/demo-images/circuit-breakers/breaker09.jpeg',
          'assets/demo-images/circuit-breakers/breaker10.jpeg',
        ],
        price: 2499.0,
        moq: 5,
        gstRate: 18.0,
        materials: ['Plastic', 'Metal'],
        customValues: {'rating': '40A', 'sensitivity': '30mA'},
        rating: 4.6,
      ),
      Product(
        id: '8',
        title: 'MCCB 100A 3 Pole',
        brand: 'ABB',
        category: 'Switchgear',
        subtitle: '100A | 3 Pole | Thermal Magnetic',
        description: 'Molded Case Circuit Breaker for higher current applications.',
        images: [
          'assets/demo-images/circuit-breakers/breaker11.jpeg',
          'assets/demo-images/circuit-breakers/breaker12.jpeg',
          'assets/demo-images/circuit-breakers/breaker13.jpeg',
          'assets/demo-images/circuit-breakers/breaker14.jpeg',
          'assets/demo-images/circuit-breakers/breaker01.jpeg',
        ],
        price: 8999.0,
        moq: 2,
        gstRate: 18.0,
        materials: ['Plastic', 'Metal'],
        customValues: {'rating': '100A', 'poles': '3'},
        rating: 4.8,
      ),
      Product(
        id: '9',
        title: 'Isolator Switch 63A',
        brand: 'L&T',
        category: 'Switchgear',
        subtitle: '63A | 3 Pole | Manual',
        description: 'Manual isolator switch for electrical isolation and maintenance.',
        images: [
          'assets/demo-images/switches/switch01.jpeg',
          'assets/demo-images/switches/switch02.jpeg',
          'assets/demo-images/switches/switch03.jpeg',
          'assets/demo-images/switches/switch04.jpeg',
          'assets/demo-images/switches/switch05.jpeg',
        ],
        price: 1599.0,
        moq: 5,
        gstRate: 18.0,
        materials: ['Metal', 'Plastic'],
        customValues: {'rating': '63A', 'type': 'Manual'},
        rating: 4.1,
      ),
      Product(
        id: '10',
        title: 'Changeover Switch 32A',
        brand: 'Havells',
        category: 'Switchgear',
        subtitle: '32A | 2 Pole | Manual',
        description: 'Manual changeover switch for generator and mains switching.',
        images: [
          'assets/demo-images/switches/switch06.jpeg',
          'assets/demo-images/switches/switch07.jpeg',
          'assets/demo-images/switches/switch01.jpeg',
          'assets/demo-images/switches/switch02.jpeg',
          'assets/demo-images/switches/switch03.jpeg',
        ],
        price: 2999.0,
        moq: 3,
        gstRate: 18.0,
        materials: ['Metal', 'Plastic'],
        customValues: {'rating': '32A', 'poles': '2'},
        rating: 4.3,
      ),

      // Lighting (5 products)
      Product(
        id: '11',
        title: 'LED Panel Light 24W',
        brand: 'Philips',
        category: 'Lighting',
        subtitle: '24W | 3000K | 1200lm',
        description: 'Energy-efficient LED panel light for office and commercial spaces.',
        images: [
          'assets/demo-images/lights/light01.jpeg',
          'assets/demo-images/lights/light02.jpeg',
          'assets/demo-images/lights/light03.jpeg',
          'assets/demo-images/lights/light04.jpeg',
          'assets/demo-images/lights/light05.jpeg',
        ],
        price: 2499.0,
        moq: 10,
        gstRate: 18.0,
        materials: ['Aluminum', 'Plastic'],
        customValues: {'wattage': '24W', 'color_temp': '3000K'},
        rating: 4.5,
      ),
      Product(
        id: '12',
        title: 'LED Street Light 50W',
        brand: 'Osram',
        category: 'Lighting',
        subtitle: '50W | 5000K | 6000lm',
        description: 'High-power LED street light for outdoor illumination.',
        images: [
          'assets/demo-images/lights/light06.jpeg',
          'assets/demo-images/lights/light07.jpeg',
          'assets/demo-images/lights/light08.jpeg',
          'assets/demo-images/lights/light09.jpeg',
          'assets/demo-images/lights/light10.jpeg',
        ],
        price: 4999.0,
        moq: 5,
        gstRate: 18.0,
        materials: ['Aluminum', 'Glass'],
        customValues: {'wattage': '50W', 'color_temp': '5000K'},
        rating: 4.7,
      ),
      Product(
        id: '13',
        title: 'LED Downlight 12W',
        brand: 'Crompton',
        category: 'Lighting',
        subtitle: '12W | 4000K | 1000lm',
        description: 'Recessed LED downlight for residential and commercial use.',
        images: [
          'assets/demo-images/lights/light11.jpeg',
          'assets/demo-images/lights/light12.jpeg',
          'assets/demo-images/lights/light01.jpeg',
          'assets/demo-images/lights/light02.jpeg',
          'assets/demo-images/lights/light03.jpeg',
        ],
        price: 1299.0,
        moq: 20,
        gstRate: 18.0,
        materials: ['Aluminum', 'Plastic'],
        customValues: {'wattage': '12W', 'type': 'Recessed'},
        rating: 4.2,
      ),
      Product(
        id: '14',
        title: 'LED Tube Light 18W',
        brand: 'Syska',
        category: 'Lighting',
        subtitle: '18W | 6500K | 2000lm',
        description: 'T8 LED tube light replacement for fluorescent tubes.',
        images: [
          'assets/demo-images/lights/light04.jpeg',
          'assets/demo-images/lights/light05.jpeg',
          'assets/demo-images/lights/light06.jpeg',
          'assets/demo-images/lights/light07.jpeg',
          'assets/demo-images/lights/light08.jpeg',
        ],
        price: 899.0,
        moq: 25,
        gstRate: 18.0,
        materials: ['Aluminum', 'Plastic'],
        customValues: {'wattage': '18W', 'length': '4ft'},
        rating: 4.0,
      ),
      Product(
        id: '15',
        title: 'LED Flood Light 100W',
        brand: 'Bajaj',
        category: 'Lighting',
        subtitle: '100W | 6000K | 12000lm',
        description: 'High-intensity LED flood light for outdoor and security applications.',
        images: [
          'assets/demo-images/lights/light09.jpeg',
          'assets/demo-images/lights/light10.jpeg',
          'assets/demo-images/lights/light11.jpeg',
          'assets/demo-images/lights/light12.jpeg',
          'assets/demo-images/lights/light01.jpeg',
        ],
        price: 8999.0,
        moq: 2,
        gstRate: 18.0,
        materials: ['Aluminum', 'Glass'],
        customValues: {'wattage': '100W', 'beam_angle': '120°'},
        rating: 4.6,
      ),

      // Motors & Drives (5 products)
      Product(
        id: '16',
        title: 'Induction Motor 5HP',
        brand: 'Crompton',
        category: 'Motors & Drives',
        subtitle: '5HP | 1440 RPM | 3 Phase',
        description: 'Three-phase induction motor for industrial applications.',
        images: [
          'assets/demo-images/motors/motor01.jpeg',
          'assets/demo-images/motors/motor02.jpeg',
          'assets/demo-images/motors/motor03.jpeg',
          'assets/demo-images/motors/motor04.jpeg',
          'assets/demo-images/motors/motor05.jpeg',
        ],
        price: 24999.0,
        moq: 1,
        gstRate: 18.0,
        materials: ['Cast Iron', 'Copper', 'Steel'],
        customValues: {'hp': '5HP', 'rpm': '1440'},
        rating: 4.8,
      ),
      Product(
        id: '17',
        title: 'VFD Drive 3HP',
        brand: 'ABB',
        category: 'Motors & Drives',
        subtitle: '3HP | 0-50Hz | 3 Phase',
        description: 'Variable Frequency Drive for motor speed control.',
        images: [
          'assets/demo-images/motors/motor06.jpeg',
          'assets/demo-images/motors/motor07.jpeg',
          'assets/demo-images/motors/motor08.jpeg',
          'assets/demo-images/motors/motor01.jpeg',
          'assets/demo-images/motors/motor02.jpeg',
        ],
        price: 18999.0,
        moq: 1,
        gstRate: 18.0,
        materials: ['Plastic', 'Metal'],
        customValues: {'hp': '3HP', 'frequency': '0-50Hz'},
        rating: 4.7,
      ),
      Product(
        id: '18',
        title: 'Single Phase Motor 2HP',
        brand: 'Havells',
        category: 'Motors & Drives',
        subtitle: '2HP | 1440 RPM | Single Phase',
        description: 'Single-phase induction motor for domestic and light commercial use.',
        images: [
          'assets/demo-images/motors/motor03.jpeg',
          'assets/demo-images/motors/motor04.jpeg',
          'assets/demo-images/motors/motor05.jpeg',
          'assets/demo-images/motors/motor06.jpeg',
          'assets/demo-images/motors/motor07.jpeg',
        ],
        price: 12999.0,
        moq: 2,
        gstRate: 18.0,
        materials: ['Cast Iron', 'Copper'],
        customValues: {'hp': '2HP', 'phase': 'Single'},
        rating: 4.3,
      ),
      Product(
        id: '19',
        title: 'Servo Motor 1KW',
        brand: 'Mitsubishi',
        category: 'Motors & Drives',
        subtitle: '1KW | 3000 RPM | Servo',
        description: 'High-precision servo motor for automation applications.',
        images: [
          'assets/demo-images/motors/motor08.jpeg',
          'assets/demo-images/motors/motor01.jpeg',
          'assets/demo-images/motors/motor02.jpeg',
          'assets/demo-images/motors/motor03.jpeg',
          'assets/demo-images/motors/motor04.jpeg',
        ],
        price: 49999.0,
        moq: 1,
        gstRate: 18.0,
        materials: ['Aluminum', 'Steel'],
        customValues: {'power': '1KW', 'type': 'Servo'},
        rating: 4.9,
      ),
      Product(
        id: '20',
        title: 'Gear Motor 1HP',
        brand: 'Bonfiglioli',
        category: 'Motors & Drives',
        subtitle: '1HP | 30 RPM | Geared',
        description: 'Gear motor with high torque for heavy-duty applications.',
        images: [
          'assets/demo-images/motors/motor05.jpeg',
          'assets/demo-images/motors/motor06.jpeg',
          'assets/demo-images/motors/motor07.jpeg',
          'assets/demo-images/motors/motor08.jpeg',
          'assets/demo-images/motors/motor01.jpeg',
        ],
        price: 15999.0,
        moq: 1,
        gstRate: 18.0,
        materials: ['Cast Iron', 'Steel'],
        customValues: {'hp': '1HP', 'rpm': '30'},
        rating: 4.5,
      ),

      // Tools & Safety (5 products)
      Product(
        id: '21',
        title: 'Digital Multimeter',
        brand: 'Fluke',
        category: 'Tools & Safety',
        subtitle: 'True RMS | 600V | Auto Range',
        description: 'Professional digital multimeter for electrical measurements.',
        images: [
          'assets/demo-images/tools/tool01.jpeg',
          'assets/demo-images/tools/tool02.jpeg',
          'assets/demo-images/tools/tool03.jpeg',
          'assets/demo-images/tools/tool04.jpeg',
          'assets/demo-images/tools/tool05.jpeg',
        ],
        price: 8999.0,
        moq: 2,
        gstRate: 18.0,
        materials: ['Plastic', 'Metal'],
        customValues: {'voltage': '600V', 'type': 'True RMS'},
        rating: 4.8,
      ),
      Product(
        id: '22',
        title: 'Insulation Tester 1000V',
        brand: 'Megger',
        category: 'Tools & Safety',
        subtitle: '1000V | Digital | Portable',
        description: 'Digital insulation tester for cable and equipment testing.',
        images: [
          'assets/demo-images/tools/tool06.jpeg',
          'assets/demo-images/tools/tool07.jpeg',
          'assets/demo-images/tools/tool08.jpeg',
          'assets/demo-images/tools/tool09.jpeg',
          'assets/demo-images/tools/tool10.jpeg',
        ],
        price: 24999.0,
        moq: 1,
        gstRate: 18.0,
        materials: ['Plastic', 'Metal'],
        customValues: {'voltage': '1000V', 'type': 'Digital'},
        rating: 4.9,
      ),
      Product(
        id: '23',
        title: 'Safety Helmet',
        brand: '3M',
        category: 'Tools & Safety',
        subtitle: 'ANSI Z89.1 | White | Adjustable',
        description: 'Industrial safety helmet for head protection.',
        images: [
          'assets/demo-images/safety/safety01.jpeg',
          'assets/demo-images/safety/safety02.jpeg',
          'assets/demo-images/safety/safety03.jpeg',
          'assets/demo-images/safety/safety04.jpeg',
          'assets/demo-images/safety/safety05.jpeg',
        ],
        price: 1299.0,
        moq: 10,
        gstRate: 18.0,
        materials: ['Plastic', 'Foam'],
        customValues: {'standard': 'ANSI Z89.1', 'color': 'White'},
        rating: 4.4,
      ),
      Product(
        id: '24',
        title: 'Insulated Gloves 500V',
        brand: 'Honeywell',
        category: 'Tools & Safety',
        subtitle: '500V | Class 0 | Rubber',
        description: 'Electrical insulating gloves for live work protection.',
        images: [
          'assets/demo-images/safety/safety06.jpeg',
          'assets/demo-images/safety/safety07.jpeg',
          'assets/demo-images/safety/safety08.jpeg',
          'assets/demo-images/safety/safety01.jpeg',
          'assets/demo-images/safety/safety02.jpeg',
        ],
        price: 2999.0,
        moq: 5,
        gstRate: 18.0,
        materials: ['Rubber', 'Cotton'],
        customValues: {'voltage': '500V', 'class': '0'},
        rating: 4.6,
      ),
      Product(
        id: '25',
        title: 'Cable Tester Kit',
        brand: 'Klein Tools',
        category: 'Tools & Safety',
        subtitle: 'Multi-Function | Digital | Portable',
        description: 'Complete cable testing kit for network and electrical cables.',
        images: [
          'assets/demo-images/tools/tool01.jpeg',
          'assets/demo-images/tools/tool02.jpeg',
          'assets/demo-images/tools/tool03.jpeg',
          'assets/demo-images/tools/tool04.jpeg',
          'assets/demo-images/tools/tool05.jpeg',
        ],
        price: 15999.0,
        moq: 1,
        gstRate: 18.0,
        materials: ['Plastic', 'Metal'],
        customValues: {'type': 'Multi-Function', 'display': 'Digital'},
        rating: 4.7,
      ),
    ];

    // Seed demo profile fields
    _profileFields = const [
      CustomFieldDef(
        id: 'business_type',
        label: 'Business Type',
        type: FieldType.dropdown,
        options: ['Manufacturer', 'Distributor', 'Retailer', 'Wholesaler'],
      ),
      CustomFieldDef(
        id: 'certification',
        label: 'ISO Certification',
        type: FieldType.boolean,
      ),
      CustomFieldDef(
        id: 'established_year',
        label: 'Established Year',
        type: FieldType.number,
      ),
    ];

    // Seed demo leads
    _leads = [
      Lead(
        id: '1',
        title: 'Bulk Cable Order for Construction Project',
        industry: 'Construction',
        materials: ['Copper', 'PVC'],
        city: 'Mumbai',
        state: 'Maharashtra',
        qty: 5000,
        turnoverCr: 85,
        needBy: DateTime.now().add(const Duration(days: 30)),
        status: 'New',
        about: 'Large wiring scope for construction project.',
      ),
      Lead(
        id: '2',
        title: 'Industrial Wiring for Factory Setup',
        industry: 'EPC',
        materials: ['Aluminium', 'XLPE'],
        city: 'Pune',
        state: 'Maharashtra',
        qty: 2000,
        turnoverCr: 120,
        needBy: DateTime.now().add(const Duration(days: 45)),
        status: 'In Progress',
        about: 'Factory electrical infrastructure.',
      ),
      Lead(
        id: '3',
        title: 'Electrical Components for Office Complex',
        industry: 'MEP',
        materials: ['Copper', 'PVC'],
        city: 'Bangalore',
        state: 'Karnataka',
        qty: 500,
        turnoverCr: 60,
        needBy: DateTime.now().add(const Duration(days: 15)),
        status: 'Quoted',
        about: 'Office complex electrical upgrade.',
      ),
    ];

    // Seed demo profile materials
    _profileMaterials = const ['Copper', 'PVC'];
    // Seed demo ads
    _ads = [
      AdCampaign(id: 'ad1', type: AdType.search, term: 'copper', slot: 2),
      AdCampaign(
          id: 'ad2', type: AdType.category, term: 'Cables & Wires', slot: 3),
    ];
  }

  // Product CRUD
  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
    // TODO(firebase): sync to Firestore
  }

  void updateProduct(Product product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      notifyListeners();
      // TODO(firebase): sync to Firestore
    }
  }

  void deleteProduct(String productId) {
    _products.removeWhere((p) => p.id == productId);
    notifyListeners();
    // TODO(firebase): sync to Firestore
  }

  Product? getProduct(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Profile Fields CRUD
  void addProfileField(CustomFieldDef field) {
    _profileFields.add(field);
    notifyListeners();
    // TODO(firebase): sync to Firestore
  }

  void updateProfileField(CustomFieldDef field) {
    final index = _profileFields.indexWhere((f) => f.id == field.id);
    if (index != -1) {
      _profileFields[index] = field;
      notifyListeners();
      // TODO(firebase): sync to Firestore
    }
  }

  void deleteProfileField(String fieldId) {
    _profileFields.removeWhere((f) => f.id == fieldId);
    notifyListeners();
    // TODO(firebase): sync to Firestore
  }

  // Lead management
  void updateLeadStatus(String leadId, String status) {
    final index = _leads.indexWhere((l) => l.id == leadId);
    if (index != -1) {
      final lead = _leads[index];
      _leads[index] = Lead(
        id: lead.id,
        title: lead.title,
        industry: lead.industry,
        materials: lead.materials,
        city: lead.city,
        state: lead.state,
        qty: lead.qty,
        turnoverCr: lead.turnoverCr,
        needBy: lead.needBy,
        status: status,
        about: lead.about,
      );
      notifyListeners();
      // TODO(firebase): sync to Firestore
    }
  }
}

enum AdType { search, category }

class AdCampaign {
  final String id;
  final AdType type;
  final String term; // keyword or category name
  final int slot; // desired 1..5
  const AdCampaign(
      {required this.id,
      required this.type,
      required this.term,
      required this.slot});
}
