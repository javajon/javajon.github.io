#!/bin/bash

# About this common script:
#   Contains all the commands that are standard and common across all the Kubernetes labs.
#   Called by the init-background.sh script. 
#   Must be the same across ALL labs for testing consistency and maintenance.
#   Any modifications to this script must be applied across ALL labs.
#   Any common background commands for all labs shall be made in init-common.sh
#   Any custom background commands for a specific lab shall be made in init-custom.sh
#   This file is a copied asset in index.yaml

# Function to wait for an asset then source it if it becomes available before the timeout.
eventual_source() {
    SOURCE_SCRIPT=$1
    MAX_WAIT=60
    WAIT_INTERVAL=3
    ERROR_STATE=1

    for ((i=0; MAX_WAIT>i; i+=WAIT_INTERVAL)); do
        if [ -f "$SOURCE_SCRIPT" ]; then
            ERROR_STATE=0
            echo "Info: Begin sourcing script $SOURCE_SCRIPT."
            source "$SOURCE_SCRIPT"
            echo "Info: End sourcing script $SOURCE_SCRIPT."
            break
        fi
        echo -en "\nWarning: Attempting to source $SOURCE_SCRIPT that is not available. Waiting $WAIT_INTERVAL seconds."
        sleep $WAIT_INTERVAL
    done

    if [ $ERROR_STATE -eq 1 ]; then
        echo "Error: $SOURCE_SCRIPT not found after waiting $MAX_WAIT seconds. Skipping initialization."
    fi
}


# Function to safely install packages.
safe_install() {
    local packages_to_install=()
    
    for pkg in "$@"; do
        if ! dpkg -s "$pkg" >/dev/null 2>&1; then
            packages_to_install+=("$pkg")
        else
            echo "Info: Package $pkg is already installed"
        fi
    done
    
    if [ ${#packages_to_install[@]} -ne 0 ]; then
        echo "Info: Installing packages: ${packages_to_install[*]}"
        apt-get update
        apt-get install -y "${packages_to_install[@]}"
    else
        echo "Info: All packages are already installed"
    fi
}

# Install missing packages:
# - Use Bat (https://github.com/sharkdp/bat) for synxtax highlighting of common files to help the learners
# - Base image is missing tree
# safe_install <--- Add any package here, currently all needed package are in the lab image. (jq, yq, tree, batcat, envsubst)

# Common curl switches (however, use `lynx url --dump` when you can)
echo '-s' >> ~/.curlrc

# Updates to the bash shell
cat <<'EOT' >> ~/.bashrc
# Ensure learner does not exit lab by accident
if [ "$HOSTNAME" != "node01" ]; then
  alias exit='echo "You can check-out any time you like, but you can never leave!" Close your browser tab if you really wish to exit.'
  alias logout='echo "You can check-out any time you like, but you can never leave!" Close your browser tab if you really wish to logout.'
  set -o ignoreeof
fi

# grep results in easier to read green, vs default red.
export GREP_COLORS="mt=1;32"

# Ensure Python has an alias (really should be in the base lab image)
alias python=python3

# Use Bat (https://github.com/sharkdp/bat) for syntax highlighting of files with improved
# readability. The alias ensures proper terminal display by adding a newline when files 
# don't end with one, preventing the prompt from appearing at the end of the last line.
alias cat='f(){ 
  batcat --paging=never --decorations=never "$@"
  status=$?
  if [ $status -eq 0 ] && [ -f "$1" ]; then
    if [ "$(tail -c 1 "$1" | wc -l)" -eq 0 ]; then
      echo
    fi
  fi
  unset -f f
  return $status
}; f'
EOT

source ~/.bashrc

# Apply custom settings for this lab
eventual_source "/opt/init-custom.sh"

echo 'done' > /opt/.backgroundfinished

echo "Info: Common initialization completed."
