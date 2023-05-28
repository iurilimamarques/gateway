FROM amazoncorretto:11-alpine as base

WORKDIR /app

ARG ENVIRONMENT
ARG API_CHATAPP_PATH
ARG AUTH_CHATAPP_PATH

ENV API_CHATAPP_PATH ${API_CHATAPP_PATH}
ENV AUTH_CHATAPP_PATH ${AUTH_CHATAPP_PATH}

COPY .mvn/ ./.mvn
COPY mvnw pom.xml ./
RUN ./mvnw dependency:resolve
COPY src ./src

FROM base as build
RUN ./mvnw package

FROM amazoncorretto:11-alpine as production
EXPOSE 8080
COPY --from=build /app/target/gateway-chatapp-*.jar /gateway-chatapp.jar
CMD ["java", "-jar", "-Dspring.profiles.active=${ENVIRONMENT}","/gateway-chatapp.jar"]
