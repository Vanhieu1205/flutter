import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../models/category_model.dart' as models;

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Categories'),
          backgroundColor: const Color(0xFF3ACBAB),
          //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          bottom: TabBar(
            indicatorColor: const Color(0xFF3ACBAB),
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black,
            tabs: const [
              Tab(text: 'Income'),
              Tab(text: 'Expense'),
            ],
          ),
        ),
        body: Consumer<CategoryViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.error != null) {
              return Center(child: Text('Error: ${viewModel.error}'));
            }

            return TabBarView(
              children: [
                _CategoryGrid(
                  categories: viewModel.categories
                      .where((category) => category.type == 'income')
                      .toList(),
                ),
                _CategoryGrid(
                  categories: viewModel.categories
                      .where((category) => category.type == 'expense')
                      .toList(),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF3ACBAB),
          foregroundColor: Colors.white,
          onPressed: () {
            Navigator.pushNamed(context, '/addCategory');
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final List<models.Category> categories;

  const _CategoryGrid({required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Center(child: Text('No categories added yet'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/editCategory', arguments: category);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Color(int.parse(category.color)),
                child: const Icon(
                  Icons.category,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
