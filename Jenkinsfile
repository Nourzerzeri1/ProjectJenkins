pipeline {
    agent any

    tools {
        maven 'M2_HOME'
        jdk 'JAVA_HOME'
    }

    environment {
        SONAR_INSTALL = 'sq1'
        DOCKER_HUB_USER = credentials('docker-username')   // ID du credential Jenkins pour Docker Hub
        DOCKER_HUB_PASS = credentials('docker-password')   // ID du credential Jenkins pour Docker Hub
    }

    stages {

        // ================= CI =================
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

        // ================= CD =================
        stage('6 - Build Docker Image') {
            steps {
                echo 'Construction de l’image Docker à partir du JAR...'
                sh 'docker build -t touche403/restaurant-app:v1 .'
            }
        }

        stage('7 - Push Docker Image') {
            steps {
                echo 'Push de l’image Docker sur Docker Hub...'
                sh """
                    echo $DOCKER_HUB_PASS | docker login -u $DOCKER_HUB_USER --password-stdin
                    docker push touche403/restaurant-app:v1
                """
            }
        }

        stage('8 - Deploy to Kubernetes') {
            steps {
                echo 'Déploiement de MySQL et du backend sur Kubernetes...'
                sh """
                    kubectl apply -f k8s/mysql-secret.yaml
                    kubectl apply -f k8s/mysql-pvc.yaml
                    kubectl apply -f k8s/mysql-deployment.yaml
                    kubectl apply -f k8s/restaurant-app-deployment.yaml
                    kubectl rollout status deployment/mysql
                    kubectl rollout status deployment/restaurant-app
                """
            }
        }

    }

    post {
        success {
            echo 'Pipeline terminé avec succès ✅'
        }
        failure {
            echo 'Échec du pipeline ❌'
        }
    }
}
