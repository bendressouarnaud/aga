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
    afterEvaluate {
        tasks.findByName("checkReleaseAarMetadata")?.enabled = false
        tasks.findByName("checkDebugAarMetadata")?.enabled = false
    }
}



subprojects {
    project.evaluationDependsOn(":app")

    /*configurations.all {
        resolutionStrategy.eachDependency {
            if (requested.group == "androidx.camera") {
                //project.dependencies.add("implementation", "androidx.concurrent:concurrent-futures:1.2.0")
                useVersion("1.6.0")
            }
        }
    }

    configurations.all {
        resolutionStrategy {
            force("androidx.camera:camera-core:1.6.0")
            force("androidx.camera:camera-camera2:1.6.0")
            force("androidx.camera:camera-lifecycle:1.6.0")
            force("androidx.camera:camera-video:1.6.0")
            force("androidx.camera:camera-view:1.6.0")
            force("androidx.camera:camera-extensions:1.6.0")
        }
    }*/
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
