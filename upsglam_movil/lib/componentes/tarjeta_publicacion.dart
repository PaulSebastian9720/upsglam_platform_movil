import 'package:flutter/material.dart';

import '../modelos/filtro/filtro.dart';
import '../modelos/publicacion/publicacion.dart';
import '../tema/app_theme.dart';
import '../utilidades/formatos.dart';
import 'app_icono.dart';
import 'avatar_usuario.dart';
import 'imagen_app.dart';
import 'zoom_en_sitio.dart';

/// Publicación completa: autor, foto con su filtro, me gusta, comentarios y
/// texto. Se usa en Inicio y en Ver publicación.
class TarjetaPublicacion extends StatelessWidget {
  const TarjetaPublicacion({
    super.key,
    required Publicacion this.publicacion,
    this.alPulsarAutor,
    this.alPulsarMeGusta,
    this.alPulsarComentarios,
    this.loSigo,
    this.alPulsarSeguir,
  });

  /// Bloques grises con la forma final, mientras llega la publicación.
  const TarjetaPublicacion.cargando({super.key})
    : publicacion = null,
      alPulsarAutor = null,
      alPulsarMeGusta = null,
      alPulsarComentarios = null,
      loSigo = null,
      alPulsarSeguir = null;

  final Publicacion? publicacion;
  final VoidCallback? alPulsarAutor;
  final VoidCallback? alPulsarMeGusta;
  final VoidCallback? alPulsarComentarios;

  /// Si sigo al autor. Nulo en mis publicaciones: no se muestra nada.
  final bool? loSigo;
  final VoidCallback? alPulsarSeguir;

  /// Marco de la foto de una publicación: todo el ancho, 5:6.

  @override
  Widget build(BuildContext context) {
    final p = publicacion;
    return p == null ? _cargando(context) : _publicacion(context, p);
  }

  Widget _publicacion(BuildContext context, Publicacion p) {
    final tema = Theme.of(context);
    final estados = tema.extension<AppEstados>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppEspacio.base,
            right: AppEspacio.xs,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppMedida.toque + AppEspacio.s,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _Autor(publicacion: p, alPulsar: alPulsarAutor),
                  ),
                ),
                if (loSigo == false)
                  TextButton(
                    onPressed: alPulsarSeguir,
                    child: const Text('Seguir'),
                  )
                else if (loSigo == true)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppEspacio.m,
                    ),
                    child: Text(
                      'Siguiendo',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
        ),
        AspectRatio(
          aspectRatio: AppMedida.proporcionPublicacion,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Pellizcar amplía la foto ahí mismo.
              ZoomEnSitio(
                child: ImagenApp.recurso(
                  p.imagen,
                  descripcion: p.texto.isEmpty
                      ? 'Foto con ${p.filtro.nombre}'
                      : p.texto,
                ),
              ),
              if (p.filtro != Filtro.original)
                Positioned(
                  left: AppEspacio.m,
                  bottom: AppEspacio.m,
                  child: _EtiquetaFiltro(p.filtro),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppEspacio.xs),
          child: Row(
            children: [
              _Accion(
                icono: p.meGustaMio ? Iconos.meGustaActivo : Iconos.meGusta,
                color: p.meGustaMio ? estados.meGusta : null,
                valor: p.meGusta,
                descripcion: p.meGustaMio
                    ? 'Quitar me gusta, ${p.meGusta}'
                    : 'Me gusta, ${p.meGusta}',
                alPulsar: alPulsarMeGusta,
              ),
              _Accion(
                icono: Iconos.comentario,
                valor: p.comentarios,
                descripcion: 'Ver ${p.comentarios} comentarios',
                alPulsar: alPulsarComentarios,
              ),
            ],
          ),
        ),
        if (p.texto.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppEspacio.base),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: p.autor.usuario,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' ${p.texto}'),
                ],
              ),
              style: tema.textTheme.bodyLarge,
            ),
          ),
      ],
    );
  }

  Widget _cargando(BuildContext context) {
    final campo = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppEspacio.base),
          child: SizedBox(
            height: AppMedida.toque + AppEspacio.s,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox.square(
                dimension: AppMedida.avatarFeed,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: campo,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
        AspectRatio(
          aspectRatio: AppMedida.proporcionPublicacion,
          child: ColoredBox(color: campo),
        ),
        const SizedBox(height: AppMedida.toque),
      ],
    );
  }
}

class _Autor extends StatelessWidget {
  const _Autor({required this.publicacion, this.alPulsar});

  final Publicacion publicacion;
  final VoidCallback? alPulsar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final autor = publicacion.autor;
    return Semantics(
      button: alPulsar != null,
      child: InkWell(
        onTap: alPulsar,
        borderRadius: BorderRadius.circular(AppRadio.base),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppMedida.toque),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AvatarUsuario(
                imagen: autor.avatar,
                usuario: autor.usuario,
                tamano: AppMedida.avatarFeed,
              ),
              const SizedBox(width: AppEspacio.m),
              Flexible(
                child: Text(
                  autor.usuario,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tema.textTheme.titleMedium,
                ),
              ),
              const SizedBox(width: AppEspacio.s),
              Text(
                Formatos.hace(publicacion.creada),
                maxLines: 1,
                style: tema.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EtiquetaFiltro extends StatelessWidget {
  const _EtiquetaFiltro(this.filtro);

  final Filtro filtro;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final letra = tema.textTheme.labelMedium!;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tema.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(AppRadio.base),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppEspacio.m,
          vertical: AppEspacio.s,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // El icono mide lo mismo que la línea de texto.
            AppIcono(
              Iconos.filtros,
              tamano: letra.fontSize! * (letra.height ?? 1),
            ),
            const SizedBox(width: AppEspacio.s),
            Text(filtro.nombre, style: letra),
          ],
        ),
      ),
    );
  }
}

class _Accion extends StatelessWidget {
  const _Accion({
    required this.icono,
    required this.valor,
    required this.descripcion,
    this.color,
    this.alPulsar,
  });

  final Iconos icono;
  final int valor;
  final String descripcion;
  final Color? color;
  final VoidCallback? alPulsar;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).colorScheme.onSurface;
    return Semantics(
      label: descripcion,
      child: TextButton(
        style: TextButton.styleFrom(foregroundColor: texto),
        onPressed: alPulsar,
        child: ExcludeSemantics(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcono(icono, color: color),
              const SizedBox(width: AppEspacio.s),
              Text('$valor'),
            ],
          ),
        ),
      ),
    );
  }
}
