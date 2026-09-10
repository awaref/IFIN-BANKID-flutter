import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/totp_account.dart';
import '../providers/authenticator_provider.dart';
import '../providers/timer_provider.dart';
import 'account_preview_screen.dart';
import 'qr_scan_screen.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountNameController = TextEditingController();
  final _issuerController = TextEditingController();
  final _secretController = TextEditingController();
  final _periodController = TextEditingController(text: '30');

  TotpAlgorithm _algorithm = TotpAlgorithm.sha1;
  int _digits = 6;
  String? _errorMessage;
  bool _showAdvanced = false;

  @override
  void dispose() {
    _accountNameController.dispose();
    _issuerController.dispose();
    _secretController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  Future<void> _openQrScan() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
              value: context.read<AuthenticatorProvider>(),
            ),
            ChangeNotifierProvider.value(
              value: context.read<TimerProvider>(),
            ),
          ],
          child: const QrScanScreen(),
        ),
      ),
    );
  }

  Future<void> _submitManual() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final secret = TotpAccount.normalizeSecret(_secretController.text);
    final period = int.tryParse(_periodController.text.trim()) ?? 30;
    final provider = context.read<AuthenticatorProvider>();

    if (provider.isDuplicateSecret(secret)) {
      setState(() => _errorMessage = l10n.authenticatorDuplicateSecret);
      return;
    }

    try {
      TotpAccount.validateFields(
        issuer: _issuerController.text.trim(),
        accountName: _accountNameController.text.trim(),
        secret: secret,
        algorithm: _algorithm,
        digits: _digits,
        period: period,
      );
    } on TotpValidationException catch (e) {
      setState(() => _errorMessage = e.message);
      return;
    }

    final previewAccount = TotpAccount(
      id: const Uuid().v4(),
      issuer: _issuerController.text.trim(),
      accountName: _accountNameController.text.trim(),
      secret: secret,
      algorithm: _algorithm,
      digits: _digits,
      period: period,
    );

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: provider),
            ChangeNotifierProvider.value(value: context.read<TimerProvider>()),
          ],
          child: AccountPreviewScreen(account: previewAccount),
        ),
      ),
    );
  }

  Widget _methodCard({
    required List<List<dynamic>> icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool emphasized = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: emphasized
          ? colorScheme.primary.withValues(alpha: 0.08)
          : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: emphasized
              ? colorScheme.primary.withValues(alpha: 0.45)
              : colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: HugeIcon(
                  icon: icon,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                    ),
                  ],
                ),
              ),
              HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authenticatorAddAccount)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _methodCard(
            icon: HugeIcons.strokeRoundedQrCode01,
            title: l10n.authenticatorScanQr,
            subtitle: l10n.authenticatorScanQrSubtitle,
            onTap: _openQrScan,
            emphasized: true,
          ),
          const SizedBox(height: 28),
          Text(
            l10n.authenticatorManualEntry,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.authenticatorManualEntrySubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _accountNameController,
                  textInputAction: TextInputAction.next,
                  decoration: _fieldDecoration(l10n.authenticatorAccountName),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? l10n.authenticatorRequiredField
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _issuerController,
                  textInputAction: TextInputAction.next,
                  decoration: _fieldDecoration(l10n.authenticatorIssuer),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? l10n.authenticatorRequiredField
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _secretController,
                  textInputAction: TextInputAction.done,
                  decoration: _fieldDecoration(l10n.authenticatorSecretKey),
                  obscureText: true,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? l10n.authenticatorRequiredField
                      : null,
                ),
                const SizedBox(height: 8),
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    initiallyExpanded: _showAdvanced,
                    onExpansionChanged: (expanded) =>
                        setState(() => _showAdvanced = expanded),
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    title: Text(
                      l10n.authenticatorAlgorithm,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    subtitle: Text(
                      '${_algorithm.label} · $_digits · ${_periodController.text}s',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    children: [
                      const SizedBox(height: 8),
                      DropdownButtonFormField<TotpAlgorithm>(
                        initialValue: _algorithm,
                        decoration:
                            _fieldDecoration(l10n.authenticatorAlgorithm),
                        items: TotpAlgorithm.values
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(item.label),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _algorithm = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        initialValue: _digits,
                        decoration: _fieldDecoration(l10n.authenticatorDigits),
                        items: const [
                          DropdownMenuItem(value: 6, child: Text('6')),
                          DropdownMenuItem(value: 8, child: Text('8')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _digits = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _periodController,
                        decoration:
                            _fieldDecoration(l10n.authenticatorPeriod),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        validator: (value) {
                          final parsed = int.tryParse(value ?? '');
                          if (parsed == null || parsed <= 0) {
                            return l10n.authenticatorInvalidPeriod;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: colorScheme.error),
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _submitManual,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(l10n.authenticatorPreviewAccount),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
