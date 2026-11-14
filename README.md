# Mercatto Flutter

Aplicación móvil Flutter creada a partir del backend Spring Boot incluido en el repositorio original de Mercatto.

## Funcionalidades incluidas
- Catálogo conectado a `GET /api/productos`.
- Categorías conectadas a `GET /api/categorias`.
- Búsqueda local por nombre y descripción.
- Detalle de producto.
- Carrito y favoritos locales para la demostración.
- Registro de comprador conectado a `POST /api/auth/registro`.
- Inicio de sesión conectado a `POST /api/auth/login` y almacenamiento local del access token.
- Navegación Inicio / Carrito / Favoritos / Perfil.

## Requisitos
- Flutter SDK instalado (canal estable).
- Android Studio o Visual Studio Code con extensiones Flutter y Dart.
- Backend Mercatto desplegado y accesible desde el dispositivo.

## Ejecutar
Desde esta carpeta, genera los directorios nativos (Android/iOS) una sola vez y ejecuta:

```bash
flutter create --platforms=android,ios .
flutter pub get
flutter run
```

La URL base se puede cambiar sin editar el código:

```bash
flutter run --dart-define=API_BASE_URL=https://TU-DOMINIO-DEL-BACKEND
```

Por defecto está configurada como `https://mercatto-backend.onrender.com`. Confirma que esa sea la URL real de despliegue. Si el backend está en tu computador y pruebas en un emulador Android, normalmente se usa `http://10.0.2.2:8080`; en un teléfono físico usa la IP local de tu computador y asegúrate de que ambos estén en la misma red.

## Endpoints utilizados
- `GET /api/productos?pagina=0&tamano=30&orden=recientes`
- `GET /api/categorias`
- `POST /api/auth/login` con `{ "email", "password", "recordarme" }`

El backend devuelve `accessToken`, que se envía en las siguientes peticiones como `Authorization: Bearer <token>`.

## Importante sobre el alcance
Esta es la primera versión móvil funcional/integrable. El carrito y favoritos se mantienen en memoria durante la ejecución; no se simula un pago ni se crean pedidos. El checkout, publicación de productos, pedidos y edición de perfil deben añadirse conectando los DTO y reglas completos del backend y probándolos con una instancia desplegada. No se incluye una URL de backend inventada como garantía de disponibilidad.

## Estructura
```
lib/
  main.dart
  models/product.dart
  services/api_service.dart
  screens/home_screen.dart
  screens/login_screen.dart
```
