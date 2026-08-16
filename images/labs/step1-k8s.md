[comment]: # (Editor note: The text in this step are common across many labs. If you must change something in this block, please change them all or let the author know of your change request.)

<img align="right" src="./assets/k8s-logo.png" width="65" />

For this lab, we've just started a fresh Kubernetes cluster for you. Verify that it's `Ready` and `ok`:

<div data-test-delay-until="kubectl get nodes | awk '/controlplane.*Ready/{a=1} /node01.*Ready/{b=1} END{exit(!(a&&b))}'">

```bash
{ 
 clear; \
 echo -e "* Kubernetes Status *\n"; \
 kubectl get --raw=/healthz?verbose; \
 kubectl version; \
 kubectl get nodes; \
 kubectl cluster-info
} | grep -z 'Ready\| ok\|passed\|running'
```{{execute}}

</div>

The <a href="https://helm.sh/">Helm</a> package manager used for installing applications on Kubernetes is also available:

<!-- Wait for the "True" on the single Headlamp deployment. The URL in the following paragraph is supposed to keep trying but it often fails with 500 failure on Cypress followLink. This is a hack to avoid the http get request failures. -->
<div data-test-timeout="10m" data-test-delay-until="kubectl get deployments -n headlamp -o custom-columns=STATUS:&quot;.status.conditions[?(@.type=='Available')].status&quot; | grep -q True">

`helm version --short`{{execute}}

</div>

<img align="right" src="./assets/headlamp.png" width="250" />

## Headlamp Dashboard ##

You can administer your cluster with the `kubectl` command-line tool or use <a href="https://headlamp.dev/">Headlamp</a>, the web dashboard that succeeded the retired Kubernetes Dashboard project. Open it from the <a href="https://[[HOST_SUBDOMAIN]]-30000-[[KATACODA_HOST]].environments.katacoda.com/" data-test-timeout="180s">Headlamp</a> tab above this command line. If the link shows an error, wait briefly for Headlamp to initialize.

Use this script to create a _Bearer Token_ to access the protected Dashboard:

<div data-test-output="At the sign-in prompt, paste in the bearer token that is revealed below.">

🔑 `k8s-dash-token.sh`{{execute test-no-wait}}

</div>
