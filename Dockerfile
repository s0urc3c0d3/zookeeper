from mesosphere/zookeeper
run apt-get update && apt-get install curl -y
add entrypoint.sh /entrypoint.sh
expose 2181
entrypoint /entrypoint.sh
