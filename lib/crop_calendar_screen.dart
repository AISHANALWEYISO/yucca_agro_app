import 'package:flutter/material.dart';

class CropCalendarScreen extends StatefulWidget {
  const CropCalendarScreen({super.key});

  @override
  State<CropCalendarScreen> createState() => _CropCalendarScreenState();
}

class _CropCalendarScreenState extends State<CropCalendarScreen>
    with SingleTickerProviderStateMixin {
  static const Color deepGreen = Color(0xFF2D5016);
  static const Color midGreen = Color(0xFF366000);
  static const Color lightGreen = Color(0xFF8BC34A);
  static const Color cream = Color(0xFFF5E9CF);
  static const Color gold = Color(0xFFC0B87A);

  late TabController _tabController;
  int _selectedMonth = DateTime.now().month - 1; // 0-indexed

  final List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  final List<String> _fullMonths = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  // Season A: Mar–May, Season B: Sep–Nov
  String _getSeason(int monthIndex) {
    if (monthIndex >= 2 && monthIndex <= 4) return 'Season A 🌧️';
    if (monthIndex >= 8 && monthIndex <= 10) return 'Season B 🌦️';
    if (monthIndex >= 5 && monthIndex <= 7) return 'Dry Season ☀️';
    return 'Dry Season ☀️';
  }

  Color _getSeasonColor(int monthIndex) {
    if (monthIndex >= 2 && monthIndex <= 4) return const Color(0xFF1565C0);
    if (monthIndex >= 8 && monthIndex <= 10) return const Color(0xFF0288D1);
    return const Color(0xFFE65100);
  }

  // Full crop data per month
  final List<Map<String, dynamic>> _monthlyData = [
    // January
    {
      'plant': ['Onions', 'Tomatoes', 'Cabbages'],
      'harvest': ['Maize', 'Sorghum', 'Sweet Potatoes'],
      'prepare': 'Clear land and apply compost. Dry season — use irrigation if available.',
      'tip': 'Good time to harvest and store dry grains. Prepare nursery beds for Season A.',
    },
    // February
    {
      'plant': ['Tomatoes', 'Peppers', 'Onions'],
      'harvest': ['Beans', 'Groundnuts', 'Cassava'],
      'prepare': 'Begin land preparation for Season A. Apply lime to acidic soils.',
      'tip': 'Start composting. Clear weeds before rains begin in March.',
    },
    // March
    {
      'plant': ['Maize', 'Beans', 'Groundnuts', 'Sorghum'],
      'harvest': ['Tomatoes', 'Onions', 'Cabbages'],
      'prepare': 'Plough and harrow fields. Apply basal fertilizer (DAP) before planting.',
      'tip': 'Season A begins. Plant early to maximize the long rains.',
    },
    // April
    {
      'plant': ['Maize', 'Beans', 'Soybeans', 'Sunflower'],
      'harvest': ['Tomatoes', 'Peppers', 'Early Cassava'],
      'prepare': 'Top-dress maize with CAN fertilizer. Weed beans at 3 weeks.',
      'tip': 'Peak rainfall month. Monitor for fungal diseases in maize and beans.',
    },
    // May
    {
      'plant': ['Cassava', 'Sweet Potatoes', 'Bananas'],
      'harvest': ['Maize (early)', 'Onions', 'Watermelon'],
      'prepare': 'Harvest Season A crops. Store grains properly to avoid weevils.',
      'tip': 'End of Season A. Start planning Season B nurseries.',
    },
    // June
    {
      'plant': ['Vegetables (irrigated)', 'Tomatoes', 'Onions'],
      'harvest': ['Maize', 'Beans', 'Groundnuts', 'Soybeans'],
      'prepare': 'Harvest and dry grains thoroughly. Clean and store tools.',
      'tip': 'Dry season — focus on irrigation crops if water is available.',
    },
    // July
    {
      'plant': ['Tomatoes', 'Cabbages', 'Eggplant'],
      'harvest': ['Sweet Potatoes', 'Cassava', 'Bananas'],
      'prepare': 'Deep plough fields to expose soil to sun. Apply organic manure.',
      'tip': 'Good time to apply manure and compost to fields. Plan Season B inputs.',
    },
    // August
    {
      'plant': ['Onions', 'Tomatoes', 'Leafy Vegetables'],
      'harvest': ['Cassava', 'Sweet Potatoes', 'Bananas'],
      'prepare': 'Final land prep for Season B. Test soil pH and amend as needed.',
      'tip': 'Purchase seeds and fertilizer for Season B. Check for storage pests.',
    },
    // September
    {
      'plant': ['Maize', 'Beans', 'Groundnuts', 'Millet'],
      'harvest': ['Tomatoes', 'Cabbages', 'Onions'],
      'prepare': 'Plant at onset of short rains. Apply DAP fertilizer at planting.',
      'tip': 'Season B begins. Plant within the first 2 weeks of rain.',
    },
    // October
    {
      'plant': ['Soybeans', 'Sunflower', 'Cowpeas'],
      'harvest': ['Tomatoes', 'Peppers', 'Early Maize'],
      'prepare': 'Top-dress crops. Control striga weed in sorghum and millet.',
      'tip': 'Peak Season B rains. Scout for armyworm and aphids.',
    },
    // November
    {
      'plant': ['Cassava', 'Bananas', 'Sweet Potatoes'],
      'harvest': ['Maize', 'Beans', 'Groundnuts'],
      'prepare': 'Begin harvesting Season B crops. Dry beans and maize before storage.',
      'tip': 'End of short rains. Harvest before excessive moisture causes mold.',
    },
    // December
    {
      'plant': ['Vegetables', 'Onions', 'Tomatoes'],
      'harvest': ['Maize', 'Soybeans', 'Millet', 'Sorghum'],
      'prepare': 'Final harvest and storage. Sell surplus before prices drop.',
      'tip': 'Dry season begins. Plan budgets and inputs for next year.',
    },
  ];

  // Crop list view data
  final List<Map<String, dynamic>> _crops = [
    {
      'name': 'Maize',
      'icon': '🌽',
      'color': Color(0xFFF9A825),
      'plant': 'Mar–Apr, Sep–Oct',
      'harvest': 'Jun–Jul, Dec–Jan',
      'duration': '3–4 months',
      'season': 'Season A & B',
      'tip': 'Apply DAP at planting and CAN at 6 weeks. Requires 600–900mm rainfall.',
    },
    {
      'name': 'Beans',
      'icon': '🫘',
      'color': Color(0xFF8D6E63),
      'plant': 'Mar, Sep',
      'harvest': 'May–Jun, Nov',
      'duration': '2–3 months',
      'season': 'Season A & B',
      'tip': 'Fix nitrogen in soil. Great intercrop with maize. Avoid waterlogging.',
    },
    {
      'name': 'Groundnuts',
      'icon': '🥜',
      'color': Color(0xFFD4A017),
      'plant': 'Mar–Apr, Sep',
      'harvest': 'Jun, Nov–Dec',
      'duration': '3–4 months',
      'season': 'Season A & B',
      'tip': 'Plant in well-drained sandy loam. Rotate with cereals to prevent disease.',
    },
    {
      'name': 'Cassava',
      'icon': '🌿',
      'color': Color(0xFF558B2F),
      'plant': 'May, Aug–Sep',
      'harvest': '9–18 months later',
      'duration': '9–18 months',
      'season': 'Any season',
      'tip': 'Drought tolerant. Plant cuttings at 45° angle. Good food security crop.',
    },
    {
      'name': 'Sweet Potatoes',
      'icon': '🍠',
      'color': Color(0xFFE64A19),
      'plant': 'Mar–May, Aug–Oct',
      'harvest': '3–5 months later',
      'duration': '3–5 months',
      'season': 'Season A & B',
      'tip': 'Vines suppress weeds. Rich in vitamins. Good for marginal soils.',
    },
    {
      'name': 'Tomatoes',
      'icon': '🍅',
      'color': Color(0xFFD32F2F),
      'plant': 'Jan–Feb, Jun–Aug',
      'harvest': '3 months after planting',
      'duration': '3 months',
      'season': 'Dry season (irrigated)',
      'tip': 'Needs staking and regular spraying. High-value crop. Use drip irrigation.',
    },
    {
      'name': 'Sorghum',
      'icon': '🌾',
      'color': Color(0xFFBF8F3C),
      'plant': 'Mar–Apr, Sep',
      'harvest': 'Jul, Dec',
      'duration': '4–5 months',
      'season': 'Season A & B',
      'tip': 'Drought tolerant. Good for dry areas. Used for food and local brew.',
    },
    {
      'name': 'Soybeans',
      'icon': '🟡',
      'color': Color(0xFF9CCC65),
      'plant': 'Apr, Sep–Oct',
      'harvest': 'Jul, Dec–Jan',
      'duration': '3–4 months',
      'season': 'Season A & B',
      'tip': 'High protein. Fixes nitrogen. Good market price. Intercrop with maize.',
    },
    {
      'name': 'Bananas',
      'icon': '🍌',
      'color': Color(0xFFFFD600),
      'plant': 'Any time (perennial)',
      'harvest': '9–12 months, then continuous',
      'duration': 'Perennial',
      'season': 'Year-round',
      'tip': 'Needs rich soil and moisture. Mulch heavily. Remove suckers regularly.',
    },
    {
      'name': 'Onions',
      'icon': '🧅',
      'color': Color(0xFFAB47BC),
      'plant': 'Jan–Feb, Jun–Aug',
      'harvest': '3–4 months later',
      'duration': '3–4 months',
      'season': 'Dry season (irrigated)',
      'tip': 'Needs well-drained soil. High market value. Start in nursery for 6 weeks.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: deepGreen,
        foregroundColor: Colors.white,
        title: const Text('Crop Calendar',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: gold,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.calendar_month, size: 18), text: 'Monthly View'),
            Tab(icon: Icon(Icons.grass, size: 18), text: 'Crop List'),
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

  // ─────────────────────────────────────────
  //  TAB 1: MONTHLY VIEW
  // ─────────────────────────────────────────
  Widget _buildMonthlyView() {
    final data = _monthlyData[_selectedMonth];
    final season = _getSeason(_selectedMonth);
    final seasonColor = _getSeasonColor(_selectedMonth);

    return Column(
      children: [
        // Month selector strip
        Container(
          color: deepGreen,
          padding: const EdgeInsets.only(bottom: 12),
          child: SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: 12,
              itemBuilder: (context, i) {
                final selected = i == _selectedMonth;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMonth = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? gold : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? gold : Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _months[i],
                      style: TextStyle(
                        color: selected ? deepGreen : Colors.white,
                        fontWeight: selected ? FontWeight.bold : FontWeight.w400,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month header
                Row(
                  children: [
                    Text(
                      _fullMonths[_selectedMonth],
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: deepGreen),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: seasonColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: seasonColor.withOpacity(0.3)),
                      ),
                      child: Text(season,
                          style: TextStyle(
                              fontSize: 12,
                              color: seasonColor,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Planting
                _buildActivityCard(
                  icon: Icons.eco,
                  title: 'Plant This Month',
                  color: const Color(0xFF2E7D32),
                  items: List<String>.from(data['plant']),
                  emptyText: 'No major planting this month',
                ),
                const SizedBox(height: 12),

                // Harvesting
                _buildActivityCard(
                  icon: Icons.agriculture,
                  title: 'Harvest This Month',
                  color: const Color(0xFFE65100),
                  items: List<String>.from(data['harvest']),
                  emptyText: 'No major harvest this month',
                ),
                const SizedBox(height: 12),

                // Soil prep
                _buildInfoCard(
                  icon: Icons.foundation,
                  title: 'Soil & Land Preparation',
                  content: data['prepare'],
                  color: const Color(0xFF6D4C41),
                ),
                const SizedBox(height: 12),

                // Tip
                _buildInfoCard(
                  icon: Icons.lightbulb_outline,
                  title: 'Farmer\'s Tip',
                  content: data['tip'],
                  color: const Color(0xFFF9A825),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard({
    required IconData icon,
    required String title,
    required Color color,
    required List<String> items,
    required String emptyText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color)),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Text(emptyText,
                style: TextStyle(color: Colors.grey[500], fontSize: 13))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((crop) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.25)),
                ),
                child: Text(crop,
                    style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w600)),
              )).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: color)),
                const SizedBox(height: 6),
                Text(content,
                    style: TextStyle(
                        fontSize: 13,
                        color: deepGreen.withOpacity(0.75),
                        height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  TAB 2: CROP LIST VIEW
  // ─────────────────────────────────────────
  Widget _buildCropListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _crops.length,
      itemBuilder: (context, i) {
        final crop = _crops[i];
        return _buildCropCard(crop);
      },
    );
  }

  Widget _buildCropCard(Map<String, dynamic> crop) {
    final color = crop['color'] as Color;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(crop['icon'], style: const TextStyle(fontSize: 22)),
            ),
          ),
          title: Text(crop['name'],
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: deepGreen)),
          subtitle: Text(crop['season'],
              style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
          children: [
            const Divider(height: 1),
            const SizedBox(height: 12),
            _cropDetailRow(Icons.eco, 'Planting Time', crop['plant'], const Color(0xFF2E7D32)),
            const SizedBox(height: 8),
            _cropDetailRow(Icons.agriculture, 'Harvest Time', crop['harvest'], const Color(0xFFE65100)),
            const SizedBox(height: 8),
            _cropDetailRow(Icons.schedule, 'Duration', crop['duration'], const Color(0xFF1565C0)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, size: 15, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(crop['tip'],
                        style: TextStyle(
                            fontSize: 12,
                            color: deepGreen.withOpacity(0.75),
                            height: 1.5)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cropDetailRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text('$label: ',
            style: TextStyle(fontSize: 12, color: deepGreen.withOpacity(0.5), fontWeight: FontWeight.w600)),
        Expanded(
          child: Text(value,
              style: TextStyle(fontSize: 12, color: deepGreen, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}