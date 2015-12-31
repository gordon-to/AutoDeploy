#!/bin/bash -l
set -e

# Set UTF-8 as default locale
export LC_ALL="C.UTF-8"

BRANCH="$1"
GIT_REPO="$2"
TMP_GIT_CLONE=/data/www/affektive.agif.me/tmp
PUBLIC_WWW=/data/www/affektive.agif.me/public_html
DEPLOY_KEY=/data/www/affektive.agif.me/keys/id_rsa.deploy
$RUBY_PATH=/usr/bin/ruby

remove_tmp_repo () {
  # Remove the temporary repo
  rm -rf $TMP_GIT_CLONE
}
# If there's an error, always remove the temporary repo
trap remove_tmp_repo ERR

# Clone the bare repo into a temporary repo with a working copy
ssh-agent bash -c "ssh-add $DEPLOY_KEY; git clone $GIT_REPO $TMP_GIT_CLONE"
# Enter the working directory
cd $TMP_GIT_CLONE
git checkout $BRANCH

# Use this section for Jekyll sites
# # Use Jekyll to generate the static site
# echo "Building Jekyll site..."
# #chown -R eraco $TMP_GIT_CLONE
# #su eraco -c "
# #bundle install && bundle exec jekyll build
# if [ -f ./Gemfile ]; then
#   echo "Gemfile found, bundle install && bundle exec jekyll build"
#   $RUBY_PATH/bundle install && $RUBY_PATH/bundle exec jekyll build
# else
#   echo "No Gemfile, running jekyll build"
#   /usr/local/rvm/wrappers/auto_deploy/jekyll build
# fi

# echo "Successfully built Jekyll site!"

# Copy the static site to htdocs, ignoring specific files
echo "Copying site to $PUBLIC_WWW ..."
if [ -r .rsyncexclude ]; then
  rsync --archive --delete --exclude-from=.rsyncexclude _site/ $PUBLIC_WWW
else
  rsync --archive --delete _site/ $PUBLIC_WWW
fi
echo "Done copying!"

# Remove the temporary repo
remove_tmp_repo
