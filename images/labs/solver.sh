#!/bin/bash

# Solve is intended to be a general utility for the authors and testers of the challenge. 
# Any improvments to the utility should be done for general availability across all challenges that use this utility.
# When changes are made, bump the VERSION number and changes propogated to other cloned scripts in other challenges.
# (TODO - if useful may want to promote script source to a central source)

VERSION=0.0.1

YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NIL_COLOR='\033[0m'

verify_enabled=true
all_until=0

# Challenge author edits these solutions and verfications for each task
source "$(dirname "$0")/task-verifications.sh"
source "$(dirname "$0")/task-solutions.sh"

task_tracker_file='/tmp/next_task.txt'

# Supporting functions

function _initialize() {
  if [ ! -f "$task_tracker_file" ] 
  then
      _reset
  fi
  next_task=$(<"$task_tracker_file")
}


function _function_exists() { 
  # https://stackoverflow.com/a/9002012/3236525
  [ $(type -t "$1")"" == 'function' ]
}


function _advance_task() {
  task=$1
  ((task+=1))

  if _function_exists verify_task_"$task"
  then
    next_task=$task
    echo "Next task is $next_task."
  else
    echo "Challenge complete."
    next_task=0
  fi

  echo $next_task > "$task_tracker_file"
}


function _verify() {
  if ! $verify_enabled
  then 
    echo "Verification skipped."
    return 0
  fi

  echo "Verifying task $1:"
  
  printf "$YELLOW"
  verify_task_"$1"
  status=$?
  printf "$NIL_COLOR"

  echo "Verification $([ $status -eq 0 ] && echo 'passed' || echo 'failed')."

  return $status
}


function verify() {
  status=1
  while [ $status -ne 0 ]
  do
    _verify "$1"
    status=$?
    if [ $status -ne 0 ]; then sleep 3; fi
  done
}

function challenge_verify() {

  _verify "$1"
  status=$?

  if [ $status -ne 0 ]
  then
    echo "verify_task$1 failed with error $status."
    exit $status   # Exit with error rather than return so can be called by challenge.sh
  fi

  echo "Verification passed for verify_task_$1."
}


function next() {
  if [ "$next_task" -gt 0 ] 
  then
    # Check to make sure task has not been solved
    _verify $next_task
    status=$?

    if [[ "$status" -ne 0 || "$verify_enabled" = false ]]
    then
      # Solve task
      echo "Solving task $next_task:"
      solve_task_$next_task
      solution_status=$?
      echo "Solution status: $solution_status"

      # Verify the solution
      sleep 3
      verify $next_task
      verify_status=$?

      status=$((solution_status + verify_status))
    fi

    if [ $status -eq 0 ]
    then
      _advance_task $next_task
    fi
  fi
}


function all() {
  while [[ $next_task -gt 0 && $next_task -ne $all_until ]]
  do
    next
  done
  all_until=0
}

function until() {
    echo "Solving tasks until task # $1"
    all_until=$1
    all
}


function solve() {
    echo "$1" > "$task_tracker_file"
    next_task=$(<"$task_tracker_file")
    next
}  

function view() {
  case ${1^^} in
    S)
    echo "Solution:"
    printf "$GREEN"
    sed "/function solve_task_$2/,/^}$/!d" /usr/local/bin/task-solutions.sh
    printf "$NIL_COLOR"
    ;;

    V)
    echo "Verification:"
    printf "$GREEN"
    sed "/function verify_task_$2/,/^}$/!d" /usr/local/bin/task-verifications.sh
    printf "$NIL_COLOR"
    ;;

    SV|VS)
    view s "$2"
    view v "$2"
    ;;

    *)
    echo "Missing specifier, either 'S'olution or 'V'erification, or 'SV' for both."
  esac
}


function _reset() {
  echo '1' > "$task_tracker_file"
}


function reset() {
  _reset
  yat
}


function yat() {
  task=$(<"$task_tracker_file")
  if [ "$task" -ne 0 ] 
  then 
     echo "Next task to solve is $task."
  else
     echo "All tasks have been completed."
  fi
}


function version() {
  echo "$VERSION"
}


function help() {
  echo "This Solve utility will solve each step in the challenge given the provided functions for the task solutions and verifications."
  echo
  echo "Use Solve with these commands:"
  echo
  echo "solve COMMAND [option]"
  echo
  echo "The solve COMMAND can be:"
  echo
  echo "  next         Solve current task and if successful advance current task."
  echo "  all          Solve all remaining tasks."
  echo "  until #      Solve all remaining tasks until reaching given task number."
  echo "  solve #      Solve task number. Subsequent commands assume next task."
  echo "  verify #     Verify task number is complete."
  echo "  view s/v #   Reveal the 'x'olution or 'v'erification code for a task. 'sv' for both. # is optional."
  echo "  reset        Clear task tracker so next task is assumed to be 1."
  echo "  yat          Where we at? Display the next task to solve."
  echo "  version      Version of Solve used in this challenge."
  echo "  help         This information."
  echo
  echo "Normally you would solve the tasks sequentially using 'next', however, some steps can be skipped if a step is optional. Before publication, the 'all' command should solve all tasks without error."
}


# If correct arcguments supplied then run command function, else show usage
if [[ $# -gt 0 ]] && [[ "$1" == @(next|all|solve|verify|view|reset|yat|version|help|challenge_verify) ]]
then
  _initialize

  # Global switches
  # verify_enabled=$([[ "${@#-noverify}" = "$@" ]])

  for arg in "$@"
  do
    case $arg in
      "-noverify")
      verify_enabled=false
    esac
  done

  # Call functions above based on passed in parameter(s)
  "$@"
else
  help
fi
