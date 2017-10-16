#在servera上
#/bin/bash

#下载软件，并安装

setenforce 0
yum -y install lftp &>/dev/null
lftp 172.25.254.250 << ENO
cd  /notes/project/UP200/UP200_cacti-master
mirror pkg/
exit
ENO
mv pkg/ /root/cacti

# 安装lamp
yum -y install httpd php php-mysql mariadb-server mariadb
cd /root/cacti
yum localinstall cacti-0.8.8b-7.el7.noarch.rpm php-snmp-5.4.16-23.el7_0.3.x86_64.rpm 

#配置mysql数据库
service mariadb start


mysql << ENO
delete from mysql.user where user='';
update mysql.user set password=password('mysql') where user='root';
create database cacti;
grant all on cacti.* to cactidb@'%' identified by 'cacti';
flush privileges;
exit
ENO

sed -i 's/$database_username.*/$database_username = "cactidb";/' /etc/cacti/db.php
sed -i 's/$database_password = "cactiuser";/$database_password = "cacti";/'  /etc/cacti/db.php
mysql -ucactidb -pcacti cacti < /usr/share/doc/cacti-0.8.8b/cacti.sql 

#配置cacti的相关参数

sed -i 's/Require host localhost/Require all granted/' /etc/httpd/conf.d/cacti.conf 

#配置php时区

timedatectl set-timezone Asia/Shanghai
sed -i "s/;date.timezone =/date.timezone = 'Asia\/Shanghai'/" /etc/php.ini
#变更计划任务 --> 让其五分钟出一一次图
sed -i 's/#//' /etc/cron.d/cacti

#启动服务

service httpd restart
service snmpd start
#然后访问测试
#用户与密码 admin/admin
#能登录即成功

#配置cacti监控本地服务器

 sed -i '/view    systemview    included   .1.3.6.1.2.1.1/i\view    systemview    included   .1' /etc/snmp/snmpd.conf
 sed -i 's/#com2sec notConfigUser   default         public/com2sec notConfigUser   default         publicaaa/' /etc/snmp/snmpd.conf
 
 service snmpd restart
 
#网页点击左边device,选择localhost,看到如下界面面,在snmp options这里里选择snmp version2


#为了监控serverb
#在serverb上运行
#/bin/bash
 setenforce 0
 yum -y install net-snmp
 
 sed -i '/view    systemview    included   .1.3.6.1.2.1.1/i\view    systemview    included   .1' /etc/snmp/snmpd.conf
 sed -i 's/#com2sec notConfigUser   default         public/com2sec notConfigUser   default         publicaaa/' /etc/snmp/snmpd.conf
service snmpd start
#在网页上点击左边device,新建serverb,看到如下界面面,在snmp options这里里选择snmp version2

