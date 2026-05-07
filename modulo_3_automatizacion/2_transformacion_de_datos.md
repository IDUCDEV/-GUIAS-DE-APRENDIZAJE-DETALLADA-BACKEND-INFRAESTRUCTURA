# Módulo 3: Automatización con n8n
## 3.2 Transformación de Datos: El Corazón de la Automatización

### Objetivos de Aprendizaje
- Dominar el nodo **Edit Fields (Set)** para limpiar datos.
- Usar el nodo **Filter** para tomar decisiones complejas.
- Aprender a unir datos de diferentes fuentes con **Merge**.
- Introducción a las **Expresiones** y al nodo **Code**.

---

## 1. Expresiones: El lenguaje de n8n
Las expresiones te permiten insertar datos dinámicos en cualquier campo. Se escriben entre llaves dobles: `{{ ... }}`.

### Ejemplos comunes:
- `{{ $json.nombre }}`: Accede al campo "nombre" del nodo anterior.
- `{{ $now.plus({ days: 1 }).toFormat('dd/MM/yyyy') }}`: Calcula la fecha de mañana.
- `{{ $json.precio * 1.21 }}`: Calcula el precio con IVA.

---

## 2. Nodos de Limpieza y Organización

### Edit Fields (Set)
Es el nodo que más usarás. Sirve para:
- **Renombrar:** Cambiar `first_name` por `nombre`.
- **Eliminar:** Quitar datos basura que no necesitas enviar a tu base de datos.
- **Calcular:** Crear un campo nuevo basado en otros (ej: `nombre_completo` = `nombre` + `apellido`).

### Filter & Sort
- **Filter:** Bloquea el flujo si no se cumple una condición (ej: "Solo procesar pedidos mayores a $100").
- **Sort:** Ordena tu lista de items (ej: por fecha o por prioridad).

---

## 3. Unir Datos con el nodo Merge
Imagina que tienes una lista de usuarios de una base de datos y quieres añadirles el clima actual de su ciudad.
- **Merge** te permite tomar la Entrada A y la Entrada B y unirlas.
- **Modos comunes:**
  - **Append:** Pone una lista debajo de la otra.
  - **Enrich:** (El más usado) Busca un ID común y pega los datos de ambos nodos en un solo item.

---

## 4. Aprender Haciendo: El Limpiador de Leads

### El Reto
Recibes una lista de correos mal escrita y necesitas enviársela a tu equipo de ventas limpia y en mayúsculas.

#### Paso A: Simular datos sucios
1. Crea un **Manual Trigger**.
2. Conecta un nodo **Code** y pega este código (solo para generar datos):
   ```javascript
   return [
     { email: "JUAN@gmail.com ", nombre: "juan" },
     { email: " maria@Hotmail.com", nombre: "MARIA" },
     { email: "pedro@gmail.com", nombre: "peDro" }
   ];
   ```

#### Paso B: Limpieza con Edit Fields
1. Añade un nodo **Edit Fields**.
2. Crea un campo nuevo `email_limpio`:
   - Valor: `{{ $json.email.trim().toLowerCase() }}` (Esto quita espacios y lo pone en minúsculas).
3. Crea un campo `nombre_formateado`:
   - Valor: `{{ $json.nombre.charAt(0).toUpperCase() + $json.nombre.slice(1).toLowerCase() }}` (Pone solo la primera letra en mayúscula).

#### Paso C: Filtrar solo Gmail
1. Añade un nodo **Filter**.
2. Condición: `{{ $json.email_limpio }}` -> `Contains` -> `@gmail.com`.

---

## 5. El Nodo Code (JavaScript Avanzado)
A veces, los nodos visuales no son suficientes. El nodo **Code** te permite usar JavaScript puro de Node.js.

### ¿Cuándo usarlo?
- Cuando necesitas hacer cálculos matemáticos muy complejos.
- Cuando quieres transformar un Array complejo de una API.
- Cuando quieres ejecutar un "Loop" personalizado.

**Ejemplo de código rápido en n8n:**
```javascript
for (const item of $input.all()) {
  item.json.iva = item.json.precio * 0.21;
  item.json.total = item.json.precio + item.json.iva;
}
return $input.all();
```

---

## 6. Buenas Prácticas de Transformación
1. **No satures el flujo:** Si puedes hacer 3 cambios en un solo nodo *Edit Fields*, no uses 3 nodos distintos.
2. **Nombra tus nodos:** En lugar de "Edit Fields", ponle "Limpiar Emails". Esto ayuda a tu "yo del futuro" a entender el flujo.
3. **Usa Notas:** Haz clic derecho en el canvas y añade notas para documentar por qué hiciste esa transformación.

---

## Ejercicio Práctico del Capítulo
1. Crea un flujo que reciba un número de teléfono.
2. Usa un nodo **Edit Fields** para asegurarte de que empiece por `+34` (si no lo tiene).
3. Usa una expresión para contar cuántos caracteres tiene el número final.

**Siguiente Guía:** 3.3 Conectividad Total - APIs, Webhooks y Credenciales.
