// ========================================================================
// LABORATORIO - DÍA 3: EDICIÓN SUPERFÓNICA Y TEXT OBJECTS EN DART
// ========================================================================
//
// INSTRUCCIONES:
// - Realiza cada ejercicio usando operadores (c, d, y) y objetos de texto (iw, i", i(, i{).
// - Presiona 'u' en modo Normal si cometes un error para deshacerlo.
// - Presiona 'Ctrl + r' para rehacer (redo).

// ------------------------------------------------------------------------
// EJERCICIO 1: Cambiar palabra completa (ciw)
// Tarea: Cambia la variable "miVariableVieja" por "nombreUsuario".
// Pasos: Pon el cursor sobre "miVariableVieja" en modo Normal.
//        Presiona `ciw`, escribe `nombreUsuario` y presiona `Esc`.

String miVariableVieja = "Invitado";

// ------------------------------------------------------------------------
// EJERCICIO 2: Cambiar texto dentro de comillas (ci") o (ci')
// Tarea: Cambia el mensaje "Ruta no encontrada" por "Acceso restringido".
// Pasos: Pon el cursor dentro de las comillas.
//        Presiona `ci"`, escribe `Acceso restringido` y presiona `Esc`.

const String mensajeError = "Ruta no encontrada";

// ------------------------------------------------------------------------
// EJERCICIO 3: Cambiar contenido de paréntesis (ci()
// Tarea: Cambia los argumentos del constructor de (String email, int edad) a (User user).
// Pasos: Pon el cursor dentro de los paréntesis.
//        Presiona `ci(`, escribe `User user` y presiona `Esc`.

void actualizarPerfil(String email, int edad) {
  print("Perfil actualizado.");
}

// ------------------------------------------------------------------------
// EJERCICIO 4: Borrar cuerpo de método entre llaves (di{)
// Tarea: Elimina el cuerpo de la función obsoleta para poder reescribirla.
// Pasos: Pon el cursor dentro de las llaves `{}`. Presiona `di{`.

Map<String, dynamic> serializarDatos() {
  final mapa = <String, dynamic>{};
  mapa['id'] = 999;
  mapa['status'] = 'deprecated';
  return mapa;
}

// ------------------------------------------------------------------------
// EJERCICIO 5: Usar el punto mágico (.)
// Tarea: Cambia la palabra "inactivo" por "activo" en todas las líneas.
// Pasos:
//   1. Coloca el cursor sobre "inactivo" en la línea 56.
//   2. Presiona `ciw`, escribe `activo` y presiona `Esc`.
//   3. Baja a la línea 57, sitúa el cursor en "inactivo" y presiona `.`.
//   4. Repite para la línea 58.

const String estadoUno = "inactivo";
const String estadoDos = "inactivo";
const String estadoTres = "inactivo";

// ========================================================================
// FIN DEL EJERCICIO - ¡Si lograste completarlos, dominas los Text Objects!
// ========================================================================
