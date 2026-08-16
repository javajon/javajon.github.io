#!/bin/bash

# Installs Headlamp (https://headlamp.dev), the successor to the retired
# kubernetes/dashboard project. See: https://artifacthub.io/packages/helm/headlamp/headlamp
#
# The filename is intentionally kept as k8s-dashboard.sh because init-common.sh
# is identical across ALL labs and sources /opt/k8s-dashboard.sh.

# Dedicate a namespace for Headlamp
kubectl create namespace headlamp

# Add an admin-user service account for the learner to sign in with. This is kept
# separate from the chart's own service account so that k8s-dash-token.sh does not
# depend on chart-internal naming.
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: headlamp
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: headlamp
EOF

## Set Headlamp Helm chart values for this context. Unlike the old dashboard chart,
## the node port is a first class value so no kubectl patch of the Service is needed.
##
## Tolerations and nodeSelector pin Headlamp to the controlplane. Two reasons:
##   1. On the kubernetes-kvm images the CNI only answers a NodePort on the node
##      actually running the backing Pod, and the lab's browser proxy reaches the
##      controlplane. A Pod scheduled onto node01 leaves port 30000 dead in the tab.
##   2. It leaves node01's resources free for the applications the lab deploys.
##
## Both taint keys are tolerated because the lab images span Kubernetes versions.
## kubeadm taints the controlplane node-role.kubernetes.io/master through 1.23 and
## node-role.kubernetes.io/control-plane from 1.24 on. Tolerating a taint that is not
## present is a no-op, so listing both keeps one script working across every image.
## The nodeSelector uses the control-plane label, which has existed since 1.20.
cat << 'EOF' > /opt/headlamp-values.yaml
service:
  type: NodePort
  port: 80
  nodePort: 30000

clusterRoleBinding:
  create: true
  clusterRoleName: cluster-admin

tolerations:
  - key: "node-role.kubernetes.io/control-plane"
    operator: "Exists"
    effect: "NoSchedule"
  - key: "node-role.kubernetes.io/master"
    operator: "Exists"
    effect: "NoSchedule"

nodeSelector:
  node-role.kubernetes.io/control-plane: ""
EOF

# Add Helm chart repo
helm repo add headlamp https://kubernetes-sigs.github.io/headlamp/
helm repo update

# Latest tested Helm chart, update this version regularly
HEADLAMP_HELM_CHART_VERSION=0.44.0

# Install Headlamp
echo "Installing chart version $HEADLAMP_HELM_CHART_VERSION"
helm install headlamp headlamp/headlamp \
  --version=$HEADLAMP_HELM_CHART_VERSION \
  --namespace headlamp \
  --values /opt/headlamp-values.yaml

# The old dashboard chart bundled metrics-server as a subchart, Headlamp does not.
# Install it so Headlamp shows CPU and memory, and so `kubectl top` keeps working.
if ! kubectl get apiservice v1beta1.metrics.k8s.io > /dev/null 2>&1; then

  # Pinned to the controlplane for the same resource reason as Headlamp above, and
  # tolerating both taint keys for the same version-span reason.
  cat << 'EOF' > /opt/metrics-server-values.yaml
# Appended to the chart defaults, which already prefer InternalIP.
args:
  - --kubelet-insecure-tls

tolerations:
  - key: "node-role.kubernetes.io/control-plane"
    operator: "Exists"
    effect: "NoSchedule"
  - key: "node-role.kubernetes.io/master"
    operator: "Exists"
    effect: "NoSchedule"

nodeSelector:
  node-role.kubernetes.io/control-plane: ""
EOF

  helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
  helm repo update

  METRICS_SERVER_HELM_CHART_VERSION=3.13.1

  echo "Installing metrics-server chart version $METRICS_SERVER_HELM_CHART_VERSION"
  helm install metrics-server metrics-server/metrics-server \
    --version=$METRICS_SERVER_HELM_CHART_VERSION \
    --namespace kube-system \
    --values /opt/metrics-server-values.yaml
fi
