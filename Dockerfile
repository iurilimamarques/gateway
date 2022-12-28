FROM eclipse-temurin:11 as base

WORKDIR /app

COPY .mvn/ ./.mvn
COPY mvnw pom.xml ./
RUN ./mvnw dependency:resolve
COPY src ./src

FROM base as development
CMD ["./mvnw", "spring-boot:run", "-Dspring.profiles.active=local"]

FROM base as build
RUN ./mvnw package

FROM eclipse-temurin:11 as production
EXPOSE 8080
COPY --from=build /app/target/gateway-chatapp-*.jar /gateway-chatapp.jar
CMD ["java", "-jar", "-Dspring.profiles.active=prod","/gateway-chatapp.jar"]