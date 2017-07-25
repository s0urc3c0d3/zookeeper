#!/bin/bash 

#Obrain the IPs of ZK instances

ZK_IPs=","

for i in $(curl -s rancher-metadata.rancher.internal/2015-12-19/stacks/mesosphere-mesos/services/zookeeper/containers/ | awk -F= '{print $2}')
do
        ZK_IPs="${ZK_IPs} $(curl -s rancher-metadata.rancher.internal/2015-12-19/stacks/mesosphere-mesos/services/zookeeper/containers/${i}/primary_ip):2181Y$(echo $i | awk -F- '{print $NF}')"
done

ZOO_SERVERS=""

for i in $(echo $ZK_IPs | sed 's/,//g')
do
	MY_ID=$(echo $i | awk -FY '{print $2}')
	ZK_INSTANCE=$(echo $i | awk -FY '{print $1}')
	ZOO_SERVERS="server.${MY_ID}=${ZK_INSTANCE} ${ZOO_SERVERS}"
done

export ZOO_SERVERS

exec /zoo_myid_start.sh $(curl -s rancher-metadata.rancher.internal/2015-12-19/self/container/name | awk -F- '{print $NF}'
