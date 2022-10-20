#!/bin/bash
export JAVA_HOME=`echo $(dirname $(readlink $(readlink $(which java)))) | sed -e 's/\/bin$//g' | sed -e 's/\/jre$//g'`
$JAVA_HOME/bin/jar --create --file lib/JavaValidatorFacade.jar -C build ISJSample/JavaValidatorFacade.class