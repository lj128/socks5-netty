#!/bin/sh
 
#===========================================================================================
# Java Environment Setting
#===========================================================================================
export JAVA_HOME

error_exit ()
{
    echo "ERROR: $1 !!"
    exit 1
}

[ ! -e "$JAVA_HOME/bin/java" ] && error_exit "Please set the JAVA_HOME variable in your environment, We need java(x64)!"

export JAVA="$JAVA_HOME/bin/java"
export BASE_DIR=$(dirname $0)/..
export CLASSPATH=.:${BASE_DIR}/config:${CLASSPATH}

if [ -z "$APP_HOME" ] ; then
  ## resolve links - $0 may be a link to maven's home
  PRG="$0"

  # need this for relative symlinks
  while [ -h "$PRG" ] ; do
    ls=`ls -ld "$PRG"`
    link=`expr "$ls" : '.*-> \(.*\)$'`
    if expr "$link" : '/.*' > /dev/null; then
      PRG="$link"
    else
      PRG="`dirname "$PRG"`/$link"
    fi
  done

  saveddir=`pwd`

  APP_HOME=`dirname "$PRG"`/..

  # make it fully qualified
  APP_HOME=`cd "$APP_HOME" && pwd`

  cd "$saveddir"
fi
 
#===========================================================================================
# JVM Configuration
#===========================================================================================
JAVA_OPT="${JAVA_OPT} -server -Xms4g -Xmx4g -Xss256K -XX:PermSize=64m -XX:MaxPermSize=128m"
JAVA_OPT="${JAVA_OPT} -XX:+DisableExplicitGC 
                      -XX:SurvivorRatio=8 
                      -XX:+UseConcMarkSweepGC 
                      -XX:+UseParNewGC
                      -XX:+CMSParallelRemarkEnabled
                      -XX:+UseCMSCompactAtFullCollection 
                      -XX:CMSFullGCsBeforeCompaction=0
                      -XX:+CMSClassUnloadingEnabled
                      -XX:LargePageSizeInBytes=128M 
                      -XX:+UseFastAccessorMethods 
                      -XX:+UseCMSInitiatingOccupancyOnly 
                      -XX:CMSInitiatingOccupancyFraction=70 
                      -XX:SoftRefLRUPolicyMSPerMB=0"
JAVA_OPT="${JAVA_OPT} -verbose:gc -Xloggc:${APP_HOME}/socks5-netty_gc.log -XX:+PrintGCDetails -XX:+PrintGCDateStamps"
JAVA_OPT="${JAVA_OPT} -XX:-OmitStackTraceInFastThrow"
JAVA_OPT="${JAVA_OPT} -Djava.ext.dirs=${BASE_DIR}/lib"
JAVA_OPT="${JAVA_OPT} -DAPP_HOME=${APP_HOME}"
#JAVA_OPT="${JAVA_OPT} -Xdebug -Xrunjdwp:transport=dt_socket,address=9555,server=y,suspend=n"
JAVA_OPT="${JAVA_OPT} -cp ${CLASSPATH}"

nohup $JAVA ${JAVA_OPT} com.geccocrawler.socks5.ProxyServer $@ >/dev/null 2>&1 &
