#!/bin/bash
set -e

#  If we're on the branch which name is of the form branch1-q-branch2
#  and all the tests pass, push this branch as branch2. Note that
#  branch1 would alreay have been rebased onto branch2 by this point.

echo '***************'
echo '** PRESUBMIT **'
echo '***************'


CHANNEL=`echo $JOB | cut -f 2 -d -`
SHA=`git rev-parse HEAD`

echo Current channel is: $CHANNEL
echo Current branch is: $TRAVIS_BRANCH
echo Test result is: $TRAVIS_TEST_RESULT

if [ "$TRAVIS_REPO_SLUG" = "markovuksanovic/angular.dart" ]; then
  if [ $TRAVIS_TEST_RESULT -eq 0 ] && [[ $TRAVIS_BRANCH =~ ^(.*)-q-(.*)$ ]]; then
    echo "Pushing HEAD to ${BASH_REMATCH[2]}..."
    if git push upstream HEAD:${BASH_REMATCH[2]}; then
      echo "${BASH_REMATCH[1]} has been merged into ${BASH_REMATCH[2]}, deleting..."
      git push upstream :"${BASH_REMATCH[1]}"
    fi
  fi
fi
