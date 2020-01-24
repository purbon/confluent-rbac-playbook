#!/usr/bin/env bash

## Login into MDS
XX_CONFLUENT_USERNAME=professor XX_CONFLUENT_PASSWORD=professor confluent login --url http://localhost:8090


## Create Service Roles
CONNECT_PRINCIPAL="User:fry"
C3_PRINCIPAL="User:hermes"
KAFKA_CLUSTER_ID="x64IAgb0TfOs-3-YoGB4gA"
CONNECT=connect-cluster


################################### CONNECT ###################################
echo "Creating Connect role bindings"

# SecurityAdmin on the connect cluster itself
confluent iam rolebinding create \
    --principal $CONNECT_PRINCIPAL \
    --role SecurityAdmin \
    --kafka-cluster-id $KAFKA_CLUSTER_ID \
    --connect-cluster-id $CONNECT

# ResourceOwner for groups and topics on broker
declare -a ConnectResources=(
    "Topic:connect-configs"
    "Topic:connect-offsets"
    "Topic:connect-status"
    "Group:connect-cluster"
    "Group:secret-registry"
    "Topic:_secrets"
)
for resource in ${ConnectResources[@]}
do
    confluent iam rolebinding create \
        --principal $CONNECT_PRINCIPAL \
        --role ResourceOwner \
        --resource $resource \
        --kafka-cluster-id $KAFKA_CLUSTER_ID
done

################################### C3 ###################################
echo "Creating C3 role bindings"

# C3 only needs SystemAdmin on the kafka cluster itself
confluent iam rolebinding create --principal $C3_PRINCIPAL --role SystemAdmin --kafka-cluster-id $KAFKA_CLUSTER_ID
