#/bin/bash
yum -y install lftp &>/dev/null
setenforce 0
#下载nagios包

lftp 172.25.254.250 << ENO
cd /notes/project/UP200/UP200_nagios-master
 mirror pkg/
 exit
ENO

mv  pkg/ /root/nagios
cd /root/nagios
yum localinstall *.rpm

yum -y install expect

expect << ENO 
spawn htpasswd -c /etc/nagios/passwd nagiosadmin
expect "password:"
send "nagios\n"
expect "password:"
send "nagios\n"
expect eno
ENO
sed -i 's/notifications_enabled.*/notifications_enabled           1/'  /etc/nagios/objects/localhost.cfg

systemctl restart httpd

systemctl start nagios


#通过servera上监控serverb
#在serverb上运行脚本
#/bin/bash
yum -y install lftp &>/dev/null

#下载nagios包

lftp 172.25.254.250 << ENO
cd /notes/project/UP200/UP200_nagios-master
 mirror pkg/
 cd /notes/project/software/nagios
 get nrpe-2.12.tar.gz 
 exit
 ENO
 mv  pkg/ /root/nagios
cd /root/nagios
yum localinstall *.rpm

yum -y install gcc
yum -y install xinetd
yum -y install openssl-devel
tar -xf nrpe-2.12.tar.gz -C /root/
cd nrpe-2.12/
 ./configure && make all && make install-plugin && make install-daemon && make install-daemon-config && make install-xinetd
 

echo  "nrpe            5666/tcp                # nrpe" >>  /etc/services 
sed -i 's/hda1/vda1/'  /usr/local/nagios/etc/nrpe.cfg
 systemctl restart  xinetd

#ssh servera 进行配置
yum -y install expect

#/bin/bash
cat > aaaaaa.sh << ENM
#/bin/bash
#将脚本scp给servera
#然后远程执行
cat >> /etc/nagios/objects/commands.cfg <<ENO
define command{
        command_name check_nrpe
        command_line $USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$
        }
ENO
cat >> /etc/nagios/objects/commands.cfg << ENO
define host{
        use                     linux-server                                                         
        host_name               serverb.pod1.example.com
        alias                   serverb1
        address                 172.25.14.11
        }
define hostgroup{
        hostgroup_name  linux-server 
        alias           linux-server
        members         serverb.pod14.example.com     
        }

# 定义监控服务
define service{
        use generic-service
        host_name serverb.pod14.example.com
        service_description load
        check_command check_nrpe!check_load
}
define service{
        use generic-service
        host_name serverb.pod14.example.com
        service_description user
        check_command check_nrpe!check_users
}
define service{
        use generic-service
        host_name serverb.pod1.example.com
        service_description zombie
        check_command check_nrpe!check_zombie_procs
}



define service{
        use generic-service
        host_name serverb.pod1.example.com
        service_description procs
        check_command check_nrpe!check_total_procs
}


define service{
        use generic-service
        host_name serverb.pod1.example.com
        service_description vda1
        check_command check_nrpe!check_vda1
}
sed -i '/cfg_file=/etc/nagios/objects/serverb.cfg/d' /etc/nagios/objects/serverb.cfg
cat >> /etc/nagios/nagios.cfg << ENO
cfg_file=/etc/nagios/objects/serverb.cfg
ENM
sed -i '/^172.25.14.10'/d /root/.ssh/known_hosts
expect << ENO 
spawn  scp aaaaaa.sh 172.25.14.10:/root/
expect "(yes/no)?"
send "yes\r"
expect "password:"
send "uplooking\r"
expect "#"
send "setenforce 0\r"
expect "#"
send "sh /root/aaaaaaa.sh"
expect "#"
send "exit"
expect eno
ENO



