# Módulo 3: Automatización (n8n + OpenClaw)

## 1. Conceptos de Automatización

### Objetivos de Aprendizaje

- Comprender qué es un workflow y cómo estructurarlo
- Identificar diferentes tipos de triggers
- Diseñar flujos de automatización eficientes
- Integrar servicios mediante APIs

---

## 1.1 ¿Qué es la Automatización?

### Concepto

La automatización consiste en crear flujos de trabajo que se ejecutan automáticamente, eliminando tareas repetitivas y manuales. Para un desarrollador Flutter, esto significa conectar servicios, procesar datos y notificaciones sin intervención manual.

### Casos de Uso para Desarrolladores

```
┌─────────────────────────────────────────────────────────────┐
│                    EJEMPLOS DE AUTOMATIZACIÓN              │
│                                                             │
│  1. Notificaciones:                                         │
│     - Nuevo usuario → Enviar email de bienvenida          │
│     - Pago realizado → Notificación push                  │
│                                                             │
│  2. Integraciones:                                         │
│     - Nuevo lead en CRM → Crear contacto en Serverpod    │
│     - Orden completada → Actualizar inventario           │
│                                                             │
│  3. Datos:                                                 │
│     - Scraping de ofertas de empleo → Guardar en DB      │
│     - Sincronización entre servicios                      │
│                                                             │
│  4. Mantenimiento:                                         │
│     - Backup automático de bases de datos                │
│     - Limpieza de datos antigos                           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 1.2 Estructura de un Workflow

### Componentes Fundamentales

```
┌─────────────────────────────────────────────────────────────┐
│                    ESTRUCTURA DE WORKFLOW                   │
│                                                             │
│  ┌──────────────┐                                          │
│  │   TRIGGER    │  ← Punto de inicio (qué inicia el flujo)│
│  └──────┬───────┘                                          │
│         │                                                  │
│         ▼                                                  │
│  ┌──────────────┐                                          │
│  │    NODOS     │  ← Acciones (procesar, transformar)     │
│  │  (Proceso)   │                                          │
│  └──────┬───────┘                                          │
│         │                                                  │
│         ▼                                                  │
│  ┌──────────────┐                                          │
│  │  ACCIÓN FINAL│  ← Resultado (enviar, guardar, etc.)   │
│  │   (Output)   │                                          │
│  └──────────────┘                                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Tipos de Nodos

| Tipo | Descripción | Ejemplo |
|------|-------------|---------|
| Trigger | Inicia el workflow | Webhook, Cron, Evento |
| Action | Ejecuta una acción | Enviar email, API request |
| Logic | Controla el flujo | IF/ELSE, Switch |
| Transform | Transforma datos | Set, Code |
| Output | Envía resultado | Telegram, Slack |

### Nomenclatura

```markdown
Buena nomenclatura:
- Obtener_Ofertas_Empleo
- Notificar_Nuevo_Usuario
- Sincronizar_Inventario

Evitar:
- Node_1
- Test
- Workflow_final
```

---

## 1.3 Tipos de Triggers

### Trigger por Webhook

```markdown
# Se activa cuando recibe una solicitud HTTP
# Útil para integraciones externas

Casos de uso:
- Payment gateway (Stripe, PayPal)
- Formularios web
- Integraciones con otros sistemas

Ejemplo:
Flutter app → Webhook → n8n → Procesar → Notificar
```

### Trigger por Tiempo (Cron)

```markdown
# Se ejecuta en intervalos programados
# Formato: Cron (minuto hora día mes día_semana)

Ejemplos:
- Every hour: 0 * * * *
- Every day at midnight: 0 0 * * *
- Every Monday at 9am: 0 9 * * 1
- Every 15 minutes: */15 * * * *

# En n8n:
# - Interval: cada X minutos/horas
# - Cron Expression: expresión personalizada
```

### Trigger por Evento

```markdown
# Se activa cuando ocurre un evento específico

Fuentes comunes:
- New row in database (PostgreSQL, MySQL)
- File created (Google Drive, Dropbox)
- New email (Gmail, IMAP)
- Webhook received
- RSS feed updated
```

### Trigger Manual

```markdown
# Se ejecuta cuando el usuario lo solicita
# Útil para testing y flujos bajo demanda

Ejemplo:
- Botón "Sincronizar ahora"
- Reprocesar datos
- Envío manual de notificaciones
```

---

## 1.4 Patrones de Diseño

### Patrón: Directo (Pipeline)

```
Trigger → Acción 1 → Acción 2 → Acción 3 → Output
```

```json
{
  "name": "Direct Pattern",
  "nodes": [
    {"type": "Webhook"},
    {"type": "HTTP Request"},
    {"type": "Set"},
    {"type": "Telegram"}
  ]
}
```

### Patrón: Condicional (Branch)

```
Trigger → Decision Node
              ├─→ Condición A → Acción 1
              └─→ Condición B → Acción 2
```

```json
{
  "nodes": [
    {"type": "Webhook"},
    {"type": "IF", "rules": {"value1": "{{$json.status}}", "operation": "equal", "value2": "new"}},
    {"type": "Telegram", "onTrue": {"message": "Nueva orden"}},
    {"type": "Telegram", "onFalse": {"message": "Orden actualizada"}}
  ]
}
```

### Patrón: Paralelo

```
Trigger → [Nodo A] ─┬─→ Merge → Output
                    [Nodo B] ─┘
```

```json
{
  "nodes": [
    {"type": "Webhook"},
    {"type": "HTTP Request (Stripe)", "branch": "parallel"},
    {"type": "HTTP Request (Email)", "branch": "parallel"},
    {"type": "Merge"}
  ]
}
```

### Patrón: Loop

```
Trigger → Loop Node → [Proceso cada item] → Fin Loop
```

```json
{
  "nodes": [
    {"type": "Cron"},
    {"type": "Read Database"},
    {"type": "Loop Over Items"},
    {"type": "Process Each"},
    {"type": "End Loop"}
  ]
}
```

---

## 1.5 Diseño de Workflows para Flutter

### Flujo: Notificación de Nuevos Usuarios

```
┌─────────────────────────────────────────────────────────────┐
│ WORKFLOW: Bienvenida a Nuevos Usuarios                     │
│                                                             │
│  Trigger: Webhook de Serverpod (onRegister)                │
│     │                                                       │
│     ▼                                                       │
│  1. Obtener datos del usuario                             │
│     - name, email, created_at                              │
│     ▼                                                       │
│  2. IF (es_usuario_premium)                               │
│     ├─→ Enviar email promocional premium                   │
│     └─→ Enviar email de bienvenida estándar                │
│     ▼                                                       │
│  3. Registrar en sistema de analytics                     │
│     ▼                                                       │
│  5. Notificar a admin via Telegram                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Flujo: Sincronización de Inventario

```
┌─────────────────────────────────────────────────────────────┐
│ WORKFLOW: Actualizar Inventario                            │
│                                                             │
│  Trigger: Cron (cada 6 horas)                              │
│     │                                                       │
│     ▼                                                       │
│  1. Consultar API de proveedor                             │
│     ▼                                                       │
│  2. Comparar con inventario local                          │
│     ▼                                                       │
│  3. IF (hay_cambios)                                       │
│     ├─→ Actualizar base de datos                           │
│     ├─→ Notificar cambios significativos                  │
│     └─→ Generar reporte                                    │
│     ▼                                                       │
│  4. Log de sincronización                                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 1.6 Errores Comunes y Mejores Prácticas

### Errores a Evitar

```markdown
1. Workflows demasiado largos
   - Dividir en sub-workflows
   - Máximo 10-15 nodos por flujo

2. No manejar errores
   - Siempre incluir nodo "IF Error"
   - Implementar reintentos

3. Datos sensibles en claro
   - Usar variables de entorno
   - Encriptar en almacenamiento

4. Sin logs o monitoreo
   - Añadir nodos de logging
   - Configurar alertas
```

### Mejores Prácticas

```markdown
1. Nombres descriptivos
   - "Notificar_Nuevo_Usuario" vs "Webhook"

2. Documentación
   - Añadir notas en nodos complejos
   - Crear manual de workflow

3. Testing
   - Probar con datos de prueba
   - Usar modo "development"

4. Versionado
   - Exportar workflows regularmente
   - Guardar en Git
```

---

## 1.7 Ejercicios Prácticos

### Ejercicio 1: Tu Primer Workflow

```markdown
# Crear: Notificación de prueba
1. Trigger: Manual
2. Nodo: Telegram (enviar mensaje)
3. Output: Mensaje "Hola desde n8n"

# Probando:
# Dar clic en "Test workflow"
# Recibirás un mensaje en Telegram
```

### Ejercicio 2: Webhook + Transformación

```markdown
# Workflow: Procesar datos de formulario
1. Trigger: Webhook (recibir JSON)
2. Nodo: Set (extraer campos)
3. Nodo: HTTP (enviar a Serverpod)
4. Nodo: Response (confirmar)

# Probar:
curl -X POST webhook_url \
  -H "Content-Type: application/json" \
  -d '{"name": "Test", "email": "test@test.com"}'
```

### Ejercicio 3: Programación con Cron

```markdown
# Workflow: Recordatorio diario
1. Trigger: Cron (cada día a las 9am)
2. Nodo: HTTP (consultar tareas pendientes)
3. Nodo: IF (hay_tareas)
4. Nodo: Telegram (enviar recordatorio)

# Configurar Cron:
# 0 9 * * 1-5 (9am, lunes a viernes)
```

---

## 1.8 Recursos Adicionales

### Herramientas de Automatización

| Herramienta | Tipo | Mejor para |
|------------|------|-------------|
| n8n | Self-hosted | Flexibilidad, código |
| Zapier | Cloud | No-code, rápido |
| Make (Integromat) | Cloud | Visual, complejo |
| Pipefy | BPM | Procesos de negocio |

### Conceptos Clave Resumen

```
Workflow = Trigger + Nodos + Output

Trigger types:
- Webhook (HTTP)
- Cron (tiempo)
- Event (base de datos, archivos)
- Manual (bajo demanda)

Nodos:
- Action (hacer algo)
- Logic (decidir)
- Transform (cambiar datos)
- Output (enviar resultado)
```

---

## Resumen

En esta guía has aprendido:

- ✅ Qué es un workflow y sus componentes
- ✅ Tipos de triggers (webhook, cron, evento, manual)
- ✅ Patrones de diseño (directo, condicional, loop)
- ✅ Mejores prácticas para workflows
- ✅ Diseñar flujos para Flutter/Serverpod

**Siguiente guía:** n8n Avanzado - Nodos, variables y transformación de datos.