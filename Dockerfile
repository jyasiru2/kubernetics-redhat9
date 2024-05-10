FROM adoptopenjdk/openjdk8:alpine-slim
EXPOSE 8080
ARG JAR_FILE=target/*.jar
ADD ${JAR_FILE} app.jar
ENTRYPOINT ["java","-jar","/app.jaar"]

## First stage: build stage
#FROM adoptopenjdk/openjdk8:alpine AS builder
#WORKDIR /app
#COPY . .
#RUN ./mvnw clean package -DskipTests=true
#
## Second stage: runtime stage
#FROM adoptopenjdk/openjdk8:alpine-slim
#EXPOSE 8080
#WORKDIR /app
#COPY --from=builder /app/target/*.jar app.jar
#ENTRYPOINT ["java", "-jar", "/app.jar"]
