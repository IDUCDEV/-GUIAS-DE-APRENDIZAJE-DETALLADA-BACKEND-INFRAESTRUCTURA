// ========================================================================
// LABORATORIO - DÍA 4: MODOS VISUALES Y SELECCIÓN EN BLOQUE EN DART
// ========================================================================
//
// INSTRUCCIONES:
// - Usa v, V y Ctrl + v para realizar selecciones visuales avanzadas.
// - Sigue las instrucciones paso a paso.

// ------------------------------------------------------------------------
// EJERCICIO 1: Selección por líneas (V)
// Tarea: Borra las 3 líneas de código de depuración obsoletas de un solo golpe.
// Pasos:
//   1. Sitúa el cursor en la línea 17 (primera línea obsoleta).
//   2. Presiona `V` para entrar en Modo Visual de Línea.
//   3. Presiona `j` dos veces para seleccionar las 3 líneas completas.
//   4. Presiona `d` para borrarlas todas juntas.

void cargarWidget() {
  print("Cargando UI...");
  print("DEBUG: Variable X = 12");
  print("DEBUG: Estado de conexión = NULL");
  print("DEBUG: Token caducado");
  print("UI cargada correctamente.");
}

// ------------------------------------------------------------------------
// EJERCICIO 2: Inserción en Bloque Vertical (Ctrl + v)
// Tarea: Convierte todas estas variables locales en "final" agregando la palabra
//        "final " al inicio de todas simultáneamente.
// Pasos:
//   1. Pon el cursor en la letra 'S' de 'String' (línea 34).
//   2. Presiona `Ctrl + v` para entrar en Modo Visual de Bloque.
//   3. Presiona `j` dos veces para seleccionar verticalmente el inicio de las 3 líneas.
//   4. Presiona `Shift + I` (Insertar al inicio).
//   5. Escribe `final ` (con espacio al final).
//   6. Presiona `Esc` (espera un segundo y verás cómo se replica en las demás).

void configurarEntorno() {
  String apiHost = "localhost";
  int apiPort = 3000;
  bool isDev = true;
}

// ------------------------------------------------------------------------
// EJERCICIO 3: Reemplazo en Bloque (Ctrl + v -> r)
// Tarea: Cambia los guiones '-' de este comentario o mapa por asteriscos '*'
// Pasos:
//   1. Pon el cursor en el primer guion '-' (línea 48).
//   2. Presiona `Ctrl + v`.
//   3. Presiona `j` dos veces para seleccionar los tres guiones verticalmente.
//   4. Presiona `r` y luego escribe `*`.

// - Tarea Flutter 1: Crear UI
// - Tarea Flutter 2: Integrar API
// - Tarea Flutter 3: Escribir Tests

// ========================================================================
// FIN DEL EJERCICIO - ¡Has dominado los Modos Visuales de Vim!
// ========================================================================
