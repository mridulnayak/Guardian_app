//plugins {
//    // Versions hata diye hain taaki version conflict na ho
//    id("com.android.application") apply false
//    id("com.android.library") apply false
//    id("org.jetbrains.kotlin.android") apply false
//    id("com.google.gms.google-services") version "4.4.0" apply false // Firebase plugin
//

plugins {
    // Versions ko puri tarah se hata dein, Flutter ise handle karega
    id("com.android.application") apply false
    id("com.android.library") apply false
    id("org.jetbrains.kotlin.android") apply false
    id("com.google.gms.google-services") version "4.4.0" apply false
}
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
