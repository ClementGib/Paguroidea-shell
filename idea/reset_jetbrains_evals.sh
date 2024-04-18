#!/bin/bash
# reset_jetbrains_evals.sh

# Function to remove evaluation directories and sed pattern from XML files
reset_evals() {
  local product="$1"
  local config_path="$2"
  
  rm -rf "$HOME/$config_path/eval"
  sed -i '/name="evlsprt.*"/d' "$HOME/$config_path/options/other.xml" >/dev/null 2>&1
}

# Function to remove user IDs from Java preferences
reset_java_prefs() {
  local prefs_file="$HOME/.java/.userPrefs/prefs.xml"
  sed -i '/key="JetBrains\.UserIdOnMachine"/d' "$prefs_file"
  sed -i '/key="device_id"/d' "$prefs_file"
  sed -i '/key="user_id_on_machine"/d' "$prefs_file"
}

# Main script
OS_NAME=$(uname -s)
JB_PRODUCTS="IntelliJIdea CLion PhpStorm GoLand PyCharm WebStorm Rider DataGrip RubyMine AppCode"

if [ "$OS_NAME" == "Darwin" ]; then
  echo 'Resetting JetBrains IDE evaluations on macOS:'

  for PRD in $JB_PRODUCTS; do
    reset_evals "$PRD" "Library/Preferences/${PRD}*"
    reset_evals "$PRD" "Library/Application Support/JetBrains/${PRD}*"
  done

  reset_java_prefs
elif [ "$OS_NAME" == "Linux" ]; then
  echo 'Resetting JetBrains IDE evaluations on Linux:'

  for PRD in $JB_PRODUCTS; do
    reset_evals "$PRD" ".$PRD*/config"
    reset_evals "$PRD" ".config/JetBrains/${PRD}*"
  done

  reset_java_prefs
else
  echo 'Unsupported OS'
  exit 1
fi

echo 'Done.'
