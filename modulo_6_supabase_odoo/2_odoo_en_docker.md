# Módulo 5: Infraestructura Pro (Supabase + Odoo)

## 2. Odoo en Docker

### Objetivos de Aprendizaje

- Instalar Odoo en Docker
- Configurar Odoo con PostgreSQL
- Gestionar módulos y aplicaciones
- Implementar backups automáticos

---

## 2.1 ¿Qué es Odoo?

### Concepto

Odoo es un sistema ERP (Enterprise Resource Planning) de código abierto. Incluye:
- CRM
- Contabilidad
- Inventario
- Ventas
- Compras
- Proyectos
- RRHH
- Manufacturing
- Website/E-commerce
- y muchos más...

### Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                     ARQUITECTURA ODOO                       │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                    ODOO SERVER                       │   │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐│   │
│  │  │   Web   │  │   API   │  │  Cron   │  │  Worker ││   │
│  │  │  (8069) │  │  (8070) │  │         │  │         ││   │
│  │  └─────────┘  └─────────┘  └─────────┘  └─────────┘│   │
│  └─────────────────────────────────────────────────────┘   │
│                           │                                │
│  ┌────────────────────────┴────────────────────────────┐  │
│  │                  POSTGRESQL                           │   │
│  │                   (5432)                              │   │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 2.2 Instalación con Docker

### docker-compose.yml

```yaml
version: '3.8'

services:
  odoo:
    image: odoo:17.0
    container_name: odoo
    depends_on:
      - postgres
    ports:
      - "8069:8069"
      - "8070:8070"
    volumes:
      - odoo_data:/var/lib/odoo
      - ./addons:/mnt/extra-addons
      - ./config:/etc/odoo
    environment:
      - HOST=postgres
      - PORT=5432
      - USER=odoo
      - PASSWORD=odoo_password
    restart: unless-stopped

  postgres:
    image: postgres:15
    container_name: odoo_db
    volumes:
      - postgres_odoo:/var/lib/postgresql/data
    environment:
      - POSTGRES_DB=odoo
      - POSTGRES_USER=odoo
      - POSTGRES_PASSWORD=odoo_password
    restart: unless-stopped

volumes:
  odoo_data:
  postgres_odoo:
```

### Iniciar Odoo

```bash
# Levantar servicios
docker compose up -d

# Ver logs
docker compose logs -f odoo

# Verificar que está corriendo
docker ps | grep odoo
```

### Acceso

```
URL: http://tu-servidor:8069
Master Password: (configurado en config)

# Crear nueva base de datos:
- Master Password: admin (o el que configures)
- Database: odoo_production
- Phone: +34...
- Language: Spanish
- Country: Spain
- Admin Email: tu@email.com
- Admin Password: tu_password
- Demo Data: No (para producción)
```

---

## 2.3 Configuración de Odoo

### Archivo de Configuración

```ini
# config/odoo.conf

[options]
; Puerto y host
http_port = 8069
http_interface = 0.0.0.0

; Base de datos
db_host = postgres
db_port = 5432
db_user = odoo
db_password = odoo_password

; Admin
admin_passwd = admin123

; Trabajadores (ajustar según recursos)
workers = 4
max_cron_threads = 2

; Logs
log_level = info
log_handler = :INFO

; Sesión
session = file
; Tiempo máximo de sesión (segundos)
session_timeout = 86400

; Límite de memoria
limit_memory_hard = 2684354560
limit_memory_soft = 2147483648

; Descargar módulos sin conexión
auto_install = False
```

### Volúmenes para Módulos Personalizados

```bash
# Estructura de módulos personalizados
./addons/
├── mi_modulo_1/
│   ├── __manifest__.py
│   ├── __init__.py
│   ├── models/
│   └── views/
└── mi_modulo_2/
    └── ...
```

### Instalar Módulos

```bash
# Opción 1: Desde la interfaz
# Apps → Buscar → Instalar

# Opción 2: Desde línea de comando
docker exec -it odoo odoo -u mi_modulo -d odoo_production
```

---

## 2.4 Módulos Esenciales

### Módulos Gratuitos Recomendados

```
1. CRM:
   - Gestión de leads
   - Pipeline de ventas
   - Forecasting

2. Contabilidad:
   - Facturación
   - Informes financieros
   - Gestión de pagos

3. Inventario:
   - Control de stock
   - Ubicaciones
   - Transfers

4. Ventas:
   - Pedidos
   - Precios
   - Descuentos

5. Proyectos:
   - Tareas
   - Timesheet
   - Gantt

6. Website:
   - Constructor web
   - Blog
   - E-commerce (si necesitas tienda)
```

### Instalar Módulos desde la UI

```
1. Ir a "Aplicaciones"
2. Buscar el módulo (ej: "CRM")
3. Clic en "Instalar"

# Los módulos instalados aparecen en la barra lateral
```

---

## 2.5 Integración con Flutter

### API de Odoo

```dart
// Flutter: Conectar con Odoo via XML-RPC

import 'package:xml_rpc/xml_rpc.dart';

class OdooClient {
  final String url;
  final String db;
  final String user;
  final String password;
  
  int? uid;
  
  OdooClient({
    required this.url,
    required this.db,
    required this.user,
    required this.password,
  });
  
  // Login
  Future<bool> login() async {
    final result = await xmlrpc.call(
      '$url/xmlrpc/2/common',
      'authenticate',
      [db, user, password, {}],
    );
    
    if (result is int) {
      uid = result;
      return true;
    }
    return false;
  }
  
  // Buscar partners
  Future<List<Map>> searchPartners(String query) async {
    final result = await xmlrpc.call(
      '$url/xmlrpc/2/object',
      'execute_kw',
      [
        db,
        uid,
        password,
        'res.partner',
        'search_read',
        [
          [['name', 'ilike', query]]
        ],
        {'fields': ['id', 'name', 'email', 'phone']}
      ],
    );
    return List<Map>.from(result);
  }
  
  // Crear lead
  Future<int> createLead(Map<String, dynamic> lead) async {
    final result = await xmlrpc.call(
      '$url/xmlrpc/2/object',
      'execute_kw',
      [
        db,
        uid,
        password,
        'crm.lead',
        'create',
        [lead]
      ],
    );
    return result;
  }
}
```

### Ejemplo: Sincronizar Clientes

```dart
// Sincronizar clientes desde Odoo a Serverpod

class SincronizacionService {
  final OdooClient odoo;
  final ServerpodClient serverpod;
  
  Future<void> sincronizarClientes() async {
    // 1. Obtener clientes de Odoo
    final partners = await odoo.searchPartners('');
    
    // 2. Por cada cliente, verificar si existe en Serverpod
    for (final partner in partners) {
      final existente = await serverpod.clienteEndpoint
        .buscarPorEmail(partner['email']);
      
      if (existente == null) {
        // 3. Crear en Serverpod
        await serverpod.clienteEndpoint.crear(
          CreateCliente(
            nombre: partner['name'],
            email: partner['email'],
            telefono: partner['phone'],
            origen: 'odoo',
          ),
        );
      }
    }
  }
}
```

---

## 2.6 Backup y Restauración

### Backup de Odoo

```bash
# Backup de la base de datos
docker exec -t odoo_db pg_dump -U odoo odoo_production > odoo_backup.sql

# Backup con compresión
docker exec -t odoo_db pg_dump -U odoo odoo_production | gzip > odoo_$(date +%Y%m%d).sql.gz

# Backup de archivos (attachments)
docker exec -it odoo tar -czf /tmp/filestore.tar.gz /var/lib/odoo/data/filestore
docker cp odoo:/tmp/filestore.tar.gz ./filestore_backup.tar.gz
```

### Restaurar Odoo

```bash
# Restaurar base de datos
docker exec -i odoo_db psql -U odoo -d odoo_production < odoo_backup.sql

# Restaurar archivos
docker cp filestore_backup.tar.gz odoo:/tmp/filestore.tar.gz
docker exec -it odoo tar -xzf /tmp/filestore.tar.gz -C /var/lib/odoo/data/
```

### Backup Automático con Script

```bash
#!/bin/bash
# backup_odoo.sh

BACKUP_DIR="/home/ubuntu/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup DB
docker exec -t odoo_db pg_dump -U odoo odoo_production | gzip > $BACKUP_DIR/odoo_$DATE.sql.gz

# Backup filestore
docker exec -it odoo tar -czf /tmp/filestore.tar.gz -C /var/lib/odoo/data/ filestore
docker cp odoo:/tmp/filestore.tar.gz $BACKUP_DIR/filestore_$DATE.tar.gz

# Eliminar backups mayores a 7 días
find $BACKUP_DIR -type f -mtime +7 -delete

echo "Backup completado: $DATE"
```

```bash
# Programar con cron (diario a las 3am)
crontab -e
0 3 * * * /home/ubuntu/backup_odoo.sh
```

---

## 2.7 Configuración con Dokploy

### Instalar Odoo en Dokploy

```
Dashboard → Databases → Create
- Type: PostgreSQL
- Name: odoo
- User: odoo
- Password: odoo_password

Dashboard → Applications → Create
- Name: odoo
- Type: Docker Image
- Image: odoo:17.0
- Environment Variables:
  - HOST=postgres
  - PORT=5432
  - USER=odoo
  - PASSWORD=odoo_password
  - DATABASE=odoo
- Ports:
  - 8069:8069
  - 8070:8070
```

---

## 2.8 Ejercicios Prácticos

### Ejercicio 1: Instalar Odoo

```bash
# Crear docker-compose.yml
# Ejecutar docker compose up -d

# Acceder a http://localhost:8069
# Crear base de datos
```

### Ejercicio 2: Configurar Módulos

```bash
# En la interfaz:
# 1. Instalar CRM
# 2. Instalar Contabilidad  
# 3. Instalar Inventory
# 4. Configurar datos de empresa
```

### Ejercicio 3: Integrar con Flutter

```dart
// Crear cliente Odoo
// Implementar login
// Listar partners
// Crear un lead de prueba
```

---

## 2.9 Recomendaciones de Producción

### Seguridad

```
1. Cambiar admin_passwd
2. Usar SSL/TLS
3. Configurar firewall (solo puerto 8069)
4. Usar usuarios y grupos de Odoo
5. Habilitar HTTPS con proxy (nginx/caddy)
```

### Rendimiento

```
1. Ajustar workers según CPU
2. Usar CDN para archivos estáticos
3. Configurar caché
4. Monitorear logs
5. Programar mantenimientos nocturnos
```

### Mantenimiento

```
1. Backups diarios
2. Actualizar Odoo regularmente
3. Revisar logs semanalmente
4. Limpiar base de datos (logs antiguos)
5. Monitorear espacio en disco
```

---

## 2.10 Recursos Adicionales

### Comandos Útiles

```bash
# Reiniciar Odoo
docker compose restart odoo

# Ver logs
docker compose logs -f odoo

# Actualizar Odoo
docker compose pull
docker compose up -d

# Instalar módulo desde línea
docker exec -it odoo odoo -u mi_modulo -d odoo_production
```

### Documentación

```
- https://www.odoo.com/documentation/17.0/
- https://www.odoo.com/es_ES/
- Foros de usuarios
```

---

## Resumen

En esta guía has aprendido:

- ✅ Instalar Odoo en Docker
- ✅ Configurar PostgreSQL para Odoo
- ✅ Gestionar módulos desde la interfaz
- ✅ API de Odoo para integración
- ✅ Backups automáticos
- ✅ Integración con Flutter via XML-RPC

**Siguiente guía:** Dominio Local y DNS - Configurar servidor DNS local.