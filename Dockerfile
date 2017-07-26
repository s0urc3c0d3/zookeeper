from mesosphere/zookeeper
run apt-get update && apt-get install curl -y
add entrypoint.sh /entrypoint.sh
expose 2181 3888
entrypoint /entrypoint.sh
