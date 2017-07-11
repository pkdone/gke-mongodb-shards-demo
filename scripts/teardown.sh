#!/bin/sh
##
# Script to remove/undepoy all project resources from GKE & GCE.
##

# Delete mongod stateful set + mongodb service + secrets + host vm configuer daemonset
kubectl delete deployments mongos
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
kubectl delete persistentvolumes data-volume-4g-1
kubectl delete persistentvolumes data-volume-4g-2
kubectl delete persistentvolumes data-volume-4g-3
kubectl delete persistentvolumes data-volume-8g-1
kubectl delete persistentvolumes data-volume-8g-2
kubectl delete persistentvolumes data-volume-8g-3
kubectl delete persistentvolumes data-volume-8g-4
kubectl delete persistentvolumes data-volume-8g-5
kubectl delete persistentvolumes data-volume-8g-6
kubectl delete persistentvolumes data-volume-8g-7
kubectl delete persistentvolumes data-volume-8g-8
kubectl delete persistentvolumes data-volume-8g-9
sleep 20

# Delete GCE disks
gcloud -q compute disks delete pd-ssd-disk-4g-1
gcloud -q compute disks delete pd-ssd-disk-4g-2
gcloud -q compute disks delete pd-ssd-disk-4g-3
gcloud -q compute disks delete pd-ssd-disk-8g-1
gcloud -q compute disks delete pd-ssd-disk-8g-2
gcloud -q compute disks delete pd-ssd-disk-8g-3
gcloud -q compute disks delete pd-ssd-disk-8g-4
gcloud -q compute disks delete pd-ssd-disk-8g-5
gcloud -q compute disks delete pd-ssd-disk-8g-6
gcloud -q compute disks delete pd-ssd-disk-8g-7
gcloud -q compute disks delete pd-ssd-disk-8g-8
gcloud -q compute disks delete pd-ssd-disk-8g-9

# Delete whole Kubernetes cluster (including its VM instances)
gcloud -q container clusters delete "gke-mongodb-demo-cluster"

