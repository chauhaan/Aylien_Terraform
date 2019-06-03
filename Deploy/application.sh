#!/bin/bash
yum install python python-setuptools* curl git -y
mkdir -p /var/www/python
curl -o /var/www/python/get-pip.py https://bootstrap.pypa.io/get-pip.py
python /var/www/python/get-pip.py
git clone https://github.com/AYLIEN/technical_challenge.git /var/www/python/paint
pip install -r /var/www/python/paint/app/requirements.txt
echo "python /var/www/python/paint/app/app.py --port 8080 --monitor 8081 &" >> /etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local
bash /etc/rc.d/rc.local
cat <<EOF >  /var/www/python/paint/crash_restart.sh
#!/bin/bash
curl http://127.0.0.1:8081 >/dev/null 2>&1
if [ \$? -eq 7 ]
then
        python /var/www/python/paint/app/app.py --port 8080 --monitor 8081 &
fi
EOF
chmod +x /var/www/python/paint/crash_restart.sh
echo "* * * * * ( sleep 5 ; /var/www/python/paint/crash_restart.sh )
* * * * * ( sleep 10 ; /var/www/python/paint/crash_restart.sh )
* * * * * ( sleep 15 ; /var/www/python/paint/crash_restart.sh )
* * * * * ( sleep 20 ; /var/www/python/paint/crash_restart.sh )
* * * * * ( sleep 25 ; /var/www/python/paint/crash_restart.sh )
* * * * * ( sleep 30 ; /var/www/python/paint/crash_restart.sh )
* * * * * ( sleep 35 ; /var/www/python/paint/crash_restart.sh )
* * * * * ( sleep 40 ; /var/www/python/paint/crash_restart.sh )
* * * * * ( sleep 45 ; /var/www/python/paint/crash_restart.sh )
* * * * * ( sleep 50 ; /var/www/python/paint/crash_restart.sh )
* * * * * ( sleep 55 ; /var/www/python/paint/crash_restart.sh )" | crontab -