// ========================================================================
// LABORATORIO - DÍA 2: MOVIMIENTOS NATIVOS (MOTIONS) EN DART
// ========================================================================
//
// INSTRUCCIONES:
// - Usa ÚNICAMENTE las teclas: h, j, k, l, w, b, e, 0, $, gg, G.
// - ¡Prohibido tocar el ratón y las flechas del teclado!
// - Realiza las siguientes tareas de navegación.

import 'dart:math';

class GestorUsuarios {
  final String apiToken;
  final int limitePeticiones;

  GestorUsuarios({required this.apiToken, this.limitePeticiones = 100});

  // ----------------------------------------------------------------------
  // TAREA 1: Navegación horizontal rápida por palabras
  // - Ubica el cursor al principio de la línea de abajo.
  // - Presiona 'w' repetidamente para avanzar de palabra en palabra.
  // - Presiona 'b' para regresar de la misma forma.
  // - Presiona 'e' para situarte al final de cada palabra.
  
  void inicializar() => print("Inicializando servicio de usuarios activos...");

  // ----------------------------------------------------------------------
  // TAREA 2: Navegación de inicio y fin de línea
  // - Sitúate en cualquier parte de la línea de abajo.
  // - Presiona '$' para saltar instantáneamente al punto final (punto y coma).
  // - Presiona '0' (cero) para regresar al inicio de la línea.
  
  final String urlBase = "https://api.flutterdev.com/v2/auth/user/profile";

  // ----------------------------------------------------------------------
  // TAREA 3: Saltos verticales extremos
  // - Presiona 'G' para ir a la última línea de este archivo.
  // - Presiona 'i' para entrar en modo Insertar, añade un comentario y sal con 'Esc'.
  // - Presiona 'gg' para volver a esta misma línea superior.
  // - Regresa a esta clase usando solo 'j' y 'k'.
}

// ========================================================================
// FIN DEL EJERCICIO - ¡Si dominas esto, estás listo para el Día 3!
// ========================================================================
