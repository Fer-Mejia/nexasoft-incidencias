
import 'package:flutter_test/flutter_test.dart';
import 'package:nexasoft_incidencias/model/incidencia.dart';
import 'package:nexasoft_incidencias/services/gestor_incidencias.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  tearDownAll(() {
    SharedPreferencesAsyncPlatform.instance = null;
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

  group('BUG-002: búsqueda de incidencias', () {
    late GestorIncidencias gestor;

    setUp(() {
      gestor = GestorIncidencias();

      gestor.incidencias = [
        Incidencia(
          id: 'INC-001',
          titulo: 'Falla de Internet',
          descripcion: 'El equipo perdió la conexión',
          cliente: 'Cliente de prueba',
          categoria: 'Redes',
          estado: 'Pendiente',
          fecha: '2026-10-12',
        ),
        Incidencia(
          id: 'INC-002',
          titulo: 'Error de impresora',
          descripcion: 'No imprime documentos',
          cliente: 'Otro cliente',
          categoria: 'Hardware',
          estado: 'Pendiente',
          fecha: '2026-10-13',
        ),
      ];
    });

    test('Encuentra coincidencias en minúsculas', () {
      expect(
        gestor.buscar('internet').map((x) => x.id),
        ['INC-001'],
      );
    });

    test('Encuentra coincidencias en mayúsculas', () {
      expect(
        gestor.buscar('INTERNET').map((x) => x.id),
        ['INC-001'],
      );
    });

    test('Ignora espacios al inicio y al final', () {
      expect(
        gestor.buscar('  internet  ').map((x) => x.id),
        ['INC-001'],
      );
    });

    test('Una búsqueda vacía devuelve todas las incidencias', () {
      expect(gestor.buscar('   ').length, 2);
    });

    test('Una búsqueda sin coincidencias devuelve una lista vacía', () {
      expect(gestor.buscar('cámara'), isEmpty);
    });
  });
}
