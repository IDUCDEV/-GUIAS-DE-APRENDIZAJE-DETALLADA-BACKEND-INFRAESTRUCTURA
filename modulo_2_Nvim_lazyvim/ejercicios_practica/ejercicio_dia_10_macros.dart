// ========================================================================
// LABORATORIO - DÍA 10: AUTOMATIZACIÓN CON MACROS EN DART
// ========================================================================
//
// INSTRUCCIONES:
// - Graba una macro en el registro 'a' para formatear la primera línea.
// - Detén la macro y aplícala a las líneas restantes de un solo golpe.

class User {
  final String name;
  const User({required this.name});
}

// ------------------------------------------------------------------------
// TAREA:
// Transformar la lista de nombres planos de abajo en instancias de la clase User.
// Ejemplo final esperado:
//   User(name: "Juan"),
//
// PASOS EXACTOS:
// 1. Pon el cursor en la primera comilla de "Juan" (línea 30).
// 2. Presiona `qa` para comenzar a grabar la macro en el registro 'a'.
// 3. Presiona `i` (Insertar) y escribe `User(name: `.
// 4. Presiona `Esc` para volver a modo Normal.
// 5. Presiona `ea` (ir al final de la palabra y entrar a modo Insertar) y escribe `),`.
// 6. Presiona `Esc` para volver a modo Normal.
// 7. Presiona `j` (bajar a la siguiente línea) y `0` (ir al inicio de la línea).
// 8. Presiona `q` para detener la grabación de la macro.
// 9. Ahora que estás en la línea de 'Maria', presiona `4@a` para formatear
//    automáticamente las 4 líneas restantes de una sola vez.

const users = [
  "Juan",
  "Maria",
  "Pedro",
  "Ana",
  "Sofia",
];

// ========================================================================
// FIN DEL EJERCICIO - ¡Si lograste formatear todos, eres un maestro de las Macros!
// ========================================================================
