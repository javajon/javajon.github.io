[comment]: # (Editor note: **Private registry common instructions** The lines below to "end" must be the same amoung several labs. If you must change something in this block, please change them all.)

It's helpful to have a container registry during the build, push, and deploy phases. There is no need to shuttle private images over the internet. Instead, we keep all this pushing and pulling in a local registry.

## Install Registry

<img align="right" src="./assets/registry.png" width="15%" />

There are many options for standing up a container image registry. We prefer a pure Kubernetes solution and thus install a registry through the [Docker Registry Helm Chart](https://artifacthub.io/packages/helm/twuni/docker-registry).

Add the repository for the Helm chart to be installed:

`helm repo add twuni https://twuni.github.io/docker-registry.helm  && helm repo list`{{execute}}

Install the chart for a private container registry:

```bash
helm install registry twuni/docker-registry \
  --version 3.0.0 \
  --namespace kube-system \
  --set service.type=NodePort \
  --set service.nodePort=31500
```{{execute}}

The registry is now available as a Service. It can be listed:

`kubectl get service --namespace kube-system`{{execute}}

Assign an environment variable to the common registry location:

`export REGISTRY=[[HOST_SUBDOMAIN]]-31500-[[KATACODA_HOST]].environments.katacoda.com`{{execute}}

It will be a few moments before the registry Deployment reports it's `Available`:

`kubectl get deployments registry-docker-registry --namespace kube-system`{{execute}}

Once the registry is available, inspect the contents of the empty registry:

<div data-test-delay-until="curl node01:31500/v2/_catalog | grep 'repositories'">

`curl $REGISTRY/v2/_catalog | jq -c`{{execute}}

</div>


You will see this registry response with the expected empty array:

`{"repositories":[]}`

If you do not see this response, wait a few moments and try again. If you have waited and continue to receive an error message, then return to step 1 and reverify the health of the cluster.

[comment]: # (Editor note: **Private registry common instructions** End)

## Install Registry UI

It's always helpful to have a decent web interface in front of your container image registry. There are a few open solutions out there that all run as containers. This particular one, [joxit/docker-registry-ui](https://github.com/Joxit/docker-registry-ui), is solid and provides a clean interface. Merci beaucoup, [Jones Magloire](https://joxit.dev/):

`kubectl apply -f ~/registry-ui.yaml`{{execute}}

In a moment the new web interface will be available. Open the [registry web interface](
https://[[HOST_SUBDOMAIN]]-31000-[[KATACODA_HOST]].environments.katacoda.com/). Observe that the container list is empty (0 images). The pipeline you will define in the next steps will add a new container here.
