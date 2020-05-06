#!/bin/bash

setup_git() {
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "Travis CI"
}

checkout_current_branch() {
  git checkout $TRAVIS_BRANCH
}

erase_existing_docs() {
  rm -rf rdfs_* || exit 0;
  mkdir rdfs_classes
  mkdir rdfs_properties
}

commit_generated_files() {
  git add rdfs_*
  git add oa.jsonld
  git status
  git commit --message "Updating auto-generated namespace documentation: $TRAVIS_BUILD_NUMBER [ci skip]"
}

push_files() {
  git remote add origin-branch https://${GH_TOKEN}@github.com/openactive/openactive.github.io.git > /dev/null 2>&1
  git push --quiet --set-upstream origin-branch $TRAVIS_BRANCH
}

echo "Git version:"
git --version

echo "Setup Git:"
setup_git

echo "Checkout master:"
checkout_current_branch

echo "Erase existing documentation..."
erase_existing_docs

echo "npm install:"
npm install
npm install @openactive/data-models@latest
npm ls @openactive/data-models

echo "Generating data model documentation..."
npm run start

echo "Commit Generated Files:"
commit_generated_files

echo "Push Files:"
push_files





#!/bin/bash
set -e # exit with nonzero exit code if anything fails

# squash messages
git config --global push.default matching

# install latest models
npm install
npm install @openactive/data-models@latest
npm ls @openactive/data-models

# clear and re-create the output directory
rm -rf output || exit 0;
mkdir output
mkdir output/rdfs_classes
mkdir output/rdfs_properties

# go to the out directory and create a *new* Git repo
cd output
git init

# inside this git repo we'll pretend to be a new user
git config user.name "Travis CI"
git config user.email "travis@openactive.org"

cd ..

# Run documentation generation
node index.js

cd output

# The first and only commit to this new Git repo contains all the
# files present with the commit message "Deploy to GitHub Pages".
git add .
git commit -m "Deploy to GitHub Pages - Static"

# Force push from the current repo's master branch to the remote
# repo's gh-pages branch. (All previous history on the gh-pages branch
# will be lost, since we are overwriting it.) We redirect any output to
# /dev/null to hide any sensitive credential data that might otherwise be exposed.
# FIXME should be authorised via key
git push --force "https://${GH_TOKEN}@${GH_REF}" master:gh-pages



8a2758c77b01523041b54aab85b46a616294dfc8

cd ..