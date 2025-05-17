buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Update these versions to match your setup
        classpath("com.android.tools.build:gradle:8.1.0") // or your AGP version
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.8.0") // or your Kotlin version
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Optional: Only include this if you specifically need to change build directory
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

