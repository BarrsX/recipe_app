import 'metric.dart';
import 'us.dart';

class Measures {
  Us? us;
  Metric? metric;

  Measures({this.us, this.metric});

  factory Measures.fromJson(Map<String, dynamic> json) => Measures(
        us: json['us'] == null
            ? null
            : Us.fromJson(json['us'] as Map<String, dynamic>),
        metric: json['metric'] == null
            ? null
            : Metric.fromJson(json['metric'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'us': us?.toJson(),
        'metric': metric?.toJson(),
      };
}
