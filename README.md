# Cornerly

**Cornerly** — Analiza. Filtra. Gana corners.

App local de análisis de apuestas de corners de fútbol para iOS. Funciona 100% en el dispositivo (sin backend, sin cuentas, sin login). Todo se guarda localmente.

## ¿Qué hace Cornerly?

Cornerly analiza los partidos de fútbol programados para hoy y aplica dos filtros sobre las cuotas 1X2 (obtenidas de Sofascore) para detectar oportunidades en el mercado de corners:

- **Filtro A — Más de 7.5 corners**: si la cuota del local es menor a 1.38.
- **Filtro B — Menos de 11.5 corners**: si la cuota del local es mayor a 2.05, la del visitante es mayor que la del local y menor a 3.30.

Solo se muestran partidos que también tengan mercado de corners disponible. Puedes agregar partidos a una combinada (slip), definir el monto a apostar, y hacer el seguimiento automático de los resultados cuando los partidos finalizan.

## Requisitos

- iPhone con iOS 13 o superior (probado en iOS 26/27).
- iTunes o Apple Devices instalado desde apple.com (la versión de Microsoft Store no funciona).
- Sideloadly (https://sideloadly.io).
- Un Apple ID gratuito (no hace falta cuenta de desarrollador de pago).

## Instalación en iPhone (6 pasos)

1. Descarga e instala **Sideloadly** desde https://sideloadly.io. Instala también **iTunes** o **Apple Devices** desde apple.com.
2. Conecta el iPhone por USB, desbloquéalo y pulsa **Confiar** cuando se lo pida.
3. Activa el **Modo desarrollador**: Ajustes > Privacidad y seguridad > Modo desarrollador → activar → reinicia el iPhone.
4. Arrastra el archivo `App-unsigned.ipa` a Sideloadly, escribe tu **Apple ID** (gratuito, sin necesidad de desarrollador) y pulsa **Start**. Introduce el código de verificación en 2 pasos cuando se te pida.
5. Ve a Ajustes > General > VPN y gestión de dispositivos > Desarrollador de la app > **Confiar** en el perfil de Cornerly.
6. Abre la app y concede los permisos que se soliciten.

### Límites de la firma gratuita de Apple

- El `.ipa` firmado con Apple ID gratuito **caduca a los 7 días**.
- Máximo **3 apps** instaladas simultáneamente por Apple ID.
- Para renovar, vuelve a pasar el `.ipa` por Sideloadly (conserva los datos locales) o usa **SideStore**.
- **TrollStore no funciona** en iOS 26/27.

## Estructura del proyecto

```
lib/
  main.dart              - Punto de entrada y navegación
  app_router.dart        - Router de pantallas
  theme/app_theme.dart   - Colores, tipografía y diseño visual
  utils/constants.dart   - Constantes de la app y umbrales de filtros
  models/data_models.dart - Modelos de datos (perfil, partidos, combinadas, saldo)
  providers/app_provider.dart - Gestión de estado con Provider
  services/
    database_service.dart - Base de datos local (sqflite)
    analysis_service.dart - Lógica de filtros A/B y análisis diario
    notification_service.dart - Notificaciones locales programadas
    prefs_service.dart - Preferencias simples (shared_preferences)
    sofascore_repository.dart - Capa de acceso a la API de Sofascore
  ui/screens/            - Pantallas de la app
  ui/widgets/            - Widgets reutilizables
test/
  analysis_test.dart     - Pruebas unitarias de filtros y conversión de cuotas
.github/workflows/
  ios-build.yml          - CI que compila el .ipa sin firmar en macOS-latest
```

## Tecnologías utilizadas

- Flutter 3.41.9 / Dart 3.11.5
- Provider para gestión de estado
- Sqflite para base de datos local
- SharedPreferences para preferencias simples
- flutter_local_notifications + timezone para notificaciones programadas
- HTTP para llamadas a la API de Sofascore
- CachedNetworkImage para caché de imágenes
- Phosphor Icons para iconografía

## Créditos

- Datos de partidos y cuotas: [Sofascore](https://www.sofascore.com) (endpoints públicos no oficiales).
- Iconos: Phosphor Icons.

## Aviso de juego responsable

Cornerly es una herramienta de análisis, no garantiza resultados. Apuesta solo lo que puedas permitirte perder. La app no procesa pagos ni apuestas reales: solo analiza y lleva un registro personal local.
