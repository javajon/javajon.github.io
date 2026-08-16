#!/bin/bash

NODE_ID=${HOSTNAME:6}
LISTENERS="PLAINTEXT://:9092,CONTROLLER://:9093"
ADVERTISED_LISTENERS="PLAINTEXT://kafka-$NODE_ID.$SERVICE.$NAMESPACE.svc.cluster.local:9092"

CONTROLLER_QUORUM_VOTERS=""
for i in $( seq 0 $REPLICAS); do
    if [[ $i != $REPLICAS ]]; then
        CONTROLLER_QUORUM_VOTERS="$CONTROLLER_QUORUM_VOTERS$i@kafka-$i.$SERVICE.$NAMESPACE.svc.cluster.local:9093,"
    else
        CONTROLLER_QUORUM_VOTERS=${CONTROLLER_QUORUM_VOTERS::-1}
    fi
done

mkdir -p $SHARE_DIR/$NODE_ID

if [[ ! -f "$SHARE_DIR/cluster_id" && "$NODE_ID" = "0" ]]; then
    CLUSTER_ID=$(kafka-storage.sh random-uuid)
    echo $CLUSTER_ID > $SHARE_DIR/cluster_id
else
    CLUSTER_ID=$(cat $SHARE_DIR/cluster_id)
fi

# Kafka 4 removed config/kraft/ - ZooKeeper mode is gone, so the shipped
# config/server.properties is already KRaft - and replaced controller.quorum.voters with
# controller.quorum.bootstrap.servers. A sed for a line that no longer exists silently
# does nothing, which would leave this broker with no quorum at all, so delete whichever
# quorum key is present and append the one this StatefulSet needs. Static voters are
# still supported in 4.x and are the right choice for fixed peers.
CONFIG=/opt/kafka/config/server.properties

sed -i \
  -e "s+^node.id=.*+node.id=$NODE_ID+" \
  -e "s+^listeners=.*+listeners=$LISTENERS+" \
  -e "s+^advertised.listeners=.*+advertised.listeners=$ADVERTISED_LISTENERS+" \
  -e "s+^log.dirs=.*+log.dirs=$SHARE_DIR/$NODE_ID+" \
  -e "/^controller.quorum.bootstrap.servers=/d" \
  -e "/^controller.quorum.voters=/d" \
  "$CONFIG"

echo "controller.quorum.voters=$CONTROLLER_QUORUM_VOTERS" >> "$CONFIG"

kafka-storage.sh format -t $CLUSTER_ID -c "$CONFIG"

exec kafka-server-start.sh "$CONFIG"