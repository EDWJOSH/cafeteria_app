import 'package:flutter/material.dart';

/// Íconos disponibles para los productos. En el JSON se guarda la clave (texto)
/// porque un IconData no se puede serializar.
const Map<String, IconData> iconosProducto = {
  'americano': Icons.coffee,
  'capuchino': Icons.coffee_maker,
  'frappe': Icons.local_drink,
  'cheesecake': Icons.cake,
  'croissant': Icons.bakery_dining,
  'coldbrew': Icons.water_drop,
  'cafe': Icons.local_cafe,
};

/// Modelo de datos de un producto del catálogo.
class Producto {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String categoria;
  final String iconoKey;

  const Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.categoria,
    required this.iconoKey,
  });

  IconData get icono => iconosProducto[iconoKey] ?? Icons.local_cafe;

  factory Producto.fromJson(Map<String, dynamic> json) => Producto(
    id: json['id'] as int,
    nombre: json['nombre'] as String,
    descripcion: json['descripcion'] as String,
    precio: (json['precio'] as num).toDouble(),
    categoria: json['categoria'] as String,
    iconoKey: json['icono'] as String? ?? 'cafe',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'descripcion': descripcion,
    'precio': precio,
    'categoria': categoria,
    'icono': iconoKey,
  };
}

/// Menú básico incluido en la app. Se usa solo si nunca se pudo descargar
/// el catálogo y tampoco hay uno guardado en caché.
const List<Producto> catalogoBase = [
  Producto(
    id: 1,
    nombre: 'Café americano',
    descripcion: 'Café negro preparado con granos tostados de la casa. Suave y aromático.',
    precio: 1.50,
    categoria: 'Bebidas calientes',
    iconoKey: 'americano',
  ),
  Producto(
    id: 2,
    nombre: 'Capuchino',
    descripcion: 'Espresso con leche vaporizada y una capa de espuma cremosa con canela.',
    precio: 2.50,
    categoria: 'Bebidas calientes',
    iconoKey: 'capuchino',
  ),
  Producto(
    id: 3,
    nombre: 'Frappé de caramelo',
    descripcion: 'Café helado licuado con hielo, leche y salsa de caramelo.',
    precio: 3.00,
    categoria: 'Bebidas frías',
    iconoKey: 'frappe',
  ),
  Producto(
    id: 4,
    nombre: 'Cheesecake de fresa',
    descripcion: 'Porción de cheesecake horneado con salsa de fresa natural.',
    precio: 3.25,
    categoria: 'Postres',
    iconoKey: 'cheesecake',
  ),
  Producto(
    id: 5,
    nombre: 'Croissant de chocolate',
    descripcion:
        'Croissant de mantequilla relleno de chocolate, recién horneado.',
    precio: 1.75,
    categoria: 'Panadería',
    iconoKey: 'croissant',
  ),
];
