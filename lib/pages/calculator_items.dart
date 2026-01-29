import 'package:flutter/material.dart';
import 'package:testing/config/theme_config.dart';
import 'package:testing/models/recipe.dart';
import 'package:testing/services/recipe_service.dart';
import 'package:testing/pages/recipe_dashboard_page.dart';

class Calculator_main extends StatefulWidget {
  const Calculator_main({super.key});

  @override
  State<Calculator_main> createState() => _Calculator_mainState();
}

class _Calculator_mainState extends State<Calculator_main> {
  final RecipeService _recipeService = RecipeService();
  List<Recipe> recipes = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ingredientNameController =
      TextEditingController();
  final TextEditingController _ingredientMassController =
      TextEditingController();
  Map<String, double> _currentIngredients = {};

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    final loadedRecipes = await _recipeService.loadRecipes();
    setState(() {
      recipes = loadedRecipes;
    });
  }

  void _addNewRecipe() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Add New Recipe',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Enter recipe name',
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: ThemeConfig.primary.withOpacity(0.2),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _nameController.clear();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.trim().isNotEmpty) {
                  final newRecipe = Recipe(
                    name: _nameController.text.trim(),
                    ingredients: {},
                  );
                  setState(() {
                    recipes.add(newRecipe);
                  });
                  await _recipeService.saveRecipes(recipes);
                  _nameController.clear();
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConfig.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _openRecipeDashboard(Recipe recipe) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RecipeDashboardPage(
          recipe: recipe,
          allRecipes: recipes,
          recipeService: _recipeService,
        ),
      ),
    );
    setState(() {}); // Refresh after returning
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ingredientNameController.dispose();
    _ingredientMassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: recipes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No recipes yet',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add a new recipe',
                    style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        _openRecipeDashboard(recipe);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            // Recipe Icon Container
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: ThemeConfig.primary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.restaurant,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 20),
                            // Recipe Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recipe.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${recipe.ingredients.length} ingredients',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[600],
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Overflow menu for Edit/Delete
                            PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  final controller = TextEditingController(
                                    text: recipe.name,
                                  );
                                  final newName = await showDialog<String>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Edit Recipe Name'),
                                      content: TextField(
                                        controller: controller,
                                        decoration: const InputDecoration(
                                          labelText: 'Recipe Name',
                                        ),
                                        autofocus: true,
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            final name = controller.text.trim();
                                            if (name.isNotEmpty) {
                                              Navigator.of(context).pop(name);
                                            }
                                          },
                                          child: const Text('Save'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (newName != null && newName.isNotEmpty) {
                                    setState(() {
                                      recipes[index] = Recipe(
                                        name: newName,
                                        ingredients: recipe.ingredients.map(
                                          (key, value) => MapEntry(key, {
                                            'mass': value['mass'],
                                            'name': value['name'] ?? key,
                                          }),
                                        ),
                                      );
                                    });
                                    await _recipeService.saveRecipes(recipes);
                                  }
                                } else if (value == 'delete') {
                                  setState(() {
                                    recipes.removeAt(index);
                                  });
                                  await _recipeService.saveRecipes(recipes);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: ThemeConfig.primary.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _addNewRecipe,
          backgroundColor: ThemeConfig.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}
