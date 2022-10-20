#!/bin/bash
export JAVA_HOME=`echo $(dirname $(readlink $(readlink $(which java)))) | sed -e 's/\/bin$//g' | sed -e 's/\/jre$//g'`
$JAVA_HOME/bin/javac java/ISJSample/JavaValidatorFacade.java -classpath lib/validator_cli.jar -d build