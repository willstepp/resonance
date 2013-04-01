#setup variables
script_dir="$( cd "$( dirname "$0" )" && pwd )"

deploy_env="prod"
if [ "$#" -ge 1 ]; then deploy_env=$1; fi
  
if [ $deploy_env != "dev" ] && [ $deploy_env != "prod" ]; then
echo -en "\033[0;31m"
echo "usage: deploy.sh <dev | prod>"
echo -en "\033[0m"
exit 1
fi

rsync_args=""
site_dir=""
if [ $deploy_env == "prod" ]; then 
  rsync_args="-arvuz $script_dir/../ prod@monomyth.io:/home/prod/public/resonance.monomyth.io --exclude-from $script_dir/exclude.txt"
  site_dir="resonance.monomyth.io"
elif [ $deploy_env == "dev" ]; then
  rsync_args="-arvuz $script_dir/../ dev@resoapp.com:/home/prod/public/resonance.monomyth.io --exclude-from $script_dir/exclude.txt"
  site_dir="resonance.monomyth.io"
fi

#deploy
cd $script_dir
echo -en "\033[0;36m"
echo "deployment started: $deploy_env"
echo -en "\033[0;33m"
echo "step one: copying website files to server"
echo -en "\033[0m"
rsync $rsync_args
echo -en "\033[0;33m"
echo "step two: run bundler on server"
echo -en "\033[0m"
ssh $deploy_env@monomyth.io "bash -l -c 'cd ./public/$site_dir;pwd;which bundle;bundle install --without development --path vendor/bundle --binstubs bin/'"

if [ $deploy_env == "prod" ]; then
echo -en "\033[0;33m"
echo "step three: restart nginx"
echo -en "\033[0m"
ssh -tt $deploy_env@monomyth.io "bash -l -c 'sudo /etc/init.d/nginx restart'"
fi

echo -en "\033[0;32m"
echo "deployment finished: $deploy_env"
echo -en "\033[0m"