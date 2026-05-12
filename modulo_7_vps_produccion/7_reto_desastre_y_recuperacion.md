# Reto Maestro 5: Plan de Recuperación ante Desastres (IaC + Backups)

### 🎯 Objetivo del Reto
Garantizar la continuidad del negocio. Debes ser capaz de reconstruir todo tu entorno de producción desde cero en tiempo récord.

---

## 🛠️ El Desafío: "El día del juicio final"
Imagina que tu proveedor de VPS borra accidentalmente tu servidor. Tienes 15 minutos para volver a estar online.

1.  **Fase de Destrucción:** Borra manualmente tu contenedor de base de datos y su volumen (asegúrate de tener un backup antes, ¡obviamente!).
2.  **Fase de Provisión (Terraform):** Usa tus archivos de Terraform para levantar una nueva instancia de servidor limpia.
3.  **Fase de Configuración (Ansible):** Ejecuta tu Playbook de Ansible para instalar Docker, configurar el Firewall y dejar el servidor listo.
4.  **Fase de Restauración:** Usa tu script de backup para descargar el último dump de la base de datos y restaurarlo en el nuevo contenedor de Postgres.

---

## 💡 Pistas Técnicas
-   Ten tus archivos `.tf` y `.yml` siempre en un repositorio privado de Git.
-   El comando `terraform apply` es tu mejor aliado aquí.
-   Para la base de datos, usa: `cat backup.sql | docker exec -i my_db_container psql -U user -d db`.

---

## ✅ Cómo validar que lo lograste
1.  La aplicación debe ser accesible desde la misma URL o IP de antes.
2.  **Crucial:** Los datos (usuarios, tareas, posts) que tenías antes del "desastre" deben estar presentes. Si la base de datos está vacía, el reto ha fallado.

---
**Reflexión:** Los mejores ingenieros no son los que nunca cometen errores, sino los que tienen los mejores sistemas para recuperarse de ellos.
