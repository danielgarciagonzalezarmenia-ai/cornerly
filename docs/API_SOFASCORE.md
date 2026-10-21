# API de Sofascore — Documentación de endpoints

**Cornerly** utiliza los endpoints públicos (no oficiales) de Sofascore para obtener partidos de fútbol, cuotas 1X2 y estadísticas de corners.

> **Importante:** Sofascore no publica una API oficial documentada. Los endpoints listados abajo son rutas web públicas/no oficiales descubiertas mediante inspección de tráfico y documentación comunitaria. Deben validarse con llamadas reales antes de usarse en producción. Si algún endpoint cambia o deja de funcionar, actualizar `SofascoreRepository` en `lib/services/sofascore_repository.dart`.

## Base URL

```
https://api.sofascore.com/api/v1
```

## Headers recomendados

Enviar siempre cabeceras razonables para simular un navegador móvil y evitar bloqueos:

| Cabecera | Valor ejemplo |
|----------|---------------|
| `User-Agent` | `Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1` |
| `Accept` | `application/json` |
| `Referer` | `https://www.sofascore.com/` |
| `Accept-Language` | `es-ES,es;q=0.9` |

## Endpoints

### 1. Partidos programados por fecha

```
GET /sport/football/scheduled-events/{YYYY-MM-DD}
```

Devuelve la lista de partidos de fútbol programados para la fecha dada (zona horaria UTC).

Parámetros de ruta:
- `{YYYY-MM-DD}`: fecha en formato ISO (ej. `2026-10-21`).

Estructura esperada (respuesta real de ejemplo):

```json
{
  "events": [
    {
      "id": 12345678,
      "startTimestamp": 1792598400,
      "homeTeam": {
        "name": "Equipo Local",
        "logo": "https://..."
      },
      "awayTeam": {
        "name": "Equipo Visitante",
        "logo": "https://..."
      },
      "tournament": {
        "name": "Liga XYZ",
        "logo": "https://..."
      }
    }
  ]
}
```

### 2. Cuotas de un partido

```
GET /event/{eventId}/odds/1/all
```

Devuelve las cuotas del mercado 1X2 (Local, Empate, Visitante) y otros mercados incluyendo corners.

Parámetros de ruta:
- `{eventId}`: ID del evento numérico.

Estructura esperada:

```json
{
  "odds": {
    "mercado_1x2": {
      "1": 1.30,
      "X": 5.20,
      "2": 9.50
    },
    "mercado_corners": {
      "name": "Total corners",
      "odds": {
        "line_7.5": {
          "line": 7.5,
          "over": 1.45,
          "under": 2.60
        },
        "line_11.5": {
          "line": 11.5,
          "over": 1.10,
          "under": 5.80
        }
      }
    }
  }
}
```

> Nota: los nombres exactos de los mercados y claves pueden variar. Validar con una llamada real antes de asumir la estructura.

### 3. Estadísticas de un partido (incluye corners)

```
GET /event/{eventId}/statistics
```

Devuelve las estadísticas del partido, incluyendo corners totales, corners por equipo, etc.

Estructura esperada (parcial):

```json
{
  "statistics": [
    {
      "period": "ALL",
      "groups": [
        {
          "groupName": "Corners",
          "statisticsItems": [
            {
              "name": "Corners",
              "home": 5,
              "away": 3
            },
            {
              "name": "Corners totales",
              "home": null,
              "away": null,
              "value": 8
            }
          ]
        }
      ]
    }
  ]
}
```

### 4. Detalle y resultado de un partido

```
GET /event/{eventId}
```

Devuelve el detalle completo del evento, incluyendo marcador, estado (programado, en vivo, finalizado) y tiempo transcurrido.

## Límites y buenas prácticas

- **Máximo 3-5 peticiones concurrentes** para evitar ser bloqueado.
- **Reintentos con backoff exponencial** en caso de error 403/429.
- **Caché local** de lo ya consultado (duración recomendada: 5 minutos).
- **Pausas pequeñas** entre peticiones para no saturar la API.
- Si hay bloqueo (403/429), mostrar mensaje claro al usuario y permitir reintentar más tarde. **Nunca rellenar con datos falsos.**

## Conversión de cuotas fraccionales a decimales

Algunas cuotas pueden venir en formato fraccional (ej. `"13/10"`). Convertir a decimal con:

```
decimal = 1 + (numerador / denominador)
```

Ejemplos:
- `13/10` → 2.30
- `1/2` → 1.50
- `6/4` → 2.50

Validar siempre el formato real que devuelva la API.

## Mercados de corners relevantes

La app busca dos líneas específicas en el mercado de corners:

| Filtro | Línea | Selección |
|--------|-------|-----------|
| A | 7.5 | Más de 7.5 corners |
| B | 11.5 | Menos de 11.5 corners |

Identificar el mercado por nombre (debe contener "corner") y por el valor exacto de `line`.

## Aislamiento

Todo el acceso a la API está aislado en `SofascoreRepository` (`lib/services/sofascore_repository.dart`) para poder cambiar la fuente fácilmente si Sofascore modifica sus rutas.
