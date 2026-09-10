import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/totp_account.dart';
import '../providers/authenticator_provider.dart';
import '../providers/timer_provider.dart';
import '../widgets/countdown_indicator.dart';
import '../widgets/totp_account_card.dart';

class AccountPreviewScreen extends StatefulWidget {
  const AccountPreviewScreen({super.key, required this.account});

  final TotpAccount account;

  @override
  State<AccountPreviewScreen> createState() => _AccountPreviewScreenState();
}

class _AccountPreviewScreenState extends State<AccountPreviewScreen> {
  String? _errorMessage;
  bool _isSaving = false;

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<AuthenticatorProvider>();
    if (provider.isDuplicateSecret(widget.account.secret)) {
      setState(() => _errorMessage = l10n.authenticatorDuplicateSecret);
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await provider.addAccount(widget.account);
      if (!mounted) return;
      Navigator.popUntil(context, (route) => route.isFirst);
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
    final provider = context.watch<AuthenticatorProvider>();
    final timer = context.watch<TimerProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final code = provider.totpService.generateCode(
      widget.account,
      timer.epochSeconds,
    );
    final remaining = provider.totpService.remainingSeconds(
      widget.account.period,
      timer.epochSeconds,
    );
    final progress = provider.totpService.progress(
      widget.account.period,
      timer.epochSeconds,
    );
    final isUrgent = remaining <= 5;
    final isDuplicate = provider.isDuplicateSecret(widget.account.secret);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authenticatorPreviewAccount)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.7),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _row(l10n.authenticatorIssuer, widget.account.issuer),
                      _row(
                        l10n.authenticatorAccountName,
                        widget.account.accountName,
                      ),
                      _row(
                        l10n.authenticatorAlgorithm,
                        widget.account.algorithm.label,
                      ),
                      _row(
                        l10n.authenticatorDigits,
                        widget.account.digits.toString(),
                      ),
                      _row(
                        l10n.authenticatorPeriod,
                        '${widget.account.period}s',
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.authenticatorLivePreview,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.45,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 180),
                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            fontFeatures: const [FontFeature.tabularFigures()],
                            color: isUrgent
                                ? colorScheme.error
                                : colorScheme.onSurface,
                          ),
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          TotpAccountCard.formatCode(code),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            '${remaining}s',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: isUrgent
                                      ? colorScheme.error
                                      : colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          l10n.authenticatorTapToCopy,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    CountdownIndicator(
                      progress: progress,
                      isUrgent: isUrgent,
                    ),
                  ],
                ),
              ),
              if (_errorMessage != null || isDuplicate) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage ?? l10n.authenticatorDuplicateSecret,
                  style: TextStyle(color: colorScheme.error),
                ),
              ],
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isSaving || isDuplicate ? null : _save,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(l10n.authenticatorAddAccount),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
