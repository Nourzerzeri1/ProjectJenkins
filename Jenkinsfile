pipeline {
  agent any

  tools {
    maven 'M2_HOME'     
    jdk 'JAVA_HOME'       
  }

  environment {
    SONAR_INSTALL = 'sq1' 
  }

  stages {

    stage('1 - Checkout (Git)') {
      steps {
        checkout scm
      }
    }

    stage('2 - Maven Clean') {
      steps {
        echo ' Nettoyage du projet...'
        sh 'mvn -B clean'
      }
    }

    stage('3 - Maven Compile') {
      steps {
        echo 'Compilation du projet'
        sh 'mvn -B -DskipTests=true compile'
      }
    }

    stage('4 - SonarQube Analysis') {
      steps {
        echo 'Lancement de l’analyse SonarQube'
        withSonarQubeEnv("${SONAR_INSTALL}") {
          sh 'mvn -B sonar:sonar'
        }
      }
    }

    stage('5 - Build & Archive JAR') {
      steps {
        echo 'Construction du package final'
        sh 'mvn -B -DskipTests=true package'
        archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
      }
    }

    stage('Quality Gate') {
      steps {
        echo 'Vérification du Quality Gate SonarQube...'
        timeout(time: 15, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }
  }

  post {
    success {
      echo 'Pipeline terminé avec succès'
    }
    failure {
      echo 'Échec du pipeline.'
    }
  }
}
Écrire à Islem Abidi
