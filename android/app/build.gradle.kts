plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.spacebl.ministryhub"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = project.properties["customNdkVersion"] as String

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.spacebl.ministryhub"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = (project.properties["customMinSdkVersion"] as String).toInt()
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        debug {
            // Uses google-services.json from src/debug/
            // Load Google Maps API key for dev environment from gradle.properties
            val mapsApiKey = (project.findProperty("GOOGLE_MAPS_ANDROID_DEV_KEY") as String?)
                ?: System.getenv("GOOGLE_MAPS_ANDROID_DEV_KEY")
                ?: ""
            
            if (mapsApiKey.isNullOrEmpty()) {
                logger.warn("⚠️ GOOGLE_MAPS_ANDROID_DEV_KEY not found. Run scripts/sync_android_maps_keys.ps1 to sync from .env")
            }
            
            manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = mapsApiKey
        }
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            // Uses google-services.json from src/release/
            // Load Google Maps API key for prod environment from gradle.properties
            val mapsApiKey = (project.findProperty("GOOGLE_MAPS_ANDROID_PROD_KEY") as String?)
                ?: System.getenv("GOOGLE_MAPS_ANDROID_PROD_KEY")
                ?: ""
            
            if (mapsApiKey.isNullOrEmpty()) {
                logger.warn("⚠️ GOOGLE_MAPS_ANDROID_PROD_KEY not found. Run scripts/sync_android_maps_keys.ps1 to sync from .env")
            }
            
            manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = mapsApiKey
        }
    }
}


flutter {
    source = "../.."
}


