import 'package:flutter/material.dart';

/// Deja las pestañas fijas arriba cuando la cabecera sube.
class BarraPestanas extends SliverPersistentHeaderDelegate {
  const BarraPestanas(this.pestanas);

  final TabBar pestanas;

  @override
  double get minExtent => pestanas.preferredSize.height;

  @override
  double get maxExtent => pestanas.preferredSize.height;

  @override
  Widget build(BuildContext context, double desplazado, bool encima) =>
      ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: pestanas,
      );

  @override
  bool shouldRebuild(BarraPestanas anterior) => anterior.pestanas != pestanas;
}
