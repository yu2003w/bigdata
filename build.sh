#!/bin/bash
if [[ $# != 1 ]]; then
   echo "Please specify os type"
   exit 1
fi
node_ver="v8.17.0"
npm_ver="6.13.4"
yarn_ver="v1.22.11"
if [[ ! -d apache-ambari-2.7.5-src ]]; then
	if [[ ! -z apache-ambari-2.7.5-src.tar.gz ]];then
	    wget https://mirrors.tuna.tsinghua.edu.cn/apache/ambari/ambari-2.7.5/apache-ambari-2.7.5-src.tar.gz
	    if [[ $? != 0 ]];then
		echo "failed to download ambari source code."
		exit 1
	    fi
	fi
	tar -xvf apache-ambari-2.7.5-src.tar.gz
	sed -i "s/v4.5.0/${node_ver}/g" apache-ambari-2.7.5-src/ambari-web/pom.xml
	sed -i "s/v0.23.2/${yarn_ver}/g" apache-ambari-2.7.5-src/ambari-web/pom.xml

	sed -i "s/v4.5.0/${node_ver}/g" apache-ambari-2.7.5-src/ambari-admin/pom.xml
	sed -i "s/2.15.0/${npm_ver}/g" apache-ambari-2.7.5-src/ambari-admin/pom.xml

	sed -i "s/v4.5.0/${node_ver}/g" apache-ambari-2.7.5-src/contrib/views/files/pom.xml
	sed -i "s/v0.23.2/${yarn_ver}/g" apache-ambari-2.7.5-src/contrib/views/files/pom.xml

	sed -i "s/v4.5.0/${node_ver}/g" apache-ambari-2.7.5-src/contrib/views/capacity-scheduler/pom.xml
	sed -i "s/2.15.0/${npm_ver}/g" apache-ambari-2.7.5-src/contrib/views/capacity-scheduler/pom.xml

	sed -i "s/v4.5.0/${node_ver}/g" apache-ambari-2.7.5-src/contrib/views/wfmanager/pom.xml
	sed -i "s/v0.23.2/${yarn_ver}/g" apache-ambari-2.7.5-src/contrib/views/wfmanager/pom.xml

	sed -i "s/v4.5.0/${node_ver}/g" apache-ambari-2.7.5-src/contrib/views/pig/pom.xml
	sed -i "s/v0.23.2/${yarn_ver}/g" apache-ambari-2.7.5-src/contrib/views/pig/pom.xml

	mkdir -p apache-ambari-2.7.5-src/ambari-web/node/yarn/dist/
	tar -C apache-ambari-2.7.5-src/ambari-web/node/yarn/dist/ \
		-xvf /root/.m2/repository/com/github/eirslett/yarn/1.22.11/yarn-1.22.11./yarn-v1.22.11.tar.gz
fi

IMAGE=ambari
if [[ "$1" = "ubuntu" ]]; then
   cd dockerfiles && docker build -t ambari:2.7.5 -f dockerfile-ubuntu.ambari .
   if [[ $? != 0 ]]; then
	echo "prepare image failed"
	exit
   fi
elif [[ "$1" = "centos" ]]; then
    cd dockerfiles && docker build -t ambari-centos:2.7.5 -f dockerfile-centos.ambari .
    if [[ $? != 0 ]]; then
	echo "prepare centos image failed"
	exit
    fi
    IMAGE=ambari-centos
fi

cd ../

docker run --rm --name build-ambari -v $(pwd)/.m2/:/home/ambari/.m2 \
	-v $(pwd)/apache-ambari-2.7.5-src:/usr/repo/apache-ambari-2.7.5-src \
	${IMAGE}:2.7.5 > ambari.log 2>&1 &

