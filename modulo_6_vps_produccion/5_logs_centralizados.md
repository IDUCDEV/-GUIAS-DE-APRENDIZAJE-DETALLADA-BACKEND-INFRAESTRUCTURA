# 5. Logs Centralizados: Journald, Promtail y Loki

> **Tiempo estimado:** 45 min  
> **Nivel:** Intermedio → Avanzado

---

## 🎯 Objetivo

Aprender a gestionar logs de forma centralizada. Cuando tengas 3 servidores, no puedes entrar a cada uno a hacer `cat /var/log/syslog`. Necesitas un sistema que recopile, almacene y permita buscar logs de todos tus servicios en un solo lugar.

---

## 📖 Conceptos Fundamentales

### ¿Por qué logs centralizados?

| Problema | Solución con Logs Centralizados |
|----------|-------------------------------|
| Tienes 5 servidores y 10 contenedores | Una sola interfaz para ver todos los logs |
| No sabes por qué falló el servidor ayer | Retención histórica y búsqueda |
| El servidor se borró y perdiste los logs | Los logs están seguros en otro servidor |

### El Stack de Logs Moderno (Promtail + Loki + Grafana)

```
┌──────────┐     ┌──────────┐     ┌──────────┐
│ Servidor │────▶│Promtail  │────▶│  Loki    │
│ (Docker) │     │(Lector)  │     │(Almacén)│
└──────────┘     └──────────┘     └────┬─────┘
                                          │
                                    ┌────▼─────┐
                                    │ Grafana  │
                                    │(Visualiz)│
                                    └──────────┘
```

---

## 🔧 Componentes

### 1. Journald (Sistema Linux)
Es el sistema de logs nativo de systemd. Ya viene en Ubuntu Server.

**Comandos básicos:**
```bash
# Ver logs del sistema en tiempo real
journalctl -f

# Ver logs de un servicio específico
journalctl -u docker.service

# Ver logs desde una fecha
journalctl --since "2026-01-01" --until "2026-01-02"
```

### 2. Promtail
Es el "agente" que lee los logs de tus archivos y contenedores, y los envía a Loki.

**Concepto clave:** Promtail no almacena, solo "empuja" (push) los logs.

### 3. Loki (Almacenamiento)
Base de datos de logs diseñada por Grafana Labs. Es como Prometheus pero para logs (más económica que ELK).

**Diferencia con ELK:**
- **ELK (Elasticsearch):** Muy pesado, busca en texto completo.
- **Loki:** Ligero, indexa solo metadatos (labels), ideal para logs estructurados.

### 4. Grafana (Visualización)
Ya lo conoces de monitoreo, ahora también lo usarás para ver logs.

---

## 🏗️ Arquitectura de Ejemplo

```
Máquina 1 (Producción)
├── Serverpod App (Docker)
├── Promtail (leyendo /var/log/*.log y Docker logs)
└── Journald

Máquina 2 (Central)
├── Loki (puerto 3100)
└── Grafana (puerto 3000)

Flujo: Promtail (M1) → Envía a Loki (M2) ← Grafana lee de Loki
```

---

## 📋 Conceptos de Configuración (Sin código completo)

### Configuración de Promtail (Concepto)
Debes definir:
1. **Scrape configs:** ¿De dónde leer? (archivos, systemd, Docker)
2. **Labels:** Etiquetas para identificar el log (ej. `job="serverpod"`, `env="prod"`)
3. **Loki address:** IP de tu servidor Loki

### Configuración de Loki (Concepto)
Debes definir:
1. **Storage:** ¿Dónde guardar? (local filesystem o S3)
2. **Retention:** ¿Cuánto tiempo guardar? (ej. 30 días)
3. **Schema:** Versión de la base de datos

### En Grafana (Concepto)
1. Agregar Loki como "Data Source"
2. Ir a "Explore" → Seleccionar Loki
3. Escribir querys tipo: `{job="serverpod"} |= "error"`

---

## 🔍 Consultas en Loki (LogQL)

LogQL es el lenguaje de consulta (similar aPrometheus query language).

| Consulta | Significado |
|----------|-------------|
| `{job="serverpod"}` | Todos los logs del job "serverpod" |
| `{job="serverpod"} |= "error"` | Logs que contienen "error" |
| `{env="prod"} != "debug"` | Logs de producción excepto debug |
| `rate({job="serverpod"}[5m])` | Tasa de logs en los últimos 5 minutos |

---

## 🎓 Cuándo usar ELK vs Loki

| Situación | Recomendación |
|-----------|---------------|
| Tienes 1 servidor, pocos logs | Solo Journald + `journalctl` |
| Tienes 3-10 servidores | Loki + Promtail + Grafana |
| Necesitas búsqueda de texto completo pesada | ELK (Elasticsearch) |
| Presupuesto limitado y muchos logs | Loki (mucho más barato) |

---

## 🚀 Siguientes Pasos

1. **Práctica básica:** Configura Promtail en tu VPS para leer logs de Docker
2. **Avanzado:** Despliega Loki en un contenedor separado
3. **Experto:** Crea alertas en Grafana cuando aparezcan palabras clave (ej. "exception", "fatal")

---

## 🔗 Recursos Oficiales

- [Grafana Loki Docs](https://grafana.com/docs/loki/latest/)
- [Promtail Configuration](https://grafana.com/docs/loki/latest/clients/promtail/)
- [LogQL Query Language](https://grafana.com/docs/loki/latest/logql/)
- [Journald Man Pages](https://www.freedesktop.org/software/systemd/man/journalctl.html)

---

## ✅ Al terminar esta guía podrás:

- ✅ Entender por qué necesitas logs centralizados
- ✅ Diferenciar entre Journald, Promtail, Loki y Grafana
- ✅ Saber cómo estructurar tu arquitectura de logs
- ✅ Escribir consultas básicas en LogQL
- ✅ Decidir entre Loki vs ELK según tu caso

---

**Nota:** Para configuraciones detalladas de YAML y despliegue con Docker Compose, consulta la documentación oficial de cada herramienta.
