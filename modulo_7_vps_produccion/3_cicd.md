# Módulo 6: Despliegue en VPS Remoto (Producción)

## 3. CI/CD - Integración Continua

### Objetivos de Aprendizaje

- Configurar GitHub Actions para build automático
- Conectar GitHub con Dokploy
- Implementar despliegues automáticos con git push
- Manejar entornos (dev, staging, prod)

---

## 3.1 ¿Qué es CI/CD?

### Concepto

CI/CD (Continuous Integration / Continuous Deployment) automatiza el proceso de:
- Build: Compilar tu código
- Test: Ejecutar pruebas
- Deploy: Desplegar a producción

```
┌─────────────────────────────────────────────────────────────┐
│                        FLUJO CI/CD                          │
│                                                             │
│  Code Push                                                   │
│     │                                                       │
│     ▼                                                       │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐  │
│  │  Build  │───►│  Test   │───►│ Staging │───►│ Production│
│  │         │    │         │    │         │    │           │
│  └─────────┘    └─────────┘    └─────────┘    └─────────┘  │
│       │              │              │              │         │
│       ▼              ▼              ▼              ▼         │
│   GitHub        GitHub         Dokploy         Dokploy      │
│   Actions       Actions        (auto)         (auto)       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 3.2 GitHub Actions para Serverpod

### Crear Workflow

```yaml
# .github/workflows/deploy.yml

name: Deploy to Serverpod

on:
  push:
    branches:
      - main
      - develop
  pull_request:
    branches:
      - main

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
      # 1. Checkout del código
      - name: Checkout code
        uses: actions/checkout@v4
      
      # 2. Instalar Dart
      - name: Setup Dart
        uses: dart-lang/setup-dart@v1
        with:
          dart-version: '3.0.0'
      
      # 3. Instalar dependencias
      - name: Install dependencies
        run: |
          cd packages/server
          dart pub get
          cd ../..
      
      # 4. Generar código Serverpod
      - name: Generate Serverpod code
        run: |
          cd packages/server
          dart run serverpod generate
        env:
          SERVERPOD_KEY: ${{ secrets.SERVERPOD_KEY }}
      
      # 5. Build (opcional: ejecutar tests)
      - name: Run tests
        run: |
          cd packages/server
          dart test
      
      # 6. Notificar a Dokploy (webhook)
      - name: Trigger Dokploy deployment
        if: github.ref == 'refs/heads/main'
        run: |
          curl -X POST ${{ secrets.DOKPLOY_WEBHOOK_URL }}
```

### Configurar Secrets en GitHub

```
1. Ir a tu repositorio en GitHub
2. Settings → Secrets → Actions
3. Agregar secrets:
   - SERVERPOD_KEY: tu_key_de_producción
   - DOKPLOY_WEBHOOK_URL: url_del_webhook_de_dokploy
```

---

## 3.3 Configurar Webhook en Dokploy

### Obtener Webhook URL

```
Dokploy Dashboard:
→ Tu Proyecto
→ Tu Aplicación
→ Deployments
→ Copy Webhook URL

La URL será algo como:
https://dokploy.com/api/webhook/abc123-def456-ghi789
```

### Configurar en GitHub

```yaml
# Agregar el secret en GitHub Actions
# Repository Settings → Secrets → Actions
# Nombre: DOKPLOY_WEBHOOK_URL
# Valor: https://dokploy.com/api/webhook/...
```

---

## 3.4 Flujo Completo de Despliegue

### Paso a Paso

```
1. Desarrollas en tu laptop (rama develop)
2. Haces commit y push a GitHub
3. GitHub Actions ejecuta:
   - Build
   - Tests
   - (si todo OK, continúa)
4. Si es push a main:
   - GitHub Actions envía webhook a Dokploy
5. Dokploy:
   - Descarga el código
   - Rebuild de la imagen
   - Despliega automáticamente
6. ✓ Tu app está actualizada
```

### Diagrama

```
┌─────────────┐     GitHub      ┌─────────────┐    Dokploy     ┌─────────────┐
│  Tu Laptop │ ──push──►│   Actions   │──webhook──►│   Server    │──deploy──►│  Prod   │
└─────────────┘              └─────────────┘               └─────────────┘

Tu laptop:
git add . && git commit -m "feat: nueva funcionalidad" && git push origin develop

GitHub Actions (auto):
✓ Checkout code
✓ Install dependencies
✓ Run tests
✓ Notify Dokploy

Dokploy (auto):
✓ Pull latest code
✓ Build Docker image
✓ Deploy to production
✓ Health check
```

---

## 3.5 Entornos Múltiples

### Configurar Entornos

```yaml
# .github/workflows/deploy.yml

name: Deploy to Multiple Environments

on:
  push:
    branches:
      - develop
      - staging
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Determine environment
        run: |
          if [[ "${{ github.ref }}" == "refs/heads/main" ]]; then
            echo "ENV=production" >> $GITHUB_ENV
          elif [[ "${{ github.ref }}" == "refs/heads/staging" ]]; then
            echo "ENV=staging" >> $GITHUB_ENV
          else
            echo "ENV=development" >> $GITHUB_ENV
          fi
      
      - name: Deploy to Development
        if: env.ENV == 'development'
        run: |
          curl -X POST ${{ secrets.DOKPLOY_WEBHOOK_DEV }}
      
      - name: Deploy to Staging
        if: env.ENV == 'staging'
        run: |
          curl -X POST ${{ secrets.DOKPLOY_WEBHOOK_STAGING }}
      
      - name: Deploy to Production
        if: env.ENV == 'production'
        run: |
          curl -X POST ${{ secrets.DOKPLOY_WEBHOOK_PROD }}
```

### Estructura de Ramas

```
main (producción)
  │
staging (pruebas antes de producción)
  │
develop (desarrollo activo)
  │
feature/fix branches
```

---

## 3.6 Docker Build en GitHub Actions

### Build Multi-Platform

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      
      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: |
            tu_usuario/tu_app:latest
            tu_usuario/tu_app:${{ github.sha }}
```

---

## 3.7 Rollback (Deshacer Cambios)

### En Dokploy

```
Dashboard → Tu Aplicación → Deployments

1. Ver historial de despliegues
2. Seleccionar versión anterior
3. Clic en "Redeploy"

# Vuelve a la versión anterior automáticamente
```

### En GitHub

```bash
# Revertir un commit
git revert HEAD

# O resetear (cuidado!)
git reset --hard HEAD~1

# Push de revert
git push origin main --force
```

---

## 3.8 Monitoreo de CI/CD

### Verificar Build en GitHub

```
GitHub → Tu Repo → Actions

- Ver estado de cada workflow
- Ver logs detallados
- Ver duración de cada paso
- Ver artifacts generados
```

### Verificar Deploy en Dokploy

```
Dokploy → Tu Aplicación → Deployments

- Ver historial
- Ver logs de deploy
- Ver estado (success/failed)
- Ver tiempo de deploy
```

---

## 3.9 Ejercicios Prácticos

### Ejercicio 1: Configurar GitHub Actions

```yaml
# Crear .github/workflows/deploy.yml

name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Notify Deploy
        run: curl -X POST ${{ secrets.WEBHOOK_URL }}
```

### Ejercicio 2: Agregar Secrets

```
GitHub → Settings → Secrets → Actions
Agregar:
- WEBHOOK_URL (url de Dokploy)
- SERVERPOD_KEY (key de producción)
```

### Ejercicio 3: Probar Despliegue

```bash
# Hacer un cambio en tu código
# Commit y push
# Ver el deploy automático

git add .
git commit -m "test: CI/CD pipeline"
git push origin main
```

---

## 3.10 Mejores Prácticas

```
✅ Commits pequeños y frecuentes
✅ Tests automatizados antes de merge
✅ Ramas protegidas (main no puede push directo)
✅ Revisión de código (Pull Requests)
✅ Notificaciones de estado (Slack/Discord)
✅ Logs claros en CI/CD
✅ Timeout apropiado para builds largos
✅ Cache de dependencias (más rápido)
```

---

## 3.11 Recursos Adicionales

### Documentación

```
- https://docs.github.com/en/actions
- https://docs.dokploy.com/
```

### Comandos Útiles

```bash
# Ver workflows
gh run list

# Ver detalles de un workflow
gh run view [run-id]

# Cancelar un workflow
gh run cancel [run-id]
```

---

## Resumen

En esta guía has aprendido:

- ✅ Qué es CI/CD y por qué usarlo
- ✅ Configurar GitHub Actions
- ✅ Configurar webhook en Dokploy
- ✅ Automatizar deployments con git push
- ✅ Manejar múltiples entornos
- ✅ Rollback y monitoreo

**Siguiente guía:** Monitoreo - Ver logs y recursos en tiempo real.