FROM adoptopenjdk/openjdk11:x86_64-alpine-jre-11.0.6_10

# Inspired from https://github.com/docker-library/tomcat/blob/d570ad0cee10e4526bcbb03391b2c0e322b59313/9.0/jdk11/openjdk-slim/Dockerfile
ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p "$CATALINA_HOME"
WORKDIR $CATALINA_HOME

# let "Tomcat Native" live somewhere isolated
ENV TOMCAT_NATIVE_LIBDIR $CATALINA_HOME/native-jni-lib
ENV LD_LIBRARY_PATH ${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}$TOMCAT_NATIVE_LIBDIR

# see https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/KEYS
# see also "update.sh" (https://github.com/docker-library/tomcat/blob/master/update.sh)
ENV GPG_KEYS 05AB33110949707C93A279E3D3EFE6B686867BA6 07E48665A34DCAFAE522E5E6266191C37C037D42 47309207D818FFD8DCD3F83F1931D684307A10A5 541FBE7D8F78B25E055DDEE13C370389288584E7 61B832AC2F1C5A90F0F9B00A1C506407564C17A3 79F7026C690BAA50B92CD8B66A3AD3F4F22C4FED 9BA44C2621385CB966EBA586F72C284D731FABEE A27677289986DB50844682F8ACB77FC2E86E29AC A9C5DF4D22E99998D9875A5110C01C5A2F6059E7 DCFD35E0BF8CA7344752DE8B6FB21E8933C60243 F3A04C595DB5B6A5F1ECA43E3B7BBB100D811BBE F7DA48BB64BCB84ECBA7EE6935CD23C10D498E23

ENV TOMCAT_MAJOR 9
ENV TOMCAT_VERSION 9.0.34
ENV TOMCAT_SHA512 9cb32f8807c0e8d2457d52ac032bb496ae7921e1ea0a0c8e6082bf8da60bb57c317a3f2376589962123dd803fdd2816ff960339cb851d9859b2241165fbc278e


# Install Tomcat
RUN wget "https://downloads.apache.org/tomcat/tomcat-9/v9.0.34/bin/apache-tomcat-9.0.34.tar.gz"\
 && mkdir -p /usr/local/tomcat\
 && tar -xf apache-tomcat-9.0.34.tar.gz --strip-components=1\
 && rm bin/*.bat\
 && rm apache-tomcat-9.0.34.tar.gz*\
 && rm -rf webapps\
 && mkdir webapps\
 && find ./bin/ -name '*.sh' -exec sed -ri 's|^#!/bin/sh$|#!/usr/bin/env bash|' '{}' + \
 && chmod -R +rX . \
 && chmod 777 logs temp work


# Copy war file to webapps
COPY target/ROOT.war webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]