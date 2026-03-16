# FASE 2 — Implementación base solo Flutter (sin backend)

Este alcance implementa únicamente la app Flutter, con flujos locales funcionales, análisis/publicación simulados y capa de datos remota preparada para conectar API real en la siguiente fase.

## 1) Comandos para crear el proyecto Flutter

```bash
mkdir -p recon && cd recon
flutter create mobile_app
cd mobile_app
flutter pub add flutter_riverpod dio image_picker flutter_image_compress path_provider shared_preferences uuid
flutter pub add --dev flutter_lints
```

## 2) Estructura de carpetas (solo Flutter)

```txt
mobile_app/
  lib/
    app/
      app.dart
      router.dart
      theme.dart
      providers.dart
    core/
      network/
        dio_client.dart
      utils/
        image_optimizer.dart
    domain/
      models/
        analyzed_item.dart
        publish_payload.dart
        process_result.dart
      repositories/
        history_repository.dart
      services/
        item_processing_service.dart
    data/
      datasources/
        item_remote_data_source.dart
        mock_item_remote_data_source.dart
        http_item_remote_data_source.dart
      repositories/
        item_processing_repository.dart
      local/
        history_local_store.dart
    features/
      capture/
        application/
          workflow_controller.dart
        presentation/
          home_capture_page.dart
      preview/
        presentation/
          preview_page.dart
      analysis/
        presentation/
          analysis_result_page.dart
      edit/
        presentation/
          manual_edit_page.dart
      publish/
        presentation/
          publish_confirmation_page.dart
      history/
        presentation/
          history_page.dart
    shared/
      widgets/
        app_section.dart
        primary_action.dart
    main.dart
  pubspec.yaml
```

## 3) Dependencias mínimas

Ya incluidas en `pubspec.yaml`:
- Riverpod
- Dio (preparado para futura API)
- image_picker
- flutter_image_compress
- path_provider
- shared_preferences
- uuid

## 4) Flujo funcional local

1. Home: tomar foto o elegir de galería.
2. Compresión iterativa hasta ~50KB objetivo.
3. Vista previa de imagen + tamaño final.
4. Análisis simulado por mock/fake.
5. Mostrar JSON resultado.
6. Edición manual del JSON.
7. Publicación simulada.
8. Guardado en historial local.

## 5) Capa de integración futura (preparada)

- Contrato principal:
  - `analyzeItem(image)`
  - `publishItem(payload, image)`
- Implementaciones:
  - `MockItemRemoteDataSource` (actual)
  - `HttpItemRemoteDataSource` (placeholder con `UnimplementedError` para conectar API real)
- `ApiClient` con Dio base + timeouts + baseUrl de referencia.

## 6) Cómo correr localmente

```bash
cd mobile_app
flutter pub get
flutter run
```

> Nota: cámara/galería requiere ejecutar en emulador o dispositivo con permisos adecuados.

