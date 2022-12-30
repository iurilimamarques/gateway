FROM amazoncorretto:11-alpine as base

WORKDIR /app

COPY .mvn/ ./.mvn
COPY mvnw pom.xml ./
RUN ./mvnw dependency:resolve
COPY src ./src

FROM base as build
RUN ./mvnw package

FROM amazoncorretto:11-alpine as production
COPY --from=build /app/target/gateway-chatapp-*.jar /gateway-chatapp.jar
CMD ["java", "-jar", "-Dspring.profiles.active=${ENVIRONMENT}","/gateway-chatapp.jar"]