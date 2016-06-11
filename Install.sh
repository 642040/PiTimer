# Update from git source
# Assumes that you cloned from git repository
# ex:  git clone http://github.com/642040/PiTimer

git pull origin

# Install/update prerequisites

apt-get update
apt-get -y install apache2 build-essential
apt-get -y install libwww-perl libxml-libxml-perl libdbd-xbase-perl
apt-get -y install libmath-complex-perl

cpan install Device::BCM2835

mv /var/www /var/www.orig
ln -s /root/PiTimer/PiTimerWWW/ /var/www
chown -h www-data:www-data /var/www
chmod 755 /root

# setup crontabs
crontab crontab.config
