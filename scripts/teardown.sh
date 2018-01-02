#!/bin/sh
##
# Script to remove/undepoy all project resources from GKE & GCE.
##

# Delete mongos stateful set + mongod stateful set + mongodb service + secrets + host vm configurer daemonset
kubectl delete statefulsets mongos-router
kubectl delete services mongos-router-service
kubectl delete statefulsets mongod-shard1
kubectl delete services mongodb-shard1-service
kubectl delete statefulsets mongod-shard2
kubectl delete services mongodb-shard2-service
kubectl delete statefulsets mongod-shard3
kubectl delete services mongodb-shard3-service
kubectl delete statefulsets mongod-configdb
kubectl delete services mongodb-configdb-service
kubectl delete secret shared-bootstrap-data
kubectl delete daemonset hostvm-configurer
sleep 3

# Delete persistent volume claims
kubectl delete persistentvolumeclaims -l tier=maindb
kubectl delete persistentvolumeclaims -l tier=configdb
sleep 3

# Delete persistent volumes
for i in 1 2 3
do
    kubectl delete persistentvolumes data-volume-4g-$i
done
for i in 1 2 3 4 5 6 7 8 9
do
    kubectl delete persistentvolumes data-volume-8g-$i
done
sleep 20

# Delete GCE disks
for i in 1 2 3
do
    gcloud -q compute disks delete pd-ssd-disk-4g-$i
done
for i in 1 2 3 4 5 6 7 8 9
do
    gcloud -q compute disks delete pd-ssd-disk-8g-$i
done

# Delete whole Kubernetes cluster (including its VM instances)
gcloud -q container clusters delete "gke-mongodb-demo-cluster"

