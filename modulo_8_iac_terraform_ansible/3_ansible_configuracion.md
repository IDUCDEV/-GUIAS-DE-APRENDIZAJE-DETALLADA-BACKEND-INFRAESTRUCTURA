# 3. Ansible: Configuración Masiva de Servidores

> **Tiempo estimado:** 60 min  
> **Nivel:** Intermedio → Avanzado

---

## 🎯 Objetivo

Aprender a usar Ansible para configurar servidores Linux automáticamente vía SSH, sin necesidad de instalar agentes en los servidores.

---

## 📖 Conceptos Fundamentales

### ¿Cómo funciona Ansible?

Ansible se conecta vía **SSH** a tus servidores (nodos) y ejecuta tareas (módulos) remotamente.

```
Tu Computadora (Control Node)
    │ (SSH)
    ├──▶ Servidor 1 (Web)      ← Instala Docker
    ├──▶ Servidor 2 (DB)        ← Configura PostgreSQL
    └──▶ Servidor 3 (Worker)   ← Clona Repo
```

### Ventajas de Ansible

| Ventaja | Descripción |
|---------|--------------|
| **Agentless** | No instalas nada en el servidor destino |
| **Idempotente** | Puedes ejecutarlo 100 veces, el resultado es el mismo |
| **YAML** | Configuración en texto plano legible |
| **SSH** | Usa el protocolo estándar de Linux |

---

## 📋 Componentes de Ansible

### 1. Inventory (Inventario)
Es la lista de servidores donde quieres trabajar.

**Formato (INI):**
```ini
[webservers]
192.168.1.10
server1.example.com

[dbservers]
192.168.1.20

[all:vars]
ansible_user=root
```

### 2. Playbook
Es el "recetario". Define qué tareas ejecutar en qué servidores.

**Estructura básica:**
```yaml
---
- name: Configurar Servidor Web
  hosts: webservers
  become: yes # Equivalente a sudo
  
  tasks:
    - name: Actualizar apt
      apt:
        update_cache: yes
        upgrade: dist

    - name: Instalar Docker
      apt:
        name: docker.io
        state: present
```

### 3. Modules (Módulos)
Son las herramientas que usas dentro de las tareas.

| Módulo | Función |
|--------|----------|
| `apt` / `yum` | Gestión de paquetes |
| `copy` | Copiar archivos al servidor |
| `template` | Copiar archivos con variables (Jinja2) |
| `service` | Iniciar/detener servicios |
| `docker_container` | Gestionar contenedores Docker |

---

## 🏗️ Conceptos de Playbooks Avanzados

### Roles (Reutilización)

En lugar de escribir todo en un archivo `site.yml`, divides la configuración en "Roles".

```
roles/
├── common/          # Tareas comunes (firewall, usuarios)
│   └── tasks/main.yml
├── docker/          # Instalar y configurar Docker
│   └── tasks/main.yml
└── serverpod/       # Desplegar Serverpod
    └── tasks/main.yml
```

**Uso en Playbook:**
```yaml
- hosts: all
  roles:
    - common
    - docker
    - serverpod
```

### Variables

Puedes definir variables para no repetir datos.

```yaml
vars:
  app_user: deploy
  docker_compose_version: "1.29.2"

tasks:
  - name: Crear usuario
    user:
      name: "{{ app_user }}"
```

---

## 🔐 Conexión y Seguridad

### SSH Keys

Ansible necesita conectarse vía SSH. Lo ideal es usar llaves SSH (sin contraseña).

**Concepto:**
1. Tu computadora tiene la llave privada (`id_rsa`).
2. El servidor tiene la llave pública (`id_rsa.pub`) en `~/.ssh/authorized_keys`.
3. Ansible se conecta automáticamente.

### Become (Privilegios)

Muchas tareas requieren ser `root`.
*   `become: yes` → Ejecuta como `sudo`.
*   `become_user: postgres` → Ejecuta como usuario específico.

---

## 🚀 Ejemplo Conceptual: Desplegar Serverpod

```
Playbook: deploy_serverpod.yml
Hosts: produccion

1. Tarea: Instalar dependencias (git, curl, docker)
2. Tarea: Clonar repositorio desde GitHub
3. Tarea: Copiar archivo .env (con variables de entorno)
4. Tarea: Ejecutar docker-compose up -d
5. Tarea: Verificar que el puerto 8080 está abierto
```

---

## 🔧 Comandos Útiles

| Comando | Qué hace |
|---------|-----------|
| `ansible all -i hosts.ini -m ping` | Verifica conexión con todos los servidores |
| `ansible-playbook site.yml` | Ejecuta el playbook |
| `ansible-playbook site.yml --tags docker` | Ejecuta solo tareas con tag "docker" |
| `ansible-vault encrypt secrets.yml` | Encripta archivos sensibles |

---

## 🎓 Cuándo usar Ansible vs Script Bash

| Situación | Mejor Opción |
|-----------|---------------|
| Configurar 1 servidor a mano | Bash Script |
| Configurar 10 servidores idénticos | Ansible |
| Gestionar configuraciones complejas | Ansible (Roles) |
| Tarea rápida y sucia | Bash |

---

## 🚀 Siguientes Pasos

1.  **Práctica:** Crea un inventario con tu VPS actual y ejecuta un "ping" con Ansible.
2.  **Avanzado:** Escribe un playbook que instale Docker y Docker Compose.
3.  **Experto:** Crea un "Role" que despliegue tu proyecto Serverpod automáticamente.

---

## 🔗 Recursos Oficiales

- [Ansible User Guide](https://docs.ansible.com/ansible/latest/user_guide/index.html)
- [Ansible Modules Index](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/index.html)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Jinja2 Templating](https://jinja.palletsprojects.com/)

---

## ✅ Al terminar esta guía podrás:

- ✅ Crear un inventario de servidores (Inventory)
- ✅ Escribir Playbooks básicos en YAML
- ✅ Usar módulos comunes (apt, copy, service)
- ✅ Entender el concepto de Roles para organizar código
- ✅ Ejecutar configuraciones masivas vía SSH

---

**Nota:** Para ejemplos detallados de playbooks y estructura de roles, consulta la documentación oficial y la guía de "Ansible Best Practices".
