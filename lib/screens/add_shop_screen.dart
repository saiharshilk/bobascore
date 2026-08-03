import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/shop.dart';
import '../providers/shops_provider.dart';

class AddShopScreen extends ConsumerStatefulWidget {
  const AddShopScreen({super.key});

  @override
  ConsumerState<AddShopScreen> createState() => _AddShopScreenState();
}

class _AddShopScreenState extends ConsumerState<AddShopScreen> {
  static const _predefinedTags = [
    'brown sugar',
    'taro',
    'matcha',
    'fruit tea',
    'milk tea',
    'fruit slush',
    'cheese foam',
    'other',
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _customTagController = TextEditingController();
  final _selectedTags = <String>{};
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _customTagController.dispose();
    super.dispose();
  }

  void _toggleTag(String tag) {
    setState(() {
      if (!_selectedTags.add(tag)) {
        _selectedTags.remove(tag);
      }
    });
  }

  void _addCustomTag() {
    final tag = _customTagController.text.trim();
    if (tag.isEmpty) return;

    setState(() {
      _selectedTags.add(tag);
      _customTagController.clear();
    });
  }

  Future<void> _saveShop() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    final shop = Shop(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      // Coordinates will be populated when map/location picking is added.
      latitude: 0,
      longitude: 0,
      tags: _selectedTags.toList(growable: false),
      status: ShopStatus.wantToTry,
    );

    try {
      await ref.read(shopsProvider.notifier).addShop(shop);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Add a new shop')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Text(
                'Save a spot for your next boba run.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                key: const Key('shopNameField'),
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Shop name',
                  hintText: 'e.g. Taro House',
                  prefixIcon: Icon(Icons.storefront_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a shop name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('addressField'),
                controller: _addressController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  hintText: 'Enter the shop address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter an address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),
              Text(
                'What are you in the mood for?',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose all that apply',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tag in _predefinedTags)
                    FilterChip(
                      label: Text(tag),
                      selected: _selectedTags.contains(tag),
                      onSelected: (_) => _toggleTag(tag),
                      selectedColor: colors.secondaryContainer,
                      checkmarkColor: colors.onSecondaryContainer,
                    ),
                  for (final tag in _selectedTags.where(
                    (tag) => !_predefinedTags.contains(tag),
                  ))
                    InputChip(
                      label: Text(tag),
                      selected: true,
                      onDeleted: () => _toggleTag(tag),
                      selectedColor: colors.tertiaryContainer,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('customTagField'),
                      controller: _customTagController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Add a custom tag',
                        hintText: 'e.g. pudding',
                        prefixIcon: Icon(Icons.sell_outlined),
                      ),
                      onSubmitted: (_) => _addCustomTag(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: IconButton.filledTonal(
                      onPressed: _addCustomTag,
                      tooltip: 'Add custom tag',
                      icon: const Icon(Icons.add),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _isSaving ? null : _saveShop,
                icon: _isSaving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.bookmark_add_outlined),
                label: Text(_isSaving ? 'Saving...' : 'Save shop'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
