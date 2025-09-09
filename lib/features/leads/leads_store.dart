import 'package:flutter/foundation.dart';
import '../sell/models.dart';

class LeadsStore extends ChangeNotifier {
  final List<Lead> _all = [];
  List<Lead> _results = [];
  List<Lead> get results => _results;

  String query = '';
  final Set<String> industries = {};
  final Set<String> materials = {};
  double minTurnCr = 0, maxTurnCr = 1000; // 0..1000 Cr
  String region = 'All'; // All / Telangana / etc

  LeadsStore() {
    _seed();
    _refresh();
  }

  void _seed() {
    if (_all.isNotEmpty) return;
    _all.addAll([
      Lead(
          id: 'L1',
          title: 'EPC Contractor — Metro Depot Wiring',
          industry: 'Construction',
          materials: ['Copper', 'PVC'],
          city: 'Hyderabad',
          state: 'Telangana',
          qty: 1200,
          turnoverCr: 85,
          needBy: DateTime.now().add(const Duration(days: 30)),
          status: 'New',
          about: 'Large wiring scope for metro depot.'),
      Lead(
          id: 'L2',
          title: 'MEP Vendor — IT Park',
          industry: 'MEP',
          materials: ['Aluminium', 'XLPE'],
          city: 'Bengaluru',
          state: 'Karnataka',
          qty: 800,
          turnoverCr: 120,
          needBy: DateTime.now().add(const Duration(days: 20)),
          status: 'New',
          about: 'Cables & switchgear for IT park.'),
      Lead(
          id: 'L3',
          title: 'Solar EPC — 5MW',
          industry: 'Solar',
          materials: ['Copper', 'FRLS'],
          city: 'Pune',
          state: 'Maharashtra',
          qty: 500,
          turnoverCr: 60,
          needBy: DateTime.now().add(const Duration(days: 45)),
          status: 'Quoted',
          about: 'Solar balance-of-system needs.'),
      // add more as needed
    ]);
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
    _results = _all.where((l) {
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
