# Future Calls y Manejo de Archivos

> Aprende a ejecutar tareas en segundo plano y a gestionar el almacenamiento de archivos en la nube con Serverpod.

---

## Tabla de Contenidos

1. [Future Calls: Tareas Programadas](#1-future-calls-tareas-programadas)
2. [Configuración de Future Calls](#2-configuración-de-future-calls)
3. [Manejo de Archivos (S3/Google Cloud Storage)](#3-manejo-de-archivos)
4. [Subida Directa desde Flutter](#4-subida-directa-desde-flutter)
5. [Buenas Prácticas](#5-buenas-prácticas)

---

## 1. Future Calls: Tareas Programadas

### ¿Qué es una Future Call?

En el backend, a menudo necesitas que algo suceda **más tarde** o de forma **asíncrona** sin bloquear la respuesta al usuario. Serverpod usa `Future Calls` para esto.

Ejemplos comunes:
- Enviar un email de bienvenida 5 minutos después del registro.
- Invalidar una sesión después de 24 horas.
- Procesar una imagen pesada en segundo plano.

### Crear una Future Call

1.  Crea una clase que herede de `FutureCall`:
    ```dart
    // lib/src/future_calls/welcome_email_call.dart
    import 'package:serverpod/serverpod.dart';

    class WelcomeEmailCall extends FutureCall {
      @override
      Future<void> invoke(Session session, SerializableModel? object) async {
        // El 'object' contiene los datos que pasaste al programar la llamada
        final userId = object as int;
        
        print('Enviando email de bienvenida al usuario: $userId');
        // Aquí iría tu lógica de envío de email real
      }
    }
    ```

2.  Regístrala en `main.dart`:
    ```dart
    void run(List<String> args) async {
      final pod = Serverpod(args, Protocol(), ...);
      
      // Registrar la Future Call
      pod.registerFutureCall(WelcomeEmailCall(), 'welcomeEmailCall');
      
      await pod.start();
    }
    ```

---

## 2. Configuración de Future Calls

### Programar una Llamada desde un Endpoint

Puedes programar una llamada para que ocurra en el futuro usando `session.server.futureCallWithDelay`:

```dart
class UserEndpoint extends Endpoint {
  Future<void> registerUser(Session session, User user) async {
    // 1. Guardar usuario en DB
    await User.db.insertRow(session, user);
    
    // 2. Programar email de bienvenida para dentro de 5 minutos
    await session.server.futureCallWithDelay(
      'welcomeEmailCall',
      user.id!,
      Duration(minutes: 5),
    );
  }
}
```

### Llamadas Recurrentes (Cron Jobs)

Si necesitas que una tarea se ejecute, por ejemplo, cada hora, puedes hacer que la llamada se programe a sí misma al final de su ejecución:

```dart
class CleanupCall extends FutureCall {
  @override
  Future<void> invoke(Session session, SerializableModel? object) async {
    // Lógica de limpieza...
    
    // Volver a programar para dentro de 1 hora
    await session.server.futureCallWithDelay('cleanupCall', null, Duration(hours: 1));
  }
}
```

---

## 3. Manejo de Archivos

### Almacenamiento en la Nube

Serverpod tiene soporte integrado para:
- **Database**: Guarda archivos pequeños directamente en la base de datos (no recomendado para producción).
- **S3**: Amazon S3, DigitalOcean Spaces, MinIO.
- **GCP**: Google Cloud Storage.

### Configuración en `config/development.yaml`

```yaml
storage:
  public:
    type: s3
    region: us-east-1
    bucket: my-app-public-files
    accessKey: your_access_key
    secretKey: your_secret_key
  private:
    type: database
```

---

## 4. Subida Directa desde Flutter

Una de las mejores características de Serverpod es que permite que la app Flutter suba archivos **directamente a S3/GCP** mediante una URL firmada, ahorrando recursos en tu servidor.

### Flujo de Subida Profesional

1.  **En Flutter**: Pides una "Upload Description" al servidor.
2.  **En el Servidor**: Generas una URL firmada segura.
3.  **En Flutter**: Subes el archivo directamente a esa URL.

### Ejemplo de Endpoint (Servidor)

```dart
class UploadEndpoint extends Endpoint {
  Future<String?> getUploadUrl(Session session, String path) async {
    // Generar descripción de subida para el almacenamiento 'public'
    return await session.storage.createDirectUploadDescription(
      storageId: 'public',
      path: path,
    );
  }
  
  Future<bool> verifyUpload(Session session, String path) async {
    // Verificar si el archivo se subió correctamente
    return await session.storage.verifyDirectUpload(
      storageId: 'public',
      path: path,
    );
  }
}
```

### Ejemplo en Flutter (Cliente)

```dart
// 1. Obtener la descripción de subida
final uploadDescription = await client.upload.getUploadUrl('profile_pics/user_123.png');

if (uploadDescription != null) {
  // 2. Usar el Uploader integrado para subir el archivo (binario)
  final uploader = FileUploader(uploadDescription);
  await uploader.upload(myFileStream, length);
  
  // 3. Confirmar al servidor que terminó
  final success = await client.upload.verifyUpload('profile_pics/user_123.png');
}
```

---

## 5. Buenas Prácticas

1.  **Future Calls**: No pases objetos pesados en el parámetro `object`. Pasa solo el `ID` y deja que la Future Call busque los datos frescos en la base de datos.
2.  **Archivos**: Nunca subas archivos grandes a través de los métodos del Endpoint (como `List<int>`). Usa siempre **Direct Upload** para eficiencia.
3.  **Seguridad**: Valida siempre quién pide la URL de subida para evitar que usuarios malintencionados llenen tu almacenamiento.
4.  **Limpieza**: Usa Future Calls para borrar archivos temporales o antiguos que ya no se necesiten.

---

## 🎯 Próximo Paso

Aprende a desplegar tu servidor profesionalmente en [09-DOCKER-Y-DESPLIEGUE.md](./09-DOCKER-Y-DESPLIEGUE.md).
