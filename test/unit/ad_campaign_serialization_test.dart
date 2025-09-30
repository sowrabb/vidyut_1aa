import 'package:flutter_test/flutter_test.dart';
import 'package:vidyut/features/sell/models.dart';

void main() {
  test('AdCampaign serialization round-trip', () {
    final ad = AdCampaign(
      id: 'ad123',
      type: AdType.product,
      term: '1',
      slot: 2,
      productId: '1',
      productTitle: 'Copper Cable 1.5sqmm',
      productThumbnail: 'http://example.com/img.png',
    );

    final json = ad.toJson();
    final parsed = AdCampaign.fromJson(json);

    expect(parsed.id, ad.id);
    expect(parsed.type, ad.type);
    expect(parsed.term, ad.term);
    expect(parsed.slot, ad.slot);
    expect(parsed.productId, ad.productId);
    expect(parsed.productTitle, ad.productTitle);
    expect(parsed.productThumbnail, ad.productThumbnail);
  });
}
