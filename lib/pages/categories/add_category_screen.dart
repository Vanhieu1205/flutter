import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../models/category_model.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.category;
  String _selectedType = 'income';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      print('Form validated. Attempting to add category.');
      final category = Category(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        type: _selectedType,
        color: _selectedColor.value.toString(),
        icon: _selectedIcon.codePoint.toString(),
      );

      print('Calling addCategory method.');
      context.read<CategoryViewModel>().addCategory(category);
      print('addCategory method called.');
      Navigator.pop(context);
      print('Navigated back.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_selectedType.toUpperCase()} category added successfully!',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADD NEW CATEGORY'),
        backgroundColor: Colors.teal,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedType = 'income';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedType == 'income'
                        ? Colors.teal
                        : Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('INCOME'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedType = 'expense';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedType == 'expense'
                        ? Colors.teal
                        : Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('EXPENSES'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter category name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 0,
              ),
              tileColor: Colors.grey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              title: Text(
                'Color',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              trailing: CircleAvatar(
                backgroundColor: _selectedColor,
                radius: 14,
                child: const Icon(
                  Icons.color_lens,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Select Color'),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: _selectedColor,
                        onColorChanged: (color) {
                          setState(() {
                            _selectedColor = color;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 0,
              ),
              tileColor: Colors.grey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              title: Text(
                'Icon',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              trailing: Icon(_selectedIcon, color: Colors.teal, size: 24),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Select Icon'),
                    content: SingleChildScrollView(
                      child: IconPicker(
                        selectedIcon: _selectedIcon,
                        onIconSelected: (icon) {
                          setState(() {
                            _selectedIcon = icon;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Add Category', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

class ColorPicker extends StatelessWidget {
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;

  const ColorPicker({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((color) {
        return InkWell(
          onTap: () => onColorChanged(color),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: pickerColor == color ? Colors.white : Colors.transparent,
                width: 2,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class IconPicker extends StatelessWidget {
  final IconData selectedIcon;
  final ValueChanged<IconData> onIconSelected;

  const IconPicker({
    super.key,
    required this.selectedIcon,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    final icons = [
      Icons.home,
      Icons.work,
      Icons.shopping_cart,
      Icons.restaurant,
      Icons.directions_car,
      Icons.local_hospital,
      Icons.school,
      Icons.sports_esports,
      Icons.movie,
      Icons.flight,
      Icons.train,
      Icons.directions_bus,
      Icons.local_grocery_store,
      Icons.local_cafe,
      Icons.local_bar,
      Icons.local_pizza,
      Icons.local_pharmacy,
      Icons.local_gas_station,
      Icons.local_atm,
      Icons.local_mall,
      Icons.category,
      Icons.fastfood,
      Icons.shopping_bag,
      Icons.health_and_safety,
      Icons.fitness_center,
      Icons.book,
      Icons.money,
      Icons.attach_money,
      Icons.payments,
      Icons.redeem,
      Icons.savings_sharp,
      Icons.sell,
      Icons.add_business,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: icons.map((icon) {
        return InkWell(
          onTap: () => onIconSelected(icon),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: selectedIcon == icon ? Colors.teal : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: selectedIcon == icon ? Colors.white : Colors.grey[800],
            ),
          ),
        );
      }).toList(),
    );
  }
}
