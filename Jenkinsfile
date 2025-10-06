pipeline {
  agent any
  tools {
    maven 'Maven3'     // nom configuré dans Global Tool Configuration
    jdk 'jdk11'        // nom configuré
  }
  environment {
    // NE PAS mettre le token ici en clair. Le token est injecté via Manage Jenkins -> Credentials.
    SONAR_INSTALL = 'SonarQube' // nom donné dans "SonarQube servers" dans Jenkins
  }
  stages {
    stage('1 - Checkout (git)') {
      steps {
        checkout scm
        // ou: git branch: 'main', url: 'https://github.com/TON_USER/TP-Foyer.git', credentialsId: 'git-cred-id'
      }
    }

    stage('2 - Maven clean') {
      steps {
        sh 'mvn -B clean'
      }
    }

    stage('3 - Maven compile (package)') {
      steps {
        // on fait package pour avoir les classes compilées (nécessaire à Sonar)
        sh 'mvn -B -DskipTests=true package'
      }
    }

    stage('4 - SonarQube analysis') {
      steps {
        // withSonarQubeEnv injecte les infos serveur (URL, token) configurées dans Jenkins.
        withSonarQubeEnv("${SONAR_INSTALL}") {
          // mvn sonar:sonar lancera l'analyse ; on a déjà compilé au stage précédent.
          sh 'mvn -B sonar:sonar'
        }
      }
    }

    stage('5 - Build final & archive jar') {
      steps {
        // relancer package sans skipTests si tu veux exécuter les tests
        sh 'mvn -B -DskipTests=false package'
        archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
      }
    }

    stage('Quality Gate') {
      steps {
        // attends le résultat Sonar (timeout pour éviter blocage infini)
        timeout(time: 15, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }
  }

  post {
    success {
      echo 'Pipeline terminé: SUCCESS'
    }
    failure {
      echo 'Pipeline terminé: FAILURE'
    }
  }
}
