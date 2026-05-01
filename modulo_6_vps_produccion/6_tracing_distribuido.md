# 6. Tracing Distribuido: OpenTelemetry y Jaeger

> **Tiempo estimado:** 45 min  
> **Nivel:** Avanzado

---

## 🎯 Objetivo

Entender cómo rastrear una petición que pasa por múltiples servicios (ej. Flutter App → Serverpod API → Supabase DB). Esto es "Tracing Distribuido".

---

## 📖 Conceptos Fundamentales

### El Problema: "La Caja Negra"

En un monolito, si algo falla, miras el log.
En microservicios, una petición toca 5 servicios. ¿En cuál falló? ¿Cuánto tardó cada paso?

### Terminología

| Término | Significado |
|---------|-------------|
| **Trace** | El viaje completo de una petición (ej. "Pagar compra") |
| **Span** | Una unidad de trabajo dentro del trace (ej. "Consultar saldo") |
| **Context Propagation** | Pasar el ID del trace de un servicio a otro |
| **Exporter** | A dónde enviamos los datos (Jaeger, Zipkin, Datadog) |

---

## 🔧 OpenTelemetry (El Estándar)

OpenTelemetry (OTel) es el estándar de la industria (CNCF) para generar datos de telemetría. No es una herramienta de visualización, es una **biblioteca** que se instala en tu código.

### Arquitectura OTel

```
Tu Código (Serverpod)
    │
    ▼
OpenTelemetry SDK (Auto-instrumentation)
    │
    ├──▶ Traces (Spans)
    ├──▶ Metrics
    └──▶ Logs
          │
          ▼
    OTLP Protocol
          │
          ▼
    Jaeger / Zipkin / Prometheus
```

### Conceptos Clave de OTel

1. **Instrumentation:** Código que genera telemetría. Puede ser:
   - **Auto-instrumentation:** Librerías que hacen "magia" y detectan HTTP, DB, etc.
   - **Manual instrumentation:** Tú escribes el código para crear spans custom.

2. **OTLP (OpenTelemetry Protocol):** El protocolo estándar para enviar datos. Es eficiente (gRPC/protobuf).

3. **Collector:** Un servicio intermedio que recibe datos de muchos servicios y los envía a donde quieras (Jaeger, Datadog, etc.).

---

## 🔍 Jaeger (Visualización)

Jaeger es la herramienta de visualización (el "Grafana" de los traces). Creada por Uber.

### ¿Qué ves en Jaeger?

```
Trace ID: abc-123
├── Span: HTTP GET /api/users (Serverpod) [200ms]
│   ├── Span: DB Query SELECT * FROM users (Postgres) [50ms]
│   └── Span: Cache GET user_123 (Redis) [5ms]
└── Span: Auth Verify Token (Auth Service) [30ms]
```

Esto te dice exactamente dónde se está tardando tu aplicación.

---

## 🏗️ Arquitectura de Ejemplo

```
┌─────────────────┐     ┌─────────────────┐
│  Flutter App    │────▶│  Serverpod      │
│                 │     │  (Instrumented) │
└─────────────────┘     └────────┬────────┘
                                 │ Traces vía OTLP
                                 ▼
                          ┌─────────────────┐
                          │  Jaeger UI      │
                          │  (Puerto 16686) │
                          └─────────────────┘
```

---

## 📋 Conceptos de Implementación (Sin código pesado)

### Paso 1: Instrumentar Serverpod
Necesitas una librería (paquete pub.dev) que integre OpenTelemetry con Serverpod.
Buscas: `serverpod_opentelemetry` o similar.

**Concepto:** El middleware de Serverpod intercepta cada request y crea un "Span" automáticamente.

### Paso 2: Configurar el Exporter
Le dices a tu app: "Envía los traces a `http://jaeger:4318`".

### Paso 3: Levantar Jaeger
Jaeger se levanta fácilmente con Docker:
```bash
docker run -d --name jaeger \
  -p 16686:16686 \
  -p 4318:4318 \
  jaegertracing/all-in-one:latest
```
*(Nota: El puerto 16686 es la UI, el 4318 es OTLP gRPC/HTTP)*

---

## 📊 Diferencias: Metrics vs Traces vs Logs

| Tipo | Responde a | Ejemplo |
|------|------------|---------|
| **Metrics** | "¿Cuántos?" (Números) | Latencia promedio: 200ms |
| **Traces** | "¿Por qué tardó?" (Viaje) | El paso 3 de 5 tardó 150ms |
| **Logs** | "¿Qué pasó?" (Evento) | "Error: Connection refused" |

---

## 🚀 Casos de Uso Avanzados

### 1. Latency Analysis
Identificar qué servicio está haciendo lento el sistema.

### 2. Error Tracking
Ver el trace completo que llevó a un error 500.

### 3. Dependency Graph
Jaeger puede dibujar automáticamente cómo se conectan tus servicios.

---

## 🎓 Cuándo usar Tracing

| Situación | ¿Necesitas Tracing? |
|-----------|----------------------|
| 1 servidor monolito | No. Con logs basta. |
| 2-3 microservicios | Sí, empieza a ver dependencias. |
| Serverpod + Supabase + n8n | Sí, para ver cuellos de botella. |
| Alta carga de usuarios | Crítico para optimización. |

---

## 🔗 Recursos Oficiales

- [OpenTelemetry Docs](https://opentelemetry.io/docs/)
- [Jaeger Documentation](https://www.jaegertracing.io/docs/)
- [What is OTLP?](https://opentelemetry.io/docs/specs/otlp/)
- [CNCF Observability Whitepaper](https://github.com/cncf/tag-observability)

---

## ✅ Al terminar esta guía podrás:

- ✅ Explicar la diferencia entre Trace, Span y Log
- ✅ Entender qué es OpenTelemetry y por qué es el estándar
- ✅ Visualizar viajes de datos en Jaeger UI
- ✅ Saber cuándo tu app necesita tracing distribuido
- ✅ Configurar arquitecturas básicas de observabilidad

---

**Nota:** Para configuraciones específicas de `opentelemetry-dart` y exportadores, revisa la documentación oficial de las librerías en `pub.dev`.
