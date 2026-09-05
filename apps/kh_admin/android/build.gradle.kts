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
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
