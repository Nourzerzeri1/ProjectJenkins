# Étape 1 : image de base
FROM openjdk:17-jdk-slim

# Étape 2 : définition du répertoire de travail
WORKDIR /app

# Étape 3 : copie du jar dans l'image
COPY target/TP-Projet-0.0.1-SNAPSHOT.jar app.jar

# Étape 4 : port exposé
EXPOSE 8080

# Étape 5 : commande de démarrage
ENTRYPOINT ["java", "-jar", "app.jar"]
