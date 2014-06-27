# Update from git source
# Assumes that you cloned from git repository
# ex:  git clone http://github.com/642040/PiTimer

git pull origin
rsync -a --delete PiTimerWWW/ /var/www/PiTimer/
rsync -a --delete PiTimerCron/ /root/PiTimerCron/
# setup crontabs