# become lokasbot 
# stop all runing jobs on tool server
toolforge-jobs flush
# remove old files
rm -fdr $HOME/repos
# start clone main repo 
git clone --recurse-submodules https://github.com/LokasWiki/LokasBot.git $HOME/repos
# make setup-venvs.sh execautable
chmod ug+x $HOME/repos/toolforge/bin/setup-venvs.sh
#  start run jobs
toolforge-jobs run setup-venvs --command $HOME/repos/toolforge/bin/setup-venvs.sh --image tf-python39
# show logs
tail -f $HOME/setup-venvs.*
# set permissions for all files in repos directory
chmod -R ug+x $HOME/repos/*
# copy auth file to repo
cp $HOME/user-config.py  $HOME/repos
cp $HOME/user-password.py $HOME/repos
# lood tasks
toolforge-jobs load $HOME/repos/toolforge/cronjobs1.yaml
# run test job
toolforge-jobs run script --command $HOME/repos/toolforge/jobs/test-pull.sh --image tf-python39 --wait

