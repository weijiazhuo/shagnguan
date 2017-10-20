初始化模版机，想初始化哪台就在哪个机子执行


[root@foundation14 vir]# cat init.sh 
#!/bin/bash

cat > /etc/hosts << EOT
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
172.25.14.101 node01.uplooking.com node01
172.25.14.102 node02.uplooking.com node02
172.25.14.103 node03.uplooking.com node03
172.25.14.104 node04.uplooking.com node04
172.25.14.105 node05.uplooking.com node05
172.25.14.106 node06.uplooking.com node06
172.25.14.107 node07.uplooking.com node07
172.25.14.108 node08.uplooking.com node08
172.25.14.109 node09.uplooking.com node09
172.25.14.110 node10.uplooking.com node10
EOT

HOST1=$(grep $1 /etc/hosts |awk '{print $2}')

cat > /etc/sysconfig/network << EOT
NETWORKING=yes
HOSTNAME=$HOST1
EOT

hostname $HOST1

#IP1=$(grep $1 /etc/hosts |awk '{print $1}')

cat > /etc/sysconfig/network-scripts/ifcfg-eth0 <<EOT
DEVICE="eth0"
BOOTPROTO="static"
ONBOOT="yes"
IPADDR=$1
NETMASK=255.255.255.0
GATEWAY=172.25.1.254
DNS1=172.25.254.250
EOT


cat > /etc/sysconfig/network-scripts/ifcfg-eth1 <<EOT
DEVICE="eth1"
BOOTPROTO="static"
ONBOOT="yes"
IPADDR=192.168.122.1$1
NETMASK=255.255.255.0
EOT

mkdir -p /root/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCWBjTw5L9pgOQ0uvASrl17QUsaWliVgpWgxroZPXXC0a6HfrTJxCEGHh4ME7Vm8pQBrlB+w1t+djJ2qCD6bjAfrVASq8eco1Droc3ctjD/FRe/WC6tlvUTw+8Tk6AJQZSbTiUgFRM+9zZ/h/tNuEvBfA9V67yXitrINBfWRXXVCeANAgrEIP+tB6wRvc420cUDvWaxlrnmRF7X47tSE/7eT6fyxWTDhgEg3/cLwr08qfCAPBiIiUh4CTWi0rr6F9Xa+RtEwTtC2OsPbOrTn8l/mz/mrTiBBoiwDlbERZFsicpfo/36DNo6XOg2hIoB2VFB0t2EZc9CKjUy689jlid9 root@foundation14.ilt.example.com" > /root/.ssh/authorized_keys



执行的时候

sh init.sh 01 -- > 01是传递参数$1 
执行完后机子ip变为101
sh init.sh 02 -- > 02是传递参数$1 
执行完后机子ip变为102

