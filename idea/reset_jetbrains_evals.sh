#!/bin/sh

# Function to reset evaluations for JetBrains products
reset_evals() {
  local product="$1"
  local config_path="$2"
  
  rm -rf "$HOME/$config_path/eval"
  if [ "$OS_NAME" == "Darwin" ]; then
    sed -i '' '/name="evlsprt.*"/d' "$HOME/$config_path/options/other.xml" >/dev/null 2>&1
  else
    sed -i '/name="evlsprt.*"/d' "$HOME/$config_path/options/other.xml" >/dev/null 2>&1
  fi
}

# Function to remove user IDs from Java preferences on macOS
reset_java_prefs_macos() {
  local plist_file="$HOME/Library/Preferences/com.apple.java.util.prefs.plist"
  
  plutil -remove "/.JetBrains\.UserIdOnMachine" "$plist_file" >/dev/null
  plutil -remove "/.jetbrains/.user_id_on_machine" "$plist_file" >/dev/null
  plutil -remove "/.jetbrains/.device_id" "$plist_file" >/dev/null
}

# Function to remove user IDs from Java preferences on Linux
reset_java_prefs_linux() {
  local prefs_file="$HOME/.java/.userPrefs/prefs.xml"
  
  sed -i '/key="JetBrains\.UserIdOnMachine"/d' "$prefs_file"
  sed -i '/key="device_id"/d' "$prefs_file"
  sed -i '/key="user_id_on_machine"/d' "$prefs_file"
}

# Function to close JetBrains applications on macOS
close_applications() {
  for product in $JB_PRODUCTS; do
    echo "Closing $product"
    ps aux | grep -i MacOs/$product | cut -d " " -f 5 | xargs kill -9
  done
}

# Main script
OS_NAME=$(uname -s)
JB_PRODUCTS="IntelliJIdea CLion PhpStorm GoLand PyCharm WebStorm Rider DataGrip RubyMine AppCode"

if [ "$OS_NAME" == "Darwin" ]; then
  echo 'Resetting JetBrains IDE evaluations on macOS:'
  close_applications

  for PRD in $JB_PRODUCTS; do
    reset_evals "$PRD" "Library/Preferences/${PRD}*"
    reset_evals "$PRD" "Library/Application Support/JetBrains/${PRD}*"
  done

  reset_java_prefs_macos

  echo "Removing additional plist files..."
  rm -f ~/Library/Preferences/com.apple.java.util.prefs.plist
  rm -f ~/Library/Preferences/com.jetbrains.*.plist
  rm -f ~/Library/Preferences/jetbrains.*.*.plist

  echo "Restarting cfprefsd"
  killall cfprefsd

elif [ "$OS_NAME" == "Linux" ]; then
  echo 'Resetting JetBrains IDE evaluations on Linux:'

  for PRD in $JB_PRODUCTS; do
    reset_evals "$PRD" ".$PRD*/config"
    reset_evals "$PRD" ".config/JetBrains/${PRD}*"
  done

  reset_java_prefs_linux
else
  echo 'Unsupported OS'
  exit 1
fi

echo 'Done.'