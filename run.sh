#!/bin/bash
export JAVA_HOME=`echo $(dirname $(readlink $(readlink $(which java)))) | sed -e 's/\/bin$//g' | sed -e 's/\/jre$//g'`
$JAVA_HOME/bin/java -cp .:lib/validator_cli.jar:lib/JavaValidatorFacade.jar ISJSample.JavaValidatorFacade $1 $2