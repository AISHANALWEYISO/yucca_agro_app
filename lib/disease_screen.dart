import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DiseaseScreen extends StatefulWidget {
  const DiseaseScreen({super.key});

  @override
  State<DiseaseScreen> createState() => _DiseaseScreenState();
}

class _DiseaseScreenState extends State<DiseaseScreen> {
  final ApiService _api = ApiService();
  List<Map<String, dynamic>> _diseases = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _isLoading = true;
  String? _error;
  final _searchCtrl = TextEditingController();

  static const String _serverRoot = 'http://192.168.1.241:5001';
  static const _primary = Color(0xFF1B5E20);
  static const _accent = Color(0xFF4CAF50);
  static const _bg = Color(0xFFF8FDF8);

  @override
  void initState() {
    super.initState();
    _fetch();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final res = await _api.getDiseases();
      if (!mounted) return;
      if (res['success'] == true) {
        setState(() {
          _diseases = List<Map<String, dynamic>>.from(res['data'] ?? []);
          _filtered = _diseases;
          _isLoading = false;
        });
      } else {
        setState(() { _error = res['message']; _isLoading = false; });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = 'Connection failed: $e'; _isLoading = false; });
    }
  }

  void _onSearch() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty ? _diseases : _diseases.where((d) {
        return (d['name'] ?? '').toLowerCase().contains(q) ||
               (d['description'] ?? '').toLowerCase().contains(q);
      }).toList();
    });
  }

  String _img(String? url) {
    if (url == null || url.isEmpty) return '';
    return url.startsWith('http') ? url : '$_serverRoot$url';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Plant Diseases'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _primary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search disease name or symptoms...',
                prefixIcon: const Icon(Icons.search, color: _accent),
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: _primary))
                : _error != null
                    ? _buildError()
                    : _filtered.isEmpty
                        ? _buildEmpty()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: _filtered.length,
                            itemBuilder: (ctx, i) => _diseaseCard(_filtered[i]),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.orange),
      const SizedBox(height: 12),
      Text(_error!, style: const TextStyle(color: Colors.grey)),
      const SizedBox(height: 12),
      ElevatedButton(onPressed: _fetch, style: ElevatedButton.styleFrom(backgroundColor: _primary, foregroundColor: Colors.white), child: const Text('Retry'))
    ]),
  );

  Widget _buildEmpty() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: const [
      Icon(Icons.eco_outlined, size: 48, color: Colors.grey),
      SizedBox(height: 12),
      Text('No diseases found', style: TextStyle(color: Colors.grey))
    ]),
  );

  Widget _diseaseCard(Map<String, dynamic> d) {
    final img = _img(d['image']);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showDetails(d),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: img.isEmpty
                    ? Container(width: 70, height: 70, color: Colors.grey[200], child: const Icon(Icons.bug_report, color: Colors.grey))
                    : Image.network(img, width: 70, height: 70, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(width: 70, height: 70, color: Colors.grey[200], child: const Icon(Icons.image_not_supported))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(d['name'] ?? 'Unknown', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _primary)),
                  const SizedBox(height: 4),
                  Text(d['description'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[700], height: 1.3))
                ]),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: _accent)
            ],
          ),
        ),
      ),
    );
  }

  void _showDetails(Map<String, dynamic> d) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.88,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Close Button (fixed: no const on BoxDecoration with Border.all)
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black),
                  ),
                  child: const Icon(Icons.close, color: Colors.black, size: 20),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Image & Title
            if (_img(d['image']).isNotEmpty) ...[
              ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(_img(d['image']), height: 200, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(height: 200, color: Colors.grey[200]))),
              const SizedBox(height: 16),
            ],
            Text(d['name'] ?? 'Disease Details', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _primary)),
            const SizedBox(height: 12),
            Text(d['description'] ?? '', style: TextStyle(color: Colors.grey[800], height: 1.5)),
            const SizedBox(height: 24),
            
            // ✅ Accordion Sections (emojis removed, clean labels)
            _buildSection('Signs & Symptoms', d['signs'], Icons.search),
            const SizedBox(height: 12),
            _buildSection('Prevention', d['prevention'], Icons.shield),
            const SizedBox(height: 12),
            _buildSection('Treatment', d['treatment'], Icons.medical_services),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }

  // ✅ Updated: accepts optional icon for visual cue (no emoji in text)
  Widget _buildSection(String title, String? content, [IconData? icon]) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: icon != null ? Icon(icon, color: _accent, size: 20) : null,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(content ?? 'No information available', style: TextStyle(color: Colors.grey[700], height: 1.5)),
          )
        ],
      ),
    );
  }
}