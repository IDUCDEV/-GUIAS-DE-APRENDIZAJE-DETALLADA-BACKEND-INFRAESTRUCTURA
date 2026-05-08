# 4. Integración de IaC con CI/CD

> **Tiempo estimado:** 45 min  
> **Nivel:** Avanzado

---

## 🎯 Objetivo

Aprender a conectar Terraform y Ansible con GitHub Actions para que tu infraestructura se despliegue automáticamente al hacer `git push`.

---

## 📖 Concepto: GitOps para Infraestructura

**GitOps:** La infraestructura se gestiona igual que el código. Si quieres cambiar un servidor, haces un commit, no ejecutas comandos manuales.

### Flujo Tradicional vs GitOps

| Tradicional | GitOps |
|-------------|--------|
| Entras por SSH | Haces `git push` |
| Ejecutas `terraform apply` | GitHub Actions ejecuta `terraform apply` |
| Escribres en Wiki qué hiciste | El `git log` lo dice todo |

---

## 🏗️ Arquitectura de CI/CD para IaC

```
GitHub Repository
├── terraform/          (Código de Infraestructura)
│   ├── main.tf
│   └── variables.tf
├── ansible/            (Código de Configuración)
│   ├── inventory/
│   └── roles/
└── .github/workflows/
    └── deploy-infra.yml (El Pipeline)
```

### El Pipeline (`deploy-infra.yml`)

```yaml
name: Deploy Infrastructure

on:
  push:
    branches: [ main ]
    paths:
      - 'terraform/**'
      - 'ansible/**'

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        
      - name: Terraform Init
        run: terraform init
        working-directory: ./terraform
        env:
          HCLOUD_TOKEN: ${{ secrets.HCLOUD_TOKEN }}
          
      - name: Terraform Apply
        run: terraform apply -auto-approve
        working-directory: ./terraform
        env:
          HCLOUD_TOKEN: ${{ secrets.HCLOUD_TOKEN }}
          
  ansible:
    needs: terraform
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run Ansible Playbook
        uses: dawidd6/action-ansible-playbook@v2
        with:
          playbook: site.yml
          directory: ./ansible
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          inventory: |
            [web]
            ${{ secrets.SERVER_IP }}
```

---

## 🔐 Manejo de Secretos en GitHub Actions

En el ejemplo anterior, usamos `secrets.HCLOUD_TOKEN`. ¿De dónde sale?

1.  Ve a tu repo en GitHub → **Settings** → **Secrets and variables** → **Actions**.
2.  Click en **New repository secret**.
3.  Añade:
    *   `HCLOUD_TOKEN`: Tu token de API.
    *   `SSH_PRIVATE_KEY`: El contenido de tu archivo `id_rsa` (privada).
    *   `SERVER_IP`: La IP de tu servidor.

---

## 🔄 El Ciclo Completo (Terraform + Ansible)

Esta es la secuencia lógica que debe seguir tu pipeline:

### Paso 1: Terraform Create (Infraestructura)
GitHub Actions ejecuta `terraform apply`.
*   **Resultado:** Servidores creados en Hetzner.
*   **Output:** Nuevas IPs (Se guardan como "Outputs" de Terraform).

### Paso 2: Update Inventory (Dinámico)
Ansible necesita saber las IPs nuevas.
*   **Concepto:** Puedes usar un script (o Terraform `local-exec`) para sobrescribir el archivo `hosts.ini` de Ansible con las nuevas IPs.

### Paso 3: Ansible Configure (Configuración)
GitHub Actions ejecuta `ansible-playbook site.yml`.
*   **Resultado:** Docker instalado, firewall configurado, app corriendo.

---

## 🚨 Consideraciones Importantes

### 1. State Locking (Terraform)
Si dos personas hacen push a la vez, `terraform apply` podría correr dos veces y fallar.
*   **Solución:** Usa un backend remoto con "State Locking" (ej. S3 con DynamoDB).

### 2. Plan before Apply
En producción, NUNCA hagas `apply` directo.
*   **Mejor práctica:** Un workflow que genere un "Plan" (artefacto) y lo suba como comentario al Pull Request. Luego, al aprobar el PR, se ejecuta el `apply`.

### 3. Destrucción
¿Cómo borras infraestructura en CI/CD?
*   **Manual:** Solo tú con acceso local.
*   **Automático:** Requiere un trigger especial (ej. crear un tag `destroy-me`).

---

## 📋 Resumen de Herramientas en el Pipeline

| Herramienta | Acción en CI/CD |
|--------------|-----------------|
| **hashicorp/setup-terraform** | Instala Terraform en el runner |
| **dawidd6/action-ansible-playbook** | Instala Ansible y ejecuta playbooks |
| **appleboy/ssh-action** | Ejecuta comandos SSH directos (alternativa) |
| **Secrets** | Almacena Tokens y Llaves privadas |

---

## 🚀 Siguientes Pasos

1.  **Práctica:** Configura un secret en GitHub con tu Token de Hetzner.
2.  **Avanzado:** Crea un workflow que solo ejecute `terraform plan` en Pull Requests.
3.  **Experto:** Implementa "Auto-scaling" donde Terraform cree más servidores si hay mucha carga (usando outputs de monitoreo).

---

## 🔗 Recursos Oficiales

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Terraform GitHub Actions](https://github.com/hashicorp/setup-terraform)
- [Ansible GitHub Actions](https://github.com/marketplace?type=actions&query=ansible)
- [GitOps Guide](https://www.weave.works/technologies/gitops/)

---

## ✅ Al terminar esta guía podrás:

- ✅ Entender el concepto de GitOps aplicado a infraestructura
- ✅ Estructurar un repositorio para Terraform + Ansible
- ✅ Configurar secretos en GitHub Actions
- ✅ Crear un pipeline básico de despliegue
- ✅ Diferenciar entre ejecución local y ejecución en CI/CD

---

**Nota:** Para configuraciones YAML específicas de workflows y manejo de outputs entre jobs, consulta la documentación oficial de GitHub Actions.
