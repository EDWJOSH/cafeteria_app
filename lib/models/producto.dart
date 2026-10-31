import 'package:flutter/material.dart';

/// Modelo de datos de un producto del catálogo.
class Producto {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String categoria;
  final IconData icono;

  const Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.categoria,
    required this.icono,
  });
}

/// Productos de ejemplo del menú de Grano & Co.
const List<Producto> catalogo = [
  Producto(
    id: 1,
    nombre: 'Café americano',
    descripcion: 'Café negro preparado con granos tostados de la casa. Suave y aromático.',
    precio: 1.50,
    categoria: 'Bebidas calientes',
    icono: Icons.coffee,
  ),
  Producto(
    id: 2,
    nombre: 'Capuchino',
    descripcion: 'Espresso con leche vaporizada y una capa de espuma cremosa con canela.',
    precio: 2.50,
    categoria: 'Bebidas calientes',
    icono: Icons.coffee_maker,
  ),
  Producto(
    id: 3,
    nombre: 'Frappé de caramelo',
    descripcion: 'Café helado licuado con hielo, leche y salsa de caramelo.',
    precio: 3.00,
    categoria: 'Bebidas frías',
    icono: Icons.local_drink,
  ),
  Producto(
    id: 4,
    nombre: 'Cheesecake de fresa',
    descripcion: 'Porción de cheesecake horneado con salsa de fresa natural.',
    precio: 3.25,
    categoria: 'Postres',
    icono: Icons.cake,
  ),
  Producto(
    id: 5,
    nombre: 'Croissant de chocolate',
    descripcion: 'Croissant de mantequilla relleno de chocolate, recién horneado.',
    precio: 1.75,
    categoria: 'Panadería',
    icono: Icons.bakery_dining,
  ),
];
