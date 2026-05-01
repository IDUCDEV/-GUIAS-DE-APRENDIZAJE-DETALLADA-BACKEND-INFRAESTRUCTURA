# 12. Arquitectura: Microservicios vs Monolitos

> **Tiempo estimado:** 45 min  
> **Nivel:** Intermedio → Avanzado

---

## 🎯 Objetivo

Entender las diferencias entre un Monolito y Microservicios, y cuándo tu aplicación (Serverpod) debe evolucionar de uno a otro.

---

## 📖 Conceptos Fundamentales

### 1. El Monolito (Todo en uno)

Toda la lógica de tu backend vive en un solo proceso/proyecto.

```
┌─────────────────────────────────┐
│       Serverpod App (Monolito)   │
│                                 │
│  ┌──────────┐  ┌──────────┐   │
│  │ Auth     │  │ Payments │   │
│  └──────────┘  └──────────┘   │
│  ┌──────────┐  ┌──────────┐   │
│  │ Users    │  │ Products │   │
│  └──────────┘  └──────────┘   │
└───────────────┬─────────────────┘
                │
                ▼
        ┌───────────────┐
        │ PostgreSQL DB  │
        └───────────────┘
```

**Pros:**
- ✅ Fácil de desarrollar y debuggear (todo está en un lugar).
- ✅ Despliegue simple (un solo contenedor Docker).
- ✅ Transacciones de base de datos simples (ACID).

**Contras:**
- ❌ Si una parte falla, toda la app falla.
- ❌ Difícil de escalar solo una parte (ej. solo "Payments").
- ❌ A medida que crece, el código se vuelve un "espagueti" difícil de mantener.

---

### 2. Microservicios (Divide y Vencerás)

La lógica se divide en servicios independientes que se comunican entre sí (usualmente vía HTTP/REST o gRPC).

```
┌────────────┐  HTTP  ┌────────────┐
│ Auth Svc   │ ◀─────▶│ User Svc   │
└────────────┘        └────────────┘
      │  HTTP               │
      ▼                    ▼
┌─────────────────────────────────┐
│         API Gateway            │  ← Punto único de entrada
└───────────────┬───────────────┘
                │
                ▼
         ┌────────────┐
         │  Flutter   │
         └────────────┘
```

**Pros:**
- ✅ Escalabilidad independiente (Puedes tener 10 instancias de "Payments" y 2 de "Auth").
- ✅ Tecnología independiente (Un servicio puede ser Python, otro Dart).
- ✅ Aislamiento de fallos (Si Payments falla, Auth sigue funcionando).

**Contras:**
- ❌ Complejidad operativa (Necesitas orquestación, Docker, Redes).
- ❌ Dificultad en transacciones distribuidas (No hay ACID simple).
- ❌ Observabilidad compleja (Necesitas Tracing, ver Módulo 6).

---

## 🏗️ ¿Cuándo pasar de Monolito a Microservicios?

Esta es la pregunta de 1 millón de dólares.

| Señal | Recomendación |
|-------|-----------------|
| Eres 1 solo desarrollador | **Monolito** (Serverpod básico) |
| Tienes un equipo de 3+ devs | Considera dividir |
| Tienes 1,000 usuarios | **Monolito** |
| Tienes 100,000 usuarios | **Microservicios** (Escala bajo demanda) |
| La app es una "Admin Panel" | **Monolito** |
| La app es "Uber/Airbnb" | **Microservicios** |

**Regla de Oro:** *"Monolito Modular" primero, Microservicios después.*

---

## 🗺️ Monolito Modular (El Camino del Medio)

No necesitas separar en proyectos diferentes inmediatamente. Puedes estructurar tu Serverpod como un monolito pero con módulos bien separados (Clean Architecture ayuda mucho aquí).

```
serverpod_project/
├── lib/src/
│   ├── auth/         (Módulo Auth)
│   │   ├── endpoints/
│   │   └── services/
│   ├── payments/     (Módulo Payments)
│   │   ├── endpoints/
│   │   └── services/
│   └── shared/       (Código común)
└── pubspec.yaml
```

Si más adelante quieres separar "Payments", solo tienes que mover la carpeta a un nuevo proyecto Serverpod.

---

## 📋 Comparación Técnica

| Característica | Monolito | Microservicios |
|----------------|-----------|----------------|
| **Despliegue** | 1 vez | N veces (1 por servicio) |
| **Base de Datos** | 1 DB compartida | 1 DB por servicio (idealmente) |
| **Comunicación** | Llamadas a funciones locales | HTTP / gRPC / Colas |
| **Testing** | Fácil (Unit + Integration) | Complejo (Contract Testing) |
| **Serverpod** | 1 Proyecto | N Proyectos Serverpod |

---

## 🚀 Siguientes Pasos

1.  **Práctica:** Mantén tu proyecto Serverpod actual como un Monolito Modular.
2.  **Avanzado:** Crea un segundo proyecto Serverpod (ej. "Notificaciones") y haz que se comunique con el primero.
3.  **Experto:** Implementa un API Gateway (como Kong o Traefik) para manejar el tráfico hacia tus microservicios.

---

## 🔗 Recursos Oficiales

- [Martin Fowler: Monolith First](https://martinfowler.com/bliki/MonolithFirst.html)
- [Microservices.io](https://microservices.io/)
- [Serverpod Documentation](https://docs.serverpod.dev/)

---

## ✅ Al terminar esta guía podrás:

- ✅ Definir qué es un Monolito y qué son Microservicios
- ✅ Identificar señales de que tu app necesita escalar
- ✅ Estructurar un Monolito Modular (La mejor práctica inicial)
- ✅ Decidir cuándo es el momento de dividir tu backend
- ✅ Entender la complejidad operativa de los microservicios

---

**Nota:** Para ejemplos de comunicación entre servicios (gRPC/REST), consulta la siguiente guía: `13-COMUNICACION-ENTRE-SERVICIOS.md`.
