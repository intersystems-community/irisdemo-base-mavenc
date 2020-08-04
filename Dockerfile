# Configure Maven with the proper IRIS JDBC Driver we should be using.
# Since IRIS JDBC Driver is not available/up-to-date on Maven, we will rely on IRIS Community to extract
# the latest JDBC Driver available instead.
#
#FROM intersystemsdc/irisdemo-base-irisdb-community:iris-community.2019.4.0.379.0
# FROM intersystemsdc/irisdemo-base-irisdb-community:iris-community.2020.1.0.197.0
#FROM intersystemsdc/irisdemo-base-irisint-community:iris-community.2020.3.0.200.0
FROM intersystemsdc/irisdemo-base-irisint-community:iris-community.2020.4.0ETL.130.0

FROM openjdk:8-jdk-alpine

LABEL maintainer="Amir Samary <amir.samary@intersystems.com>"

# Section 1 - Taken from https://github.com/Zenika/alpine-maven

RUN apk add --update ca-certificates && rm -rf /var/cache/apk/* && \
  find /usr/share/ca-certificates/mozilla/ -name "*.crt" -exec keytool -import -trustcacerts \
  -keystore /usr/lib/jvm/java-1.8-openjdk/jre/lib/security/cacerts -storepass changeit -noprompt \
  -file {} -alias {} \; && \
  keytool -list -keystore /usr/lib/jvm/java-1.8-openjdk/jre/lib/security/cacerts --storepass changeit

ENV MAVEN_VERSION 3.5.4
ENV MAVEN_HOME /usr/lib/mvn
ENV PATH $MAVEN_HOME/bin:$PATH

RUN wget http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz && \
  tar -zxvf apache-maven-$MAVEN_VERSION-bin.tar.gz && \
  rm apache-maven-$MAVEN_VERSION-bin.tar.gz && \
  mv apache-maven-$MAVEN_VERSION /usr/lib/mvn

# End of Section 1

# Section 2 - For health check
RUN apk --update --no-cache add curl
# End of Section 2

# Section 3 - IRIS Specific

WORKDIR /irislib
COPY --from=0 /usr/irissys/dev/java/lib/JDK18/*.jar /irislib/

RUN mvn install:install-file -Dfile=/irislib/intersystems-jdbc-3.2.0.jar \
-DgroupId=com.intersystems \
-DartifactId=intersystems-jdbc \
-Dversion=3.2.0 \
-Dpackaging=jar \
-DcreateChecksum=true && \
mvn install:install-file -Dfile=/irislib/intersystems-xep-3.2.0.jar \
-DgroupId=com.intersystems \
-DartifactId=intersystems-xep \
-Dversion=3.2.0 \
-Dpackaging=jar \
-DcreateChecksum=true && \
mvn install:install-file -Dfile=/irislib/intersystems-gateway-3.2.0.jar \
-DgroupId=com.intersystems \
-DartifactId=intersystems-gateway \
-Dversion=3.2.0 \
-Dpackaging=jar \
-DcreateChecksum=true && \
mvn install:install-file -Dfile=/irislib/intersystems-utils-3.2.0.jar \
-DgroupId=com.intersystems \
-DartifactId=intersystems-utils \
-Dversion=3.2.0 \
-Dpackaging=jar \
-DcreateChecksum=true
# End of Section 3

# Configuring make
RUN apk add --update alpine-sdk

# This is where all maven projects will be. This should be a volume
WORKDIR /usr/projects

# We expect to find a Makefile on this volume. CMD will run it to compile the one or more projects with maven

CMD [ "make"]