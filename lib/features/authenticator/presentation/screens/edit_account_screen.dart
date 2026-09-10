import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/totp_account.dart';
import '../providers/authenticator_provider.dart';

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key, required this.account});

  final TotpAccount account;

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _accountNameController;
  late final TextEditingController _issuerController;
  late final TextEditingController _secretController;
  late final TextEditingController _periodController;
  late TotpAlgorithm _algorithm;
  late int _digits;
  String? _errorMessage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _accountNameController = TextEditingController(text: widget.account.accountName);
    _issuerController = TextEditingController(text: widget.account.issuer);
    _secretController = TextEditingController(text: widget.account.secret);
    _periodController = TextEditingController(text: widget.account.period.toString());
    _algorithm = widget.account.algorithm;
    _digits = widget.account.digits;
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _issuerController.dispose();
    _secretController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    final secret = TotpAccount.normalizeSecret(_secretController.text);
    final period = int.parse(_periodController.text.trim());
    final provider = context.read<AuthenticatorProvider>();

    if (provider.isDuplicateSecret(secret, exceptId: widget.account.id)) {
      setState(() => _errorMessage = l10n.authenticatorDuplicateSecret);
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await provider.updateAccount(
        widget.account.copyWith(
          issuer: _issuerController.text.trim(),
          accountName: _accountNameController.text.trim(),
          secret: secret,
          algorithm: _algorithm,
          digits: _digits,
          period: period,
        ),
      );
      if (!mounted) return;
      Navigator.pop(context);
    } on DuplicateSecretException {
      setState(() {
        _errorMessage = l10n.authenticatorDuplicateSecret;
        _isSaving = false;
      });
    } on TotpValidationException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isSaving = false;
      });
    } catch (_) {
      setState(() {
        _errorMessage = l10n.authenticatorSaveFailed;
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authenticatorEditAccount)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
              TextFormField(
                controller: _accountNameController,
                decoration: InputDecoration(labelText: l10n.authenticatorAccountName),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? l10n.authenticatorRequiredField : null,
              ),
              TextFormField(
                controller: _issuerController,
                decoration: InputDecoration(labelText: l10n.authenticatorIssuer),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? l10n.authenticatorRequiredField : null,
              ),
              TextFormField(
                controller: _secretController,
                decoration: InputDecoration(labelText: l10n.authenticatorSecretKey),
                obscureText: true,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? l10n.authenticatorRequiredField : null,
              ),
              DropdownButtonFormField<TotpAlgorithm>(
                initialValue: _algorithm,
                decoration: InputDecoration(labelText: l10n.authenticatorAlgorithm),
                items: TotpAlgorithm.values
                    .map((item) => DropdownMenuItem(value: item, child: Text(item.label)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _algorithm = value);
                },
              ),
              DropdownButtonFormField<int>(
                initialValue: _digits,
                decoration: InputDecoration(labelText: l10n.authenticatorDigits),
                items: const [
                  DropdownMenuItem(value: 6, child: Text('6')),
                  DropdownMenuItem(value: 8, child: Text('8')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _digits = value);
                },
              ),
              TextFormField(
                controller: _periodController,
                decoration: InputDecoration(labelText: l10n.authenticatorPeriod),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final parsed = int.tryParse(value ?? '');
                  if (parsed == null || parsed <= 0) return l10n.authenticatorInvalidPeriod;
                  return null;
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.saveChanges),
              ),
            ],
          ),
        ),
        ],
      ),
    );
  }
}
