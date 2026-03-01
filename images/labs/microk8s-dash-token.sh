#!/bin/bash
export COLOR_RESET='\e[0m'
export COLOR_LIGHT_GREEN='\e[0;49;32m' 

# Technique to grab Kubernetes dashboard access token.
# Typically used in labs.

echo 'To access the dashboard click on the Kubernetes Dashboard tab above this command '
echo 'line. At the sign in prompt select Token and paste in the token that is shown below.'
echo ''
echo 'For Kubernetes clusters exposed to the public, always lock administration access including '
echo 'access to the dashboard. Why? https://www.wired.com/story/cryptojacking-tesla-amazon-cloud/'

export TOKEN=$(microk8s config | yq .users[0].user.token)
echo ""
echo "--- Copy and paste this token for dashboard access ---"
echo -e $COLOR_LIGHT_GREEN
echo -e $TOKEN
echo -e $COLOR_RESET