# 🚀 Ruta de Aprendizaje: Backend & Infraestructura para Flutter

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)

> **Nivel**: Intermedio → Avanzado  
> **Duración estimada**: 3-4 meses (1-2 horas/día)  
> **Total de guías**: 21 documentos detallados

## 📖 Descripción

Esta ruta de aprendizaje está diseñada para desarrolladores Flutter que desean expandir sus conocimientos hacia el backend y la infraestructura. El objetivo es que puedas:

- 🏗️ **Construir tu propio backend** con Serverpod (Dart)
- 🐳 **Desplegar aplicaciones** con Docker y Dokploy
- 🗄️ **Gestionar bases de datos** PostgreSQL
- ⚙️ **Automatizar tareas** con n8n
- ☁️ **Operar tu propia infraestructura** en un VPS

---

## 🗺️ Tabla de Contenidos

| Módulo | Tema | Guías |
|--------|------|:-----:|
| **1** | Fundamentos de Linux y Redes | [4](./modulo_1_linux_redes/) |
| **2** | Docker y Dokploy (Orquestación) | [3](./modulo_2_docker_dokploy/) |
| **3** | Automatización (n8n + OpenClaw) | [3](./modulo_3_automatizacion/) |
| **4** | Backend con Serverpod (El Cerebro) | [4](./modulo_4_serverpod/) |
| **5** | Infraestructura Pro (Supabase + Odoo) | [3](./modulo_5_supabase_odoo/) |
| **6** | Despliegue en VPS Remoto (Producción) | [4](./modulo_6_vps_produccion/) |

---

## 📚 Contenido por Módulo

### 🟦 Módulo 1: Fundamentos de Linux y Redes

El cimiento de todo. Antes de programar, debes saber dónde vive tu código.

| Guía | Descripción |
|------|-------------|
| [1. Instalación y Acceso](./modulo_1_linux_redes/1_instalacion_y_acceso.md) | Ubuntu Server headless, SSH, IP dinámica vs estática |
| [2. La Terminal (Bash/Zsh)](./modulo_1_linux_redes/2_terminal_bash_zsh.md) | Navegación, gestión de archivos, nano/vim |
| [3. Usuarios y Seguridad](./modulo_1_linux_redes/3_usuarios_y_seguridad.md) | sudoers, permisos (chmod/chown), UFW firewall |
| [4. Networking Básico](./modulo_1_linux_redes/4_networking_basico.md) | Puertos, sockets, localhost vs IP privada |

---

### 🟨 Módulo 2: Docker y Dokploy

Aprende a desplegar servicios sin ensuciar tu sistema operativo.

| Guía | Descripción |
|------|-------------|
| [1. Fundamentos de Docker](./modulo_2_docker_dokploy/1_fundamentos_docker.md) | Imágenes, contenedores, volúmenes, redes |
| [2. Docker Compose](./modulo_2_docker_dokploy/2_docker_compose.md) | Orquestación YAML, múltiples servicios |
| [3. Dokploy](./modulo_2_docker_dokploy/3_dokploy.md) | Panel de control, deployments con un clic, SSL |

---

### 🟩 Módulo 3: Automatización (n8n + OpenClaw)

Tu primera herramienta de productividad real.

| Guía | Descripción |
|------|-------------|
| [1. Conceptos de Automatización](./modulo_3_automatizacion/1_conceptos_automatizacion.md) | Workflows, triggers, patrones de diseño |
| [2. n8n Avanzado](./modulo_3_automatizacion/2_n8n_avanzado.md) | HTTP Request, Set, Code (JS), variables de entorno |
| [3. Scraping y APIs](./modulo_3_automatizacion/3_scraping_y_apis.md) | OpenClaw, webhooks, integración con Serverpod |

---

### 🟥 Módulo 4: Backend con Serverpod

Aquí es donde tu lógica de Flutter se convierte en servidor.

| Guía | Descripción |
|------|-------------|
| [1. Arquitectura de Servidor](./modulo_4_serverpod/1_arquitectura_servidor.md) | RPC vs REST, generación de código, estructura de proyecto |
| [2. Modelado de Datos (YAML)](./modulo_4_serverpod/2_modelado_datos_yaml.md) | Modelos, tipos de datos, relaciones, validaciones |
| [3. Lógica de Endpoints](./modulo_4_serverpod/3_logica_endpoints.md) | Session, CRUD, queries avanzadas, transacciones |
| [4. Gestión de Sesiones y Auth](./modulo_4_serverpod/4_gestion_sesiones_auth.md) | Registro, login, @protected, roles, scopes |

---

### 🟪 Módulo 5: Infraestructura Pro

Escalabilidad y gestión empresarial.

| Guía | Descripción |
|------|-------------|
| [1. Supabase Profundo](./modulo_5_supabase_odoo/1_supabase_profundo.md) | PostgreSQL avanzado, Storage, Realtime |
| [2. Odoo en Docker](./modulo_5_supabase_odoo/2_odoo_en_docker.md) | ERP completo, módulos, integración con Flutter |
| [3. Dominio Local y DNS](./modulo_5_supabase_odoo/3_dominio_local_dns.md) | Pi-hole, dnsmasq, Caddy con SSL local |

---

### 🚀 Módulo 6: Despliegue en VPS Remoto

El paso final: llevar todo a internet.

| Guía | Descripción |
|------|-------------|
| [1. Selección de VPS](./modulo_6_vps_produccion/1_seleccion_vps.md) | Hetzner, DigitalOcean, comparación |
| [2. Hardening del Servidor](./modulo_6_vps_produccion/2_hardening_servidor.md) | SSH keys, UFW, Fail2Ban, actualizaciones |
| [3. CI/CD](./modulo_6_vps_produccion/3_cicd.md) | GitHub Actions, webhooks, despliegues automáticos |
| [4. Monitoreo](./modulo_6_vps_produccion/4_monitoreo.md) | htop, logs, Prometheus/Grafana, alertas |

---

## 🎯 Requisitos Previos

- 💙 Conocimiento básico de **Flutter/Dart**
- 🖥️ **Laptop** con al menos 8GB RAM
- 🌐 **Conexión a internet** estable
- 🧪 Ganas de **experimentar** y equivocarte

---

## ⏱️ Duración Estimada

| Fase | Tiempo | Descripción |
|------|--------|-------------|
| **Semanas 1-2** | ~20 horas | Módulo 1: Linux y Redes |
| **Semanas 3-4** | ~15 horas | Módulo 2: Docker y Dokploy |
| **Semanas 5-6** | ~12 horas | Módulo 3: Automatización |
| **Semanas 7-10** | ~25 horas | Módulo 4: Serverpod |
| **Semanas 11-12** | ~12 horas | Módulo 5: Supabase + Odoo |
| **Semanas 13-16** | ~16 horas | Módulo 6: VPS Producción |

> **Total estimado**: ~100 horas (3-4 meses con 1-2 horas/día)

---

## 🛠️ Stack Tecnológico

### Backend
- **Serverpod** - Framework backend en Dart
- **PostgreSQL** - Base de datos relacional
- **Redis** - Cache y sesiones

### Contenedores y Orquestación
- **Docker** - Contenedores
- **Docker Compose** - Orquestación
- **Dokploy** - Panel de gestión

### Automatización
- **n8n** - Workflow automation
- **OpenClaw** - Web scraping

### Infraestructura
- **Ubuntu Server** - Sistema operativo
- **Nginx** - Proxy reverso
- **Caddy** - Servidor web con SSL

### ERP y Gestión
- **Odoo** - ERP empresarial
- **Supabase** - Firebase self-hosted

### Monitoreo
- **Prometheus** - Métricas
- **Grafana** - Visualización
- **Fail2Ban** - Seguridad
- **UFW** - Firewall

---

## 📖 Cómo Usar Estas Guías

### Orden Recomendado

```
1. Empieza por el Módulo 1 (Linux)
   └─> Es fundamental para todo lo demás

2. Módulo 2 (Docker) + Módulo 4 (Serverpod)
   └─> Son paralelos, puedes hacerlos juntos

3. Módulo 3 (Automatización)
   └─> Una vez tengas un servidor funcionando

4. Módulo 5 (Supabase + Odoo)
   └─> Solo si necesitas estas herramientas

5. Módulo 6 (VPS)
   └─> Al final, para producción
```

### Enfoque de Aprendizaje

1. **Lee la teoría** - Antes de tocar la terminal
2. **Practica** - Cada guía tiene ejercicios
3. **Experimenta** - Modifica los ejemplos
4. **Documente** - Guarda tus configuraciones

---

## 🔗 Recursos Adicionales

### Documentación Oficial

- [Serverpod Docs](https://docs.serverpod.dev/)
- [Docker Docs](https://docs.docker.com/)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)
- [n8n Docs](https://docs.n8n.io/)
- [Odoo Docs](https://www.odoo.com/documentation/)
- [Grafana Docs](https://grafana.com/docs/)

### Herramientas Recomendadas

| Herramienta | Uso |
|-------------|-----|
| [Hetzner Cloud](https://hetzner.cloud/) | VPS (€4.63/mes) |
| [GitHub Actions](https://github.com/features/actions) | CI/CD |
| [Let's Encrypt](https://letsencrypt.org/) | SSL gratuito |
| [UptimeRobot](https://uptimerobot.com/) | Monitoreo externo |

---

## 📝 Contribuciones

¿Encontraste un error? ¿Tienes sugerencias?

1. Fork del repositorio
2. Crea una rama (`git checkout -b fix/descripcion`)
3. Commitea tus cambios (`git commit -m 'Fix: descripción'`)
4. Push a la rama (`git push origin fix/descripcion`)
5. Abre un Pull Request

---

## 📜 Licencia

Este material está bajo licencia **MIT**. Puedes usarlo, modificarlo y distribuirlo libremente.

---

## 👨‍💻 Sobre el Autor

Desarrollador Flutter con interés en backend e infraestructura. Esta ruta de aprendizaje fue diseñada para compartir conocimiento y facilitar el aprendizaje de otros desarrolladores.

---

<div align="center">

### 🎉 ¡Éxito en tu camino hacia Backend e Infraestructura!

```
╔══════════════════════════════════════════════════════════════════╗
║  FLUTTER → SERVERPOD → DOCKER → POSTGRESQL → PRODUCCIÓN         ║
║                                                                  ║
║  ¡Tu app, tu servidor, tu infraestructura!                       ║
╚══════════════════════════════════════════════════════════════════╝
```

</div>