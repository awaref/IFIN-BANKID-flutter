import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../data/models/totp_account.dart';
import '../../data/services/totp_service.dart';
import 'countdown_indicator.dart';

class TotpAccountCard extends StatelessWidget {
  const TotpAccountCard({
    super.key,
    required this.account,
    required this.epochSeconds,
    required this.totpService,
    required this.onCopy,
    required this.onEdit,
    required this.onDelete,
  });

  final TotpAccount account;
  final int epochSeconds;
  final TotpService totpService;
  final VoidCallback onCopy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static const _urgentSeconds = 5;

  static String formatCode(String code) {
    if (code.length == 6) {
      return '${code.substring(0, 3)} ${code.substring(3)}';
    }
    if (code.length == 8) {
      return '${code.substring(0, 4)} ${code.substring(4)}';
    }
    return code;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final code = totpService.generateCode(account, epochSeconds);
    final remaining =
        totpService.remainingSeconds(account.period, epochSeconds);
    final progress = totpService.progress(account.period, epochSeconds);
    final isUrgent = remaining <= _urgentSeconds;
    final codeColor = isUrgent ? colorScheme.error : colorScheme.onSurface;
    final initial = account.issuer.isNotEmpty
        ? account.issuer.characters.first.toUpperCase()
        : '?';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isUrgent
              ? colorScheme.error.withValues(alpha: 0.35)
              : colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.issuer,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        account.accountName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Semantics(
                  button: true,
                  label: l10n.authenticatorMoreActions,
                  child: PopupMenuButton<_CardAction>(
                    tooltip: l10n.authenticatorMoreActions,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    onSelected: (action) {
                      switch (action) {
                        case _CardAction.edit:
                          onEdit();
                        case _CardAction.delete:
                          onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: _CardAction.edit,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const HugeIcon(
                            icon: HugeIcons.strokeRoundedEdit02,
                            size: 20,
                          ),
                          title: Text(l10n.authenticatorEditAccount),
                          dense: true,
                        ),
                      ),
                      PopupMenuItem(
                        value: _CardAction.delete,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: HugeIcon(
                            icon: HugeIcons.strokeRoundedDelete01,
                            size: 20,
                            color: colorScheme.error,
                          ),
                          title: Text(
                            l10n.authenticatorDeleteConfirm,
                            style: TextStyle(color: colorScheme.error),
                          ),
                          dense: true,
                        ),
                      ),
                    ],
                    icon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedMoreVertical,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onCopy,
                borderRadius: BorderRadius.circular(12),
                child: Semantics(
                  button: true,
                  label: l10n.authenticatorTapToCopy,
                  value: code,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 180),
                            style: theme.textTheme.headlineMedium!.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              fontFeatures: const [FontFeature.tabularFigures()],
                              color: codeColor,
                            ),
                            // Force LTR so spaced digit groups are not
                            // visually swapped under Arabic RTL locales.
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                formatCode(code),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                          child: IconButton(
                            tooltip: MaterialLocalizations.of(context)
                                .copyButtonLabel,
                            onPressed: onCopy,
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedCopy01,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 180),
                            style: theme.textTheme.titleMedium!.copyWith(
                              color: isUrgent
                                  ? colorScheme.error
                                  : colorScheme.primary,
                              fontWeight: FontWeight.w700,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                            child: Text('${remaining}s'),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            CountdownIndicator(progress: progress, isUrgent: isUrgent),
          ],
        ),
      ),
    );
  }
}

enum _CardAction { edit, delete }
