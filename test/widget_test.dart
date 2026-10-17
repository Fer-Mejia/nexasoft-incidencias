import 'package:flutter_test/flutter_test.dart';
import 'package:nexasoft_incidencias/model/incidencia.dart';
import 'package:nexasoft_incidencias/services/gestor_incidencias.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('Una incidencia antigua puede convertirse desde JSON', () {
    final registro = Incidencia.desdeJson({
      'id': 'INC-DEMO',
      'titulo': 'Prueba',
      'descripcion': 'Caso de ejemplo',
      'cliente': 'Cliente ficticio',
      'categoria': 'Redes',
      'estado': 'Pendiente',
      'fecha': '2026-10-12',
    });

    expect(registro.id, 'INC-DEMO');
    expect(registro.toJson()['estado'], 'Pendiente');
  });

  test('contar devuelve la cantidad correcta por estado', () {
    final gestor = GestorIncidencias();

    gestor.incidencias = [
      crearIncidencia('1', 'Pendiente'),
      crearIncidencia('2', 'Pendiente'),
      crearIncidencia('3', 'Resuelta'),
    ];

    expect(gestor.contar('Pendiente'), 2);
    expect(gestor.contar('Resuelta'), 1);
    expect(gestor.contar('En proceso'), 0);
  });

  test('crear aumenta el contador de pendientes', () async {
    final gestor = GestorIncidencias();

    await gestor.crear(
  'Error de red',
  'No hay conexión',
  'Cliente de prueba',
  'Redes',
  'Media',
);
    expect(gestor.cantidadPendientes, 1);
    expect(gestor.contar('Pendiente'), 1);
  });

  test('cambiar estado actualiza el contador de pendientes', () async {
    final gestor = GestorIncidencias();

    gestor.incidencias = [
      crearIncidencia('1', 'Pendiente'),
      crearIncidencia('2', 'Pendiente'),
    ];
    gestor.cantidadPendientes = 2;

    await gestor.cambiarEstado('1', 'Resuelta');

    expect(gestor.cantidadPendientes, 1);
    expect(gestor.contar('Pendiente'), 1);
    expect(gestor.contar('Resuelta'), 1);
  });
}

Incidencia crearIncidencia(String id, String estado) {
  return Incidencia(
    id: id,
    titulo: 'Incidencia $id',
    descripcion: 'Descripción de prueba',
    cliente: 'Cliente de prueba',
    categoria: 'Redes',
    estado: estado,
    fecha: '2026-10-12',
  );
}