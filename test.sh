#!/bin/bash
set -e

green="\033[0;32m"
red="\033[0;31m"
nc="\033[0m"

run_command() {
  echo -e "${green}========== $1 ==========${nc}"
  if ! eval "$2"; then
    echo -e "${red}❌ $1 failed!${nc}"
    exit 1
  else
    echo -e " "
  fi
}

run_command "Brakeman" "bundle exec brakeman"
run_command "Importmap" "bin/importmap audit"
run_command "Bundle-audit" "bundle-audit"
run_command "Cucumber" "bundle exec cucumber"
run_command "Rubocop" "bundle exec rubocop"
run_command "RSpec" "bundle exec rspec"
