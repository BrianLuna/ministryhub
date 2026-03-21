# Firestore: error `permission-denied` al iniciar sesión

Ese mensaje **no viene del código Dart**: Firestore rechaza la lectura porque las **reglas de seguridad** del proyecto en la consola de Firebase **no permiten** la consulta que hace la app (colección `ministries` con `where('administratorId', == uid)` y subcolección `churches`).

## 1. Desplegar las reglas de este repo

En la raíz del proyecto (donde está `firestore.rules`):

```bash
npm install -g firebase-tools
firebase login
firebase use dev
firebase deploy --only firestore:rules
```

- **`firebase use dev`** → proyecto **ministryhub-dev-38d80** (definido en `.firebaserc`).
- Para **producción**: `firebase use prod` y luego el mismo `deploy`.

## 2. Qué proyecto usa la app según el modo de compilación

En `lib/main.dart`:

- **Debug** (`flutter run` en modo debug) → **Dev** (`DevFirebaseOptions` → `ministryhub-dev-38d80`).
- **Profile / Release** → **Prod** (`ProdFirebaseOptions` → `ministryhub-prod-22147`).

Tenés que tener reglas desplegadas en **el mismo proyecto** que esté usando la app en ese momento.

## 3. Comprobar en la consola

1. [Firebase Console](https://console.firebase.google.com/) → tu proyecto → **Firestore Database** → pestaña **Reglas**.
2. Deberían verse reglas que permitan leer `ministries` solo si `request.auth.uid` coincide con `resource.data.administratorId` (como en `firestore.rules` del repo).
3. Si sigue el modo de prueba con fecha vencida, o `allow read, write: if false`, seguirás viendo `permission-denied`.

## 4. Datos existentes

Si en Firestore los documentos de `ministries` **no tienen** el campo **`administratorId`** (o tiene otro nombre), las reglas actuales no los consideran legítimos. Creá ministerios desde la app o añadí el campo a mano para tu usuario.

## 5. Cambio reciente en código (web)

Se llama a `ensureAuthTokenForFirestore` antes de cargar ministerios/iglesias para reducir carreras en web entre Auth y Firestore. Si tras desplegar reglas **aún** falla, el problema sigue siendo reglas o proyecto equivocado, no ese helper.
