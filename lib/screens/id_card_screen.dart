// import 'package:flutter/material.dart';
// import 'package:hugeicons/hugeicons.dart';
// import 'package:bankid_app/config.dart';
// import 'package:bankid_app/services/api_service.dart';
// import 'package:bankid_app/services/auth_repository.dart';
// import 'package:bankid_app/l10n/app_localizations.dart';

// class IDCardScreen extends StatefulWidget {
//   const IDCardScreen({super.key});

//   @override
//   State<IDCardScreen> createState() => _IDCardScreenState();
// }

// class _IDCardScreenState extends State<IDCardScreen> {
//   late Future<Map<String, dynamic>> _userFuture;

//   @override
//   void initState() {
//     super.initState();
//     _userFuture = _fetchUser();
//   }

//   Future<Map<String, dynamic>> _fetchUser() async {
//     final apiService = ApiService(baseUrl: AppConfig.baseUrl);
//     final authRepository = AuthRepository(apiService: apiService);
//     return await authRepository.fetchCurrentUser();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final l10n = AppLocalizations.of(context)!;
//     final screenWidth = MediaQuery.of(context).size.width;
//     final profileSize = (screenWidth * 0.35 > 190 ? 190 : screenWidth * 0.35)
//         .toDouble();

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFD01F39),
//         foregroundColor: Colors.white,
//       ),
//       backgroundColor: const Color(0xFFEFEEF5),
//       body: FutureBuilder<Map<String, dynamic>>(
//         future: _userFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(
//               child: Text("${l10n.failedToLoadUserData}: ${snapshot.error}"),
//             );
//           }
//           if (!snapshot.hasData) {
//             return Center(child: Text(l10n.noUserDataFound));
//           }

//           final user = snapshot.data!;
//           final firstName = user['first_name'] ?? '';
//           final lastName = user['last_name'] ?? '';
//           final nationalId = user['national_id'] ?? '';
//           final kycStatus = user['kyc_status'] ?? '';
//           final isVerified = kycStatus.toString().toLowerCase() == "approved";

//           return SingleChildScrollView(
//             child: Column(
//               children: [
//                 // Header section
//                 Container(
//                   width: double.infinity,
//                   height: 130,
//                   color: const Color(0xFFD01F39),
//                 ),

//                 // Card containers
//                 Transform.translate(
//                   offset: const Offset(0, -60),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Column(
//                       children: [
//                         // ===== First white container =====
//                         Stack(
//                           clipBehavior: Clip.none,
//                           alignment: Alignment.topCenter,
//                           children: [
//                             Container(
//                               width: double.infinity,
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(16),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withAlpha(
//                                       (0.05 * 255).round(),
//                                     ),
//                                     blurRadius: 8,
//                                     offset: const Offset(0, 4),
//                                   ),
//                                 ],
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 16,
//                                   vertical: 24,
//                                 ),
//                                 child: Column(
//                                   children: [
//                                     const SizedBox(height: 140),
//                                     Text(
//                                       "$firstName $lastName",
//                                       style: const TextStyle(
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.w500,
//                                         color: Color(0xFF212B36),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 6),
//                                     Text(
//                                       "${l10n.nationalIdNumberLabel}: $nationalId",
//                                       style: const TextStyle(
//                                         fontSize: 16,
//                                         color: Color(0xFF637381),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 10),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         HugeIcon(
//                                           icon: isVerified
//                                               ? HugeIcons
//                                                     .strokeRoundedCheckmarkBadge01
//                                               : HugeIcons.strokeRoundedAlert02,
//                                           size: 20,
//                                           color: isVerified
//                                               ? const Color(0xFF10B67E)
//                                               : Colors.orange,
//                                         ),
//                                         const SizedBox(width: 6),
//                                         Text(
//                                           isVerified
//                                               ? l10n.accountVerifiedAccount
//                                               : l10n.accountKycPending,
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                             color: isVerified
//                                                 ? const Color(0xFF10B67E)
//                                                 : Colors.orange,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             Positioned(
//                               top: 8,
//                               right: 0,
//                               child: Image.asset(
//                                 'assets/images/oman_emblem.png',
//                                 width: 194,
//                               ),
//                             ),
//                             // Profile image
//                             Positioned(
//                               top: -47,
//                               child: Container(
//                                 width: profileSize,
//                                 height: profileSize,
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   border: Border.all(
//                                     color: Colors.white,
//                                     width: 3,
//                                   ),
//                                   image: const DecorationImage(
//                                     image: AssetImage(
//                                       'assets/images/selfie_placeholder.png',
//                                     ),
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 16),

//                         // ===== Second white container =====
//                         // Container(
//                         //   width: double.infinity,
//                         //   decoration: BoxDecoration(
//                         //     color: Colors.white,
//                         //     borderRadius: BorderRadius.circular(16),
//                         //     boxShadow: [
//                         //       BoxShadow(
//                         //         color: Colors.black.withAlpha((0.05 * 255).round()),
//                         //         blurRadius: 8,
//                         //         offset: const Offset(0, 4),
//                         //       ),
//                         //     ],
//                         //   ),
//                         //   child: Padding(
//                         //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//                         //     child: Container(
//                         //       decoration: BoxDecoration(
//                         //         color: const Color(0xFFF9FAFB),
//                         //         borderRadius: BorderRadius.circular(12),
//                         //       ),
//                         //       child: Padding(
//                         //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//                         //         child: Column(
//                         //           children: [
//                         //             Container(
//                         //               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                         //               decoration: BoxDecoration(
//                         //                 color: const Color(0xFFD01F39).withAlpha((0.12 * 255).round()),
//                         //                 borderRadius: BorderRadius.circular(28),
//                         //               ),
//                         //               child: Text(
//                         //                 l10n.idCardScanUsingDigitalIdApp,
//                         //                 style: const TextStyle(
//                         //                   fontSize: 14,
//                         //                   color: Color(0xFFEF4444),
//                         //                   fontWeight: FontWeight.w500,
//                         //                 ),
//                         //               ),
//                         //             ),
//                         //             const SizedBox(height: 16),
//                         //             QrImageView(
//                         //               data: l10n.idCardQrData,
//                         //               version: QrVersions.auto,
//                         //               size: 130.0,
//                         //             ),
//                         //             const SizedBox(height: 16),
//                         //             Text(
//                         //               l10n.idCardShareViaQrCode,
//                         //               textAlign: TextAlign.center,
//                         //               style: const TextStyle(
//                         //                 fontSize: 12,
//                         //                 color: Colors.black54,
//                         //               ),
//                         //             ),
//                         //           ],
//                         //         ),
//                         //       ),
//                         //     ),
//                         //   ),
//                         // ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:bankid_app/config.dart';
import 'package:bankid_app/services/api_service.dart';
import 'package:bankid_app/services/auth_repository.dart';
import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:bankid_app/core/utils/country_utils.dart';

class IDCardScreen extends StatefulWidget {
  const IDCardScreen({super.key});

  @override
  State<IDCardScreen> createState() => _IDCardScreenState();
}

class _IDCardScreenState extends State<IDCardScreen> {
  late Future<Map<String, dynamic>> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUser();
  }

  Future<Map<String, dynamic>> _fetchUser() async {
    final apiService = ApiService(baseUrl: AppConfig.baseUrl);
    final authRepository = AuthRepository(apiService: apiService);
    return authRepository.fetchCurrentUser();
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  Widget _buildInfoRow(String label, String value, String colorHex) {
    if (value.trim().isEmpty || value == '-') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: TextStyle(
              fontSize: 14,
              color: _hexToColor(colorHex),
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: _hexToColor("#212B36"),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  bool _isKycApproved(dynamic status) {
    final s = status.toString().toLowerCase();

    const approvedStatuses = [
      "approved",
      "verified",
      "completed",
      "success",
      "active",
    ];

    return approvedStatuses.contains(s) || status == true;
  }

  bool _isKycRejected(dynamic status) {
    final s = status.toString().toLowerCase();

    const rejectedStatuses = [
      "rejected",
      "declined",
      "failed",
      "blocked",
    ];

    return rejectedStatuses.contains(s);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final screenWidth = MediaQuery.of(context).size.width;
    final profileSize =
        (screenWidth * 0.35 > 190 ? 190 : screenWidth * 0.35).toDouble();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD01F39),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFEFEEF5),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("${l10n.failedToLoadUserData}: ${snapshot.error}"),
            );
          }

          if (!snapshot.hasData) {
            return Center(child: Text(l10n.noUserDataFound));
          }

          final response = snapshot.data!;
          final user = response['user'] ?? response;

          final firstName = user['first_name'] ?? '';
          final lastName = user['last_name'] ?? '';
          final nationalId = user['national_id'] ?? '';
          final kycStatus = user['kyc_status'];

          final isVerified = _isKycApproved(kycStatus);
          final isRejected = _isKycRejected(kycStatus);

          final bank = response['bank_tenant'] ?? user['bank_tenant'] ?? {};
          final bankName = bank['name'] ?? '';

          const primaryColorHex = '#D01F39';
          const secondaryColorHex = '#637381';

          final phone = user['phone'] ?? '';
          final rawNationality = user['nationality'] ?? '';

          final nationality = CountryUtils.getCountryName(
            rawNationality,
            locale: Localizations.localeOf(context).languageCode,
          );

          final accounts = user['accounts'] as List<dynamic>? ?? [];
          final primaryAccount = accounts.isNotEmpty ? accounts.first : {};

          final accountNumber = primaryAccount['account_number'] ?? '';
          final balance = primaryAccount['balance']?.toString() ?? '';
          final currency = primaryAccount['currency'] ?? '';

          /// STATUS UI
          List<List<dynamic>> statusIcon;
          Color statusColor;
          String statusText;

          if (isVerified) {
            statusIcon = HugeIcons.strokeRoundedCheckmarkBadge01;
            statusColor = const Color(0xFF10B67E);
            statusText = l10n.accountVerifiedAccount;
          } else if (isRejected) {
            statusIcon = HugeIcons.strokeRoundedCancelCircle;
            statusColor = Colors.red;
            statusText = "KYC Rejected";
          } else {
            statusIcon = HugeIcons.strokeRoundedAlert02;
            statusColor = Colors.orange;
            statusText = l10n.accountKycPending;
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 130,
                  color: _hexToColor(primaryColorHex),
                ),

                Transform.translate(
                  offset: const Offset(0, -60),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topCenter,
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(
                                      (0.05 * 255).round(),
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 24,
                                ),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 140),

                                    Text(
                                      "$firstName $lastName",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: _hexToColor("#212B36"),
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    _buildInfoRow(
                                      l10n.nationalIdNumberLabel,
                                      nationalId,
                                      secondaryColorHex,
                                    ),
                                    _buildInfoRow(
                                      l10n.bankNameLabel,
                                      bankName,
                                      secondaryColorHex,
                                    ),
                                    _buildInfoRow(
                                      l10n.accountNumberLabel,
                                      accountNumber,
                                      secondaryColorHex,
                                    ),
                                    _buildInfoRow(
                                      l10n.accountBalanceLabel,
                                      "$balance $currency",
                                      secondaryColorHex,
                                    ),
                                    _buildInfoRow(
                                      l10n.accountPhoneNumber,
                                      phone,
                                      secondaryColorHex,
                                    ),
                                    _buildInfoRow(
                                      l10n.nationalityLabel,
                                      nationality,
                                      secondaryColorHex,
                                    ),

                                    const SizedBox(height: 20),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        HugeIcon(
                                          icon: statusIcon,
                                          size: 20,
                                          color: statusColor,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          statusText,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: statusColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Positioned(
                              top: -47,
                              child: Container(
                                width: profileSize,
                                height: profileSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  image: const DecorationImage(
                                    image: AssetImage(
                                      'assets/images/selfie_placeholder.png',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),

                            Positioned(
                              top: 8,
                              right: 0,
                              child: Image.asset(
                                'assets/images/oman_emblem.png',
                                width: 194,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}