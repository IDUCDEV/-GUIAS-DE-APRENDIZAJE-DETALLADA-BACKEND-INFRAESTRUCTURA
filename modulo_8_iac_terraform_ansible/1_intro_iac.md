# 1. Introducción a Infrastructure as Code (IaC)

> **Tiempo estimado:** 30 min  
> **Nivel:** Intermedio

---

## 🎯 Objetivo

Entender qué es Infrastructure as Code y por qué es el "siguiente nivel" después de aprender comandos manuales de Linux y Docker.

---

## 📖 ¿Qué es IaC?

**Definición:** Escribir código para provisionar y gestionar infraestructura (servidores, redes, bases de datos) en lugar de hacerlo manualmente por consola.

### El Problema: "Snowflake Servers" (Servidores Copo de Nieve)

Imagina que configuras un servidor a mano:
1. Entras por SSH
2. Instalas Docker (`apt install docker`)
3. Configuras el firewall (`ufw allow 8080`)
4. Despliegas tu app

**Resultado:** Tienes un servidor único, misterioso, que nadie sabe cómo recrear si se borra. Si contratas a un nuevo dev, ¿cómo le explicas qué hiciste?

### La Solución: IaC

Escribes un archivo `main.tf`:
```hcl
resource "hcloud_server" "mi_servidor" {
  name  = "servidor-produccion"
  image = "ubuntu-22.04"
  server_type = "cx11"
}
```

**Resultado:** Cualquiera puede leer el archivo y recrear el servidor exacto con un solo comando (`terraform apply`).

---

## 🏗️ Beneficios Clave

| Beneficio | Explicación |
|-----------|--------------|
| **Reproducibilidad** | Puedes crear 10 servidores idénticos en segundos |
| **Versionado** | Guardas la infraestructura en Git (`git log` te dice quién cambió qué) |
| **Auditoría** | Sabes exactamente qué recursos tienes y por qué existen |
| **Menos errores humanos** | El código es preciso, no se equivoca al tipiar comandos |
| **Economía** | Puedes borrar y recrear servidores según demanda |

---

## 🛠️ Herramientas Principales

### 1. Terraform (Provisioning)
Se encarga de **crear** los recursos (VPS, Redes, Volúmenes).

*   **Filosofía:** "Declarativo". Tú dices: "Quiero 3 servidores", y Terraform decide cómo lograrlo.
*   **State File:** Terraform guarda un archivo (`terraform.tfstate`) con el estado real de tu infraestructura.

### 2. Ansible (Configuration Management)
Se encarga de **configurar** los recursos ya creados (instalar Docker, crear usuarios, editar archivos).

*   **Filosofía:** "Procedural/Declarativo". Tiene un inventario de servidores y aplica "Playbooks" (recetas) en ellos.
*   **Agentless:** No necesitas instalar nada en el servidor destino, usa SSH.

### 3. Comparación Rápida

| Acción | Terraform | Ansible |
|--------|-----------|---------|
| Crear VPS en Hetzner | ✅ Sí | ❌ No |
| Instalar Docker en el VPS | ❌ No (puede, pero no es lo suyo) | ✅ Sí |
| Crear Base de Datos | ✅ Sí | ❌ No |
| Configurar Nginx | ❌ No | ✅ Sí |

---

## 🗺️ Flujo de Trabajo Típico

```
1. Terraform crea 3 VPS en Hetzner
   └─> Output: IPs de los 3 servidores

2. Ansible recibe las IPs (Inventory)
   └─> Playbook: "Instalar Docker, crear usuario 'deploy', clonar repo"

3. Resultado: 3 Servidores listos para producción
```

---

## 📋 Conceptos de Terraform (Sin código pesado)

### Bloques Principales

1.  **Provider:** ¿Quién nos da la infraestructura? (Hetzner, DigitalOcean, AWS).
2.  **Resource:** ¿Qué queremos crear? (Servidor, Firewall, Volumen).
3.  **Variable:** Datos de entrada (API Token, Region).
4.  **Output:** Datos de salida (La IP del servidor recién creado).

### Comandos Esenciales

| Comando | Qué hace |
|---------|-----------|
| `terraform init` | Descarga los "Providers" (plugins) |
| `terraform plan` | Muestra qué va a cambiar (simulación) |
| `terraform apply` | Crea/Modifica la infraestructura |
| `terraform destroy` | Borra TODO lo que creó |

---

## 📋 Conceptos de Ansible (Sin código pesado)

### Componentes

1.  **Inventory:** Lista de IPs o DNS de tus servidores (`hosts.ini`).
2.  **Playbook:** Archivo YAML con las tareas a ejecutar (`site.yml`).
3.  **Module:** La unidad de trabajo (ej. `apt`, `copy`, `docker_container`).
4.  **Role:** Agrupación de playbooks para reutilizar código.

### Comando Esencial

```bash
ansible-playbook -i hosts.ini site.yml
```

---

## 🚀 Siguientes Pasos

1.  **Práctica:** Elige un provider (ej. Hetzner) y escribe un `main.tf` que cree 1 servidor.
2.  **Avanzado:** Usa el output de Terraform para llenar el inventario de Ansible automáticamente.
3.  **Experto:** Integra esto en tu pipeline de GitHub Actions (Módulo 6).

---

## 🔗 Recursos Oficiales

- [Terraform Docs](https://developer.hashicorp.com/terraform/docs)
- [Ansible Documentation](https://docs.ansible.com/)
- [Hetzner Cloud API](https://docs.hetzner.cloud/)
- [IaC Best Practices](https://www.terraform-best-practices.com/)

---

## ✅ Al terminar esta guía podrás:

- ✅ Diferenciar entre configuración manual vs IaC
- ✅ Entender la diferencia entre Terraform y Ansible
- ✅ Saber qué herramienta usar según la tarea
- ✅ Comprender el flujo de trabajo de un DevOps moderno

---

**Nota:** Para archivos `.tf` y `.yml` listos para copiar/pegar, consulta la documentación oficial de Terraform y Ansible o las siguientes guías prácticas de este módulo.
