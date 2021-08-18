#!/bin/bash
mkdir -p ${HOME}/.yarn
echo "set build version"
cd /usr/repo/apache-ambari-2.7.5-src
mvn versions:set -DnewVersion=2.7.5.0.0 && pushd ambari-metrics
if [[ $? != 0 ]]; then
	echo "failed to set version for ambari metrics"
	exit 1
fi
mvn versions:set -DnewVersion=2.7.5.0.0 && popd
if [[ $? != 0 ]]; then
	echo "failed to set version for ambari"
	exit 1
fi
echo "start to build ambari"
export PHANTOMJS_CDNURL="https://cnpmjs.org/downloads"
#export PHANTOMJS_CDNURL="https://npm.taobao.org/mirrors/phantomjs/"
env | grep PHANTOMJS_CDNURL
echo "Start build image for $OS"
#npm set strict-ssl false

if [[ "$OS" = "ubuntu" ]]; then
   mvn -B clean install jdeb:jdeb -DnewVersion=2.7.5.0.0 \
       -DbuildNumber=5895e4ed6b30a2da8a90fee2403b6cab91d19972 -DskipTests \
       -Dpython.ver="python >= 2.6"
elif [[ "$OS" = "centos" ]]; then
   mvn -B clean install rpm:rpm -DnewVersion=2.7.5.0.0 \
      -DbuildNumber=5895e4ed6b30a2da8a90fee2403b6cab91d19972 -DskipTests \
      -Dpython.ver="python >= 2.6"
fi

