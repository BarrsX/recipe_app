class Instruction {
  final int? number;
  final String? step;
  final List<Equipment>? equipment;
  final List<Ingredient>? ingredients;
  final Length? length;

  Instruction({
    this.number,
    this.step,
    this.equipment,
    this.ingredients,
    this.length,
  });

  factory Instruction.fromJson(Map<String, dynamic> json) {
    return Instruction(
      number: json['number'],
      step: json['step'],
      ingredients: json['ingredients'] != null
          ? List<Ingredient>.from(
              json['ingredients'].map((x) => Ingredient.fromJson(x)))
          : [],
      equipment:
          json['equipment'] != null && json['equipment'].toString().isNotEmpty
              ? List<Equipment>.from(
                  json['equipment'].map((x) => Equipment.fromJson(x)))
              : [],
    );
  }
}

class Equipment {
  final int? id;
  final String? image;
  final String? name;
  final Temperature? temperature;

  Equipment({this.id, this.image, this.name, this.temperature});

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'],
      image: json['image'],
      name: json['name'],
      temperature: json['temperature'] != null ? Temperature.fromJson(json['temperature']) : null,
    );
  }
}

class Temperature {
  final double? number;
  final String? unit;

  Temperature({this.number, this.unit});

  factory Temperature.fromJson(Map<String, dynamic> json) {
    return Temperature(
      number: json['number'],
      unit: json['unit'],
    );
  }
}

class Ingredient {
  final int? id;
  final String? image;
  final String? name;
  final String? original;

  Ingredient({this.id, this.image, this.name, this.original});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'],
      image: json['image'],
      name: json['name'],
      original: json['original'],
    );
  }
}

class Length {
  final double? number;
  final String? unit;

  Length({this.number, this.unit});

  factory Length.fromJson(Map<String, dynamic> json) {
    return Length(
      number: json['number'],
      unit: json['unit'],
    );
  }
}
