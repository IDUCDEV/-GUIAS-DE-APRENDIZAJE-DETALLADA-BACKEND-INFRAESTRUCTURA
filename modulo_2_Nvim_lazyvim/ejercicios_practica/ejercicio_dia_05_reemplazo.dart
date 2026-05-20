// ========================================================================
// LABORATORIO - DÍA 5: BÚSQUEDA Y REEMPLAZO EN DART
// ========================================================================
//
// INSTRUCCIONES:
// - Usa comandos de búsqueda (/) y reemplazo (:s).
// - No utilices el ratón.

// ------------------------------------------------------------------------
// EJERCICIO 1: Búsqueda interactiva (/)
// Tarea: Localiza la clase "ServicioAntiguo" y cámbiala por "ServicioNuevo".
// Pasos:
//   1. En modo Normal, presiona `/` y escribe "ServicioAntiguo" seguido de Enter.
//   2. El cursor saltará a la primera ocurrencia.
//   3. Presiona `n` para ir a la siguiente ocurrencia.
//   4. Usa `ciw` sobre la palabra para cambiarla a "ServicioNuevo" y pulsa Esc.

class ServicioAntiguo {
  void iniciar() => print("Servicio antiguo activo.");
}

void inyectarDependencias() {
  final api = ServicioAntiguo();
  api.iniciar();
}

// ------------------------------------------------------------------------
// EJERCICIO 2: Reemplazo global en el archivo actual (:s)
// Tarea: Reemplaza todas las palabras "Mock" por "Real" en las líneas de abajo.
// Pasos:
//   1. En modo Normal, escribe el comando:
//      :%s/Mock/Real/g
//   2. Presiona Enter. Verás cómo todas cambian automáticamente.

class MockAuthRepository {}
class MockDatabaseHelper {}
class MockAnalyticService {}

// ------------------------------------------------------------------------
// EJERCICIO 3: Búsqueda y reemplazo con confirmación (:s...c)
// Tarea: Reemplaza "TODO" por "FIXME" pero solo confirmando algunas.
// Pasos:
//   1. Ejecuta el comando:
//      :%s/TODO/FIXME/gc
//   2. Neovim se detendrá en cada ocurrencia preguntando si deseas realizar el cambio.
//   3. Presiona 'y' (yes) para cambiar, o 'n' (no) para saltar esa ocurrencia.

// TODO: Refactorizar este helper de fechas (Cambiar esta)
// TODO: Documentar método de autenticación (Ignorar esta / pulsar 'n')
// TODO: Arreglar error de null safety (Cambiar esta)

// ========================================================================
// FIN DEL EJERCICIO - ¡Dominas la búsqueda y el reemplazo!
// ========================================================================
