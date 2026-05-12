# Reto Maestro 4: Sincronización Total (n8n + Serverpod + Supabase)

### 🎯 Objetivo del Reto
Lograr una integración "Full-Stack" donde los datos fluyan automáticamente entre diferentes plataformas.

---

## 🛠️ El Desafío
Crea un ecosistema automatizado que haga lo siguiente:

1.  **Origen (Serverpod):** Cuando insertes un nuevo usuario en la base de datos de tu backend de Serverpod (PostgreSQL).
2.  **Procesador (n8n):** Un workflow de n8n debe detectar ese cambio (puedes usar un nodo de "Postgres Trigger" o un Webhook).
3.  **Acción 1 (Supabase):** n8n debe crear un perfil espejo para ese usuario en una tabla de Supabase llamada `profiles`.
4.  **Acción 2 (Notificación):** n8n debe enviar un mensaje a un canal de Discord o Telegram con los detalles del nuevo usuario y un mensaje de bienvenida.

---

## 💡 Pistas Técnicas
-   Para **n8n**, usa el nodo `Supabase` para la inserción.
-   Si usas el nodo de Postgres, asegúrate de que el usuario de base de datos tenga permisos de lectura.
-   Usa expresiones en n8n `{{ $json.name }}` para mapear los nombres correctamente entre Serverpod y Supabase.

---

## ✅ Cómo validar que lo lograste
1.  Inserta un usuario usando el cliente de Flutter o directamente con `psql`.
2.  Verifica en el historial de ejecuciones de n8n que el flujo se disparó correctamente.
3.  Entra al dashboard de Supabase y confirma que el dato apareció allí mágicamente.
4.  Mira tu teléfono y sonríe cuando llegue la notificación de Telegram.

---
**Importante:** Este es un flujo de producción real. Se usa para sincronizar CRMs, enviar correos de bienvenida o generar reportes automáticos.
