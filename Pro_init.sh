#!/bin/bash
source /etc/profile &>/dev/null
private_ip=$1
hostname=$2
root_password=$3
admin_password=$4
app_list=$5

check_private_ip(){
#    local_ip=$(ip addr | grep -w eth0 | grep -w inet | awk '{print $2}' | awk -F'/' '{print $1}')
#    if [[ $private_ip != $local_ip ]];then
     ip_count=$(ip addr|grep $private_ip|wc -l)
     if [[ $ip_count -eq 0 ]];then
        echo "private_ip error"
        exit 1
    fi
}

hostname_init(){
    system=`rpm -q centos-release | awk -F - '{print $3}'`
    if [ $system == '6' ]
    then
        sed -i "s/127\.0\.0\.1\(.*\)/127.0.0.1   $hostname\1/" /etc/hosts
        sed -i "s/::1\(.*\)/::1 $hostname\1/" /etc/hosts
        sed -i "s/HOSTNAME=.*/HOSTNAME=$hostname/" /etc/sysconfig/network
        echo $hostname > /etc/hostname
	echo "223.6.250.204 gw.api.taobao.com" >> /etc/hosts

        hostname $hostname
    else
        hostnamectl set-hostname $hostname
    fi
}

system_init(){
    echo "fs.file-max = 65535" >> /etc/sysctl.conf
    echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_fin_timeout = 30" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_max_syn_backlog = 10240" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_keepalive_time = 1200" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_synack_retries = 3" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_syn_retries = 3" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_max_orphans = 8192" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_max_tw_buckets = 5000" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_window_scaling = 0" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_sack = 0" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_timestamps = 0" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_tw_reuse = 1" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_tw_recycle = 1" >> /etc/sysctl.conf
    echo "net.ipv4.ip_local_port_range = 1024 65000" >> /etc/sysctl.conf
    echo "net.ipv4.icmp_echo_ignore_all = 0" >> /etc/sysctl.conf
    sysctl -p
    echo "* soft    nofile  131072" >> /etc/security/limits.conf
    echo "* hard    nofile  131072" >> /etc/security/limits.conf
    echo "* soft    nproc   131072" >> /etc/security/limits.conf
    echo "* hard    nproc   131072" >> /etc/security/limits.conf
    echo "* soft    core    unlimited" >> /etc/security/limits.conf
    echo "* hard    core    unlimited" >> /etc/security/limits.conf
    echo "* soft    memlock 50000000" >> /etc/security/limits.conf
    echo "* hard    memlock 50000000" >> /etc/security/limits.conf
    sed -i '/^.*nproc.*$/d' /etc/security/limits.d/90-nproc.conf
    echo "*          soft    nproc     100000" >> /etc/security/limits.d/90-nproc.conf
    sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config
    setenforce = 0
    iptables -F
    iptables -t nat -F
    echo "iptables -F" >> /etc/rc.local
    echo "iptables -t nat -F" >> /etc/rc.local

    echo "120.55.247.15 hub.fenxibao.com" >> /etc/hosts
}

system_yum(){
    yum install -y wget ntp gcc gcc-c++ bc vim lrzsz telnet openssl-devel python-devel git
    mkdir -p /etc/yum.repos.d/backup
    mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup/
    wget -O /etc/yum.repos.d/shuyun.repo yum.ops.fenxibao.com/repo/shuyun.repo
    yum clean all
    yum -y install mysql
    yum -y install zabbix-proj-ZD
    yum -y install lvm2
    yum -y install nc mongodb redis
}

time_aciton(){
    /etc/init.d/ntpd stop
    /sbin/chkconfig  zabbix_agentd on
   # systemctl enable zabbix_agentd
    cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    ntpdate  cn.pool.ntp.org
    echo "*/6 * * * *  /usr/sbin/ntpdate -u  cn.pool.ntp.org" >> /var/spool/cron/root
    echo "*/6 * * * *  /usr/sbin/hwclock -w" >> /var/spool/cron/root
    echo "0 * * * * export LANG=en_US.UTF-8" >> /var/spool/cron/root
}

pass_admin(){
    useradd  admin 
    echo $admin_password |passwd admin --stdin
}

pass_root(){
    echo $root_password |passwd root --stdin
}

hosts_allow(){
    echo "sshd: 121.41.163.203/255.255.255.255" > /etc/hosts.allow
    echo "sshd: 121.41.163.203/255.255.255.255" >> /etc/hosts.allow
    echo "sshd: 121.41.163.217/255.255.255.255" >> /etc/hosts.allow
    echo "sshd: 120.55.184.63/255.255.255.255" >> /etc/hosts.allow
    echo "sshd: 113.200.156.105/255.255.255.255" >> /etc/hosts.allow
    echo "sshd: 101.37.175.46" >> /etc/hosts.allow
    echo "sshd: 101.37.32.52" >> /etc/hosts.allow
    echo "sshd: 101.37.69.87" >> /etc/hosts.allow
    echo "sshd: 101.37.28.226" >> /etc/hosts.allow
    echo "sshd: 27.115.15.198/255.255.255.255" >> /etc/hosts.allow
    echo "sshd: 10.*" >> /etc/hosts.allow
    echo "sshd: 172.*" >> /etc/hosts.allow
    echo "sshd: 192.*" >> /etc/hosts.allow
    echo "sshd: 127.0.0.1/255.255.255.255" >> /etc/hosts.allow
    echo "sshd: ALL" > /etc/hosts.deny
}

app_install(){
    for i in $(echo $app_list | tr ',' '\n')
    do 
        if [ $i == 'java1_6' ];then
            yum install -y shuyun-java-6u30
        elif [ $i == 'java1_7' ];then
            yum install -y shuyun-java1.7_71
        elif [ $i == 'java1_8' ];then
            yum install -y shuyun-java-1.8
        elif [ $i == 'karaf' ];then
            yum install -y shuyun-karaf
        elif [ $i == 'resin' ];then
            yum install -y shuyun-resin
        elif [ $i == 'nginx' ];then
            yum install -y http://yum.ops.fenxibao.com/6/shuyun-nginx-pro-1.13.8-1.x86_64.rpm
	    wget http://yum.ops.fenxibao.com/pro/dealnginxlog.sh -O /etc/nginx/dealnginxlog.sh
	    echo "59     23       *       *       *  sh  /etc/nginx/dealnginxlog.sh" >>  /var/spool/cron/root
           # yum install -y http://yum.ops.fenxibao.com/7/shuyun-nginx-1.10.2-2.x86_64.rpm
        elif [ $i == 'redis' ];then
            yum install -y http://yum.ops.fenxibao.com/6/shuyun-redis-0.0.1-el5.x86_64.rpm
        elif [ $i == 'docker' ];then
            yum install -y shuyun-docker.x86_64
        fi
    done
}

fdisk_data(){
    val=$(echo $app_list | tr ',' '\n' | grep -w docker |wc -l)
    if [[ $val -eq 0 ]];then
        yum install -y fdisk-SHO
    elif [[ $val -eq 1 ]];then
        yum install -y fdisk-SHO-docker
    fi
}

check_private_ip

hostname_init

system_init

echo "nameserver 8.8.8.8" >> /etc/resolv.conf
system_yum

fdisk_data

app_install

pass_admin

pass_root

time_aciton

res_type=$(echo $hostname | awk -F'-' '{print $2}')
if [ $res_type == 'ecs' ]
then
    hosts_allow
fi
