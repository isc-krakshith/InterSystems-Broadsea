FROM maven:3.6-jdk-11 as builder

WORKDIR /war

RUN curl -LJO https://github.com/isc-krakshith/InterSystems-OHDSI-WebAPI/releases/latest/download/WebAPI.war
RUN jar -xf WebAPI.war \
    && rm WebAPI.war

# OHDSI WebAPI and ATLAS web application running as a Spring Boot application with Java 11
FROM openjdk:8-jre-slim

MAINTAINER Benjamin DeBoe

# Any Java options to pass along, e.g. memory, garbage collection, etc.
ENV JAVA_OPTS="-Dcom.intersystems.SSLConfigFile=/var/lib/ohdsi/webapi/SSLConfig.properties"
# Additional classpath parameters to pass along. If provided, start with colon ":"
ENV CLASSPATH=":/var/lib/ohdsi/webapi/WEB-INF/lib/:/varlib/ohdsi/webapi/"
# Default Java options. The first entry is a fix for when java reads secure random numbers:
# in a containerized system using /dev/random may reduce entropy too much, causing slowdowns.
ENV DEFAULT_JAVA_OPTS="-Djava.security.egd=file:///dev/./urandom"

# set working directory to a fixed WebAPI directory
WORKDIR /var/lib/ohdsi/webapi

# deploy the just built OHDSI WebAPI war file
# copy resources in order of fewest changes to most changes.
# This way, the libraries step is not duplicated if the dependencies
# do not change.
COPY --from=builder /war/WEB-INF/lib*/* WEB-INF/lib/
COPY --from=builder /war/org org
COPY --from=builder /war/WEB-INF/classes WEB-INF/classes
COPY --from=builder /war/META-INF META-INF

COPY ./assets/intersystems-jdbc-3.8.4.jar /var/lib/ohdsi/webapi/WEB-INF/lib/

#setup and import ssl cert into java
COPY ./iriscert/certificateSQLaaS.pem .
COPY ./iriscert/SSLConfig.properties .
RUN keytool -importcert -file /var/lib/ohdsi/webapi/certificateSQLaaS.pem -alias IRIScert -keystore /var/lib/ohdsi/webapi/keystore.jks -storepass changeit -noprompt
RUN rm /var/lib/ohdsi/webapi/certificateSQLaaS.pem

EXPOSE 8080

USER 101

# Directly run the code as a WAR.
CMD exec java ${DEFAULT_JAVA_OPTS} ${JAVA_OPTS} \
    -cp ".:WebAPI.jar:WEB-INF/lib/*.jar${CLASSPATH}" \
    org.springframework.boot.loader.WarLauncher