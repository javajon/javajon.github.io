#!/bin/bash
#
# metrics-server-switch.sh - Toggle the Kubernetes metrics-server on/off
#
# Usage: ./metrics-server-switch.sh [true|false] [--yes|--no|-y|-n]
#   - true|false: Enable or disable metrics-server
#   - --yes|--no|-y|-n: Accepted for backward compatibility, ignored
#
# The retired Kubernetes Dashboard chart shipped metrics-server as a subchart, so
# this script used to toggle it with a `helm upgrade` of the dashboard release.
# Headlamp has no such subchart: k8s-dashboard.sh now installs metrics-server as
# its own release in kube-system, and this script installs or uninstalls it there.

# Parse command line arguments
METRICS_ENABLED=""

while [[ $# -gt 0 ]]; do
  case $1 in
    true|false)
      METRICS_ENABLED="$1"
      shift
      ;;
    --yes|-y|--no|-n)
      # Retained so existing callers keep working. The old flag answered a prompt
      # about installing a standalone metrics-server, which is now the only mode.
      shift
      ;;
    *)
      echo "Error: Unknown parameter: $1"
      echo "Usage: $0 [true|false] [--yes|--no|-y|-n]"
      exit 1
      ;;
  esac
done

# Check if METRICS_ENABLED is provided
if [ -z "$METRICS_ENABLED" ]; then
  echo "Error: Missing parameter true/false."
  echo "Usage: $0 [true|false] [--yes|--no|-y|-n]"
  exit 1
fi

echo "Setting metrics-server enabled = $METRICS_ENABLED"

METRICS_SERVER_HELM_CHART_VERSION=3.13.1

if [ "$METRICS_ENABLED" == "true" ]; then

  # Same values k8s-dashboard.sh uses, so a re-enable matches a fresh lab start.
  # Pinned to the controlplane to leave node01's resources free for the app.
  cat << 'EOF' > /opt/metrics-server-values.yaml
# Appended to the chart defaults, which already prefer InternalIP.
args:
  - --kubelet-insecure-tls

tolerations:
  - key: "node-role.kubernetes.io/control-plane"
    operator: "Exists"
    effect: "NoSchedule"

nodeSelector:
  node-role.kubernetes.io/control-plane: ""
EOF

  helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
  helm repo update

  if helm status metrics-server -n kube-system > /dev/null 2>&1; then
    echo "Upgrading existing metrics-server release..."
    helm upgrade metrics-server metrics-server/metrics-server \
      --version=$METRICS_SERVER_HELM_CHART_VERSION \
      --namespace kube-system \
      --values /opt/metrics-server-values.yaml
  else
    echo "Installing metrics-server chart version $METRICS_SERVER_HELM_CHART_VERSION"
    helm install metrics-server metrics-server/metrics-server \
      --version=$METRICS_SERVER_HELM_CHART_VERSION \
      --namespace kube-system \
      --values /opt/metrics-server-values.yaml
  fi

  echo "Metrics server has been ENABLED"
  echo "It may take a minute for metrics to become available"
  echo "You can check with: kubectl top nodes"

else

  # k8s-dashboard.sh installs metrics-server in the background at lab start. A
  # learner who advances quickly can reach this before that install lands, which
  # would leave the puzzle solved. Wait briefly for the release to appear first.
  for i in $(seq 1 30); do
    helm status metrics-server -n kube-system > /dev/null 2>&1 && break
    sleep 5
  done

  if helm status metrics-server -n kube-system > /dev/null 2>&1; then
    helm uninstall metrics-server --namespace kube-system
  else
    echo "No metrics-server release found in kube-system, nothing to remove."
  fi

  # The chart owns the APIService, but delete any straggler so the metrics API
  # fails fast rather than hanging on an endpoint with no backend.
  kubectl delete apiservice v1beta1.metrics.k8s.io --ignore-not-found

  echo "Metrics server has been DISABLED"

fi

exit 0
