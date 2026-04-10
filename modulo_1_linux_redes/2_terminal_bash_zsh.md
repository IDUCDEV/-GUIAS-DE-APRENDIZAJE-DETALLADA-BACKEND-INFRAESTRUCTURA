# Módulo 1: Fundamentos de Linux y Redes

## 2. La Terminal (Bash/Zsh)

### Objetivos de Aprendizaje

- Navegar por el sistema de archivos
- Gestionar archivos y directorios
- Editar archivos con nano y vim básico
- Dominar los comandos esenciales para administración de servidores

---

## 2.1 Navegación del Sistema de Archivos

### Conceptos Fundamentales

```
/ (root)
├── home/
│   └── ubuntu/          ← Tu directorio personal
│       ├── Documents/
│       ├── Downloads/
│       └── projects/
├── etc/                 ← Configuraciones del sistema
├── var/                 ← Logs, bases de datos, aplicaciones
├── usr/                 ← Aplicaciones instaladas
├── opt/                 ← Software adicional
└── tmp/                 ← Archivos temporales
```

### Comandos de Navegación

```bash
# Ver directorio actual
pwd                    # print working directory

# Listar archivos
ls                     # básico
ls -l                  # formato largo (detalles)
ls -la                 # incluye archivos ocultos
ls -lh                 # tamaños legibles (MB, GB)
ls -la | grep pattern  # filtrar resultados

# Cambiar directorio
cd /home/ubuntu        # ruta absoluta
cd ~                  # home del usuario
cd ..                 # subir un nivel
cd -                  # volver al directorio anterior

# Información de archivos
file nombre.txt        # tipo de archivo
stat nombre.txt        # metadatos detallados
```

### Atajos de Teclado

| Atajo | Descripción |
|-------|-------------|
| `Tab` | Autocompletar comandos |
| `Ctrl+A` | Ir al inicio de la línea |
| `Ctrl+E` | Ir al final de la línea |
| `Ctrl+U` | Borrar línea actual |
| `Ctrl+L` | Limpiar pantalla |
| `Ctrl+C` | Cancelar comando |
| `Ctrl+D` | Salir de terminal |

---

## 2.2 Gestión de Archivos y Directorios

### Crear, Copiar, Mover, Eliminar

```bash
# Crear directorios
mkdir nueva_carpeta
mkdir -p proyecto/src/{lib,bin,tests}   # crear estructura completa
mkdir -p ~/projects/flutter_app          # con ruta absoluta

# Crear archivos
touch archivo.txt
touch app.{dart,yaml,json}              # múltiples archivos

# Copiar archivos
cp origen.txt destino.txt
cp -r carpeta/ carpeta_backup/          # copiar directorio
cp -v archivo.* ~/backup/                # verbose (mostrar qué hace)

# Mover/Renombrar
mv archivo.txt nuevo_nombre.txt
mv carpeta/ ~/Documents/                 # mover
mv viejo.txt nuevo.txt                   # renombrar

# Eliminar
rm archivo.txt
rm -rf carpeta/                          # eliminar directorio con contenido
rm -i *.txt                              # interactivo (confirmar)
```

### Comandos de Búsqueda

```bash
# Buscar archivos
find /home -name "*.dart"                # por nombre
find . -type d -name "lib"               # por tipo (d=directorio)
find . -mtime -7                         # modificados en últimos 7 días

# Buscar contenido en archivos
grep "texto" archivo.txt                 # buscar texto
grep -r "Widget" ./lib/                  # buscar en directorio
grep -i "error" *.log                    # ignore case
grep -n "TODO" *.dart                    # mostrar número de línea

# Alternativa más rápida: ripgrep
rg "class User" --type dart
```

---

## 2.3 Edición de Texto

### Nano - El Editor para Principiantes

```bash
# Abrir/crear archivo
nano nombre.txt

# Atajos dentro de nano (mostrados abajo de la pantalla):
# ^G = Ctrl+G (ayuda)
# ^O = Ctrl+O (guardar)
# ^X = Ctrl+S (salir)
# ^W = Ctrl+W (buscar)
# ^K = Ctrl+K (cortar línea)
# ^U = Ctrl+U (pegar)
```

**Ejemplo de uso:**

```bash
# Editar configuración de Serverpod
nano /home/ubuntu/mi_servidor/config/generator.yaml

# Dentro de nano:
# Escribir el contenido
# Ctrl+O para guardar
# Enter para confirmar
# Ctrl+X para salir
```

### Vim - El Editor Avanzado (Básico)

```bash
# Abrir archivo
vim nombre.txt

# Modos de vim:
# 1. Normal (por defecto) - navegación
# 2. Insert (i) - editar texto
# 3. Visual (v) - selección

# Comandos esenciales:
i           # entrar en modo inserción
Esc         # volver a modo normal
:w          # guardar
:q          # salir
:wq         # guardar y salir
:q!         # salir sin guardar

# Navegación en modo normal:
h j k l     # izquierda, abajo, arriba, derecha
0 $         # inicio/fin de línea
gg          # inicio del archivo
G           # final del archivo
10G         # ir a línea 10
/texto      # buscar hacia adelante
n           # siguiente resultado

# Editar:
dd          # cortar línea
p           # pegar
u           # deshacer
Ctrl+R      # rehacer
```

### ¿Cuál usar?

| Herramienta | Uso Recomendado |
|------------|-----------------|
| **Nano** | Cambios rápidos, principiantes |
| **Vim** | Editing avanzado, servidores remotos |
| **VS Code** | Desarrollo principal (con SSH remoto) |

**Instalar Vim:**
```bash
sudo apt update
sudo apt install vim
```

---

## 2.4 Combinaciones de Comandos

### Pipes y Redirección

```bash
# Redirección
echo "texto" > archivo.txt      # sobrescribir
echo "texto" >> archivo.txt    # añadir al final
comando > salida.txt           # stdout a archivo
comando 2> error.txt          # stderr a archivo
comando > todo.txt 2>&1        # ambos a archivo

# Pipes (concatenar comandos)
ls -la | grep ".dart"          # filtrar lista
cat log.txt | tail -20        # últimas 20 líneas
ps aux | grep docker           # buscar proceso
history | grep ssh             # buscar en historial
```

### Comandos de Estado del Sistema

```bash
# Procesos y recursos
top              # administrador de tareas (interactivo)
htop             # versión mejorada (instalar con: sudo apt install htop)
ps aux           # lista de procesos
df -h            # espacio en disco
du -sh carpeta/  # tamaño de carpeta
free -h          # memoria RAM
uptime           # tiempo activo del servidor

# Redes
ip a             # direcciones IP
ip route         # rutas
netstat -tulpn   # puertos en uso (requiere net-tools)
ss -tulpn        # puertos (alternativa moderna)
curl -I https://google.com  # probar conectividad
```

---

## 2.5 Ejercicios Prácticos

### Ejercicio 1: Estructura de Proyecto Serverpod

```bash
# Crea la estructura típica de un proyecto Serverpod
mkdir -p ~/mi_servidor/{config,lib/{src/{endpoints,models,services}},packages/{client,server}}
ls -la ~/mi_servidor/
```

### Ejercicio 2: Buscar en Logs

```bash
# Simula un log de servidor
echo -e "INFO: Server started\nERROR: Connection failed\nINFO: User logged in\nERROR: Timeout" > /tmp/test.log

# Busca errores
grep "ERROR" /tmp/test.log

# Muestra últimas 2 líneas
tail -2 /tmp/test.log
```

### Ejercicio 3: Monitorear tu Servidor

```bash
# Crea un script simple de monitoreo
nano ~/monitor.sh

#!/bin/bash
echo "=== Estado del Sistema ==="
echo "Uptime: $(uptime)"
echo "Espacio en disco:"
df -h | grep "/dev/"
echo "Memoria:"
free -h | grep Mem:
```

```bash
# Ejecutar
chmod +x ~/monitor.sh
./monitor.sh
```

---

## 2.6 Tips para Flutter Developers

### SSH + VS Code - Desarrollo Remoto

```bash
# En tu laptop, instalar Remote VS Code extension
# Luego conectar:
ssh ubuntu@192.168.1.100

# VS Code permitirá editar archivos del servidor
# como si estuvieran en tu máquina local
```

### Atajos para Desarrollo

```bash
# Navegación rápida en proyectos
cd ~/projects/flutter_app
cd ..            # subir
cd -             # volver

# Ver estructura de proyecto Flutter
find . -name "*.dart" | head -20

# Buscar en todo el proyecto
rg "StatelessWidget" --type dart
```

### Estructura de Proyecto Típica

```
~/projects/
├── flutter_app/          # Tu app Flutter
├── serverpod_app/        # Tu backend Serverpod
├── docker_configs/       # Configuraciones Docker
└── scripts/              # Scripts de utilidad
```

---

## 2.7 Recursos Adicionales

### Comandos Esenciales Resumen

```bash
# Navegación
pwd, ls, cd, tree

# Archivos
touch, mkdir, cp, mv, rm, cat, head, tail

# Búsqueda
find, grep, rg

# Sistema
top, htop, df, free, ps

# Red
ip, curl, ping, ssh, scp

# Permisos
chmod, chown
```

### Alias Útiles

```bash
# Agregar a ~/.bashrc o ~/.zshrc
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'

# Alias para Flutter/Serverpod
alias sp='cd ~/serverpod'
alias fl='flutter'
alias spg='dart run serverpod generate'
```

---

## Resumen

En esta guía has aprendido:

- ✅ Navegar por el sistema de archivos
- ✅ Crear, copiar, mover y eliminar archivos
- ✅ Usar nano para ediciones rápidas
- ✅ Fundamentos de vim para edición avanzada
- ✅ Pipes, redirección y comandos de sistema

**Siguiente guía:** Administración de Usuarios y Seguridad - Permisos, sudoers y firewall.