import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// ✅ Читаем local.properties (Flutter генерирует его из pubspec.yaml)
val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    FileInputStream(localPropertiesFile).use { stream ->
        localProperties.load(stream)
    }
}

// ✅ Получаем версию из Flutter (из pubspec.yaml через local.properties)
fun getFlutterVersionCode(): Int {
    val versionCode = localProperties.getProperty("flutter.versionCode")
    return versionCode?.toIntOrNull() ?: 1
}

fun getFlutterVersionName(): String {
    val versionName = localProperties.getProperty("flutter.versionName")
    return versionName ?: "1.0.0"
}

android {
    namespace = "kg.asdf.contoller_app"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "kg.asdf.contoller_app"

        minSdk = 21
        targetSdk = 34

        // ✅ ПРАВИЛЬНО: Берём версию из pubspec.yaml через Flutter
        versionCode = getFlutterVersionCode()
        versionName = getFlutterVersionName()

        multiDexEnabled = true
    }

    buildTypes {
        getByName("debug") {
            applicationIdSuffix = ".debug"
            isDebuggable = true
        }

        getByName("release") {
            // Используем debug ключ для подписи
            signingConfig = signingConfigs.getByName("debug")

            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    packaging {
        resources {
            excludes += setOf(
                "/META-INF/{AL2.0,LGPL2.1}",
                "/META-INF/DEPENDENCIES",
                "/META-INF/LICENSE",
                "/META-INF/LICENSE.txt",
                "/META-INF/license.txt",
                "/META-INF/NOTICE",
                "/META-INF/NOTICE.txt",
                "/META-INF/notice.txt",
                "/META-INF/ASL2.0"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}