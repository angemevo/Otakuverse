plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.otakuverse"  // ✅ CORRIGÉ
    compileSdk = 36  // ✅ REMIS À 36 (comme avant)
    
    defaultConfig {
        applicationId = "com.example.otakuverse"  // ✅ CORRIGÉ
        minSdk = flutter.minSdkVersion  // ✅ Minimum pour Google Sign-In
        targetSdk = 34  // ✅ 34 suffit pour targetSdk
        versionCode = 1
        versionName = "1.0.0"
    }
    
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true 
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Kotlin
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.10")
    
    // Desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    
    // ✅ Google Sign-In
    implementation("com.google.android.gms:play-services-auth:20.7.0")
}

flutter {
    source = "../.."
}
