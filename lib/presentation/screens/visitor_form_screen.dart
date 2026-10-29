import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visitor_management/common/widgets/custom_drop_down.dart';
import 'package:visitor_management/core/constants.dart';
import 'package:visitor_management/domain/entities/visitor_entity.dart';
import 'package:visitor_management/presentation/providers/visitor_providers.dart';
import 'package:visitor_management/common/utils/ui_helpers.dart';
import 'package:visitor_management/common/widgets/custom_button.dart';
import 'package:visitor_management/common/widgets/custom_text_field.dart';

import 'visitor_details_screen.dart';

class VisitorFormScreen extends ConsumerStatefulWidget {
  const VisitorFormScreen({super.key, this.visitor});
  final VisitorEntity? visitor;

  @override
  ConsumerState<VisitorFormScreen> createState() => _VisitorFormScreenState();
}

class _VisitorFormScreenState extends ConsumerState<VisitorFormScreen> {
  static final RegExp _emailPattern = RegExp(
    r'^[\w.+\-]+@[\w\-]+(\.[\w\-]+)+$',
  );

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _mobile;
  late final TextEditingController _email;
  late final TextEditingController _purpose;
  String? _type;
  String? _project;
  bool _saving = false;

  bool get _isEdit => widget.visitor != null;

  @override
  void initState() {
    super.initState();
    final v = widget.visitor;
    _name = TextEditingController(text: v?.name);
    _mobile = TextEditingController(text: v?.mobile);
    _email = TextEditingController(text: v?.email);
    _purpose = TextEditingController(text: v?.purpose);
    if (v != null) {
      _type = visitorTypes.contains(v.visitorType) ? v.visitorType : null;
      _project = projects.contains(v.project) ? v.project : null;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _mobile.dispose();
    _email.dispose();
    _purpose.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (_saving || !_formKey.currentState!.validate()) return;

    final notifier = ref.read(visitorListProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final email = _email.text.trim();
    final draft = VisitorDraft(
      name: _name.text.trim(),
      mobile: _mobile.text.trim(),
      email: email.isEmpty ? null : email,
      visitorType: _type!,
      project: _project!,
      purpose: _purpose.text.trim(),
    );

    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await notifier.updateDetails(widget.visitor!.id, draft);
        showSnack(messenger, 'Visitor updated successfully');
        navigator.pop();
      } else {
        final created = await notifier.register(draft);
        showSnack(
          messenger,
          'Visitor registered successfully (ID: ${created.id})',
        );
        // Details screen shows the freshly generated QR code.
        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (_) => VisitorDetailsScreen(visitorId: created.id),
          ),
        );
      }
    } catch (e) {
      showSnack(messenger, errorMessage(e), isError: true);
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Visitor' : 'Register Visitor'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  required: true,
                  controller: _name,
                  label: 'Visitor Name',
                  icon: Icons.person_outline,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Visitor name is required'
                      : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  required: true,
                  controller: _mobile,
                  label: 'Mobile Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return 'Mobile number is required';
                    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return 'Enter exactly 10 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _email,
                  label: 'Email (optional)',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return null;
                    return _emailPattern.hasMatch(value)
                        ? null
                        : 'Enter a valid email address';
                  },
                ),
                const SizedBox(height: 16),
                AppDropdownField<String>(
                  required: true,
                  value: _type,
                  isExpanded: true,
                  items: visitorTypes,
                  onChanged: (v) => setState(() => _type = v),
                  validator: (v) => v == null ? 'Select a visitor type' : null,
                  label: 'Visitor Type',
                ),
                const SizedBox(height: 16),
                AppDropdownField<String>(
                  required: true,
                  value: _project,
                  isExpanded: true,
                  items: projects,
                  onChanged: (v) => setState(() => _project = v),
                  validator: (v) => v == null ? 'Select a project' : null,
                  label: 'Project',
                ),
                const SizedBox(height: 16),
                AppTextField(
                  required: true,
                  controller: _purpose,
                  label: 'Purpose of Visit',
                  icon: Icons.edit_note,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  maxLines: 2,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Purpose of visit is required'
                      : null,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Cancel',
                        type: AppButtonType.outlined,
                        onPressed: _saving
                            ? null
                            : () => context.pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: _isEdit ? 'Save Changes' : 'Save',
                        icon: Icons.check,
                        isLoading: _saving,
                        onPressed: _save,
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
