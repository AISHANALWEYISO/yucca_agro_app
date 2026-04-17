import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final ApiService _api = ApiService();
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _isLoading = true;
  String? _error;
  String _selectedCategory = 'All';
  final _searchCtrl = TextEditingController();

  static const String _serverRoot = 'http://192.168.1.241:5001';
  static const _primary = Color(0xFF1B5E20);
  static const _accent = Color(0xFF3498DB);
  static const _bg = Color(0xFFF8FDF8);

  final List<String> _categories = [
    'All', 'Seeds', 'Tools', 'Fertilizer', 'Pesticides', 'Equipment', 'Produce'
  ];

  @override
  void initState() {
    super.initState();
    _fetchItems();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchItems() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final res = await _api.getMarketItems(
        category: _selectedCategory == 'All' ? null : _selectedCategory,
        search: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
      );
      if (!mounted) return;
      if (res['success'] == true) {
        setState(() {
          _items = List<Map<String, dynamic>>.from(res['data'] ?? []);
          _filtered = _items;
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
      _filtered = _items.where((item) {
        final name = (item['name'] ?? '').toLowerCase();
        final desc = (item['description'] ?? '').toLowerCase();
        final matchesSearch = q.isEmpty || name.contains(q) || desc.contains(q);
        final matchesCategory = _selectedCategory == 'All' || 
            item['category'] == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  String _img(String? url) {
    if (url == null || url.isEmpty) return '';
    return url.startsWith('http') ? url : '$_serverRoot$url';
  }

  String _formatPrice(double price, String unit) {
    return 'UGX ${price.toStringAsFixed(0)} / $unit';
  }

  Future<void> _contactSeller(String? phone, String name) async {
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No contact info available')),
      );
      return;
    }
    // Try WhatsApp first, fallback to phone call
    final whatsappUrl = 'https://wa.me/${phone.replaceAll(RegExp(r'\D'), '')}';
    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else if (await canLaunch('tel:$phone')) {
      await launch('tel:$phone');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not contact $name')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Farmers Market'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchItems,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search seeds, tools, fertilizer...',
                prefixIcon: const Icon(Icons.search, color: _accent),
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (_) => _onSearch(),
            ),
          ),
          // 🏷️ Category Chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = cat == _selectedCategory;
                return FilterChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => _selectedCategory = cat);
                    _onSearch();
                  },
                  selectedColor: _accent.withOpacity(0.2),
                  checkmarkColor: _accent,
                  labelStyle: TextStyle(
                    color: isSelected ? _accent : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          // 📦 Items List (Expanded Cards)
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: _primary))
                : _error != null
                    ? _buildError()
                    : _filtered.isEmpty
                        ? _buildEmpty()
                        : ListView.separated(
                            padding: const EdgeInsets.all(12),
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 16),
                            itemBuilder: (ctx, i) => _expandedItemCard(_filtered[i]),
                          ),
          ),
        ],
      ),
      // ➕ Floating Action Button (for sellers to list items)
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showListDialog(),
        backgroundColor: _accent,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'List an Item',
      ),
    );
  }

  Widget _buildError() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.orange),
      const SizedBox(height: 12),
      Text(_error!, style: const TextStyle(color: Colors.grey)),
      const SizedBox(height: 12),
      ElevatedButton(
        onPressed: _fetchItems,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
        ),
        child: const Text('Retry'),
      )
    ]),
  );

  Widget _buildEmpty() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: const [
      Icon(Icons.shopping_bag_outlined, size: 48, color: Colors.grey),
      SizedBox(height: 12),
      Text('No items found', style: TextStyle(color: Colors.grey)),
      SizedBox(height: 4),
      Text('Try adjusting filters or list your first item!',
          style: TextStyle(color: Colors.grey, fontSize: 12)),
    ]),
  );

  // ✅ EXPANDED CARD: Shows ALL info without tapping
  Widget _expandedItemCard(Map<String, dynamic> item) {
    final img = _img(item['image']);
    final phone = item['seller_phone'];
    final location = item['seller_location'];
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: img.isEmpty
                  ? Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: const Icon(Icons.shopping_bag, color: Colors.grey, size: 60),
                    )
                  : Image.network(
                      img,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 180,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            
            // Category Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item['category'] ?? 'General',
                style: TextStyle(
                  fontSize: 12,
                  color: _accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            // Name & Price
            Text(
              item['name'] ?? 'Unknown Item',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatPrice((item['price'] ?? 0).toDouble(), item['unit'] ?? 'kg'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _accent,
              ),
            ),
            const SizedBox(height: 12),
            
            // Description
            Text(
              item['description'] ?? 'No description available',
              style: TextStyle(
                color: Colors.grey[700],
                height: 1.4,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            
            // Seller Info Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Seller Information',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _infoRow(Icons.person, item['seller_name'] ?? 'Unknown Seller'),
                  if (phone != null && phone.toString().isNotEmpty)
                    _infoRow(Icons.phone, phone, isPhone: true, onTap: () => _contactSeller(phone, item['seller_name'])),
                  if (location != null && location.toString().isNotEmpty)
                    _infoRow(Icons.location_on, location),
                  const SizedBox(height: 4),
                  Text(
                    'Available: ${item['quantity_available'] ?? 0} ${item['unit'] ?? 'units'}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Contact Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: phone != null && phone.toString().isNotEmpty
                    ? () => _contactSeller(phone, item['seller_name'])
                    : null,
                icon: const Icon(Icons.contact_phone, size: 18),
                label: Text(
                  phone != null && phone.toString().isNotEmpty
                      ? 'Contact ${item['seller_name']?.split(' ')[0] ?? 'Seller'}'
                      : 'No Contact Info',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, {bool isPhone = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: isPhone && onTap != null
                ? GestureDetector(
                    onTap: onTap,
                    child: Text(
                      text,
                      style: TextStyle(
                        color: _accent,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : Text(
                    text,
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
          ),
        ],
      ),
    );
  }

  void _showListDialog() {
    // TODO: Implement form to list new item (requires login)
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('List an Item'),
        content: const Text('This feature requires login. Please sign in to list your farming products.'),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: _primary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: Navigate to login
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please login to list items')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}

// lib/screens/list_market_item_screen.dart
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import '../services/api_service.dart';
// import '../utils/auth_service.dart'; // Your auth helper

// class ListMarketItemScreen extends StatefulWidget {
//   const ListMarketItemScreen({super.key});

//   @override
//   State<ListMarketItemScreen> createState() => _ListMarketItemScreenState();
// }

// class _ListMarketItemScreenState extends State<ListMarketItemScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _api = ApiService();
//   final _auth = AuthService();

//   // Form controllers
//   final _nameCtrl = TextEditingController();
//   final _descCtrl = TextEditingController();
//   final _priceCtrl = TextEditingController();
//   final _quantityCtrl = TextEditingController();
//   final _locationCtrl = TextEditingController();
//   String _category = 'Seeds';
//   String _unit = 'kg';
//   File? _image;
//   bool _isSubmitting = false;

//   // 🎨 Colors (match MarketScreen)
//   static const _primary = Color(0xFF1B5E20);   // Forest Green
//   static const _accent = Color(0xFFE67E22);    // Pumpkin Orange
//   static const _bg = Color(0xFFFEFBE8);        // Soft Cream

//   final List<String> _categories = [
//     'Seeds', 'Tools', 'Fertilizer', 'Pesticides', 'Equipment', 'Produce'
//   ];
//   final List<String> _units = ['kg', 'piece', 'liter', 'bag', 'bunch', 'dozen'];

//   @override
//   void dispose() {
//     _nameCtrl.dispose(); _descCtrl.dispose(); _priceCtrl.dispose();
//     _quantityCtrl.dispose(); _locationCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _pickImage() async {
//     try {
//       final picker = ImagePicker();
//       final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200);
//       if (picked != null) {
//         setState(() => _image = File(picked.path));
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to pick image: $e')),
//       );
//     }
//   }

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_image == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please add at least one photo')),
//       );
//       return;
//     }

//     setState(() => _isSubmitting = true);

//     try {
//       final user = _auth.getCurrentUser(); // { name, phone, location }
//       final success = await _api.listMarketItem(
//         name: _nameCtrl.text.trim(),
//         category: _category,
//         price: double.parse(_priceCtrl.text),
//         unit: _unit,
//         quantity: int.parse(_quantityCtrl.text),
//         description: _descCtrl.text.trim(),
//         image: _image!, // File object
//         sellerPhone: user?['phone'] ?? '',
//         sellerLocation: _locationCtrl.text.trim().isNotEmpty 
//             ? _locationCtrl.text.trim() 
//             : user?['location'] ?? 'Unknown',
//         sellerName: user?['name'] ?? 'Farmer',
//       );

//       if (!mounted) return;
//       if (success) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('🎉 Item listed successfully!'),
//             backgroundColor: _primary,
//             duration: Duration(seconds: 3),
//           ),
//         );
//         Navigator.pop(context, true); // Return success to MarketScreen
//       } else {
//         throw Exception('Server rejected the listing');
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to list item: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       if (mounted) setState(() => _isSubmitting = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _bg,
//       appBar: AppBar(
//         title: const Text('List an Item'),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         foregroundColor: _primary,
//       ),
//       body: _isSubmitting
//           ? const Center(child: CircularProgressIndicator(color: _primary))
//           : Form(
//               key: _formKey,
//               child: ListView(
//                 padding: const EdgeInsets.all(16),
//                 children: [
//                   // 📸 Image Picker
//                   GestureDetector(
//                     onTap: _pickImage,
//                     child: Container(
//                       height: 200,
//                       decoration: BoxDecoration(
//                         color: Colors.grey[200],
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(color: _accent, width: 2),
//                       ),
//                       child: _image == null
//                           ? Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(Icons.add_a_photo, size: 48, color: _accent),
//                                 const SizedBox(height: 8),
//                                 Text(
//                                   'Tap to add photo',
//                                   style: TextStyle(color: Colors.grey[600]),
//                                 ),
//                               ],
//                             )
//                           : ClipRRect(
//                               borderRadius: BorderRadius.circular(14),
//                               child: Image.file(_image!, fit: BoxFit.cover),
//                             ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),

//                   // 🌾 Item Name
//                   TextFormField(
//                     controller: _nameCtrl,
//                     decoration: _inputDecoration('Item name', Icons.agriculture),
//                     validator: (v) => v!.trim().length < 3 ? 'Enter a valid name' : null,
//                   ),
//                   const SizedBox(height: 16),

//                   // 🏷️ Category & Unit Row
//                   Row(
//                     children: [
//                       Expanded(
//                         child: DropdownButtonFormField<String>(
//                           value: _category,
//                           decoration: _inputDecoration('Category', Icons.category),
//                           items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
//                           onChanged: (v) => setState(() => _category = v!),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: DropdownButtonFormField<String>(
//                           value: _unit,
//                           decoration: _inputDecoration('Unit', Icons.scale),
//                           items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
//                           onChanged: (v) => setState(() => _unit = v!),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),

//                   // 💰 Price & Quantity Row
//                   Row(
//                     children: [
//                       Expanded(
//                         child: TextFormField(
//                           controller: _priceCtrl,
//                           keyboardType: TextInputType.number,
//                           decoration: _inputDecoration('Price (UGX)', Icons.monetization_on),
//                           validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid price' : null,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: TextFormField(
//                           controller: _quantityCtrl,
//                           keyboardType: TextInputType.number,
//                           decoration: _inputDecoration('Quantity', Inventory),
//                           validator: (v) => int.tryParse(v ?? '') == null ? 'Invalid quantity' : null,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),

//                   // 📝 Description
//                   TextFormField(
//                     controller: _descCtrl,
//                     maxLines: 3,
//                     decoration: _inputDecoration('Description', Icons.description),
//                     validator: (v) => v!.trim().length < 10 ? 'Add more details (min 10 chars)' : null,
//                   ),
//                   const SizedBox(height: 16),

//                   // 📍 Location
//                   TextFormField(
//                     controller: _locationCtrl,
//                     decoration: _inputDecoration('Location (e.g., Mbarara)', Icons.location_on),
//                     validator: (v) => v!.trim().length < 3 ? 'Enter a valid location' : null,
//                   ),
//                   const SizedBox(height: 24),

//                   // ✅ Submit Button
//                   SizedBox(
//                     width: double.infinity,
//                     height: 52,
//                     child: ElevatedButton(
//                       onPressed: _submit,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _accent,
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//                         elevation: 2,
//                       ),
//                       child: const Text('🌱 List Item for Sale', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }

//   InputDecoration _inputDecoration(String label, IconData icon) {
//     return InputDecoration(
//       labelText: label,
//       prefixIcon: Icon(icon, color: _accent),
//       filled: true,
//       fillColor: Colors.white,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: BorderSide(color: Colors.grey[300]!),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: BorderSide(color: Colors.grey[300]!),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: const BorderSide(color: _accent, width: 2),
//       ),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//     );
//   }
// }