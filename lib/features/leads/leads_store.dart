import 'package:flutter/foundation.dart';
import '../sell/models.dart';
import '../../services/lightweight_demo_data_service.dart';

class LeadsStore extends ChangeNotifier {
  final LightweightDemoDataService _demoDataService;
  List<Lead> _results = [];
  List<Lead> get results => _results;

  String query = '';
  final Set<String> industries = {};
  final Set<String> materials = {};
  double minTurnCr = 0, maxTurnCr = 1000; // 0..1000 Cr
  String region = 'All'; // All / Telangana / etc

  LeadsStore(this._demoDataService) {
    _refresh();
    // Listen to demo data changes
    _demoDataService.addListener(_onDemoDataChanged);
  }

  @override
  void dispose() {
    _demoDataService.removeListener(_onDemoDataChanged);
    super.dispose();
  }

  void _onDemoDataChanged() {
    _refresh();
  }

  void setQuery(String q) {
    query = q;
    _refresh();
  }

  void toggleIndustry(String s) {
    industries.toggle(s);
    _refresh();
  }

  void toggleMaterial(String s) {
    materials.toggle(s);
    _refresh();
  }

  void setTurnover(double minCr, double maxCr) {
    minTurnCr = minCr;
    maxTurnCr = maxCr;
    _refresh();
  }

  void setRegion(String r) {
    region = r;
    _refresh();
  }

  void _refresh() {
    _results = _demoDataService.allLeads.where((l) {
      final qOk = query.isEmpty ||
          l.title.toLowerCase().contains(query.toLowerCase()) ||
          l.industry.toLowerCase().contains(query.toLowerCase());
      final iOk = industries.isEmpty || industries.contains(l.industry);
      final mOk = materials.isEmpty || l.materials.any(materials.contains);
      final tOk = l.turnoverCr >= minTurnCr && l.turnoverCr <= maxTurnCr;
      final rOk = (region == 'All') || l.state == region;
      return qOk && iOk && mOk && tOk && rOk;
    }).toList();
    notifyListeners();
  }
}

extension _Toggle<E> on Set<E> {
  void toggle(E e) => contains(e) ? remove(e) : add(e);
}
