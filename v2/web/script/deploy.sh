#setup variables
script_dir="$( cd "$( dirname "$0" )" && pwd )"

deploy_env="dev"
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
	rsync_args="-arvuz $script_dir/../ prod@resoapp.com:/home/prod/public/resoapp.com --exclude-from $script_dir/exclude.txt"
	site_dir="resoapp.com"
elif [ $deploy_env == "dev" ]; then
	rsync_args="-arvuz $script_dir/../ dev@resoapp.com:/home/prod/public/dev.resoapp.com --exclude-from $script_dir/exclude.txt"
	site_dir="dev.resoapp.com"
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
ssh $deploy_env@resoapp.com "bash -l -c 'cd ./public/$site_dir;pwd;which bundle;bundle install --without development'"

if [ $deploy_env == "prod" ]; then
echo -en "\033[0;33m"
echo "step three: restart apache"
echo -en "\033[0m"
ssh -tt $deploy_env@resoapp.com "bash -l -c 'sudo service apache2 restart'"
fi

echo -en "\033[0;32m"
echo "deployment finished: $deploy_env"
echo -en "\033[0m"