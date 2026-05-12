# Reto Maestro 1: El Médico del Servidor (Bash + VS Code SSH)

### 🎯 Objetivo del Reto
Crear un script de Bash profesional que monitoree los recursos críticos del servidor y genere alertas automáticas. Puedes usar **VS Code (Remote SSH)** para escribirlo o **Nano** directamente en la terminal.

---

## 🛠️ El Desafío
Debes crear un archivo llamado `health_check.sh` en la carpeta home de tu servidor que realice las siguientes tareas:

1.  **Chequeo de Disco:** Si el uso de disco es mayor al 80%, debe escribir un mensaje de "CRITICAL" en un archivo de log llamado `server_health.log`.
2.  **Chequeo de RAM:** Mostrar el uso de memoria RAM actual en formato humano (MB/GB).
3.  **Chequeo de Procesos:** Listar los 5 procesos que más CPU están consumiendo en ese momento.
4.  **Automatización:** Configurar un `cron job` para que este script se ejecute automáticamente cada hora.

---

## 💡 Pistas Técnicas
-   Usa `df -h` para el disco y `awk` o `grep` para filtrar el porcentaje.
-   Usa `free -h` para la RAM.
-   Usa `ps aux --sort=-%cpu | head -6` para los procesos.
-   Para el cron: `crontab -e` y usa la sintaxis `0 * * * *`.

---

## ✅ Cómo validar que lo lograste
1.  Ejecuta el script manualmente (`bash health_check.sh`) y verifica que el output sea legible.
2.  Verifica que el archivo `server_health.log` se haya creado y tenga contenido.
3.  Usa `grep "CRITICAL" server_health.log` para buscar alertas.

---
**Nota de progreso:** Estás usando VS Code para escribir el código, pero el script se ejecuta en el corazón de Linux. ¡Ese es el flujo de trabajo de un desarrollador backend real!
