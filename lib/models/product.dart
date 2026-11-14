class Product {
  final dynamic id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String category;
  final int stock;

  const Product({required this.id, required this.name, required this.description, required this.price, required this.image, required this.category, required this.stock});

  factory Product.fromJson(Map<String, dynamic> json) {
    final images = json['imagenes'] ?? json['imagenesUrls'] ?? json['fotos'];
    String image = '';
    if (images is List && images.isNotEmpty) {
      final first = images.first;
      image = first is String ? first : (first is Map ? (first['url'] ?? '').toString() : '');
    }
    image = image.isNotEmpty ? image : (json['imagenUrl'] ?? json['imagen'] ?? json['urlImagen'] ?? '').toString();
    final categoryValue = json['categoria'];
    return Product(
      id: json['id'] ?? json['productoId'],
      name: (json['nombre'] ?? json['titulo'] ?? json['name'] ?? 'Producto').toString(),
      description: (json['descripcion'] ?? json['description'] ?? '').toString(),
      price: double.tryParse((json['precio'] ?? json['price'] ?? 0).toString()) ?? 0,
      image: image,
      category: categoryValue is Map ? (categoryValue['nombre'] ?? 'General').toString() : (categoryValue ?? 'General').toString(),
      stock: int.tryParse((json['stock'] ?? 0).toString()) ?? 0,
    );
  }
}
