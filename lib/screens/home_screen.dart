import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  final search = TextEditingController();
  List<Product> products = [];
  List<Product> filtered = [];
  List<String> categories = ['Todos'];
  final Set<String> favorites = {};
  final List<Product> cart = [];
  bool loading = true;
  String? error;
  String selectedCategory = 'Todos';
  int tab = 0;

  @override void initState() { super.initState(); loadData(); }
  @override void dispose() { search.dispose(); super.dispose(); }

  Future<void> loadData() async {
    setState(() { loading = true; error = null; });
    try {
      final results = await Future.wait([ApiService.get('/api/productos?pagina=0&tamano=30&orden=recientes'), ApiService.get('/api/categorias')]);
      final raw = results[0];
      final List list = raw is List ? raw : (raw is Map && raw['content'] is List ? raw['content'] as List : (raw is Map && raw['data'] is List ? raw['data'] as List : []));
      products = list.whereType<Map>().map((e) => Product.fromJson(Map<String, dynamic>.from(e))).toList();
      final cats = results[1];
      if (cats is List) categories = ['Todos', ...cats.whereType<Map>().map((e) => (e['nombre'] ?? '').toString()).where((e) => e.isNotEmpty)];
      _filter();
    } catch (e) { error = e.toString().replaceFirst('Exception: ', ''); }
    if (mounted) setState(() => loading = false);
  }

  void _filter() {
    final q = search.text.trim().toLowerCase();
    filtered = products.where((p) => (selectedCategory == 'Todos' || p.category.toLowerCase() == selectedCategory.toLowerCase()) && (q.isEmpty || p.name.toLowerCase().contains(q) || p.description.toLowerCase().contains(q))).toList();
  }
  void _message(String value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  Future<void> _login() async { final ok = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const LoginScreen())); if (ok == true) _message('Sesión iniciada correctamente.'); }
  Future<void> _logout() async { final p = await SharedPreferences.getInstance(); await p.remove('accessToken'); await p.remove('userEmail'); if (mounted) setState(() {}); }

  @override Widget build(BuildContext context) {
    final pages = [ _homeContent(), _cartContent(), _favoritesContent(), _profileContent() ];
    return Scaffold(
      appBar: AppBar(title: Row(children: [const Icon(Icons.storefront_rounded, color: Color(0xFFE53935), size: 29), const SizedBox(width: 8), const Text('Mercatto', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -.5)), const Spacer(), IconButton(tooltip: 'Actualizar', onPressed: loadData, icon: const Icon(Icons.refresh))]),
      body: pages[tab],
      bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (v) => setState(() => tab = v), destinations: [const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'), NavigationDestination(icon: Badge(label: Text('${cart.length}'), isLabelVisible: cart.isNotEmpty, child: const Icon(Icons.shopping_bag_outlined)), label: 'Carrito'), const NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Favoritos'), const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil')]),
    );
  }

  Widget _homeContent() => RefreshIndicator(onRefresh: loadData, child: ListView(padding: const EdgeInsets.fromLTRB(16, 10, 16, 24), children: [
    Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: const LinearGradient(colors: [Color(0xFFE53935), Color(0xFFB71C1C)])), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('TODO LO QUE BUSCAS,\nEN UN SOLO LUGAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 23, height: 1.2)), SizedBox(height: 8), Text('Compra y descubre productos de diferentes vendedores.', style: TextStyle(color: Colors.white70))]),),
    const SizedBox(height: 18), TextField(controller: search, onChanged: (_) => setState(_filter), decoration: InputDecoration(hintText: '¿Qué estás buscando?', prefixIcon: const Icon(Icons.search), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
    const SizedBox(height: 18), const Text('Categorías', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 10), SizedBox(height: 40, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: categories.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (_, i) => ChoiceChip(label: Text(categories[i]), selected: selectedCategory == categories[i], onSelected: (_) => setState(() { selectedCategory = categories[i]; _filter(); })))),
    const SizedBox(height: 20), Row(children: [const Expanded(child: Text('Productos para ti', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))), Text('${filtered.length} resultados', style: const TextStyle(color: Colors.black54, fontSize: 12))]), const SizedBox(height: 12),
    if (loading) const Padding(padding: EdgeInsets.all(35), child: Center(child: CircularProgressIndicator()))
    else if (error != null) _errorBox()
    else if (filtered.isEmpty) const Padding(padding: EdgeInsets.all(30), child: Center(child: Text('No encontramos productos. Intenta actualizar o cambiar la búsqueda.')))
    else GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: filtered.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: .67, crossAxisSpacing: 12, mainAxisSpacing: 12), itemBuilder: (_, i) => _productCard(filtered[i])),
  ]));

  Widget _errorBox() => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(children: [const Icon(Icons.cloud_off_outlined, size: 40, color: Colors.redAccent), const SizedBox(height: 8), const Text('No pudimos conectar con Mercatto', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 6), Text(error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54, fontSize: 12)), const SizedBox(height: 12), OutlinedButton.icon(onPressed: loadData, icon: const Icon(Icons.refresh), label: const Text('Reintentar'))]));

  Widget _productCard(Product p) => InkWell(onTap: () => _showProduct(p), borderRadius: BorderRadius.circular(16), child: Card(clipBehavior: Clip.antiAlias, margin: EdgeInsets.zero, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Stack(fit: StackFit.expand, children: [Container(color: const Color(0xFFF0F0F0), child: p.image.isEmpty ? const Icon(Icons.image_outlined, size: 55, color: Colors.black26) : Image.network(p.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined, size: 45, color: Colors.black26))), Positioned(right: 6, top: 6, child: CircleAvatar(radius: 17, backgroundColor: Colors.white, child: IconButton(padding: EdgeInsets.zero, iconSize: 18, onPressed: () => setState(() { final id = '${p.id}'; favorites.contains(id) ? favorites.remove(id) : favorites.add(id); }), icon: Icon(favorites.contains('${p.id}') ? Icons.favorite : Icons.favorite_border, color: Colors.red))))])), Padding(padding: const EdgeInsets.fromLTRB(10, 9, 10, 10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)), const SizedBox(height: 5), Text(p.category, style: const TextStyle(color: Colors.black45, fontSize: 11)), const SizedBox(height: 5), Text(_money(p.price), style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFE53935), fontSize: 16)), const SizedBox(height: 7), SizedBox(width: double.infinity, child: FilledButton.tonal(onPressed: () { setState(() => cart.add(p)); _message('Producto agregado al carrito.'); }, child: const Text('Agregar', style: TextStyle(fontSize: 12))))]))]));

  void _showProduct(Product p) => showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 30), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [ClipRRect(borderRadius: BorderRadius.circular(14), child: SizedBox(height: 210, width: double.infinity, child: p.image.isEmpty ? const Icon(Icons.image, size: 60) : Image.network(p.image, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 50)))), const SizedBox(height: 16), Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 21)), const SizedBox(height: 5), Text(_money(p.price), style: const TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.bold, fontSize: 20)), const SizedBox(height: 12), Text(p.description.isEmpty ? 'Consulta los detalles del producto con el vendedor.' : p.description), const SizedBox(height: 15), SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () { Navigator.pop(context); setState(() => cart.add(p)); _message('Producto agregado al carrito.'); }, icon: const Icon(Icons.shopping_bag_outlined), label: const Text('Agregar al carrito')))])));

  Widget _cartContent() => cart.isEmpty ? _empty('Tu carrito está vacío', Icons.shopping_bag_outlined, 'Explora los productos y agrega los que te interesen.') : ListView(padding: const EdgeInsets.all(16), children: [Text('${cart.length} producto(s)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), ...cart.asMap().entries.map((e) => Card(child: ListTile(leading: const Icon(Icons.shopping_bag_outlined, color: Colors.red), title: Text(e.value.name), subtitle: Text(_money(e.value.price)), trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => setState(() => cart.removeAt(e.key))))), const SizedBox(height: 12), Text('Total: ${_money(cart.fold<double>(0, (s, p) => s + p.price))}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)), const SizedBox(height: 12), FilledButton(onPressed: _login, child: const Text('Inicia sesión para continuar'))]);
  Widget _favoritesContent() { final list = products.where((p) => favorites.contains('${p.id}')).toList(); return list.isEmpty ? _empty('Aún no tienes favoritos', Icons.favorite_border, 'Marca con el corazón los productos que quieras guardar.') : ListView(padding: const EdgeInsets.all(16), children: list.map((p) => Card(child: ListTile(title: Text(p.name), subtitle: Text(_money(p.price)), leading: const Icon(Icons.favorite, color: Colors.red), onTap: () => _showProduct(p)))).toList()); }
  Widget _profileContent() => FutureBuilder<SharedPreferences>(future: SharedPreferences.getInstance(), builder: (_, snap) { final prefs = snap.data; final email = prefs?.getString('userEmail'); final token = prefs?.getString('accessToken'); return ListView(padding: const EdgeInsets.all(20), children: [const CircleAvatar(radius: 42, child: Icon(Icons.person, size: 45)), const SizedBox(height: 14), Center(child: Text(token == null ? 'Bienvenido a Mercatto' : (email ?? 'Mi cuenta'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19))), const SizedBox(height: 18), if (token == null) FilledButton(onPressed: _login, child: const Text('Iniciar sesión')) else OutlinedButton.icon(onPressed: _logout, icon: const Icon(Icons.logout), label: const Text('Cerrar sesión')), const SizedBox(height: 10), const ListTile(leading: Icon(Icons.shield_outlined), title: Text('Compra con mayor confianza'), subtitle: Text('Revisa la información del producto y del vendedor antes de realizar tu pedido.'))]); });
  Widget _empty(String title, IconData icon, String subtitle) => Center(child: Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 60, color: Colors.black26), const SizedBox(height: 12), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), const SizedBox(height: 6), Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54))])));
  String _money(double value) => '\$${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}';
}
