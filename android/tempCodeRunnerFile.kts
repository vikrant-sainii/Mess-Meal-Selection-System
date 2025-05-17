import org.gradle.api.tasks.Delete

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.2.2")
        classpath("com.google.gms:google-services:4.4.2")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.22")

    }
}

plugins {
    // apply false so it doesn’t apply globally unless specified
    id("com.google.gms.google-services") version "4.4.2" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Clean task
tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}