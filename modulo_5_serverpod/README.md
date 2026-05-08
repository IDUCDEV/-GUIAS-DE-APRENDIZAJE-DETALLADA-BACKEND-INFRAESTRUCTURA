# Guía de Clean Architecture para Backend con Serverpod

> Una guía práctica para desarrolladores Flutter que quieren dar el salto al desarrollo backend usando Serverpod, aplicando los principios de Clean Architecture que ya conoces.

---

## 📚 Estructura de la Guía Completa

### Archivos de la Guía

```
clean_arquitecture_backend_serverpod/
├── README.md                                        ← Este archivo (índice)
├── 01-GUIA-CONCEPTUAL-BACKEND-PARA-MOBILE-DEVS.md  ← Fundamentos conceptuales
├── 02-ARQUITECTURA-CLEAN-PARA-SERVERPOD.md        ← Clean Architecture adaptada
├── 03-ESTRUCTURA-PROYECTO-SERVERPOD.md            ← Estructura de carpetas
├── 04-MODELS-Y-DATABASE.md                        ← Modelos y ORM
├── 05-ENDPOINTS-Y-SERVICIOS.md                    ← Endpoints y autenticación
├── 06-DI-DEPENDENCY-INJECTION.md                  ← Inyección de dependencias
├── 07-TESTING-BACKEND.md                          ← Testing en backend
├── 08-FUTURE-CALLS-Y-ARCHIVOS.md                  ← Streams y tiempo real
├── 09-DOCKER-Y-DESPLIEGUE.md                      ← Docker y despliegue
├── 10-GUIA-USO-IA-SERVERPOD.md                   ← Framework AIDR para IA
└── 11-GUIA-PRACTICA-PROMPTS-SERVERPOD.md          ← Prompts optimizados
```

### Contenido Detallado por Archivo

| # | Archivo | Descripción | Tiempo Estimado |
|---|---------|-------------|-----------------|
| 1 | `01-GUIA-CONCEPTUAL-BACKEND-PARA-MOBILE-DEVS.md` | Conceptos backend: API, base de datos, autenticación explicados desde Flutter | 30 min |
| 2 | `02-ARQUITECTURA-CLEAN-PARA-SERVERPOD.md` | Adaptación de Clean Architecture: Endpoints=UI, Services=UseCases, Models=Data | 45 min |
| 3 | `03-ESTRUCTURA-PROYECTO-SERVERPOD.md` | Estructura completa de carpetas, templates de código | 30 min |
| 4 | `04-MODELS-Y-DATABASE.md` | Modelos YAML, ORM de Serverpod, migraciones, serialización | 45 min |
| 5 | `05-ENDPOINTS-Y-SERVICIOS.md` | CRUD completo, autenticación Serverpod 3, validaciones, DTOs | 60 min |
| 6 | `06-DI-DEPENDENCY-INJECTION.md` | Inyección automática de Serverpod, Service Locator, Scoped Sessions | 30 min |
| 7 | `07-TESTING-BACKEND.md` | Unit tests, integration tests con `withServerpod`, mocks con mocktail | 45 min |
| 8 | `08-FUTURE-CALLS-Y-ARCHIVOS.md` | Future calls, streams, comunicación en tiempo real | 30 min |
| 9 | `09-DOCKER-Y-DESPLIEGUE.md` | Docker, despliegue a producción, CI/CD | 45 min |
| 10 | `10-GUIA-USO-IA-SERVERPOD.md` | Framework AIDR adaptado para Serverpod, prompts optimizados | 30 min |
| 11 | `11-GUIA-PRACTICA-PROMPTS-SERVERPOD.md` | 18 prompts específicos listos para usar | 20 min |

**Tiempo total estimado: ~6 horas**

### 📖 Parte 1: Fundamentos Conceptuales

| Archivo | Descripción |
|---------|-------------|
| [01-GUIA-CONCEPTUAL-BACKEND-PARA-MOBILE-DEVS.md](./01-GUIA-CONCEPTUAL-BACKEND-PARA-MOBILE-DEVS.md) | Conceptos backend explicados desde tu perspectiva mobile |
| [02-ARQUITECTURA-CLEAN-PARA-SERVERPOD.md](./02-ARQUITECTURA-CLEAN-PARA-SERVERPOD.md) | Cómo adaptar Clean Architecture a Serverpod |

### 📦 Parte 2: Implementación Práctica

| Archivo | Descripción |
|---------|-------------|
| [03-ESTRUCTURA-PROYECTO-SERVERPOD.md](./03-ESTRUCTURA-PROYECTO-SERVERPOD.md) | Estructura de carpetas y organización del proyecto |
| [04-MODELS-Y-DATABASE.md](./04-MODELS-Y-DATABASE.md) | Modelos, ORM de Serverpod, y migraciones |
| [05-ENDPOINTS-Y-SERVICIOS.md](./05-ENDPOINTS-Y-SERVICIOS.md) | Endpoints, autenticación, validaciones, y servicios |

### ⚙️ Parte 3: Configuración y Calidad

| Archivo | Descripción |
|---------|-------------|
| [06-DI-DEPENDENCY-INJECTION.md](./06-DI-DEPENDENCY-INJECTION.md) | Inyección de dependencias en el backend |
| [07-TESTING-BACKEND.md](./07-TESTING-BACKEND.md) | Testing en backend con Serverpod |

### 🔄 Parte 4: Comunicación y Tiempo Real

| Archivo | Descripción |
|---------|-------------|
| [08-FUTURE-CALLS-Y-ARCHIVOS.md](./08-FUTURE-CALLS-Y-ARCHIVOS.md) | Future calls, streams y comunicación en tiempo real |

### 🚀 Parte 5: Despliegue y Producción

| Archivo | Descripción |
|---------|-------------|
| [09-DOCKER-Y-DESPLIEGUE.md](./09-DOCKER-Y-DESPLIEGUE.md) | Docker, despliegue a producción y CI/CD |

### 🤖 Parte 6: IA en el Desarrollo Backend

| Archivo | Descripción |
|---------|-------------|
| [10-GUIA-USO-IA-SERVERPOD.md](./10-GUIA-USO-IA-SERVERPOD.md) | Framework AIDR adaptado para desarrollo con IA en Serverpod |
| [11-GUIA-PRACTICA-PROMPTS-SERVERPOD.md](./11-GUIA-PRACTICA-PROMPTS-SERVERPOD.md) | 18 prompts específicos optimizados para Serverpod |

---

## 🎯 Objetivo de la Guía

Después de completar esta guía, serás capaz de:

- ✅ Entender los conceptos fundamentales del desarrollo backend
- ✅ Aplicar Clean Architecture en un proyecto Serverpod
- ✅ Crear modelos, endpoints y servicios escalables
- ✅ Implementar autenticación y autorización
- ✅ Escribir tests para tu backend
- ✅ Implementar comunicación en tiempo real con streams
- ✅ Desplegar tu backend a producción
- ✅ Usar IA de forma inteligente para acelerar el desarrollo

---

## 🗺️ Mapa de Conceptos: Mobile → Backend

```
┌─────────────────────────────────────────────────────────────┐
│                 FLUTTER (Frontend)                          │
├─────────────────────────────────────────────────────────────┤
│  Presentation    →  Domain    →  Data                      │
│  (Widgets/Cubit)    (UseCases)   (Repositories)          │
└───────────────────────────┬─────────────────────────────────┘
                            │ Type-safe client
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                 SERVERPOD (Backend)                        │
├─────────────────────────────────────────────────────────────┤
│  Endpoints       →  Services   →  Models →  Database      │
│  (Controllers)      (UseCases)   (ORM)      (PostgreSQL)  │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔧 Requisitos Previos

- Conocimiento básico de Dart y Flutter
- Haber completado la [guía de Clean Architecture para Flutter](../clean_architecture_guide/)
- Dart SDK 3.0+
- PostgreSQL (para desarrollo local)
- Docker (para despliegue)

---

## 📦 Instalación de Serverpod

```bash
# Instalar Serverpod CLI globalmente
dart pub global activate serverpod

# Verificar instalación
serverpod --version

# Crear un nuevo proyecto
serverpod create my_project --template=blank
```

---

## 📖 Cómo Usar Esta Guía

### Si eres completamente nuevo en backend:

1. Lee [01-GUIA-CONCEPTUAL-BACKEND-PARA-MOBILE-DEVS.md](./01-GUIA-CONCEPTUAL-BACKEND-PARA-MOBILE-DEVS.md)
2. Lee [02-ARQUITECTURA-CLEAN-PARA-SERVERPOD.md](./02-ARQUITECTURA-CLEAN-PARA-SERVERPOD.md)
3. Sigue la estructura de [03-ESTRUCTURA-PROYECTO-SERVERPOD.md](./03-ESTRUCTURA-PROYECTO-SERVERPOD.md)
4. Implementa tu primer modelo siguiendo [04-MODELS-Y-DATABASE.md](./04-MODELS-Y-DATABASE.md)
5. Crea tus primeros endpoints con [05-ENDPOINTS-Y-SERVICIOS.md](./05-ENDPOINTS-Y-SERVICIOS.md)

### Si ya conoces conceptos backend:

1. Comienza con [02-ARQUITECTURA-CLEAN-PARA-SERVERPOD.md](./02-ARQUITECTURA-CLEAN-PARA-SERVERPOD.md)
2. Revisa [06-DI-DEPENDENCY-INJECTION.md](./06-DI-DEPENDENCY-INJECTION.md)
3. Aprende testing con [07-TESTING-BACKEND.md](./07-TESTING-BACKEND.md)
4. Optimiza tu flujo con [10-GUIA-USO-IA-SERVERPOD.md](./10-GUIA-USO-IA-SERVERPOD.md)

### Si quieres usar IA en tu desarrollo:

1. Lee [10-GUIA-USO-IA-SERVERPOD.md](./10-GUIA-USO-IA-SERVERPOD.md) - Aprende el framework AIDR
2. Consulta [11-GUIA-PRACTICA-PROMPTS-SERVERPOD.md](./11-GUIA-PRACTICA-PROMPTS-SERVERPOD.md) - Prompts listos para copiar

---

## 🎓 Frameworks y Patrones Cubiertos

### Clean Architecture
```
Endpoints (UI) → Services (UseCases) → Models (Data) → Database
```

### Dependency Injection
```
Constructor Injection → Service Locator → Scoped Sessions
```

### Testing
```
Unit Tests → Integration Tests → E2E Tests
```

### AI-Assisted Development
```
Framework AIDR: Analyze → Investigate → Decide → Review
```

---

## 🤝 Recursos Adicionales

- [Documentación oficial de Serverpod](https://docs.serverpod.io)
- [Serverpod GitHub](https://github.com/serverpod/serverpod)
- [Discord de Serverpod](https://discord.gg/serverpod)
- [Guía de Clean Architecture para Flutter](../clean_architecture_guide/)
- [Guía de Uso de IA para Flutter](../clean_architecture_guide/🤖%20GUÍA%20-%20Uso%20Inteligente%20de%20IA%20en%20Desarrollo%20Flutter.md)

---

**Última actualización:** 2026-03-21
**Versión:** 2.0.0
