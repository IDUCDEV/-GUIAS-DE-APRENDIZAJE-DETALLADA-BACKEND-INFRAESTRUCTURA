# 13. Comunicación entre Servicios: gRPC, REST y Colas

> **Tiempo estimado:** 45 min  
> **Nivel:** Avanzado

---

## 🎯 Objetivo

Aprender los patrones de comunicación cuando tienes múltiples servicios (Microservicios) y necesitan hablarse entre sí.

---

## 📖 Patrones de Comunicación

### 1. Síncrona (Request/Response)
El Servicio A le pregunta al Servicio B y espera la respuesta.

| Protocolo | Descripción | Cuándo usar |
|-----------|--------------|-------------|
| **REST API** | Basado en HTTP/JSON. Fácil de debuggear con Postman. | Llamadas simples, baja carga. |
| **gRPC** | Basado en HTTP/2 y Protobuf. Muy rápido y eficiente. | Alta performance, baja latencia. |
| **GraphQL** | Pides exactamente lo que necesitas. | Frontend móvil que quiere evitar over-fetching. |

### 2. Asíncrona (Event-Driven / Message Queues)
El Servicio A envía un mensaje y no espera respuesta inmediata.

| Tecnología | Descripción | Cuándo usar |
|------------|--------------|-------------|
| **Redis Pub/Sub** | "Publica" un evento, los que escuchan lo reciben. | Notificaciones en tiempo real. |
| **RabbitMQ** | Cola de mensajes robusta con confirmación. | Tareas pesadas (enviar emails, procesar video). |
| **Apache Kafka** | Stream de eventos masivo. | Big Data, logs, métricas. |

---

## 🔧 gRPC con Serverpod (El estándar moderno)

Serverpod usa **gRPC** por defecto para la comunicación entre Flutter y el Backend.
*Nota: Esto es lo que hace que Serverpod sea "type-safe" (el cliente Flutter sabe qué tipos esperar).*

### Concepto de Protobuf
En lugar de JSON (texto), usas Protocol Buffers (binario).
```protobuf
// Esto es lo que Serverpod genera automáticamente por ti
message User {
  string id = 1;
  string name = 2;
  string email = 3;
}
```

### Comunicación Server-to-Server (Conceptual)
Si tienes un Serverpod "Auth" y uno "Payments":

1.  **Auth Service** necesita verificar un pago.
2.  **Auth Service** llama a **Payments Service** usando un cliente gRPC generado.
3.  **Payments Service** responde con el estado del pago.

*En Serverpod, esto se hace creando un "client" del otro servidor en tu código.*

---

## 📦 Colas de Mensajes (Redis / RabbitMQ)

Imagina que un usuario se registra. Tienes que:
1. Guardar en DB.
2. Enviar Email de bienvenida.
3. Generar PDF de contrato.

**Problema:** Si el servicio de Email está caído, el registro falla.

**Solución: Colas (Async)**
```
User Registration (Serverpod)
    │
    ├──▶ Guardar en DB (Inmediato)
    └──▶ Enviar a COLA: "send_welcome_email" (Asíncrono)
              │
              ▼
        [ RabbitMQ ]
              │
              ▼
    Worker de Emails (Lee de la cola y envía)
```

### Redis Pub/Sub (Simple)
Ideal para notificaciones en tiempo real dentro de tu infraestructura.
```
Serverpod A (Publicador): "Hey, el usuario 123 cambió su foto"
Serverpod B (Suscriptor): "Ok, avisaré al cliente Flutter vía WebSocket"
```

---

## 🏗️ Arquitectura de Ejemplo (Híbrida)

```
┌───────────┐
│  Flutter App (Client)                      │
└──────────────────┬──────────────────────────┘
                   │ gRPC (Serverpod Client)
                   ▼
┌─────────────────────────────────────────────┐
│  API Gateway (Opcional)                     │
└───────────────┬────────────────────────────┘
                │
    ┌───────────┴───────────┐
    ▼                       ▼
┌───────────┐         ┌───────────┐
│ Serverpod │◀─REST──▶│ Serverpod │
│  Auth     │         │ Payments  │
└─────┬─────┘         └─────┬─────┘
      │                       │
      └───────────┬───────────┘
                  │ Redis Pub/Sub
                  ▼
          ┌───────────────┐
          │ Notifications  │
          │ (Worker/Svc)   │
          └───────────────┘
```

---

## 📋 Cuadro Comparativo: ¿Qué usar?

| Situación | Mejor Opción |
|-----------|--------------|
| Flutter ↔ Backend (Serverpod) | **gRPC** (Nativo de Serverpod) |
| Backend A ↔ Backend B (Rápido) | **gRPC** o **REST** |
| Tarea pesada (Procesar video) | **RabbitMQ** (Cola) |
| Notificar a otros servicios | **Redis Pub/Sub** |
| Transacción crítica (Pagar) | **Síncrono (REST/gRPC)** con fallback |

---

## 🚀 Siguientes Pasos

1.  **Práctica:** Configura dos containers Docker: uno con Serverpod y otro con un "servicio fake" (puede ser un Nginx simple) y haz una petición HTTP desde Serverpod.
2.  **Avanzado:** Levanta un Redis y haz que tu Serverpod publique un mensaje simple.
3.  **Experto:** Implementa un "Circuit Breaker" (patrón de resiliencia) para que si un servicio falla, el otro no se cuelgue esperando.

---

## 🔗 Recursos Oficiales

- [gRPC Official Docs](https://grpc.io/docs/)
- [RabbitMQ Tutorials](https://www.rabbitmq.com/tutorials)
- [Redis Pub/Sub](https://redis.io/docs/interact/pubsub/)
- [Serverpod Clients](https://docs.serverpod.dev/concepts/clients)

---

## ✅ Al terminar esta guía podrás:

- ✅ Diferenciar comunicación Síncrona vs Asíncrona
- ✅ Entender por qué Serverpod usa gRPC
- ✅ Saber qué es una Cola de Mensajes (Message Queue)
- ✅ Elegir el protocolo correcto según el caso de uso
- ✅ Diseñar arquitecturas híbridas (Síncrono + Colas)

---

**Nota:** Para implementaciones específicas de `HttpClient` en Serverpod o configuración de paquetes como `rabbitmq_client`, consulta la documentación oficial de pub.dev.
