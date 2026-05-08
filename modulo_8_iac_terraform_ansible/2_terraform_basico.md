# 2. Terraform Básico: Escribiendo tu Infraestructura

> **Tiempo estimado:** 60 min  
> **Nivel:** Intermedio → Avanzado

---

## 🎯 Objetivo

Aprender la sintaxis HCL (HashiCorp Configuration Language) y cómo usar Terraform para provisionar un VPS real en Hetzner Cloud.

---

## 📖 Conceptos de HCL (Sintaxis)

Terraform usa HCL. Es similar a JSON pero más legible.

### Estructura de un archivo `main.tf`

```hcl
# 1. Definir el Provider (Hetzner)
provider "hcloud" {
  token = var.hcloud_token
}

# 2. Definir el Recurso (Servidor)
resource "hcloud_server" "web" {
  name  = "mi-servidor-web"
  image = "ubuntu-22.04"
  server_type = "cx11" # El más barato (~3.50€/mes)
}
```

### Bloques de Configuración

| Bloque | Propósito | Ejemplo |
|--------|-----------|---------|
| `terraform {}` | Requerimientos y versión | `required_providers` |
| `provider {}` | Configuración del proveedor | API Token, Region |
| `resource {}` | El recurso a crear | Servidor, Firewall, Volumen |
| `variable {}` | Entrada de datos | `type = string` |
| `output {}` | Salida de datos | La IP del servidor |

---

## 🔧 Ciclo de Vida de un Recurso

1.  **Init:** Descarga el provider.
    ```bash
    terraform init
    ```
2.  **Plan:** Ver qué va a pasar (Dry Run).
    ```bash
    terraform plan
    # Output: + create, - destroy, ~ change
    ```
3.  **Apply:** Ejecutar los cambios.
    ```bash
    terraform apply
    # Te pide confirmación: yes
    ```
4.  **Destroy:** Borrar todo.
    ```bash
    terraform destroy
    ```

---

## 🏗️ Conceptos de Estado (State)

### ¿Qué es `terraform.tfstate`?

Es un archivo JSON que Terraform crea automáticamente. Es la "fuente de la verdad".

*   **Sin State:** Terraform no sabe qué existe. Intentaría crear todo de nuevo.
*   **Con State:** Terraform compara tu código (`.tf`) con el `.tfstate` y aplica solo los cambios necesarios.

### State Remoto (Best Practice)

Nunca guardes el `.tfstate` en tu computadora local si trabajas en equipo.
Guárdalo en un **S3 Bucket** o **Hetzner S3**. Así todo el equipo comparte el mismo estado.

---

## 📋 Variables y Outputs

### Variables (Entrada)

Evita poner datos sensibles (como el Token) directo en el código.

**variables.tf:**
```hcl
variable "hcloud_token" {
  description = "Token de API de Hetzner"
  type        = string
  sensitive   = true # No se muestra en logs
}
```

**terraform.tfvars (Gitignore):**
```hcl
hcloud_token = "tu-token-secreto-aqui"
```

### Outputs (Salida)

Obtener datos después de crear la infraestructura.

```hcl
output "server_ip" {
  value = hcloud_server.web.ipv4_address
  description = "La IP pública de nuestro servidor"
}
```

Para usarla:
```bash
terraform output server_ip
```

---

## 🌐 Ejemplo Conceptual: Crear Red Privada + Servidor

```
1. Crear Red Privada (Network)
   └─> ID: net-123

2. Crear Servidor
   └─> Asignar a Red Privada (net-123)
   └─> Asignar IP Pública

3. Crear Firewall
   └─> Permitir puerto 22 (SSH)
   └─> Permitir puerto 80 (HTTP)
```

---

## 🛡️ Manejo de Secretos

**NUNCA** subas el Token de API a GitHub.

1.  Usa archivos `.tfvars` y añádelos a `.gitignore`.
2.  Usa variables de entorno del sistema operativo:
    ```bash
    export HCLOUD_TOKEN="tu-token"
    ```
3.  En CI/CD (GitHub Actions), usa "Secrets".

---

## 🚀 Siguientes Pasos

1.  **Práctica:** Crea un servidor en Hetzner usando solo Terraform.
2.  **Avanzado:** Crea un módulo de Terraform (carpeta `modules/`) para reutilizar código de "Servidor Web".
3.  **Experto:** Configura el State File para que se guarde remotamente en la nube.

---

## 🔗 Recursos Oficiales

- [Terraform Hetzner Provider](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs)
- [Terraform Variables](https://developer.hashicorp.com/terraform/language/variables)
- [Terraform State](https://developer.hashicorp.com/terraform/language/state)
- [HCL Syntax](https://developer.hashicorp.com/terraform/language/syntax/configuration)

---

## ✅ Al terminar esta guía podrás:

- ✅ Escribir archivos `.tf` básicos
- ✅ Entender el ciclo Init-Plan-Apply
- ✅ Gestionar variables de entrada y salida
- ✅ Comprender la importancia del State File
- ✅ Proteger tus secretos (API Tokens)

---

**Nota:** Para ejemplos detallados de `resource "hcloud_server"` y configuración de redes, consulta la documentación oficial del Provider de Hetzner.
