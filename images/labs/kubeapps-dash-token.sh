#!/bin/bash
# Used in labs to reveal Kubeapps access token.

COLOR_RESET='\e[0m'
COLOR_LIGHT_GREEN='\e[0;1;32m' 
COLOR_CAUTION='\e[0;1;33m'

# Get the token
TOKEN=$(kubectl get secret kubeapps-operator-token -o jsonpath='{.data.token}' -n kubeapps | base64 --decode)

echo ""
echo 'To access Kubeapps, click on the Kubeapps Dashboard tab or access the NodePort service.'
echo 'At the sign-in prompt, paste in the bearer token that is revealed below.'
echo ""
echo "--- ✂ --- ▼ Copy and paste this colored token for Kubeapps access ▼ ---"
if [ -z "$TOKEN" ]
then
  echo -e "$COLOR_CAUTION"
  echo "⚠️  Kubeapps is initializing so the token is not available yet. Try again in a moment."
else
  echo -e "$COLOR_LIGHT_GREEN"
  echo -e "$TOKEN"
fi
echo -e "$COLOR_RESET"
echo "--- ✂ --- ▲"
echo ''
echo '💡 For Kubernetes clusters exposed to the public, always lock administrative access, including access to Kubeapps.'
echo 'This token has cluster-admin permissions, which is appropriate for learning but not for production!'
echo ''