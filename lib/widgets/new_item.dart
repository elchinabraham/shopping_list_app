import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/category.dart';
import 'package:shopping_list_app/models/category.dart';

import 'package:http/http.dart' as http;

import '../models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var enteredName = '';
  var enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;
  var isLoaing = false;

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        isLoaing = true;
      });

      // save data in firebase real time database
      final url = Uri.https(
        'flutter-prop-2ed83-default-rtdb.firebaseio.com',
        'shopping-list.json',
      );
      final response = await http.post(
        url,
        headers: {
          'content-Type': 'application/json',
        },
        body: json.encode(
          {
            'name': enteredName,
            'quantity': enteredQuantity,
            'category': _selectedCategory.title,
          },
        ),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      print(response.body);
      print(response.statusCode);

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop(GroceryItem(
        id: responseData['name'],
        name: enteredName,
        quantity: enteredQuantity,
        category: _selectedCategory,
      ));
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text('Name'),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Name mush be 1 and 50 characters';
                  }

                  return null;
                },
                onSaved: (value) {
                  enteredName = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      initialValue: '$enteredQuantity',
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value)! <= 0) {
                          return 'Quantity should not be empty';
                        }

                        return null;
                      },
                      onSaved: (value) {
                        enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(width: 6),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        _selectedCategory = value!;
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isLoaing ? null : _resetForm,
                    child: const Text('Reset'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _saveItem,
                    child: isLoaing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Save Item'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
