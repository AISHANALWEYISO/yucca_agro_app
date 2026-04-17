import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────────────────────────────────────
//  MODEL
// ─────────────────────────────────────────────────────────────────────────────
class Crop {
  final int id;
  final String name;
  final String plantingTime;
  final String harvestTime;
  final String duration;
  final String season;
  final String tip;
  final String colorHex;

  Crop({
    required this.id,
    required this.name,
    required this.plantingTime,
    required this.harvestTime,
    required this.duration,
    required this.season,
    required this.tip,
    required this.colorHex,
  });

  factory Crop.fromJson(Map<String, dynamic> json) => Crop(
        id:           json['id'] ?? 0,
        name:         json['name'] ?? '',
        plantingTime: json['planting_time'] ?? '',
        harvestTime:  json['harvest_time'] ?? '',
        duration:     json['duration'] ?? '',
        season:       json['season'] ?? '',
        tip:          json['tip'] ?? '',
        colorHex:     json['color'] ?? '#4CAF50',
      );

  Color get color {
    final hex = colorHex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class CropCalendarScreen extends StatefulWidget {
  const CropCalendarScreen({super.key});

  @override
  State<CropCalendarScreen> createState() => _CropCalendarScreenState();
}

class _CropCalendarScreenState extends State<CropCalendarScreen>
    with SingleTickerProviderStateMixin {

  // ── Palette ────────────────────────────────
  static const Color deepGreen  = Color(0xFF1B4D1F);
  static const Color midGreen   = Color(0xFF2D6A31);
  static const Color cream      = Color(0xFFF4F1EB);
  static const Color cardWhite  = Color(0xFFFFFFFF);
  static const Color gold       = Color(0xFFC0A84A);
  static const Color textDark   = Color(0xFF1A2B1C);
  static const Color textMuted  = Color(0xFF6B7C61);
  static const Color dividerCol = Color(0xFFE4EDE0);
  static const Color plantGreen = Color(0xFF2E7D32);
  static const Color harvestAmb = Color(0xFFE07B00);
  static const Color durationBl = Color(0xFF1565C0);

  // ── State ──────────────────────────────────
  late TabController _tabController;
  int _selectedMonth = DateTime.now().month - 1;
  List<Crop> _crops = [];
  bool _loadingCrops = false;
  String? _cropError;

  // ── Labels ─────────────────────────────────
  final _months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
  final _fullMonths = ['January','February','March','April','May','June',
                        'July','August','September','October','November','December'];

  String _getSeason(int m) {
    if ((m >= 2 && m <= 4) || (m >= 8 && m <= 10)) return 'Rainy Season';
    return 'Dry Season';
  }

  Color _getSeasonColor(int m) =>
      ((m >= 2 && m <= 4) || (m >= 8 && m <= 10))
          ? const Color(0xFF1565C0)
          : const Color(0xFFBF6900);

  // ── Monthly hardcoded data ──────────────────
  final List<Map<String, dynamic>> _monthlyData = [
    {
      'plant':   ['Onions','Tomatoes','Cabbages'],
      'harvest': ['Maize','Sorghum','Sweet Potatoes'],
      'prepare': 'Clear land and apply compost. Use irrigation if available.',
      'tip':     'Harvest and store dry grains. Prepare nursery beds for the rainy season.',
    },
    {
      'plant':   ['Tomatoes','Peppers','Onions'],
      'harvest': ['Beans','Groundnuts','Cassava'],
      'prepare': 'Begin land preparation. Apply lime to acidic soils.',
      'tip':     'Start composting. Clear weeds before rains begin in March.',
    },
    {
      'plant':   ['Maize','Beans','Groundnuts','Sorghum'],
      'harvest': ['Tomatoes','Onions','Cabbages'],
      'prepare': 'Plough and harrow fields. Apply DAP fertilizer before planting.',
      'tip':     'Rainy season begins. Plant early to make the most of the rains.',
    },
    {
      'plant':   ['Maize','Beans','Soybeans','Sunflower'],
      'harvest': ['Tomatoes','Peppers','Early Cassava'],
      'prepare': 'Top-dress maize with CAN fertilizer. Weed beans at 3 weeks.',
      'tip':     'Peak rainfall month. Watch for fungal diseases in maize and beans.',
    },
    {
      'plant':   ['Cassava','Sweet Potatoes','Bananas'],
      'harvest': ['Maize (early)','Onions','Watermelon'],
      'prepare': 'Harvest rainy season crops. Store grains properly to avoid weevils.',
      'tip':     'Rains winding down. Start planning dry season irrigation crops.',
    },
    {
      'plant':   ['Tomatoes','Onions','Vegetables (irrigated)'],
      'harvest': ['Maize','Beans','Groundnuts','Soybeans'],
      'prepare': 'Harvest and dry grains thoroughly. Clean and store your tools.',
      'tip':     'Dry season — focus on irrigated crops if water is available.',
    },
    {
      'plant':   ['Tomatoes','Cabbages','Eggplant'],
      'harvest': ['Sweet Potatoes','Cassava','Bananas'],
      'prepare': 'Deep plough fields. Apply organic manure to improve soil.',
      'tip':     'Apply compost to fields. Start planning inputs for the next rains.',
    },
    {
      'plant':   ['Onions','Tomatoes','Leafy Vegetables'],
      'harvest': ['Cassava','Sweet Potatoes','Bananas'],
      'prepare': 'Final land prep before short rains. Test and amend soil pH.',
      'tip':     'Purchase seeds and fertilizer before the rains return.',
    },
    {
      'plant':   ['Maize','Beans','Groundnuts','Millet'],
      'harvest': ['Tomatoes','Cabbages','Onions'],
      'prepare': 'Plant at onset of short rains. Apply DAP at planting time.',
      'tip':     'Short rainy season begins. Plant in the first 2 weeks of rain.',
    },
    {
      'plant':   ['Soybeans','Sunflower','Cowpeas'],
      'harvest': ['Tomatoes','Peppers','Early Maize'],
      'prepare': 'Top-dress crops. Control striga weed in sorghum and millet.',
      'tip':     'Peak short rains. Scout for armyworm and aphid attacks.',
    },
    {
      'plant':   ['Cassava','Bananas','Sweet Potatoes'],
      'harvest': ['Maize','Beans','Groundnuts'],
      'prepare': 'Harvest crops. Dry beans and maize well before storage.',
      'tip':     'Rains ending. Harvest before excess moisture causes mold.',
    },
    {
      'plant':   ['Vegetables','Onions','Tomatoes'],
      'harvest': ['Maize','Soybeans','Millet','Sorghum'],
      'prepare': 'Final harvest and storage. Sell surplus before prices drop.',
      'tip':     'Dry season begins. Plan your budget and inputs for next year.',
    },
  ];

  // ── Lifecycle ──────────────────────────────
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1 && _crops.isEmpty && !_loadingCrops) {
        _fetchCrops();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── API call ───────────────────────────────
  Future<void> _fetchCrops() async {
    setState(() { _loadingCrops = true; _cropError = null; });
    try {
      // 🔁 Replace with your real base URL
      const baseUrl = 'https://your-api.com';
      final res = await http
          .get(Uri.parse('$baseUrl/api/crops'),
               headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        setState(() {
          _crops = data.map((e) => Crop.fromJson(e)).toList();
          _loadingCrops = false;
        });
      } else {
        setState(() {
          _cropError = 'Server error (${res.statusCode}). Please try again.';
          _loadingCrops = false;
        });
      }
    } catch (_) {
      setState(() {
        _cropError = 'Could not load crops. Check your connection and try again.';
        _loadingCrops = false;
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: deepGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Crop Calendar',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: gold,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: 'Monthly View'),
            Tab(text: 'Crop List'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMonthlyView(),
          _buildCropListView(),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════
  //  TAB 1 — MONTHLY VIEW
  // ═════════════════════════════════════════════
  Widget _buildMonthlyView() {
    final data        = _monthlyData[_selectedMonth];
    final season      = _getSeason(_selectedMonth);
    final seasonColor = _getSeasonColor(_selectedMonth);

    return Column(
      children: [
        // Month selector
        Container(
          color: midGreen,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: 12,
              itemBuilder: (_, i) {
                final sel = i == _selectedMonth;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMonth = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: sel ? gold : Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: sel ? gold : Colors.white.withOpacity(0.18),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _months[i],
                        style: TextStyle(
                          color: sel ? deepGreen : Colors.white70,
                          fontWeight: sel ? FontWeight.w800 : FontWeight.w400,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Season banner — text only, no icon
        Container(
          width: double.infinity,
          color: seasonColor.withOpacity(0.09),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: Text(
            '${_fullMonths[_selectedMonth]}  ·  $season',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: seasonColor,
              letterSpacing: 0.2,
            ),
          ),
        ),

        // Cards
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            child: Column(
              children: [
                _monthCard(
                  title: 'Crops to Plant This Month',  // ✅ CHANGED
                  accentColor: plantGreen,
                  child: _chipRow(List<String>.from(data['plant']), plantGreen),
                ),
                const SizedBox(height: 12),
                _monthCard(
                  title: 'Crops Ready to Harvest',  // ✅ CHANGED
                  accentColor: harvestAmb,
                  child: _chipRow(List<String>.from(data['harvest']), harvestAmb),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _monthCard(
                        title: 'Land Preparation',
                        accentColor: const Color(0xFF795548),
                        child: Text(
                          data['prepare'],
                          style: const TextStyle(
                              fontSize: 12.5, color: textMuted, height: 1.6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _monthCard(
                        title: "Farmer's Note",
                        accentColor: gold,
                        child: Text(
                          data['tip'],
                          style: const TextStyle(
                              fontSize: 12.5, color: textMuted, height: 1.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _monthCard({
    required String title,
    required Color accentColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header band — coloured strip, text only
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              border:
                  Border(bottom: BorderSide(color: accentColor.withOpacity(0.15))),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: accentColor,
                letterSpacing: 0.2,
              ),
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(14),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _chipRow(List<String> items, Color color) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: items
          .map((item) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(
                  item,
                  style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600),
                ),
              ))
          .toList(),
    );
  }

  // ═════════════════════════════════════════════
  //  TAB 2 — CROP LIST (dynamic)
  // ═════════════════════════════════════════════
  Widget _buildCropListView() {
    if (_loadingCrops) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: plantGreen),
            SizedBox(height: 14),
            Text('Loading crops...',
                style: TextStyle(color: textMuted, fontSize: 13)),
          ],
        ),
      );
    }

    if (_cropError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _cropError!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: textMuted, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchCrops,
                style: ElevatedButton.styleFrom(
                  backgroundColor: deepGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 11),
                ),
                child: const Text('Try Again',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      );
    }

    if (_crops.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No crops found.',
                style: TextStyle(color: textMuted, fontSize: 13)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchCrops,
              style: ElevatedButton.styleFrom(
                backgroundColor: deepGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Reload',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: plantGreen,
      onRefresh: _fetchCrops,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        itemCount: _crops.length,
        itemBuilder: (_, i) => _buildCropCard(_crops[i]),
      ),
    );
  }

  Widget _buildCropCard(Crop crop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: crop.color, width: 4)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 7,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding:
              const EdgeInsets.fromLTRB(14, 0, 14, 14),
          title: Text(
            crop.name,
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: textDark),
          ),
          subtitle: Text(
            crop.season,
            style: TextStyle(
                fontSize: 11,
                color: crop.color,
                fontWeight: FontWeight.w500),
          ),
          children: [
            Divider(height: 1, thickness: 1, color: dividerCol),
            const SizedBox(height: 12),
            _infoRow('Planting',  crop.plantingTime, plantGreen),
            const SizedBox(height: 7),
            _infoRow('Harvest',   crop.harvestTime,  harvestAmb),
            const SizedBox(height: 7),
            _infoRow('Duration',  crop.duration,     durationBl),
            const SizedBox(height: 12),
            // Farmer's note — no icon
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: gold.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: gold.withOpacity(0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Farmer's Note",
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: gold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    crop.tip,
                    style: const TextStyle(
                        fontSize: 12.5, color: textMuted, height: 1.55),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 68,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: textMuted,
                  fontWeight: FontWeight.w500)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value,
              style: TextStyle(
                  fontSize: 12.5,
                  color: color,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}