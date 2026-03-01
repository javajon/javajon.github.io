#!/bin/bash
# On clear show session minutes remaining. Typically 60m but can be ~5-10m more.

if [ -z "${LAB_START_TIMESTAMP}" ]; then
  echo ""
  exit 0
fi

COLOR_RESET='\e[0m'
COLOR_NORM='\e[0;1;2m'
COLOR_WARN='\e[0;1;33m'
COLOR_ALERT='\e[0;1;91m'

remaining_minutes()
{
    ELAPSED=$(( $(date +%s) - LAB_START_TIMESTAMP))
    ELAPSED_MINUTES=$(( ELAPSED / 60 ))
    echo $(( 60 - ELAPSED_MINUTES ))
}

REMAINING_MINUTES="${MOCK_REMAINING_MINUTES:=$(remaining_minutes)}"

if [[ ${REMAINING_MINUTES} -lt 0 ]]
then
  REMAINING_MINUTES=0
fi

if [[ ${REMAINING_MINUTES} -le 10 ]]
then
  COLOR=$COLOR_ALERT
elif [[ ${REMAINING_MINUTES} -le 20 ]]
then
  COLOR=$COLOR_WARN
else
  COLOR=$COLOR_NORM
fi

if [[ ${REMAINING_MINUTES} -eq 0 ]]
then
   YOUR_DONE=". This session will expire at any moment."
fi

if [[ ${REMAINING_MINUTES} -lt 30 ]]
then
  echo -e "${COLOR}Remaining ⏱  ${REMAINING_MINUTES} minutes$YOUR_DONE${COLOR_RESET}"
fi
