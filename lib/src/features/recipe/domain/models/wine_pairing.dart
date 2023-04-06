import 'product_match.dart';

class WinePairing {
  List<dynamic>? pairedWines;
  String? pairingText;
  List<ProductMatch>? productMatches;

  WinePairing({this.pairedWines, this.pairingText, this.productMatches});

  factory WinePairing.fromJson(Map<String, dynamic> json) => WinePairing(
        pairedWines: json['pairedWines'] as List<dynamic>?,
        pairingText: json['pairingText'] as String?,
        productMatches: (json['productMatches'] as List<dynamic>?)
            ?.map((e) => ProductMatch.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'pairedWines': pairedWines,
        'pairingText': pairingText,
        'productMatches': productMatches?.map((e) => e.toJson()).toList(),
      };
}
