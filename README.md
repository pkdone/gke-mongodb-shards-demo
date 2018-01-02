# MongoDB Sharded Cluster Deployment Demo for Kubernetes on GKE

An example project demonstrating the deployment of a MongoDB Sharded Cluster via Kubernetes on the Google Kubernetes Engine (GKE), using Kubernetes' feature StatefulSet. Contains example Kubernetes YAML resource files (in the 'resource' folder) and associated Kubernetes based Bash scripts (in the 'scripts' folder) to configure the environment and deploy a MongoDB Replica Set.

For further background information on what these scripts and resource files do, plus general information about running MongoDB with Kubernetes, see: [http://k8smongodb.net/](http://k8smongodb.net/)


## 1 How To Run

### 1.1 Prerequisites

Ensure the following dependencies are already fulfilled on your host Linux/Windows/Mac Workstation/Laptop:

1. An account has been registered with the Google Compute Platform (GCP). You can sign up to a [free trial](https://cloud.google.com/free/) for GCP. Note: The free trial places some restrictions on account resource quotas, in particular restricting storage to a maximum of 100GB.
2. GCP’s client command line tool [gcloud](https://cloud.google.com/sdk/docs/quickstarts) has been installed on your local workstation. 
3. Your local workstation has been initialised to: (1) use your GCP account, (2) install the Kubernetes command tool (“kubectl”), (3) configure authentication credentials, and (4) set the default GCP zone to be deployed to:

    ```
    $ gcloud init
    $ gcloud components install kubectl
    $ gcloud auth application-default login
    $ gcloud config set compute/zone europe-west1-b
    ```

**Note:** To specify an alternative zone to deploy to, in the above command, you can first view the list of available zones by running the command: `$ gcloud compute zones list`

### 1.2 Deployment

Using a command-line terminal/shell, execute the following (first change the password variable in the script "generate.sh", if appropriate):

    $ cd scripts
    $ ./generate.sh
    
This takes a few minutes to complete. Once completed, you should have a MongoDB Sharded Cluster initialised, secured and running in some Kubernetes StatefulSets. The executed bash script will have created the following resources:

* 1x Config Server Replica Set containing 3x replicas (k8s deployment type: "StatefulSet")
* 3x Shards with each Shard being a Replica Set containing 3x replicas (k8s deployment type: "StatefulSet")
* 2x Mongos Routers (k8s deployment type: "StatefulSet")

You can view the list of Pods that contain these MongoDB resources, by running the following:

    $ kubectl get pods
    
You can also view the the state of the deployed environment via the [Google Cloud Platform Console](https://console.cloud.google.com) (look at both the “Kubernetes Engine” and the “Compute Engine” sections of the Console).

The running mongos routers will be accessible to any "app tier" containers, that are running in the same Kubernetes cluster, via the following hostnames and ports (remember to also specify the username and password, when connecting to the database):

    mongos-router-0.mongos-router-service.default.svc.cluster.local:27017
    mongos-router-1.mongos-router-service.default.svc.cluster.local:27017

### 1.3 Test Sharding Your Own Collection

To test that the sharded cluster is working properly, connect to the container running the first "mongos" router, then use the Mongo Shell to authenticate, enable sharding on a specific collection, add some test data to this collection and then view the status of the Sharded cluster and collection:

    $ kubectl exec -it mongos-router-0 -c mongos-container bash
    $ mongo
    > db.getSiblingDB('admin').auth("main_admin", "abc123");
    > sh.enableSharding("test");
    > sh.shardCollection("test.testcoll", {"myfield": 1});
    > use test;
    > db.testcoll.insert({"myfield": "a", "otherfield": "b"});
    > db.testcoll.find();
    > sh.status();

### 1.4 Undeploying & Cleaning Down the Kubernetes Environment

**Important:** This step is required to ensure you aren't continuously charged by Google Cloud for an environment you no longer need.

Run the following script to undeploy the MongoDB Services & StatefulSets plus related Kubernetes resources, followed by the removal of the GCE disks before finally deleting the GKE Kubernetes cluster.

    $ ./teardown.sh
    
It is also worth checking in the [Google Cloud Platform Console](https://console.cloud.google.com), to ensure all resources have been removed correctly.


## 2 Factors Addressed By This Project

* Deployment of a MongoDB on the Google Kubernetes Engine
* Use of Kubernetes StatefulSets and PersistentVolumeClaims to ensure data is not lost when containers are recycled
* Proper configuration of a MongoDB Sharded Cluster for Scalability with each Shard being a Replica Set for full resiliency
* Securing MongoDB by default for new deployments
* Leveraging XFS filesystem for data file storage to improve performance
* Disabling Transparent Huge Pages to improve performance
* Disabling NUMA to improve performance
* Controlling CPU & RAM Resource Allocation
* Correctly configuring WiredTiger Cache Size in containers
* Controlling Anti-Affinity for Mongod Replicas to avoid a Single Point of Failure

