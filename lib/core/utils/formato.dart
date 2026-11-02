/// Formatea una fecha como dd/MM/yyyy HH:mm (sin depender de intl).
String formatearFecha(DateTime fecha) {
  String dos(int n) => n.toString().padLeft(2, '0');
  return '${dos(fecha.day)}/${dos(fecha.month)}/${fecha.year} ${dos(fecha.hour)}:${dos(fecha.minute)}';
}

/// Convierte bytes a un texto legible (KB o MB).
String formatearBytes(int bytes) {
  if (bytes >= 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
  return '${(bytes / 1024).toStringAsFixed(0)} KB';
}
