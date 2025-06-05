import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/category_viewmodel.dart'; // Adjust the import path as necessary
import '../../models/category_model.dart'
    as models; // Import AddCategoryScreen for ColorPicker and IconPicker

class EditCategoryScreen extends StatefulWidget {
  final models.Category category;

  const EditCategoryScreen({super.key, required this.category});

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late Color _selectedColor;
  late IconData _selectedIcon;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _selectedColor = Color(int.parse(widget.category.color));
    _selectedIcon =
        Icons.category; // Use a constant icon instead of dynamic IconData
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _deleteCategory() async {
    // Add confirmation dialog
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this category?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(false), // Dismiss and return false
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(true), // Dismiss and return true
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      context.read<CategoryViewModel>().deleteCategory(widget.category.id);
      Navigator.pop(context); // Pop edit screen after deleting
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category deleted successfully!')),
      );
      // Depending on the desired flow, you might want to pop the Category Management screen too
      // Navigator.pop(context);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final updatedCategory = models.Category(
        id: widget.category.id,
        name: _nameController.text.trim(), // Trim whitespace
        type: widget.category.type,
        color: _selectedColor.value.toString(),
        icon: _selectedIcon.codePoint.toString(),
      );

      context.read<CategoryViewModel>().updateCategory(updatedCategory);
      Navigator.pop(context); // Pop edit screen after saving
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category updated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EDIT CATEGORY'), // Updated title
        backgroundColor: Colors.teal, // Consistent AppBar color
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.white,
            ), // Styled delete icon
            onPressed: _deleteCategory,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24), // Increased padding
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Category Name', // Updated label
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0), // Rounded corners
                  borderSide: BorderSide.none, // No border line
                ),
                filled: true,
                fillColor: Colors.grey[200], // Light grey background
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ), // Adjust padding
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter category name'; // Updated validation message
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              // Style the ListTile to look like the other input fields
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 0,
              ), // Adjust padding
              tileColor: Colors.grey[200], // Light grey background
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ), // Rounded corners
              title: Text(
                'Color',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ), // Styled label
              trailing: CircleAvatar(
                backgroundColor: _selectedColor,
                radius: 14, // Adjust size
                child: const Icon(
                  Icons.color_lens,
                  color: Colors.white,
                  size: 18,
                ), // Adjust icon size
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Select Color'), // Updated title
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
              // Style the ListTile to look like the other input fields
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 0,
              ), // Adjust padding
              tileColor: Colors.grey[200], // Light grey background
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ), // Rounded corners
              title: Text(
                'Icon',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ), // Styled label
              trailing: Icon(
                _selectedIcon,
                color: Colors.teal,
                size: 24,
              ), // Styled icon
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Select Icon'), // Updated title
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
                backgroundColor: Colors.teal, // Button color
                foregroundColor: Colors.white, // Text color
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                ), // Adjust padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0), // Rounded corners
                ),
                minimumSize: const Size(
                  double.infinity,
                  50,
                ), // Full width button
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(fontSize: 18),
              ), // Updated label and size
            ),
            const SizedBox(height: 16), // Space between buttons
            OutlinedButton(
              onPressed: _deleteCategory,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red, // Text color
                side: const BorderSide(color: Colors.red), // Border color
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                minimumSize: const Size(
                  double.infinity,
                  50,
                ), // Full width button
              ),
              child: const Text(
                'Delete Category',
                style: TextStyle(fontSize: 18),
              ), // Updated label and size
            ),
          ],
        ),
      ),
    );
  }
}

// Keep ColorPicker and IconPicker as they are
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
              color: selectedIcon == icon
                  ? Colors.teal.withOpacity(0.1)
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: selectedIcon == icon ? Colors.teal : Colors.transparent,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: selectedIcon == icon ? Colors.teal : Colors.grey,
            ),
          ),
        );
      }).toList(),
    );
  }
}
