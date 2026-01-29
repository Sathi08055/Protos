class Recipe {
  final String name;
  // Map of foodId -> { 'mass': double, 'name': String, 'nut_per_100g': Map<String, dynamic> }
  final Map<String, Map<String, dynamic>> ingredients;

  Recipe({required this.name, required this.ingredients});

  Map<String, dynamic> toJson() => {'name': name, 'ingredients': ingredients};

  factory Recipe.fromJson(Map<String, dynamic> json) {
    Map<String, Map<String, dynamic>> ingredients = {};
    if (json['ingredients'] != null) {
      (json['ingredients'] as Map<String, dynamic>).forEach((key, value) {
        if (value is Map<String, dynamic>) {
          ingredients[key] = {
            'mass': (value['mass'] as num).toDouble(),
            'name': value['name'] as String? ?? key,
            'nut_per_100g':
                value['nut_per_100g'] as Map<String, dynamic>? ?? {},
          };
        } else if (value is num) {
          // Backward compatibility: only mass stored
          ingredients[key] = {
            'mass': value.toDouble(),
            'name': key,
            'nut_per_100g': {},
          };
        }
      });
    }
    return Recipe(name: json['name'] as String, ingredients: ingredients);
  }
}
