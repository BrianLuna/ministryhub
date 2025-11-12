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
    ndkVersion = flutter.ndkVersion

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
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        debug {
            // Use dev google-services.json
        }
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            // Use prod google-services.json
        }
    }
}

// Tasks to copy the correct google-services.json based on build type
// This approach is more reliable as it uses the actual build variants
afterEvaluate {
    android.applicationVariants.all { variant ->
        val buildType = variant.buildType.name
        val sourceFile = if (buildType == "release") {
            "google-services-prod.json"
        } else {
            "google-services-dev.json"
        }
        
        val copyTask = tasks.register<Copy>("copyGoogleServices${variant.name.replaceFirstChar { it.uppercaseChar() }}") {
            from(sourceFile)
            into(".")
            rename(sourceFile, "google-services.json")
            
            doFirst {
                println("Copying $sourceFile to google-services.json for ${variant.name} build (${buildType.uppercase()})")
            }
        }
        
        // Ensure the copy task runs before the variant's preBuild
        variant.preBuildProvider.configure {
            dependsOn(copyTask)
        }
    }
}

flutter {
    source = "../.."
}

