import 'package:flutter/foundation.dart';

import '../../modelos/publicacion/publicacion.dart';
import '../../repositorios/perfil/perfil_repositorio.dart';
import '../../repositorios/publicaciones/publicaciones_repositorio.dart';

class PublicacionController extends ChangeNotifier {
  PublicacionController(this._publicaciones, this._perfil, this.id);

  final PublicacionesRepositorio _publicaciones;
  final PerfilRepositorio _perfil;
  final String id;

  Publicacion? _publicacion;
  bool _cargando = false;
  bool _fallo = false;
  bool _noExiste = false;
  bool _viva = true;

  /// Nula mientras llega por primera vez.
  Publicacion? get publicacion => _publicacion;
  bool get cargando => _cargando;
  bool get fallo => _fallo;

  /// Se borró, por ejemplo desde Editar publicación.
  bool get noExiste => _noExiste;
  bool get esMia => _publicacion?.autor.id == _perfil.miId;

  /// Al recargar se mantiene lo que había mientras llega lo nuevo.
  Future<void> cargar() async {
    if (_cargando) return;
    _cambiar(() {
      _cargando = true;
      _fallo = false;
    });
    try {
      final nueva = await _publicaciones.publicacion(id);
      _cambiar(() {
        _publicacion = nueva;
        _noExiste = false;
      });
    } on StateError {
      // Así responde hoy el repositorio cuando la publicación ya no está.
      _cambiar(() {
        _publicacion = null;
        _noExiste = true;
      });
    } catch (_) {
      _cambiar(() => _fallo = true);
    } finally {
      _cambiar(() => _cargando = false);
    }
  }

  /// Cambia al instante. Aún no hay servidor al que avisar.
  void alternarMeGusta() {
    final p = _publicacion;
    if (p == null) return;
    final mio = !p.meGustaMio;
    _cambiar(
      () => _publicacion = Publicacion(
        id: p.id,
        autor: p.autor,
        imagen: p.imagen,
        filtro: p.filtro,
        creada: p.creada,
        texto: p.texto,
        meGusta: p.meGusta + (mio ? 1 : -1),
        meGustaMio: mio,
        comentarios: p.comentarios,
        privada: p.privada,
      ),
    );
  }

  void _cambiar(VoidCallback cambio) {
    cambio();
    if (_viva) notifyListeners();
  }

  @override
  void dispose() {
    _viva = false;
    super.dispose();
  }
}
