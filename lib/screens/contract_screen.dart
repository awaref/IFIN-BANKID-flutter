import 'dart:typed_data';
import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:bankid_app/models/contract.dart';
import 'package:bankid_app/screens/home_screen.dart';
import 'package:bankid_app/services/api_service.dart';
import 'package:bankid_app/services/biometric_service.dart';
import 'package:bankid_app/config.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:provider/provider.dart';

class SignContractRequest {
  final String signatureType;
  final bool? biometricVerified;
  final String? pinCode;
  final String? certificateId;
  final Map<String, dynamic>? signaturePosition;

  SignContractRequest({
    required this.signatureType,
    this.biometricVerified,
    this.pinCode,
    this.certificateId,
    this.signaturePosition,
  });

  Map<String, dynamic> toJson() {
    return {
      "signature_type": signatureType,
      if (biometricVerified != null)
        "biometric_verified": biometricVerified,
      if (pinCode != null)
        "pin_code": pinCode,
      if (certificateId != null)
        "certificate_id": certificateId,
      if (signaturePosition != null)
        "signature_position": signaturePosition,
    };
  }
}

class ContractScreen extends StatefulWidget {
  final Contract? contract;
  final String? contractId;

  const ContractScreen({super.key, this.contract, this.contractId});

  @override
  State<ContractScreen> createState() => _ContractScreenState();
}

class _ContractScreenState extends State<ContractScreen> {
  Contract? _contract;
  bool _isLoading = false;
  String? _error;
  Uint8List? _pdfBytes;

  final BiometricService _biometricService = BiometricService();

  /// Original biometric check (kept unchanged)
  Future<bool> _verifyAction() async {
    final isEnabled = await _biometricService.isBiometricEnabledByUser();
    if (!isEnabled) return true;

    final isAvailable = await _biometricService.isBiometricAvailable();
    if (!isAvailable) return true;

    return await _biometricService.authenticate(
      reason: AppLocalizations.of(context)!.authenticateReason,
    );
  }

  /// NEW: biometric + refresh token authorization
  Future<bool> _authorizeSensitiveAction() async {
    final apiService = Provider.of<ApiService>(context, listen: false);

    final isEnabled = await _biometricService.isBiometricEnabledByUser();
    if (!isEnabled) return true;

    final isAvailable = await _biometricService.isBiometricAvailable();
    if (!isAvailable) return true;

    final authenticated = await _biometricService.authenticate(
      reason: AppLocalizations.of(context)!.authenticateReason,
    );

    if (!authenticated) return false;

    final refreshToken = await apiService.getStoredRefreshToken();

    if (refreshToken != null) {
      return await apiService.refreshWithToken(refreshToken);
    }

    return false;
  }

  @override
  void initState() {
    super.initState();
    _contract = widget.contract;

    if (_contract == null && widget.contractId != null) {
      _fetchContract();
    } else if (_contract != null) {
      _loadPdfAutomatically();
    }
  }

  Future<void> _fetchContract() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final id = _contract?.id ?? widget.contractId!;
      final fullContract = await apiService.fetchContractById(id);

      setState(() {
        _contract = fullContract;
        _isLoading = false;
      });

      _loadPdfAutomatically();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPdfAutomatically() async {
    if (_contract == null) return;

    String type = _contract!.status.toLowerCase() == 'signed'
        ? 'signed'
        : 'original';

    await _loadPdf(type: type);
  }

  Future<void> _loadPdf({String type = 'original'}) async {
    if (_contract == null) return;

    setState(() => _isLoading = true);

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);

      final pdfUrl =
          '${AppConfig.baseUrl}/contracts/${_contract!.id}/download?type=$type';

      final bytes = await apiService.getBytes(pdfUrl);

      if (mounted) {
        setState(() {
          _pdfBytes = bytes;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("PDF load error: $e");

      if (mounted) {
        setState(() {
          _error = "Failed to load PDF";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            _contract?.title ?? l10n.contractScreenTitle,
            style: const TextStyle(
              color: Color(0xFF1A1D3D),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : _pdfBytes != null
                    ? SfPdfViewer.memory(_pdfBytes!)
                    : const Center(child: Text("No document")),
        bottomNavigationBar:
            (_contract?.status == 'signed' || _contract?.status == 'rejected')
                ? null
                : _buildBottomBar(l10n),
      ),
    );
  }

  Widget _buildBottomBar(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading || _contract == null
                  ? null
                  : () async {
                      final authorized =
                          await _authorizeSensitiveAction();

                      if (authorized && mounted) {
                        _showRejectDialog(l10n);
                      }
                    },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text(l10n.statusRejected),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading || _contract == null
                  ? null
                  : () async {
                      final authorized =
                          await _authorizeSensitiveAction();

                      if (authorized && mounted) {
                        setState(() => _isLoading = true);

                        try {
                          final apiService = Provider.of<ApiService>(
                            context,
                            listen: false,
                          );

                          await apiService.signContract(
                            _contract!.id,
                            SignContractRequest(
                              signatureType: "biometric",
                              biometricVerified: true,
                            ).toJson(),
                          );

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Contract signed successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );

                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const HomeScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            setState(() {
                              _error = e.toString();
                              _isLoading = false;
                            });
                          }
                        }
                      }
                    },
              child: Text(l10n.contractScreenSignContractButton),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showRejectDialog(AppLocalizations l10n) async {
    final TextEditingController reasonController = TextEditingController();

    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.statusRejected),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: 'Reason...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _rejectContract(reasonController.text);
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Future<void> _rejectContract(String reason) async {
    setState(() => _isLoading = true);

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);

      await apiService.rejectContract(_contract!.id, reason);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contract rejected successfully'),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }
}