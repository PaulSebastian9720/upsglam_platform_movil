import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../componentes/estado_vacio.dart';
import '../../tema/app_theme.dart';
import 'comentarios_controller.dart';
import 'componentes/cabecera_hoja.dart';
import 'componentes/campo_comentario.dart';
import 'componentes/fila_comentario.dart';

/// Hoja de comentarios de una publicación. Se abre desde Inicio y desde Ver
/// publicación.
class ComentariosPage extends StatelessWidget {
  const ComentariosPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => ComentariosController(context.read(), id),
    child: const _ComentariosVista(),
  );
}

class _ComentariosVista extends StatefulWidget {
  const _ComentariosVista();

  @override
  State<_ComentariosVista> createState() => _ComentariosVistaState();
}

class _ComentariosVistaState extends State<_ComentariosVista> {
  ScrollController? _lista;

  /// Tras publicar, baja hasta el comentario nuevo, que es el último.
  Future<bool> _enviar(String texto) async {
    final publicado = await context.read<ComentariosController>().enviar(texto);
    if (publicado) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final lista = _lista;
        if (lista == null || !lista.hasClients) return;
        lista.animateTo(
          lista.position.maxScrollExtent,
          duration: kThemeAnimationDuration,
          curve: Curves.easeOut,
        );
      });
    }
    return publicado;
  }

  @override
  Widget build(BuildContext context) {
    final control = context.watch<ComentariosController>();
    final lista = control.comentarios;
    return Padding(
      // El campo de escribir sube con el teclado.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 1,
        snap: true,
        snapSizes: const [0.7],
        builder: (context, desplazar) {
          _lista = desplazar;
          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  controller: desplazar,
                  slivers: [
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: CabeceraHoja(
                        titulo: 'Comentarios',
                        alCerrar: () => Navigator.maybePop(context),
                      ),
                    ),
                    if (control.fallo)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: EstadoVacio(
                          mensaje: 'No se pudieron cargar los comentarios',
                          accion: 'Reintentar',
                          alPulsar: control.cargar,
                        ),
                      )
                    else if (lista == null)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (lista.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: EstadoVacio(
                          mensaje:
                              'Aún no hay comentarios. Escribe el primero.',
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.all(AppEspacio.base),
                        sliver: SliverList.separated(
                          itemCount: lista.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppEspacio.l),
                          itemBuilder: (_, i) =>
                              FilaComentario(comentario: lista[i]),
                        ),
                      ),
                  ],
                ),
              ),
              CampoComentario(enviando: control.enviando, alEnviar: _enviar),
            ],
          );
        },
      ),
    );
  }
}
