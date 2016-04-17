# Update from git source
# Assumes that you cloned from git repository
# ex:  git clone http://github.com/642040/PiTimer

git pull origin

# Install/update prerequisites

apt-get update
apt-get -y install apache2 build-essential

cd ~
wget http://www.airspayce.com/mikem/bcm2835/bcm2835-1.50.tar.gz
tar zxvf bcm2835-1.50.tar.gz
cd bcm2835-1.50
./configure
make
make check
make install
cd -

cpan Device::BCM2835

ln -s PiTimerWWW/ /var/www/PiTimer/
ln -s PiTimerCron/ /root/PiTimerCron/

# setup crontabs
crontab crontab.config
