from mesosphere/zookeeper
run apt-get update && apt-get install curl cron cronutils -y
add gen_hosts.sh /gen_hosts.sh
add entrypoint.sh /entrypoint.sh
expose 2181 3888
entrypoint /entrypoint.sh
