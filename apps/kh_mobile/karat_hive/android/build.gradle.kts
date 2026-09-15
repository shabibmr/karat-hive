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

subprojects {
    if (project.name != "app") {
        afterEvaluate {
            val android = project.extensions.findByName("android")
            if (android != null) {
                for (m in android.javaClass.methods) {
                    if (m.name == "setCompileSdk" || m.name == "compileSdkVersion") {
                        if (m.parameterCount == 1) {
                            val type = m.parameterTypes[0]
                            try {
                                if (type == java.lang.Integer::class.java || type == java.lang.Integer.TYPE) {
                                    m.invoke(android, 36)
                                } else if (type == java.lang.String::class.java) {
                                    m.invoke(android, "android-36")
                                }
                            } catch (_: Exception) {}
                        }
                    }
                }
                // Align plugin Java/Kotlin targets with app (avoids flutter_avif 11 vs 21 mismatch).
                try {
                    val compileOptions = android.javaClass.methods
                        .firstOrNull { it.name == "getCompileOptions" && it.parameterCount == 0 }
                        ?.invoke(android)
                    if (compileOptions != null) {
                        compileOptions.javaClass.methods
                            .firstOrNull { it.name == "setSourceCompatibility" && it.parameterCount == 1 }
                            ?.invoke(compileOptions, JavaVersion.VERSION_17)
                        compileOptions.javaClass.methods
                            .firstOrNull { it.name == "setTargetCompatibility" && it.parameterCount == 1 }
                            ?.invoke(compileOptions, JavaVersion.VERSION_17)
                    }
                } catch (_: Exception) {}
            }
            tasks.withType<JavaCompile>().configureEach {
                sourceCompatibility = JavaVersion.VERSION_17.toString()
                targetCompatibility = JavaVersion.VERSION_17.toString()
            }
            // flutter_avif_android 3.1.0 ships duplicate FlutterAvifPlugin in java/ and kotlin/.
            // Keep the Java implementation; skip Kotlin so the class is not redeclared.
            if (project.name == "flutter_avif_android") {
                tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
                    enabled = false
                }
            } else {
                tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
                    compilerOptions {
                        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
                    }
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
