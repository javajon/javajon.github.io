# Task Hints Authoring Guidelines

When authoring this collection of hints, mark each hint with the double pound (##) markdown header and title the header with `## Task n, Hint n`. Capital T and H. Tasks and Hints start at 1. See this [Challenge Hints](https://www.katacoda.community/challenges.html#ui-example) in the authoring guide on how to provide hints for your challenge. TODO - The [Lab markdown extensions](https://www.katacoda.community/scenario-syntax.html#katacoda-s-markdown-extensions) can be applied in this markdown.

## Task 1, Hint 1

For this task all you have to do is run the script `./install-registry.sh`{{execute}}. It takes a few moments before the container image registry service is available and responds with an empty list from the command `curl -f $REGISTRY/v2/_catalog`{{execute}}.

## Task 2, Hint 1

For this task all you have to do is run the script `./install-operator-sdk.sh`{{execute}}. If you think it's installed, check the version with `operator-sdk version`{{execute}}

## Task 3, Hint 1

The project source directory for the memcached-operator has not been created yet.

## Task 3, Hint 2

The source code for memcached-operator not created yet.

## Task 4, Hint 1

We are not seeing the expected content in subdirectory `api/v1alpha1`. Did you apply the parameter `--version v1alpha1`? See `operator-sdk create api --help`{{execute}}.

## Task 4, Hint 2

We are not seeing the expected generated source file `api/v1alpha1/memcached_types.go`. Did you apply the parameter `--kind Memcached`? See `operator-sdk create api --help`{{execute}}.

## Task 4, Hint 3

We are not seeing the expected generated source file `config/crd/bases/cache.example.com_memcacheds.yaml`. Did you apply the parameter `--group cache`? See `operator-sdk create api --help`{{execute}}.

## Task 4, Hint 4

We are not seeing the expected generated source file `controllers/memcached_controller.go`. Did you apply the parameter `--resource --controller`? See `operator-sdk create api --help`{{execute}}.

## Task 5, Hint 1

In the `memcache_types.go` source the struct MemcachedSpec is not matching the needed edits as found in `MemcachedSpec.go`. See how the struct should look: `less ~/MemcachedSpec.go | tee`{{execute}}

## Task 5, Hint 2

In the `memcache_types.go` source the struct MemcachedStatus is not matching the needed edits as found in `MemcachedStatus.go`. See how the struct should look: `less ~/MemcachedStatus.go | tee`{{execute}}

## Task 6, Hint 1

When the `make` task called _generate_ succeeds, then various files are created. We are specifically looking for the file `api/v1alpha1/zz_generated.deepcopy.go`.

## Task 7, Hint 1

When the `make` task called _manifests_ succeeds, then various files are created. We are specifically looking for the subdirector `config/crd/bases`.

## Task 8, Hint 1

It does not appear you have updated the source file `controllers/memcached_controller.go` with the necessary code.

## Task 9, Hint 1

Make sure you set the IMG environment variable accurately. Check it with `echo $IMG`. This is a setting that is picked up by the Makefile so you can tag, push, and pull the container image to your cluster. Did you run `make docker-build` and `make docker-push`? The container `memcached-operator` is expected in the registry. List the registry contents with `curl $REGISTRY/v2/_catalog`{{execute}}.

## Task 10, Hint 1

Did you run `make deploy`? Once the Operator is running the rollout status for the operator should report it is running with `kubectl rollout status deployment -n memcached-operator-system memcached-operator-controller-manager`{{execute}}/  There should also be a new Service Account seen with `kubectl get serviceaccount -n memcached-operator-system memcached-operator-controller-manager`{{execute}}

## Task 11, Hint 1

Expecting a file called `memcached.yaml` in your home (~) directory.

## Task 11, Hint 2

Still not seeing `size: 3` in  `~/memcached.yaml`.

## Task 11, Hint 3

Your memcached.yaml declared 3 memcached agents to run. All three are not running yet. It takes a few moments for the pods to start. Did you apply the memcached.yaml file? Check your 3 pod memcached cluster status with `kubectl describe deployment memcached-sample`{{execute}}

## Task 12, Hint 1

Still not seeing the new count of 5 in the field `size: 5` in  `~/memcached.yaml`.

## Task 12, Hint 2

You changed `memchached.yaml`, but did you reapply the manifest with the increased size count? All five are not running yet. It takes a few moments for the pods to start. Check your 3 pod memcached cluster status with `kubectl get pods`{{execute}}.
