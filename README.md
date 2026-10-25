# Café Aroma - Catálogo de productos

Prototipo (MVP) de una aplicación móvil en Flutter para el catálogo de una cafetería.
Actividad Integradora 1 - Desarrollo de Aplicaciones Móviles.

## Funcionalidades

- **Pantalla 1 (HomeScreen):** banner, información del local y menú de productos en tarjetas.
- **Pantalla 2 (DetalleScreen):** detalle del producto y formulario de pedido
  (nombre con validación, tamaño, cantidad y total calculado).
- **Navegación:** `Navigator.push` envía el producto elegido a la Pantalla 2 y
  `Navigator.pop` regresa el resumen del pedido, que se muestra en la Pantalla 1.

## Estructura del proyecto

```
lib/
├── main.dart                  # Punto de entrada y tema de la app
├── models/
│   └── producto.dart          # Modelo Producto y catálogo de ejemplo
├── screens/
│   ├── home_screen.dart       # Pantalla 1
│   └── detalle_screen.dart    # Pantalla 2
└── widgets/
    ├── info_chip.dart         # Ícono + texto (horario, ubicación)
    └── producto_card.dart     # Tarjeta reutilizable de producto
```

## Entorno

- Flutter 3.47.8 (canal stable), Dart 3.13.7
- Verificación del entorno: `flutter doctor -v`

## Cómo ejecutarlo

```bash
flutter pub get
flutter run
```

## Pruebas

```bash
flutter test
```

Incluye una prueba del flujo completo: abrir el detalle del Capuchino, validar el
formulario y regresar a la Pantalla 1 con el pedido.

## Autor

Edwin Quiroz
