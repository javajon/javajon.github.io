#!/bin/bash
#
# metrics-server-switch.sh - Toggle the Kubernetes metrics-server on/off
#
# Usage: ./metrics-server-switch.sh [true|false] [--yes|--no|-y|-n]
#   - true|false: Enable or disable metrics-server
#   - --yes|--no|-y|-n: Optional - Auto-answer yes or no to prompts

# Parse command line arguments
METRICS_ENABLED=""
NON_INTERACTIVE=""
AUTO_ANSWER=""

while [[ $# -gt 0 ]]; do
  case $1 in
    true|false)
      METRICS_ENABLED="$1"
      shift
      ;;
    --yes|-y)
      NON_INTERACTIVE="true"
      AUTO_ANSWER="y"
      shift
      ;;
    --no|-n)
      NON_INTERACTIVE="true"
      AUTO_ANSWER="n"
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

# Create the dashboard values file based on the parameter
cat << EOF > /opt/dashboard-values.yaml
protocolHttp: true
extraArgs:
  - --enable-insecure-login
metricsScraper:
  enabled: true
metrics-server:
  enabled: $METRICS_ENABLED
  args:
    - --kubelet-preferred-address-types=InternalIP
    - --kubelet-insecure-tls
service:
  type: NodePort
  nodePort: 30000
  externalPort: 80
EOF

echo "Created dashboard values file with metrics-server.enabled = $METRICS_ENABLED"

# Update the dashboard with the new configuration
echo "Updating Kubernetes Dashboard..."
helm upgrade kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
  -n kubernetes-dashboard \
  -f /opt/dashboard-values.yaml

# Display status message
if [ "$METRICS_ENABLED" == "true" ]; then
  echo "Metrics server has been ENABLED"
  echo "It may take a minute for metrics to become available"
  echo "You can check with: kubectl top nodes"
else
  echo "Metrics server has been DISABLED"
fi

# If metrics were disabled, check if a standalone metrics server should be installed
if [ "$METRICS_ENABLED" == "false" ]; then
  INSTALL_STANDALONE=""
  
  # Use the auto-answer if in non-interactive mode, otherwise prompt
  if [ "$NON_INTERACTIVE" == "true" ]; then
    INSTALL_STANDALONE=$AUTO_ANSWER
  else
    echo ""
    read -p "Do you want to install a standalone metrics-server instead? (y/n): " INSTALL_STANDALONE
  fi
  
  if [ "$INSTALL_STANDALONE" == "y" ] || [ "$INSTALL_STANDALONE" == "Y" ]; then
    echo "Installing standalone metrics-server..."
    
    # Add the metrics-server repo and update
    helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
    helm repo update
    
    # Check if metrics-server is already installed in kube-system
    if helm list -n kube-system | grep -q metrics-server; then
      echo "Metrics server already installed in kube-system namespace. Upgrading..."
      helm upgrade metrics-server metrics-server/metrics-server \
        --namespace kube-system \
        --set args="{--kubelet-insecure-tls,--kubelet-preferred-address-types=InternalIP}" \
        --set apiService.insecureSkipTLSVerify=true
    else
      echo "Installing new metrics-server in kube-system namespace..."
      helm install metrics-server metrics-server/metrics-server \
        --namespace kube-system \
        --set args="{--kubelet-insecure-tls,--kubelet-preferred-address-types=InternalIP}" \
        --set apiService.insecureSkipTLSVerify=true
    fi
    
    echo "Waiting for metrics-server to initialize..."
    sleep 10
    
    # Check if it's working
    if kubectl top nodes &>/dev/null; then
      echo "Standalone metrics server successfully installed and working."
    else
      echo "Standalone metrics server installed but not yet providing metrics."
      echo "Please check again in a few minutes with: kubectl top nodes"
    fi
  fi
fi

exit 0