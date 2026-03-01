#!/bin/bash

# This script is called by the solver utility. Each function should be named 
# verify_task_#, where # is the number of the task each function will solve.
# When a verification fails for a step, the error number returned corresponds 
# to the hint number found in hints.md.

# Max time for verify blocking commands. Zero or positive integer time units s, m, h.
export VERIFY_TIMEOUT=3s

PROJECT_HOME=$HOME/projects/memcached-operator
MEMCACHED_MANIFEST="$HOME/memcached.yaml"

function verify_task_1() {
  object_name=deployment/registry-docker-registry
  namespace=kube-system

  kubectl rollout status --timeout=$VERIFY_TIMEOUT $object_name -n $namespace
  if [ $? -ne 0 ]
  then 
    return 1
  fi

  # Verify Registry responding, takes a few moments to return the correct result
  curl -f "$REGISTRY/v2/_catalog" | grep -q 'repositories'
  if [ $? -ne 0 ]
  then 
    return 1
  fi
}


function verify_task_2() {
  OPERATOR_SDK_VERSION=v1.11.0

  operator-sdk version | grep $OPERATOR_SDK_VERSION
  if [ $? -ne 0 ]
  then 
    return 1
  fi
}


function verify_task_3() {
  if [ ! -d "$PROJECT_HOME" ]
  then 
    return 1
  fi

  if [ ! -f "$PROJECT_HOME/Dockerfile" ]
  then 
    return 2
  fi
}


function verify_task_4() {
  
  if [ ! -d "$PROJECT_HOME/api/v1alpha1" ]
  then 
    return 1
  fi

  if [ ! -f "$PROJECT_HOME/api/v1alpha1/memcached_types.go" ]
  then 
    return 2
  fi

  if [ ! -f "$PROJECT_HOME/config/samples/cache_v1alpha1_memcached.yaml" ]
  then 
    return 3
  fi

  if [ ! -f "$PROJECT_HOME/controllers/memcached_controller.go" ]
  then 
    return 4
  fi
}


function verify_task_5() {
  SOURCE=$HOME/projects/memcached-operator/api/v1alpha1/memcached_types.go
  TAIL="/}/"

  HEAD="/type MemcachedSpec struct {/"  
  sed -n "${HEAD},${TAIL}p" "$SOURCE" | grep "Size int32 \`json:\"size\"\`"
  if [ $? -ne 0 ]
  then 
    return 1
  fi

  HEAD="/type MemcachedStatus struct {/"
  sed -n "${HEAD},${TAIL}p" "$SOURCE" | grep "Nodes \[\]string \`json:\"nodes\"\`"
  if [ $? -ne 0 ]
  then 
    return 2
  fi
}


function verify_task_6() {
  grep "in.Status.DeepCopyInto(&out.Status)" "$PROJECT_HOME"/api/v1alpha1/zz_generated.deepcopy.go
  if [ $? -ne 0 ]
  then 
    return 1
  fi
}


function verify_task_7() {
 if [ ! -d "$PROJECT_HOME/config/crd/bases" ]
  then 
    return 1
  fi
}


function verify_task_8() {
  count=$(sed -n '/^import ($/,/^)$/ p' "$PROJECT_HOME"/controllers/memcached_controller.go | wc -l)
  if [ "$count" -le 10 ]
  then 
    return 1
  fi
}


function verify_task_9() {
  count=$(curl "$REGISTRY/v2/_catalog" | grep -c 'memcached-operator')
  if [ $count -ne 1 ]
  then 
    return 2
  fi
}


function verify_task_10() {
  object_name=memcached-operator-controller-manager
  namespace=memcached-operator-system

  # Verify controller deployment ready
  kubectl rollout status --timeout=$VERIFY_TIMEOUT deployment -n $namespace $object_name
  if [ $? -ne 0 ]
  then 
    return 1
  fi

  # Verify RBAC
  kubectl get serviceaccount -n $namespace $object_name
  if [ $? -ne 0 ]
  then 
    return 1
  fi
}


function verify_task_11() { 
  count_expected=3

  # Manifest created
  if [ ! -f "$MEMCACHED_MANIFEST" ]
  then 
    return 1
  fi

  # Manifest has declaration of 3
  grep "size: $count_expected" "$MEMCACHED_MANIFEST"
  if [ $? -ne 0 ]
  then 
    return 2
  fi

  count_expected=3
  kubectl describe deployment memcached-sample | grep "$count_expected available"
  if [ $? -ne 0 ]
  then 
    return 3
  fi
}


function verify_task_12() {
  count_expected=5

  # Manifest has declaration of 3
  grep "size: $count_expected" "$MEMCACHED_MANIFEST"
  if [ $? -ne 0 ]
  then 
    return 1
  fi

  kubectl describe deployment memcached-sample | grep "$count_expected available"
  if [ $? -ne 0 ]
  then 
    return 2
  fi
}
