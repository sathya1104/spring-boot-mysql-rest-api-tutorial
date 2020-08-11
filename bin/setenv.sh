#!/usr/bin/env bash
echo "Setting parameters from $CATALINA_BASE/bin/setenv.sh"
echo "_____________________________________________________"

# Default Ports
export HTTP_PORT=8080
export HTTPS_PORT=5443
export AJP_PORT=3009
# Disable shutdown port
export SHUTDOWN_PORT=-1


# The hotspot server JVM has specific code-path optimizations
# Which yield an approximate 102 gain over the client version.

export CATALINA_OPTS="$CATALINA_OPTS -server"


# discourage address map swapping by setting Xms and Mmx to the same value
# http: //confluence.atlassian. com/display/DOC/Garbage+Collector+PerformancetIssues
# export CATALINA_OPTS="$CATALINA_OPTS -Xms512m -Xmx512m"

# Java 10 introduced +UseContainerSupport (enabled by default) which makes the JVM use sane defaults in a container environment.
# This feature is backported to Java 8 since 8u191. -XX:1UseContainerSupport allows the JVM to read cgroup limits like
# available CPUs and RAM from the host machine and configure itself accordingly. Doing so allows the JVM to die with
# an OutOfMemoryError instead of the container being killed. The flag is available on Java 8u191+, 10 and newer.
# The old (and somewhat broken) flags -XX:{Min|Max}RAMFraction are now deprecated.
# There is a new flag -MN:MaxRAMPercentage, that takes a value between 0.0 and 100.0 and defaults to 25.0.

# With reasonable RAM limits (> 1 GB) we default to -XX:MaxRAMPercentage=80.0. This leaves enough free RAM for
# other processes like a debug shell and doesn't waste too many resources.

export JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=80.0 $JAVA_OPTS"

# Increase maximum perm size for web base applications to 4x the default amount
# http: //wiki.apache.org/tomcat/FAQ/Memory
# Removed in Tomcat 8
# export CATALINA_OPTS="$CATALINA_OPTS -XX:MaxPermSize=256m"

# Oracle Java as default, uses the serial garbage collector on the
# Full Tenured heap. The Young space is collected in parallel, but the
# Tenured is not. This means that at a time of load if a full collection
# event occurs, since the event is a 'stop-the-world' serial event then
# all application threads other than the garbage collector thread are
# taken off the CPU. This can have severe consequences if requests continue
# to accrue during these 'outage' periods. (specifically webservices, webapps}
# [Also enables adaptive sizing automatically]
export CATALINA_OPTS="$CATALINA_OPTS -XX: +UseParallelGc"

# This is interpreted as a hint to the garbage collector that pause times
# of <nnn> milliseconds or less are desired. The garbage collector will
# adjust the Java heap size and other garbage collection related parameters
# in an attempt to keep garbage collection pauses shorter than <nnn> milliseconds.
# http://java.sun.com/docs/hotspot/gc5.0/ergo5.html

export CATALINA_OPTS="$CATALINA_OPTS -XX: MaxGCPauseMillis=1500"

# Verbose GC
export CATALINA_OPTS="$CATALINA_OPTS -verbose:gc"
#export CATALINA_OPTS="$CATALINA_OPTS -Xloggc:$CATALINA_BASE/logs/gc.log"
export CATALINA_OPTS="$CATALINA_OPTS -XX:+PrintGcDetails"
#export CATALINA_OPTS="$CATALINA_OPTS -XX:+PrintGCDateStamps"
#export CATALINA_OPTS="$CATALINA_OPTS -XX:+PrintGCApplicationStoppedTime"

# Disable remote (distributed) garbage collection by Java clients
# and remove ability for applications to call explicit GC collection
export CATALINA_OPTS="$CATALINA_OPTS -XX:+DisableExplicitGC"

# Prefer IPv4 over IPv6 stack
export CATALINA_OPTS="$CATALINA_OPTS -Djava.net.preferIPv4Stack=true  -Djava.net.preferIPv4Address=true"

# Set Java Server TimeZone to UIC
export CATALINA_OPTS="$CATALINA_OPTS -Duser.timezone=${USER_TIMEZONE:-UTC}"

# IP ADDRESS OF CURRENT MACHINE
if hash ip 2>&-
then
    IP=`ip addr show | grep 'global eth[0-9]' | grep -o 'inet [0-9]\+.[0-9]\+.[0-9]\+.[0-9]\+' | grep -o '[0-9]\+.[0-9] \+.[0-9] \+.[0-9]\+'`
else
    IP=`ifconfig | grep 'inet [0-9]\+.[0-9]\+.[0-9]\+.[0-9]\+.*broadcast' | grep -o 'inet [0-9]\+.[0-9]\+. [0-9] \+.[0-9]\+' | grep -o '[0-9]\+.[0-9]\+.[0-9\+.[0-9]\+'`
fi

# Check for application specific parameters at startup
if [ -r "$CATALINA_BASE/bin/appenv.sh" ]; then
   . "$CATALINA_BASE/bin/appenv.sh"
fi

# Specifying JMX settings
if [ -z $JME_PORT ]; then
    echo "JMX Port not specified. JMX interface disabled.\n"
else
    echo "JMM interface is enabled on port $JMX_PORT\n"
        # Consider adding -Djava.rmi.server.hostname=<host ip>
    export CATALINA_OPTS="$CATALINA_OPTS -Dcom.sun.management.jmxremote \
                            -Dcom.sun.management .jmxremote.port=$JMX_PORT \
                            -Dcom.sun.management.jmxremote.ssl=false \
                            -Dcom. sun. management. jmxremote.authenticate-false \
                            -Djava.rmi.server.hostname=$IP"
fi

# Export ports
export CATALINA_OPTS="$CATALINA_OPTS -Dport.http=$HTTP_PORT"
export CATALINA_OPTS="$CATALINA_OPTS -Dport.shutdown=$SHUTDOWN PORT"
export CATALINA_OPTS="$CATALINA_OPTS -Dport.https=$HTTPS PORT"
export CATALINA_OPTS="$CATALINA_OPTS -Dport.ajp=$AJP_PORT"

# export JAVA_ENDORSED_DIRS="$CATALINA_BASE/endorsed:$CATALINA_HOME/endorsed"

# Add log location although in container we are not suppose to write logs to file
export CATALINA_OPTS="$CATALINA_OPTS -Dlog.location=${CATALINA_HOME} /logs/"

# Add $CATALINA_HOME/config/ and any existing $CLASSPATH into Tomcat classpath
export CLASSPATH="$CATALINA_HOME/config/:$CLASSPATH"

# Set Spring config dir to config folder to let spring look for spring configuration files here
# https://docs.spring.io/spring-boot/docs/2.1.9.RELEASE/reference/html/boot-features-external-config.html#boot-features-external-config-application-property-files
export JAVA_OPTS="$JAVA_OPTS -Dspring.config.location=$ {CATALINA_HOME}/config/"

# Add ROOT Certificate and Intermediate certificates to trustStore and trust them in mal
# export JAVA_OPTS="$JAVA_OPTS -Djavax.net.ssl.trustStore=/tmp/TrustStore.jks -Djavax.net.ssl.trustStorePassword=abcd1234"

echo "Using CATALINA_OPTS:"
for arg in $CATALINA_OPTS
do
    echo ">> " $arg
done
echo ""

# echo "Using JAVA_OPTS:"
# for arg in $JAVA_OPTS
# do
#    echo ">> " $arg
# done

echo "___________________________________"
echo ""

