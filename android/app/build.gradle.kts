import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("android/app/key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.ideadot.flutter_mixcall_normaluser"
    compileSdk = 35
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        applicationId = "com.ideadot.flutter_mixcall_normaluser"
        minSdk = 24
        targetSdk = 35
        versionCode = 6
        versionName = "1.0.6"
        multiDexEnabled = true
        ndk {
             abiFilters += listOf("armeabi-v7a", "arm64-v8a", "x86_64")
        }
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = keystoreProperties.getProperty("storeFile")?.let { rootProject.file("android/app/$it") }
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(kotlin("stdlib"))

    implementation("com.google.ar:core:1.40.0")
    implementation("com.google.android.gms:play-services-location:21.1.0")
    implementation("androidx.browser:browser:1.7.0")
    implementation("com.google.android.play:integrity:1.3.0")
    implementation("com.google.firebase:firebase-messaging:23.4.0")
    implementation("androidx.multidex:multidex:2.0.1")
    implementation(platform("com.google.firebase:firebase-bom:32.7.2"))
    implementation("com.google.firebase:firebase-analytics")

    implementation("androidx.window:window:1.0.0")
    implementation("androidx.window:window-java:1.0.0")
}
