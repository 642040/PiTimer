# Update from git source
# Assumes that you cloned from git repository
# ex:  git clone http://github.com/642040/PiTimer

git pull origin

# Install/update prerequisites

apt-get update
apt-get -y install apache2 build-essential
apt-get -y install libwww-perl libxml-libxml-perl libdbd-xbase-perl
apt-get -y install libmath-complex-perl

olddir=`pwd`
cd ~

wget http://www.airspayce.com/mikem/bcm2835/bcm2835-1.50.tar.gz
tar zxvf bcm2835-1.50.tar.gz
cd bcm2835-1.50
./configure
make
make check
make install

cd $olddir

mv /var/www /var/www.orig
ln -s /root/PiTimer/PiTimerWWW/ /var/www
chown -h www-data:www-data /var/www
chmod 755 /root

# setup crontabs
crontab crontab.config
