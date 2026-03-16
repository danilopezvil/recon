# Recon Mobile App

Aplicación Flutter para captura de imágenes, análisis de ítems y preparación/publicación de contenido con arquitectura por capas y soporte de integración API (mock + HTTP).

## 1. Objetivo de la app

La app permite ejecutar un flujo completo desde dispositivo móvil:

1. Captura o selección de imagen.
2. Optimización de imagen para reducir tamaño.
3. Vista previa del recurso.
4. Análisis de datos del ítem (actualmente con mock por defecto).
5. Edición manual del borrador.
6. Confirmación de publicación.
7. Persistencia de historial local.

## 2. Stack técnico

- **Flutter** (SDK `>=3.3.0 <4.0.0`)
- **Riverpod** para estado y orquestación de flujo.
- **Dio** para cliente HTTP y capa de red.
- **image_picker** para cámara/galería.
- **flutter_image_compress** para optimización de imágenes.
- **shared_preferences** para historial local (MVP).

## 3. Estructura del proyecto

```txt
mobile_app/
  lib/
    app/                 # App raíz, tema, ruteo y providers
    core/                # Red, errores, utilidades
    data/                # Datasources, DTOs, mappers y repositorios
    domain/              # Modelos y contratos de dominio
    features/            # Flujos por pantalla/caso de uso
    shared/              # Widgets reutilizables
    main.dart            # Entry point
  test/                  # Pruebas unitarias
  pubspec.yaml
```

## 4. Proceso de generación de la app (bootstrap)

Si necesitas recrear esta app desde cero, usa este flujo base:

```bash
mkdir -p recon && cd recon
flutter create mobile_app
cd mobile_app
flutter pub add flutter_riverpod dio image_picker flutter_image_compress path_provider shared_preferences uuid
flutter pub add --dev flutter_lints
```

Después, incorpora la estructura de capas (`app`, `core`, `domain`, `data`, `features`, `shared`) y migra los módulos funcionales del repositorio actual.

## 5. Instalación y ejecución local

Desde la raíz del repositorio:

```bash
cd mobile_app
flutter pub get
flutter run
```

> Recomendado: ejecutar en emulador o dispositivo físico con permisos de cámara y galería habilitados.

## 6. Entornos y API

La app está preparada para dos modos de datasource:

- **MockItemRemoteDataSource**: flujo local/simulado para desarrollo rápido.
- **HttpItemRemoteDataSource**: punto de integración para API real (fase backend).

Para conectar backend real:

1. Implementar endpoints en `HttpItemRemoteDataSource`.
2. Ajustar `baseUrl` y timeouts en la configuración de red.
3. Mantener contratos de dominio (`analyzeItem`, `publishItem`) para no romper la UI.

## 7. Ejecución de pruebas

```bash
cd mobile_app
flutter test
```

También puedes ejecutar una prueba específica:

```bash
flutter test test/features/workflow_controller_test.dart
```

## 8. Flujo funcional resumido

1. **Home Capture**: origen de imagen (cámara/galería).
2. **Preview**: validación visual y tamaño.
3. **Analysis Result**: resultado estructurado del análisis.
4. **Manual Edit**: ajustes de datos previo a publicación.
5. **Publish Confirmation**: confirmación y persistencia.
6. **History**: consulta de ítems procesados/publicados.

## 9. Buenas prácticas recomendadas

- Mantener reglas de mapeo en `data/mappers`.
- Conservar modelos puros y sin dependencias de infraestructura en `domain/models`.
- Usar providers para coordinar estado y side effects.
- Agregar pruebas al introducir nuevos casos de negocio.

## 10. Referencias internas

- `docs/FASE1_arquitectura.md`: visión de arquitectura general.
- `docs/FASE2_flutter_only.md`: alcance Flutter-only y comandos base.
