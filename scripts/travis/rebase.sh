#!/bin/bash
set -e

#  If we're on the presubmit branch, the dev Dart release, and all unit
#  tests pass, merge the presubmit branch into master and push it.

echo '***************'
echo '** REBASE    **'
echo '***************'


CHANNEL=`echo $JOB | cut -f 2 -d -`
SHA=`git rev-parse HEAD`

echo Current channel is: $CHANNEL
echo Current branch is: $TRAVIS_BRANCH

if [ "$TRAVIS_REPO_SLUG" = "markovuksanovic/angular.dart" ]; then
  if [[ $TRAVIS_BRANCH =~ ^(.*)-q-(.*)$ ]]; then
    git config credential.helper "store --file=.git/credentials"
    # travis encrypt GITHUB_TOKEN_ANGULAR_ORG=??? --repo=angular/angular.dart
    echo "https://${GITHUB_TOKEN_ANGULAR_ORG}:@github.com" > .git/credentials
    git config user.name "deploy-test@travis-ci.org"

    echo "rebasing " ${BASH_REMATCH[1]} " onto " ${BASH_REMATCH[2]}
    git remote add upstream https://github.com/angular/angular.dart.git
    git fetch upstream master
    git rebase upstream/master
    if git push upstream HEAD:master; then
      echo "$TRAVIS_BRANCH has been merged into master, deleting..."
      git push upstream :"$TRAVIS_BRANCH"
    fi
  fi
fi
