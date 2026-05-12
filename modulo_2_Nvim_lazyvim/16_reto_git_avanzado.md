# Reto Maestro 2: Lazygit Pro & Git Mastery

### 🎯 Objetivo del Reto
Dominar las operaciones avanzadas de Git usando la interfaz de **Lazygit** para mantener un historial de código limpio y profesional.

---

## 🛠️ El Desafío
Dentro de tu proyecto de práctica, realiza las siguientes acciones exclusivamente usando Lazygit (`<leader>gg`):

1.  **El "Squash" Elegante:** Realiza 3 pequeños cambios (por ejemplo, añade comentarios) y haz un commit por cada uno. Luego, usa Lazygit para combinar esos 3 commits en uno solo con un mensaje profesional.
2.  **El "Cherry-pick" Quirúrgico:** Crea una rama llamada `experimento`. Haz un cambio ahí y comitealo. Luego, vuelve a la rama `main` y trae **solo ese commit** específico sin fusionar toda la rama.
3.  **Limpieza de Ramas:** Identifica ramas locales que ya no uses y elimínalas masivamente.
4.  **Recuperación:** Usa el panel de `Reflog` en Lazygit para encontrar un commit que "borraste" accidentalmente y restáuralo.

---

## 💡 Pistas Técnicas
-   Para el Squash: En el panel de commits, presiona `s` sobre los commits que quieres combinar.
-   Para el Cherry-pick: Selecciona el commit en la rama de origen, presiona `c` (copy) y luego `v` (paste) en la rama de destino.
-   El Reflog está disponible en la pestaña de Commits presionando `R`.

---

## ✅ Cómo validar que lo lograste
1.  Tu historial de `git log --oneline` debe verse limpio y con mensajes claros.
2.  No deben quedar "commits de basura" (ej: "fix", "test2", "cambio").
3.  Debes poder explicar la diferencia entre un Merge y un Rebase usando Lazygit.

---
**Recuerda:** Un buen desarrollador backend no solo escribe código, sino que gestiona su historial como un arquitecto.
