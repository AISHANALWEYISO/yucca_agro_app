import 'package:flutter/material.dart';
import '../services/api_service.dart'; // ⚠️ Adjust path to match your project

class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  final ApiService _api = ApiService();
  List<Map<String, dynamic>> _allTips = [];
  List<Map<String, dynamic>> _filteredTips = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const String _serverRoot = 'http://192.168.1.241:5001';

  static const Color colorLogoGreen = Color(0xFF366000);
  static const Color colorCardGreen = Color(0xFFBCD9A2);
  static const Color colorBtnGreen = Color(0xFF427A43);

  @override
  void initState() {
    super.initState();
    _fetchTips();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTips() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _api.getAllTips();

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          _allTips = List<Map<String, dynamic>>.from(result['data'] ?? []);
          _filteredTips = _allTips;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to fetch tips';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Connection error: $e';
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredTips = _allTips;
      } else {
        _filteredTips = _allTips.where((tip) {
          final title = (tip['title'] ?? '').toLowerCase();
          final content = (tip['content'] ?? '').toLowerCase();
          return title.contains(query) || content.contains(query);
        }).toList();
      }
    });
  }

  String _getFullImageUrl(String? relativeUrl) {
    if (relativeUrl == null || relativeUrl.isEmpty) return '';
    if (relativeUrl.startsWith('http')) return relativeUrl;
    return '$_serverRoot$relativeUrl';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farming Tips'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: colorLogoGreen,
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tips...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              textInputAction: TextInputAction.search,
            ),
          ),

          // Result Count
          if (_searchQuery.isNotEmpty && !_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${_filteredTips.length} result${_filteredTips.length == 1 ? '' : 's'} for "$_searchQuery"',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),

          const Divider(height: 1),

          // Content Area
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _fetchTips,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorBtnGreen,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _filteredTips.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _searchQuery.isEmpty ? Icons.lightbulb_outline : Icons.search_off,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'No tips available yet'
                                      : 'No tips found for "$_searchQuery"',
                                  style: TextStyle(color: Colors.grey[600]),
                                  textAlign: TextAlign.center,
                                ),
                                if (_searchQuery.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                    child: const Text('Clear search'),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredTips.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) => _buildTipCard(_filteredTips[index]),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(Map<String, dynamic> tip) {
    final imageUrl = _getFullImageUrl(tip['image_url']);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showTipDetails(tip),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tip['title'] ?? 'No Title',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorLogoGreen,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                tip['content'] ?? '',
                style: TextStyle(color: Colors.grey[700], height: 1.4),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Read more',
                    style: TextStyle(
                      color: colorBtnGreen,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const Icon(Icons.arrow_forward, size: 14, color: colorBtnGreen),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTipDetails(Map<String, dynamic> tip) {
    final imageUrl = _getFullImageUrl(tip['image_url']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ⭕ Close Button: Black X in White Circle (top-right)
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Title
              Text(
                tip['title'] ?? 'No Title',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colorLogoGreen,
                ),
              ),
              const SizedBox(height: 20),
              
              // Image (if available)
              if (imageUrl.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              
              // Content
              Text(
                tip['content'] ?? 'No content available',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[800],
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}