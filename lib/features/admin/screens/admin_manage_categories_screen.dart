import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminManageCategoriesScreen extends StatefulWidget {
  const AdminManageCategoriesScreen({super.key});

  @override
  AdminManageCategoriesScreenState createState() =>
      AdminManageCategoriesScreenState();
}

class AdminManageCategoriesScreenState
    extends State<AdminManageCategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final CollectionReference _categoriesCollection =
      FirebaseFirestore.instance.collection('categories');
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  String _convertToTitleCase(String text) {
    if (text.isEmpty) {
      return text;
    }
    return text.trim().split(RegExp(r'\s+')).map((word) {
      if (word.isEmpty) {
        return '';
      }
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  void _showCategoryBottomSheet(
      {String? id, String? existingCategory, List<String>? currentNames}) {
    _categoryController.text = existingCategory ?? '';
    final isEditing = id != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit Category' : 'Add Category',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _categoryController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Category Name',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        BorderSide(color: Colors.blue[600]!, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[200]!),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Cancel',
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () async {
                          final parsedName =
                              _convertToTitleCase(_categoryController.text);
                          if (parsedName.isEmpty) {
                            return;
                          }

                          if (currentNames != null &&
                              currentNames.contains(parsedName.toLowerCase()) &&
                              parsedName.toLowerCase() !=
                                  existingCategory?.toLowerCase()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Category already exists.'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

// Cache Navigator state safely before the async gap block
                          final navigator = Navigator.of(context);

                          if (isEditing) {
                            await _categoriesCollection.doc(id).update({
                              'name': parsedName,
                              'updatedAt': FieldValue.serverTimestamp(),
                            });
                          } else {
                            await _categoriesCollection.add({
                              'name': parsedName,
                              'createdAt': FieldValue.serverTimestamp(),
                              'updatedAt': FieldValue.serverTimestamp(),
                            });
                          }

                          _categoryController.clear();
                          navigator.pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteBottomSheet(String id) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 24),
              const Text(
                'Delete Category?',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                'This action cannot be undone.',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[200]!),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Cancel',
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () async {
// Cache Navigator state safely before the async gap block
                          final navigator = Navigator.of(context);

                          await _categoriesCollection.doc(id).delete();

                          navigator.pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Delete',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _categoryController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _categoriesCollection.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildErrorState();
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerLoading();
            }

            final docs = snapshot.data?.docs ?? [];

            final allCategories = docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>?;
              return {
                "id": doc.id,
                "name": data?["name"]?.toString() ?? "N/A",
              };
            }).toList();

            allCategories.sort((a, b) {
              final nameA = (a["name"] ?? "").toLowerCase();
              final nameB = (b["name"] ?? "").toLowerCase();
              return nameA.compareTo(nameB);
            });

            final validationNamesList = allCategories
                .map((c) => (c["name"] ?? "").toLowerCase())
                .toList();

            final filteredCategories = allCategories.where((category) {
              final name = (category["name"] ?? "").toLowerCase();
              return name.contains(_searchQuery);
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Manage Categories",
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${allCategories.length} Categories",
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 10,
                            offset: Offset(0, 4))
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: "Search categories...",
                        hintStyle:
                            TextStyle(color: Colors.grey[400], fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 15),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear,
                                    color: Colors.grey[400], size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  FocusScope.of(context).unfocus();
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showCategoryBottomSheet(
                            currentNames: validationNamesList);
                      },
                      icon:
                          const Icon(Icons.add, size: 20, color: Colors.white),
                      label: const Text("Add Category",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: allCategories.isEmpty
                      ? _buildGlobalEmptyState()
                      : filteredCategories.isEmpty
                          ? _buildSearchEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              itemCount: filteredCategories.length,
                              itemBuilder: (context, index) {
                                final item = filteredCategories[index];
                                return CategoryListItem(
                                  name: item["name"] ?? "N/A",
                                  // Handled type check safely
                                  onEdit: () {
                                    _showCategoryBottomSheet(
                                      id: item["id"],
                                      existingCategory: item["name"],
                                      currentNames: validationNamesList,
                                    );
                                  },
                                  onDelete: () {
                                    final id = item["id"];
                                    if (id != null) {
                                      _showDeleteBottomSheet(id);
                                    }
                                  },
                                );
                              },
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("📂", style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          const Text("No categories found",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 4),
          Text("Try another search query.",
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildGlobalEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("📂", style: TextStyle(fontSize: 44)),
          const SizedBox(height: 14),
          const Text("No Categories",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 6),
          Text('Tap "Add Category" to create one.',
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("⚠", style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          const Text("Unable to load categories",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {});
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            child: const Text("Retry", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 180, height: 28, color: Colors.grey[200]),
          const SizedBox(height: 6),
          Container(width: 80, height: 16, color: Colors.grey[200]),
          const SizedBox(height: 20),
          Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16))),
          const SizedBox(height: 14),
          Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16))),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: 4,
              itemBuilder: (_, __) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  height: 92,
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CategoryListItem extends StatefulWidget {
  final String name; // Ensured explicit non-nullable variable signatures
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CategoryListItem({
    required this.name,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  @override
  State<CategoryListItem> createState() => _CategoryListItemState();
}

class _CategoryListItemState extends State<CategoryListItem> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    final avatarLetter =
        widget.name.isNotEmpty ? widget.name[0].toUpperCase() : "?";

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isTapped = true);
      },
      onTapUp: (_) {
        setState(() => _isTapped = false);
      },
      onTapCancel: () {
        setState(() => _isTapped = false);
      },
      child: AnimatedScale(
        scale: _isTapped ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 92,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x04000000),
                spreadRadius: 1,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    avatarLetter,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blue[700]),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 3,
                  onSelected: (value) {
                    if (value == 'edit') {
                      widget.onEdit();
                    } else if (value == 'delete') {
                      widget.onDelete();
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined,
                              size: 18, color: Colors.blue[600]),
                          const SizedBox(width: 10),
                          const Text('Edit',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded,
                              size: 18, color: Colors.red[600]),
                          const SizedBox(width: 10),
                          const Text('Delete',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
