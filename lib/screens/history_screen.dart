import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool noInternet = false;
  List<Map<String, String>> _filteredHistoryItems = [];
  late List<Map<String, String>> _historyItems;

  @override
  void initState() {
    super.initState();
    noInternet = true; // Temporarily set to true for demonstration
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    _historyItems = [
      {"title": "SEB", "subtitle": l10n.identity, "date": "March 24, 2025 - 1:50 PM (UTC+02)", "type": "identity"},
      {"title": "Swish at SEB", "subtitle": l10n.signature, "date": "March 24, 2025 - 1:50 PM (UTC+02)", "type": "signature"},
      {"title": "SEB", "subtitle": l10n.signature, "date": "March 24, 2025 - 1:50 PM (UTC+02)", "type": "signature"},
      {"title": "Minimum application - date", "subtitle": l10n.identity, "date": "March 24, 2025 - 1:50 PM (UTC+02)", "type": "identity"},
      {"title": "Application ID-Kort", "subtitle": l10n.identity, "date": "March 24, 2025 - 1:50 PM (UTC+02)", "type": "identity"},
      {"title": "SEB", "subtitle": l10n.identity, "date": "March 24, 2025 - 1:50 PM (UTC+02)", "type": "identity"},
    ];
    _filteredHistoryItems = _historyItems;
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterHistoryItems(_searchController.text);
  }

  void _filterHistoryItems(String query) {
    setState(() {
      if (noInternet) return;
      if (query.isEmpty) {
        _filteredHistoryItems = _historyItems;
      } else {
        _filteredHistoryItems = _historyItems.where((item) {
          final titleLower = item["title"]!.toLowerCase();
          final subtitleLower = item["subtitle"]!.toLowerCase();
          final dateLower = item["date"]!.toLowerCase();
          final searchLower = query.toLowerCase();
          return titleLower.contains(searchLower) ||
              subtitleLower.contains(searchLower) ||
              dateLower.contains(searchLower);
        }).toList();
      }
    });
  }

  

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowLeft01,
                          size: 22,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            noInternet = false;
                          });
                          FocusScope.of(context).unfocus();
                        },
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedSearch01,
                          size: 20,
                          color: Colors.black54,
                        ),
                      ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: l10n.search,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        onChanged: (value) {
                          _filterHistoryItems(value);
                        },
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedCancelCircle,
                          size: 20,
                          color: Colors.black54,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            noInternet = false;
                          });
                          FocusScope.of(context).unfocus();
                        },
                      ),
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              child: noInternet
                  ? _buildNoInternet(l10n)
                  : _filteredHistoryItems.isEmpty && _searchController.text.isNotEmpty
                      ? _buildNoResults(l10n, _searchController.text)
                      : _buildHistoryList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredHistoryItems.length,
      itemBuilder: (context, index) {
        final item = _filteredHistoryItems[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey.shade100,
              child: HugeIcon(
                icon: item["type"] == "identity"
                    ? HugeIcons.strokeRoundedId
                    : HugeIcons.strokeRoundedSignature,
                size: 20,
                color: Colors.black54,
              ),
            ),
            title: Text(
              item["title"]!,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item["subtitle"]!, style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(
                    item["date"]!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoInternet(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HugeIcon(
              icon: HugeIcons.strokeRoundedWifiDisconnected01,
              size: 56,
              color: Colors.black54,
            ),
            const SizedBox(height: 20),
            Text(
              l10n.noInternetConnectionTitle,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.noInternetConnectionDescription,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF37C293),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                setState(() {
                  noInternet = false;
                });
              },
              child: Text(l10n.retryButton, style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults(AppLocalizations l10n, String searchQuery) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HugeIcon(
              icon: HugeIcons.strokeRoundedSearch01,
              size: 56,
              color: Colors.black54,
            ),
            const SizedBox(height: 20),
            Text(
              l10n.noResultsFoundTitle,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
            Text(
              l10n.noResultsFoundDescription(searchQuery),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}