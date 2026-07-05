#!/usr/bin/env bats

# ====================================================== project information ===

# author      : jimmy mg lim (mirageglobe@gmail.com)
# source      : https://github.com/mirageglobe/swissknife
# license     : Apache License 2.0
# version     : 0.2.0

# --------------------------------------------------------------------- main ---

# shellcheck source=./jsk-bash-lib.sh
source ./jsk-bash-lib.sh

@test "_allow_os test os" {
  local current_os
  current_os="$(uname -s)"
  run _allow_os "$current_os"
  [ "$status" -eq 0 ]
}

@test "_timestamp returns non-empty string" {
  run _timestamp
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}

@test "_datestamp returns non-empty string" {
  run _datestamp
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}

@test "_is_installed detects system commands" {
  run _is_installed "ls"
  [ "$status" -eq 0 ]
  
  run _is_installed "non_existent_command_xyz"
  [ "$status" -ne 0 ]
}

@test "_file_exists and _directory_exists" {
  local temp_file="/tmp/jsk_test_file_$$"
  local temp_dir="/tmp/jsk_test_dir_$$"
  
  touch "$temp_file"
  mkdir "$temp_dir"
  
  run _file_exists "$temp_file"
  [ "$status" -eq 0 ]
  
  run _directory_exists "$temp_dir"
  [ "$status" -eq 0 ]
  
  run _file_exists "/non/existent/path"
  [ "$status" -ne 0 ]
  
  rm "$temp_file"
  rmdir "$temp_dir"
}

@test "_is_macos and _is_linux consistency" {
  local os
  os=$(uname -s)
  
  if [[ "$os" == "Darwin" ]]; then
    run _is_macos
    [ "$status" -eq 0 ]
    run _is_linux
    [ "$status" -ne 0 ]
  elif [[ "$os" == "Linux" ]]; then
    run _is_linux
    [ "$status" -eq 0 ]
    run _is_macos
    [ "$status" -ne 0 ]
  fi
}

@test "_print_success and _print_error output" {
  run _print_success "Great success"
  [[ "$output" == *"Great success"* ]]
  
  run _print_error "Oh no error"
  [[ "$output" == *"Oh no error"* ]]
}

@test "_parse_yaml simple test" {
  local yaml_file="/tmp/test.yaml"
  cat <<EOF > "$yaml_file"
app:
  name: "swissknife"
  version: 1.0
EOF
  
  run _parse_yaml "$yaml_file" "CONF_"
  [ "$status" -eq 0 ]
  [[ "$output" == *"CONF_app_name=\"swissknife\""* ]]
  [[ "$output" == *"CONF_app_version=\"1.0\""* ]]
  
  rm "$yaml_file"
}

@test "_try utility" {
  run _try true
  [ "$status" -eq 0 ]
}

@test "_quit utility" {
  run _quit
  [ "$status" -eq 0 ]
}
