# Mercatto Flutter

Este repositorio contiene la aplicación móvil de Mercatto que estoy desarrollando con Flutter. La idea es ofrecer desde el celular una forma sencilla de consultar los productos que se publican en la plataforma.

La aplicación consume los servicios REST del backend de Mercatto desarrollado con Spring Boot. No reemplaza el backend ni guarda los productos en una base de datos propia.

## Funciones que incluye esta versión

- Consultar el catálogo de productos desde `GET /api/productos`.
- Consultar las categorías desde `GET /api/categorias`.
- Buscar productos por nombre o descripción dentro de los productos cargados.
- Filtrar los productos por categoría.
- Ver el detalle básico de un producto.
- Agregar y quitar productos del carrito durante el uso de la aplicación.
- Marcar productos como favoritos durante el uso de la aplicación.
- Crear una cuenta de comprador mediante `POST /api/auth/registro`.
- Iniciar sesión mediante `POST /api/auth/login` y guardar el token de acceso en el dispositivo.
- Consultar el correo de la sesión y cerrar sesión.

## Tecnologías

- Flutter y Dart para la aplicación móvil.
- Spring Boot para los servicios del backend.
- API REST para el intercambio de información.
- `http` para realizar las peticiones al backend.
- `shared_preferences` para guardar localmente el token y el correo de la sesión.

## Requisitos para ejecutar

- Flutter SDK instalado y agregado al PATH de Windows.
- Android Studio o Visual Studio Code con las extensiones Flutter y Dart.
- Un emulador Android o un teléfono Android con depuración USB.
- El backend de Mercatto encendido y accesible desde el dispositivo.

## Pasos para ejecutar en Windows

Abre una terminal dentro de esta carpeta y ejecuta:

```bash
flutter create --platforms=android .
flutter pub get
flutter run
```

El primer comando genera la estructura nativa de Android que necesita Flutter. Solo hace falta ejecutarlo la primera vez si esa estructura todavía no existe.

Para comprobar la instalación de Flutter puedes ejecutar:

```bash
flutter doctor
```

## Dirección del backend

La aplicación tiene como dirección predeterminada:

```text
https://mercatto-backend.onrender.com
```

Esta dirección corresponde a la configuración de despliegue que aparece en el repositorio original. Para usarla, el servicio debe estar publicado y disponible. Si el backend está apagado, la aplicación no podrá cargar los productos ni iniciar sesión.

Si se quiere usar otra dirección, se puede indicar al ejecutar la aplicación:

```bash
flutter run --dart-define=API_BASE_URL=https://DIRECCION-REAL-DEL-BACKEND
```

Si el backend se ejecuta localmente en el mismo computador y se prueba con el emulador Android, normalmente se utiliza:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

En un teléfono físico se debe utilizar la dirección IP local del computador, siempre que ambos estén conectados a la misma red y el backend permita conexiones desde ella.

## Servicios del backend utilizados

| Función | Método y ruta |
|---|---|
| Listar productos | `GET /api/productos` |
| Listar categorías | `GET /api/categorias` |
| Registrar comprador | `POST /api/auth/registro` |
| Iniciar sesión | `POST /api/auth/login` |

El inicio de sesión y el registro de comprador guardan el `accessToken` que devuelve el backend. Las solicitudes posteriores incluyen ese token como `Authorization: Bearer`.

## Alcance y aspectos pendientes

Esta es una primera versión móvil conectada a los servicios de consulta de productos, categorías y autenticación del backend. El carrito y los favoritos todavía se manejan temporalmente en memoria: se pierden al cerrar la aplicación. En esta versión no se realiza el pago, no se confirma una compra y no se crea un pedido desde el carrito. Tampoco se incluyen todavía las funciones de publicación y administración de productos para vendedores.

La conexión depende de que el backend esté disponible y tenga configurada la base de datos y los servicios que necesita. Antes de presentar una demostración, se debe ejecutar la aplicación en un dispositivo o emulador y comprobar que la dirección del backend responda.

## Estructura principal

```text
lib/
  main.dart
  models/
    product.dart
  services/
    api_service.dart
  screens/
    home_screen.dart
    login_screen.dart
```
