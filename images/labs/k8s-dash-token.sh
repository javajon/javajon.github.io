#!/bin/bash
# Used in labs to reveal Kubernetes dashboard access token.
# K8s dashboard is started when a K8s based lab is started in 
# background script k8s-dashboard.sh

COLOR_RESET='\e[0m'
COLOR_LIGHT_GREEN='\e[0;1;32m' 
COLOR_CAUTION='\e[0;1;33m'

TOKEN=$(kubectl -n kubernetes-dashboard create token admin-user)

echo ""
echo 'To access the Dashboard click on the Kubernetes Dashboard tab above this command '
echo 'line. At the sign-in prompt, paste in the bearer token that is revealed below.'
echo ""
echo "--- ✂ --- ▼ Copy and paste this colored token for Dashboard access ▼ ---"
if [ -z "$TOKEN" ]
then
  echo -e "$COLOR_CAUTION"
  echo "⚠️  The Dashboard is initializing so the token is not available yet. Try again in a moment."
else
  echo -e "$COLOR_LIGHT_GREEN"
  echo -e "$TOKEN"
fi
echo -e "$COLOR_RESET"
echo "--- ✂ --- ▲"
echo ''
echo '💡 For Kubernetes clusters exposed to the public, always lock administrative access, including access to the Dashboard.'
echo 'Why? https://www.wired.com/story/cryptojacking-tesla-amazon-cloud/'
echo ''
