# FASE 1 — Arquitectura, stack y contratos

## 1) Arquitectura general propuesta

Se propone una arquitectura de 3 capas principales para el MVP:

1. **Flutter App (cliente móvil)**
   - Captura/selección de imagen.
   - Compresión iterativa a `<= 50 KB`.
   - Previsualización, edición manual de campos y envío.
   - Manejo de estado de UI y errores de forma explícita.

2. **Backend API seguro (FastAPI)**
   - Autenticación por **JWT corto** emitido por backend (sin secretos en app).
   - Validación de archivo + rate limit + sanitización.
   - Orquestación de análisis (servicio visión/LLM) y normalización a JSON objetivo.
   - Publicación al sitio final.

3. **Sitio final / endpoint de publicación**
   - Recibe payload normalizado del backend.
   - Crea/actualiza publicación.

### Diagrama lógico (alto nivel)

`Flutter -> (JWT + multipart) -> FastAPI -> (LLM/visión) -> FastAPI normaliza JSON -> sitio final`

---

## 2) Justificación de stack (MVP)

### Backend elegido: **Python + FastAPI**

**Por qué para MVP:**
- Tipado claro con Pydantic para contratos JSON confiables.
- Muy buen soporte para `multipart/form-data` y validaciones.
- Arranque rápido y estructura limpia.
- Fácil integración con proveedores de IA y cliente HTTP asíncrono.
- Excelente DX para logging, middlewares y documentación OpenAPI.

### Gestión de estado Flutter: **Riverpod**

**Por qué:**
- Escalable y explícito sin boilerplate excesivo.
- Facilita separar UI de lógica (providers/notifiers).
- Testeable y limpio para flujos asíncronos (compresión, upload, análisis).

### Cliente HTTP en Flutter: **Dio**

**Por qué:**
- Manejo robusto de multipart, interceptores, timeouts y errores tipados.
- Mejor ergonomía que `http` para retries básicos y logging controlado.

---

## 3) Estructura de carpetas — Flutter

```txt
mobile_app/
  lib/
    app/
      app.dart
      router.dart
      theme.dart
      config/
        env.dart
        constants.dart
    core/
      error/
        app_exception.dart
        failure.dart
      network/
        dio_client.dart
        auth_interceptor.dart
      utils/
        validators.dart
        sanitizer.dart
        image_optimizer.dart
      logging/
        logger.dart
    features/
      capture/
        data/
          image_source_service.dart
        application/
          capture_controller.dart
        presentation/
          capture_page.dart
      preview/
        application/
          preview_controller.dart
        presentation/
          preview_page.dart
      analysis/
        data/
          analysis_repository.dart
          dto/
            analyze_response_dto.dart
        application/
          analysis_controller.dart
        presentation/
          analysis_result_page.dart
      listing_edit/
        application/
          listing_form_controller.dart
        presentation/
          listing_edit_page.dart
      publish/
        data/
          publish_repository.dart
          dto/
            publish_response_dto.dart
        application/
          publish_controller.dart
        presentation/
          publish_success_page.dart
      history/
        data/
          history_local_store.dart
        application/
          history_controller.dart
        presentation/
          history_page.dart
    shared/
      widgets/
        app_scaffold.dart
        primary_button.dart
        inline_error.dart
        loading_indicator.dart
      models/
        listing_draft.dart
        listing_result.dart
  assets/
    fonts/
    icons/
  test/
    unit/
    widget/
  pubspec.yaml
```

---

## 4) Estructura de carpetas — Backend (FastAPI)

```txt
backend_api/
  app/
    main.py
    api/
      v1/
        routes/
          auth.py
          upload.py
          health.py
    core/
      config.py
      security.py
      rate_limit.py
      logging.py
    models/
      listing.py
      auth.py
    schemas/
      listing_schema.py
      response_schema.py
      error_schema.py
    services/
      auth_service.py
      image_validation_service.py
      image_storage_service.py
      vision_llm_service.py
      listing_mapper_service.py
      site_publisher_service.py
    clients/
      llm_client.py
      site_client.py
    utils/
      sanitize.py
      file_helpers.py
  tests/
    test_auth.py
    test_upload.py
    test_mapping.py
  .env.example
  pyproject.toml
  README.md
```

---

## 5) Dependencias necesarias

## Flutter (`mobile_app/pubspec.yaml`)

- `flutter_riverpod`
- `dio`
- `image_picker`
- `flutter_image_compress` (compresión iterativa por calidad y opcional resolución)
- `path_provider`
- `mime`
- `uuid`
- `shared_preferences` (historial local MVP)
- `json_annotation` (opcional si luego usan codegen)

Dev:
- `flutter_lints`
- `build_runner` (opcional)
- `json_serializable` (opcional)

### Comandos instalación Flutter

```bash
flutter create mobile_app
cd mobile_app
flutter pub add flutter_riverpod dio image_picker flutter_image_compress path_provider mime uuid shared_preferences
flutter pub add --dev flutter_lints build_runner json_serializable
```

## Backend (`backend_api`)

- `fastapi`
- `uvicorn[standard]`
- `python-multipart`
- `pydantic-settings`
- `httpx`
- `python-jose[cryptography]` (JWT)
- `passlib[bcrypt]` (si luego extienden auth)
- `slowapi` (rate limit)
- `orjson`
- `tenacity` (retry simple)

Dev/test:
- `pytest`
- `pytest-asyncio`
- `ruff`

### Comandos instalación Backend

```bash
mkdir backend_api && cd backend_api
python -m venv .venv
source .venv/bin/activate
pip install fastapi "uvicorn[standard]" python-multipart pydantic-settings httpx "python-jose[cryptography]" "passlib[bcrypt]" slowapi orjson tenacity
pip install pytest pytest-asyncio ruff
```

---

## 6) Flujo end-to-end

1. Usuario abre Home y elige **Cámara** o **Galería**.
2. App recibe imagen local.
3. `image_optimizer` ejecuta compresión iterativa:
   - Ajusta calidad (p.ej. 90 -> 80 -> 70 ...).
   - Si no alcanza `<= 50 KB`, reduce dimensión progresivamente.
   - Frena con umbral mínimo para no destruir legibilidad.
4. App muestra vista previa y tamaño final.
5. Usuario confirma análisis.
6. App solicita/usa JWT corto (obtenido desde backend con API bootstrap o device token temporal).
7. App envía `multipart/form-data` a backend: imagen + metadatos opcionales.
8. Backend valida token, MIME, tamaño, rate limit.
9. Backend almacena temporalmente imagen.
10. Backend llama servicio visión/LLM (con secretos solo en backend).
11. Backend genera JSON normalizado del anuncio.
12. Backend reenvía JSON (y opcional URL de imagen) al sitio final.
13. Backend responde a app con estado final, payload enviado y detalles.
14. App muestra resultado, permite editar y reenviar si aplica.
15. App guarda historial local básico de envíos.

---

## 7) Contratos API entre app y backend

## 7.1 Auth bootstrap (MVP)

### `POST /api/v1/auth/device-token`

**Request**

```json
{
  "device_id": "string",
  "app_version": "1.0.0"
}
```

**Response 200**

```json
{
  "access_token": "jwt",
  "token_type": "Bearer",
  "expires_in": 900
}
```

Notas:
- JWT corto (15 min).
- Preparado para migrar a login real luego.

## 7.2 Upload + analyze + publish (orquestado)

### `POST /api/v1/upload/analyze-publish`
Headers:
- `Authorization: Bearer <jwt>`
- `X-Request-Id: <uuid>`

`multipart/form-data`:
- `image`: archivo comprimido (`image/jpeg` o `image/png`)
- `pickup_area`: string opcional
- `user_notes`: string opcional
- `dry_run`: boolean opcional (si `true`, analiza sin publicar)

**Response 200**

```json
{
  "status": "success",
  "analysis": {
    "title": "Mesa auxiliar de madera",
    "price": 35,
    "category": "hogar",
    "condition": "good",
    "pickup_area": "Gràcia",
    "description": "Mesa auxiliar compacta en buen estado...",
    "author": null,
    "genre": null,
    "language": null
  },
  "published": true,
  "site_response": {
    "listing_id": "abc123",
    "url": "https://sitio/item/abc123"
  },
  "request_id": "uuid"
}
```

**Errores estándar**

```json
{
  "status": "error",
  "code": "INVALID_FILE_TYPE",
  "message": "Solo se permiten imágenes JPG o PNG",
  "request_id": "uuid"
}
```

Códigos sugeridos:
- `400` validación de entrada.
- `401` token inválido/expirado.
- `413` archivo demasiado grande.
- `429` rate limit.
- `502` fallo en proveedor externo.

---

## 8) Contrato backend -> sitio final

### `POST /external/listings`
Headers:
- `Authorization: Bearer <SITE_API_TOKEN>`
- `Content-Type: application/json`
- `X-Idempotency-Key: <uuid>`

**Payload mínimo compatible**

```json
{
  "title": "string",
  "price": 0,
  "category": "string",
  "condition": "new | like_new | good | fair | parts",
  "pickup_area": "string",
  "description": "string"
}
```

**Campos opcionales solo si aporta valor**

```json
{
  "author": "string",
  "genre": "string",
  "language": "string"
}
```

Reglas:
- Si no es libro, no enviar campos de libro.
- Sanitizar texto (trim, longitud máxima, caracteres de control).
- Aplicar idempotencia para evitar duplicados por reintentos.

---

## 9) Seguridad MVP propuesta

- Secreto LLM solo en backend (`.env`).
- JWT corto para app -> backend.
- Rate limit por IP/device.
- Validación de MIME real y extensión.
- Límite de tamaño de upload de entrada (p.ej. 5 MB) antes de procesar.
- Compresión en app a `<= 50 KB` como requisito funcional final.
- Sanitización en backend de todo texto generado o enviado por usuario.
- Logs estructurados sin datos sensibles.

---

## 10) Archivos base mínimos sugeridos (solo estructura)

### `mobile_app/lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'app/app.dart';

void main() {
  runApp(const App());
}
```

### `backend_api/app/main.py`

```python
from fastapi import FastAPI

app = FastAPI(title="Recon Backend API", version="0.1.0")

@app.get("/health")
async def health():
    return {"status": "ok"}
```

### `backend_api/.env.example`

```env
APP_ENV=development
APP_PORT=8000
JWT_SECRET=change_me
JWT_EXPIRES_MIN=15
LLM_API_KEY=change_me
LLM_MODEL=gpt-4.1-mini
SITE_API_URL=https://example.com/external/listings
SITE_API_TOKEN=change_me
MAX_UPLOAD_MB=5
RATE_LIMIT_PER_MIN=30
```

