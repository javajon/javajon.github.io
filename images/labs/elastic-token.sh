#!/bin/bash
# Used in labs to reveal Elasticsearch password for Kibana login.

COLOR_RESET='\e[0m'
COLOR_LIGHT_GREEN='\e[0;1;32m' 
COLOR_CAUTION='\e[0;1;33m'

PASSWORD=$(kubectl get secrets --namespace=logs elasticsearch-master-credentials -ojsonpath='{.data.password}' | base64 -d)

echo ""
echo 'To access Kibana, click on the Kibana tabe above this terminal area.'
echo 'At the login prompt, use the username "elastic" and the password revealed below.'
echo ""
echo "--- ✂ --- ▼ Copy and paste this colored password for Kibana access ▼ ---"
if [ -z "$PASSWORD" ]
then
  echo -e "$COLOR_CAUTION"
  echo "⚠️  Elasticsearch is initializing so the password is not available yet. Try again in a moment."
else
  echo -e "$COLOR_LIGHT_GREEN"
  echo "Username: elastic"
  echo -e "Password: $PASSWORD"
fi
echo -e "$COLOR_RESET"
echo "--- ✂ --- ▲"
echo ''
echo '💡 For production Elasticsearch clusters, always implement proper security measures,'
echo 'including strong passwords, network isolation, and HTTPS.'
echo ''
