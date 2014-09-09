#!/bin/bash

# Tell bash that we want the whole script to fail if any part fails.
set -e

# Global Variables
SOURCE_DIR=`pwd`

# Begin
echo "*************************************"
echo "Running build script..."
echo "PWD :"$SOURCE_DIR

main() {
  echo "*************************************"
  startTime=$(date +%s)

  bundle install --path vendor/bundle
  bundle exec rake rubocop
  bundle exec rake spec:full --trace
  gem build orb_configuration.gemspec

  endTime=$(date +%s)
  timeDifference=$(( $endTime - $startTime ))

  echo "Execution time :" $timeDifference
  echo "Finished."
}

# RUN
main
