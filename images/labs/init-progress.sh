#!/bin/bash

# About this script:
#   Called by init-foreground.sh
#   Shows progress animation to learner as lab initializes.
#   This file is a copied asset in index.yaml

FREQUENCY=1                                          # Delay between each check for completion
BACKGROUND_SIGNAL_FILE='/opt/.backgroundfinished'    # File updated by background to indicate completion
BACKGROUND_SAFE_WORD='done'                          # Word in BACKGROUND_SIGNAL_FILE indicating completion

TYPE='lab'
START_MESSAGE="Starting $TYPE"
END_NORMAL_MESSAGE="${TYPE^} ready. You have a running Kubernetes cluster."
END_KILLED_MESSAGE="Interupted. This $TYPE may still be initializing."
HUNG_MESSAGE="\n\n🚩  It has been more than a minute and the #TYPE has\nnot started as expected. Consider refreshing ⟳  this\nbrowser page to request a new $TYPE instance."
MAX_EXPECTED_START_TIME=1.1
LAB_START_TIMESTAMP=$(date +%s)
export LAB_START_TIMESTAMP

SPINNER_COLOR_NUM=2                # Color to use, unless COLOR_CYCLE=1
SPINNER_COLOR_CYCLE=0              # 1 to rotate colors between each animation
INTERVAL=.25
SPINNER_NORMAL=$(tput sgr0)        # Reset encoding
symbols=("▐⠂       ▌" "▐⠈       ▌" "▐ ⠂      ▌" "▐ ⠠      ▌" "▐  ⡀     ▌" "▐  ⠠     ▌" "▐   ⠂    ▌" "▐   ⠈    ▌" "▐    ⠂   ▌" "▐    ⠠   ▌" "▐     ⡀  ▌" "▐     ⠠  ▌" "▐      ⠂ ▌" "▐      ⠈ ▌" "▐       ⠂▌" "▐       ⠠▌" "▐       ⡀▌" "▐      ⠠ ▌" "▐      ⠂ ▌" "▐     ⠈  ▌" "▐     ⠂  ▌" "▐    ⠠   ▌" "▐    ⡀   ▌" "▐   ⠠    ▌" "▐   ⠂    ▌" "▐  ⠈     ▌" "▐  ⠂     ▌" "▐ ⠠      ▌" "▐ ⡀      ▌" "▐⠠       ▌")

progress_pid=0

cleanup () {
  kill $progress_pid >/dev/null 2>&1
  progress_pid=-1
  end_message=$END_KILLED_MESSAGE
}

show_progress () {
  while :; do
    tput civis
    for symbol in "${symbols[@]}"; do
      if [ $SPINNER_COLOR_CYCLE -eq 1 ]; then
        if [ $SPINNER_COLOR_NUM -eq 7 ]; then
          SPINNER_COLOR_NUM=1
        else
          SPINNER_COLOR_NUM=$((SPINNER_COLOR_NUM+1))
        fi
      fi
      local color
      color=$(tput setaf ${SPINNER_COLOR_NUM})
      tput sc
      printf "%s%s%s  \n" "${color}" "${symbol}" "${SPINNER_NORMAL}"
      if test -f '/opt/.backgroundfinished' && test $(find '/opt/.backgroundfinished' -mmin +${MAX_EXPECTED_START_TIME}); 
      then
         printf "${HUNG_MESSAGE}"
      fi
      tput rc
      sleep "${INTERVAL}"
    done
  done
  tput cnorm
  return 0
}

start_progress () {
  show_progress &
  progress_pid=$!

  # Catch any exit and stop progress animation
  trap cleanup SIGINT EXIT INT QUIT TERM

  clear && echo -n "$START_MESSAGE "

  # Periodically check for background signal or user Ctrl-C interuption
  end_message=$END_NORMAL_MESSAGE
  while [[ $progress_pid -ge 0 ]]; do
    grep -i ${BACKGROUND_SAFE_WORD} ${BACKGROUND_SIGNAL_FILE} &> /dev/null
    if [[ "$?" -eq 0 ]]; then
      kill $progress_pid >/dev/null 2>&1
      break
    fi
    sleep ${FREQUENCY}
  done

  # Pick up any changes during background
  source ~/.bashrc

  stty sane; tput cnorm; clear
  printf "%s\n\n" "${end_message}"
  history -c && history -w
}
