RECIPIENT=adrian@allan.me
SUBJECT=`grep Ratio /var/www/evapadj.txt`

{
	echo To: $RECIPIENT
	echo From: PiTImer@azallans.com
	echo Subject: PiTimer $SUBJECT
	cat /var/www/evapadj.txt
} |/usr/sbin/ssmtp $RECIPIENT
