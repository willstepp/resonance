#setup variables
script_dir="$( cd "$( dirname "$0" )" && pwd )"
rsync_args="-arvuz $script_dir/ prod@monomyth.io:/opt/reso_mix_processor --exclude-from $script_dir/exclude.txt"

#deploy
cd $script_dir
echo "\033[0;36m"
echo "deployment started to /opt/reso_mix_processor"

#copy web files
echo "\033[0;33m"
echo "step one: copying files to server"
echo "\033[0m"
rsync $rsync_args
res=$?
[ $res -ne 0 ] && echo "\033[0;31m" && echo $error_output && echo "\033[0m" && exit 1

#run bundler
echo "\033[0;33m"
echo "step two: run bundler on server"
echo "\033[0m"
ssh prod@monomyth.io "bash -l -c 'cd /opt/reso_mix_processor;pwd;which bundle;bundle install --path vendor/bundle --binstubs bin/'"
res=$?
[ $res -ne 0 ] && echo "\033[0;31m" && echo $error_output && echo "\033[0m" && exit 1

#finished
echo "\033[0;32m"
echo "deployment finished to /opt/reso_mix_processor"
echo "\033[0m"