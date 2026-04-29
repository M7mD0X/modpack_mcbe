import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/modpack_service.dart';
import '../theme/app_theme.dart';

class CreateModpackScreen extends StatefulWidget {
  const CreateModpackScreen({super.key});

  @override
  State<CreateModpackScreen> createState() => _CreateModpackScreenState();
}

class _CreateModpackScreenState extends State<CreateModpackScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createModpack() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCreating = true);

    try {
      final modpackService = context.read<ModpackService>();
      await modpackService.createModpack(
        _nameController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isCreating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to create modpack'),
            backgroundColor: AppTheme.destructive,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Create Modpack'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.create_new_folder_rounded,
                    size: 40,
                    color: AppTheme.accent.withOpacity(0.6),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingXl),

              // Name field
              Text(
                'Name',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AppTheme.spacingSm),
              TextFormField(
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  if (value.trim().length > 50) {
                    return 'Name must be under 50 characters';
                  }
                  return null;
                },
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppTheme.spacingLg),

              // Description field
              Text(
                'Description (optional)',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AppTheme.spacingSm),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                maxLength: 200,
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value != null && value.trim().length > 200) {
                    return 'Description must be under 200 characters';
                  }
                  return null;
                },
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppTheme.spacingXxl),

              // Create button
              FilledButton(
                onPressed: _isCreating ? null : _createModpack,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
                ),
                child: _isCreating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.textOnPrimary,
                        ),
                      )
                    : const Text(
                        'Create Modpack',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
