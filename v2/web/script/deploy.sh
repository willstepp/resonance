#setup variables
script_dir="$( cd "$( dirname "$0" )" && pwd )"
deploy_env="prod"
init=""
if [ "$#" -ge 1 ]; then init=$1; fi
rsync_args="-arvuz $script_dir/../ prod@monomyth.io:/home/prod/public/resonance.monomyth.io --exclude-from $script_dir/exclude.txt"
site_dir="resonance.monomyth.io"

#deploy
cd $script_dir
echo "\033[0;36m"
echo "deployment started: $deploy_env"

#copy web files
echo "\033[0;33m"
echo "step one: copying website to server"
echo "\033[0m"
rsync $rsync_args

#run bundler
echo "\033[0;33m"
echo "step two: run bundler on server"
echo "\033[0m"
ssh $deploy_env@monomyth.io "bash -l -c 'cd ./public/$site_dir;pwd;which bundle;bundle install --without development --path vendor/bundle --binstubs bin/'"

#run assets precompile
echo "\033[0;33m"
echo "step three: run assets precompile on server"
echo "\033[0m"
ssh $deploy_env@monomyth.io "bash -l -c 'cd ./public/$site_dir;rake assets:precompile RAILS_ENV=production'"

#init db
if [ $init == "init" ]; then
  echo "\033[0;33m"
  echo "db init: creating database"
  echo "\033[0m"
  ssh $deploy_env@monomyth.io "bash -l -c 'cd ./public/$site_dir;rake db:create RAILS_ENV=production'"
fi

#run migrations
echo "\033[0;33m"
echo "step four: run migrations on database"
echo "\033[0m"
ssh $deploy_env@monomyth.io "bash -l -c 'cd ./public/$site_dir;rake db:migrate RAILS_ENV=production'"

#restart web server
if [ $deploy_env == "prod" ]; then
echo "\033[0;33m"
echo "step five: restart nginx on server"
echo "\033[0m"
ssh -tt $deploy_env@monomyth.io "bash -l -c 'sudo /etc/init.d/nginx restart'"
fi

#finished
echo "\033[0;32m"
echo "deployment finished: $deploy_env"
echo "\033[0m"