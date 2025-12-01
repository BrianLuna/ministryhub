# Configuración de FVM (Flutter Version Management)

## Estado Actual
- ✅ Flutter 3.35.7 está instalado y configurado localmente
- ⚠️ El symlink no se pudo crear (requiere Modo Desarrollador en Windows)

## Soluciones

### Opción 1: Usar FVM directamente (Recomendado - Sin cambios en Windows)

Usa `fvm flutter` en lugar de `flutter`:

```powershell
# En lugar de: flutter pub get
fvm flutter pub get

# En lugar de: flutter run
fvm flutter run -d chrome

# En lugar de: flutter build
fvm flutter build web
```

### Opción 2: Habilitar Modo Desarrollador (Permite usar `flutter` directamente)

1. Abre Configuración de Windows:
   ```powershell
   start ms-settings:developers
   ```

2. Activa "Modo de desarrollador"

3. Luego ejecuta:
   ```powershell
   fvm use 3.35.7
   ```

4. Después de esto, podrás usar `flutter` normalmente y usará la versión 3.35.7

### Verificar Versión

```powershell
# Ver versión de FVM
fvm flutter --version

# Ver versión del sistema (si el symlink está creado)
flutter --version
```

## Nota

Si prefieres usar `flutter` directamente sin el prefijo `fvm`, necesitas habilitar el Modo Desarrollador en Windows para que FVM pueda crear el symlink necesario.

