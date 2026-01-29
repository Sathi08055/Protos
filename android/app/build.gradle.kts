import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.testing"
    compileSdk = flutter.compileSdkVersion.toInt()

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.testing"
        minSdk = flutter.minSdkVersion.toInt()
        targetSdk = flutter.targetSdkVersion.toInt()
        versionCode = flutter.versionCode.toInt()
        versionName = flutter.versionName
    }

    // Load keystore properties
    val keystoreProperties = Properties().apply {
        val keystoreFile = rootProject.file("key.properties")
        if (keystoreFile.exists()) {
            load(FileInputStream(keystoreFile))
        }
    }

    signingConfigs {
        create("release") {
            val keystorePath = keystoreProperties.getProperty("storeFile")?.let { 
                file("${rootProject.projectDir}/app/$it") 
            }
            
            // Safe null check and existence verification
            storeFile = keystorePath?.takeIf { it.exists() }
                ?: throw GradleException("""
                    Keystore file not found at: ${keystorePath?.absolutePath ?: "null"}
                    Expected location: ${rootProject.projectDir}/app/upload-keystore.jks
                """.trimIndent())
            
            storePassword = keystoreProperties.getProperty("storePassword") ?: ""
            keyAlias = keystoreProperties.getProperty("keyAlias") ?: ""
            keyPassword = keystoreProperties.getProperty("keyPassword") ?: ""
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.8.22")
}