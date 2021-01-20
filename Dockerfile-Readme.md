# Jre11-Tomcat9 build

####Get version of jdk
https://pkgs.alpinelinux.org/package/edge/community/x86_64/openjdk11

Run Alpine container

jre11
```docker run -ti --rm alpine sh
apk add openjdk11
java -version
```

jre8
```docker run -ti --rm alpine sh
apk add openjdk8-jre
java -version
```
copy Build version number into ENV JAVA_VERSION=<<????>>



### Get Tomcat9 version
https://tomcat.apache.org/tomcat-9.0-doc/changelog.html
copy latest version number from page above to ENV TOMCAT_VERSION <<<???>>>

### Image tag
prasad1210/tomcat-custom:<<TOMCAT_VERSION>>.<<BUILD_NUMBER>>-alpine-jre-<JRE_VERSION_3_decimals>
prasad1210/tomcat-custom:9.0.41.0-alpine-jre-11.0.09

### doker build command
```
docker build -t prasad1210/tomcat-custom:9.0.41.0-alpine-jre-11.0.09 . -f Dockerfile-tomcat-jre --no-cache
docker push prasad1210/tomcat-custom:9.0.41.0-alpine-jre-11.0.09
```