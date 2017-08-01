#!/bin/bash 


cron 
crontab -r
echo "*/5 * * * * /gen_hosts.sh > /etc/hosts" > /tmp/mycron 
crontab /tmp/mycron


#Generate zoo.conf

cat > /etc/zookeeper/conf/zoo.cfg << EOF
tickTime=2000
dataDir=/var/lib/zookeeper/
clientPort=2181
initLimit=5
syncLimit=2
EOF

licznik=1
for i in $(curl -s rancher-metadata.rancher.internal/2015-12-19/stacks/mesos/services/zookeeper/containers/ | awk -F= '{print $2}')
do
	echo "server.${licznik}=$(curl -s rancher-metadata.rancher.internal/2015-12-19/stacks/mesos/services/zookeeper/containers/${i}/primary_ip):2888:3888" >> /etc/zookeeper/conf/zoo.cfg
	licznik=$(($licznik+1))
done

#Obrain the IPs of ZK instances

ZK_IPs=","

for i in $(curl -s rancher-metadata.rancher.internal/2015-12-19/stacks/mesos/services/zookeeper/containers/ | awk -F= '{print $2}')
do
        ZK_IPs="${ZK_IPs} $(curl -s rancher-metadata.rancher.internal/2015-12-19/stacks/mesos/services/zookeeper/containers/${i}/primary_ip):2181Y$(echo $i | awk -F- '{print $NF}')"
done

ZOO_SERVERS=""

for i in $(echo $ZK_IPs | sed 's/,//g')
do
	MY_ID=$(echo $i | awk -FY '{print $2}')
	ZK_INSTANCE=$(echo $i | awk -FY '{print $1}')
	ZOO_SERVERS="server.${MY_ID}=${ZK_INSTANCE} ${ZOO_SERVERS}"
done

export ZOO_SERVERS

java -jar /opt/exhibitor/exhibitor.jar --port 8181 --defaultconfig /opt/exhibitor/defaults.conf -c file --hostname $(hostname) &

exec /zoo_myid_start.sh $(curl -s rancher-metadata.rancher.internal/2015-12-19/self/container/name | awk -F- '{print $NF}')
