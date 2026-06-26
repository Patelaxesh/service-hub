import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final TextEditingController _categoryController = TextEditingController();
  final CollectionReference _categoriesCollection =
      FirebaseFirestore.instance.collection('categories');

  void _addOrEditCategory({String? id, String? existingCategory}) {
    _categoryController.text = existingCategory ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              Text(existingCategory == null ? 'Add Category' : 'Edit Category'),
          content: TextField(
            controller: _categoryController,
            decoration: const InputDecoration(hintText: 'Enter category name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                String categoryName = _categoryController.text.trim();
                if (categoryName.isNotEmpty) {
                  if (id == null) {
                    // Add new category
                    await _categoriesCollection.add({'name': categoryName});
                  } else {
                    // Update existing category
                    await _categoriesCollection
                        .doc(id)
                        .update({'name': categoryName});
                  }
                }
                _categoryController.clear();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
              ),
              child: Text(
                existingCategory == null ? 'Add' : 'Update',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteCategory(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Category'),
          content: const Text(
            'Are you sure you want to delete this category?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await _categoriesCollection.doc(id).delete();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
              ),
              child: const Text(
                'Delete',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        backgroundColor: Colors.lightBlue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _categoriesCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No categories found.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              ),
            );
          }

          final categories = snapshot.data!.docs;

          // Sort categories alphabetically by name
          categories.sort((a, b) {
            final nameA = a['name'].toString().toLowerCase();
            final nameB = b['name'].toString().toLowerCase();
            return nameA.compareTo(nameB);
          });

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final categoryName = category['name'];

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 4.0,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(
                    categoryName,
                    style: const TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _addOrEditCategory(
                            id: category.id, existingCategory: categoryName),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteCategory(category.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditCategory(),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
