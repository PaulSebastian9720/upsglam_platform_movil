abstract final class Formatos {
  /// "ahora", "hace 5 min", "hace 3 h", "ayer", "hace 4 días" o la fecha.
  static String hace(DateTime fecha, {DateTime? ahora}) {
    final d = (ahora ?? DateTime.now()).difference(fecha);
    if (d.inMinutes < 1) return 'ahora';
    if (d.inHours < 1) return 'hace ${d.inMinutes} min';
    if (d.inDays < 1) return 'hace ${d.inHours} h';
    if (d.inDays == 1) return 'ayer';
    if (d.inDays < 7) return 'hace ${d.inDays} días';
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }
}
