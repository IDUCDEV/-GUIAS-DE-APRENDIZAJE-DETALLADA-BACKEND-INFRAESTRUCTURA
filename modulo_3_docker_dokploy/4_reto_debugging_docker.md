# Reto Maestro 3: El Detective de Docker (Inyección de Errores)

### 🎯 Objetivo del Reto
Aprender a diagnosticar y reparar fallos en entornos de contenedores. No basta con saber "levantar" Docker, hay que saber por qué se cae.

---

## 🛠️ El Desafío: Los 3 Contenedores Rotos
Crea un archivo `debug-challenge.yml` e intenta levantarlo con `docker compose up`. Verás que nada funciona. Tu misión es arreglarlo.

```yaml
version: '3.8'
services:
  db:
    image: postgres:15
    # ERROR 1: Falta algo obligatorio para que Postgres arranque
    ports:
      - "5432:5432"

  backend:
    image: nginx:alpine
    ports:
      - "80:80"
    # ERROR 2: El backend intenta conectar a la DB pero no puede. 
    # ¿Están en la misma red? ¿El host es correcto?
    environment:
      - DB_URL=postgres://user:pass@localhost:5432/db

  app:
    image: busybox
    command: ["sh", "-c", "while true; do echo hello; sleep 10; done"]
    volumes:
      - ./data:/app/data
    # ERROR 3: Error de permisos. El contenedor no puede escribir en ./data
```

---

## 🔍 Herramientas de Investigación
1.  `docker compose logs -f`: Tu mejor amigo para ver los errores en tiempo real.
2.  `docker inspect <container_id>`: Para ver la configuración interna y redes.
3.  `docker exec -it <container_id> sh`: Entra al contenedor y trata de hacer `ping db`.

---

## ✅ Cómo validar que lo lograste
1.  Los tres servicios deben aparecer como `Up` o `Running` al hacer `docker ps`.
2.  El backend debe poder responder en el puerto 80.
3.  Debes poder ver el archivo creado por el contenedor `app` en tu carpeta local `./data`.

---
**Nota:** En el mundo real, los errores más comunes son de redes (networks) y de permisos de volúmenes. ¡Domina esto y serás el héroe de tu equipo!
