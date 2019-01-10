#!/bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
source /etc/profile

# 使用root运行
[ $(id -u) -gt 0 ] && echo "please use root run the script! " && exit 1

# 检查系统版本
OS_Version=$(awk '{print $(NF-1)}' /etc/redhat-release)

# 定义脚本存放路径
LOGPATH=/var/log/linux_check.log
[ -d $LOGPATH ] || mkdir -p $LOGPATH
RESULTFILE="$LOGPATH/Check-`hostname`-`date +%Y%m%d`"


 getCpuStatus(){
    echo ""
    echo "############################ Check CPU Status#############################"
    Physical_CPUs=$(grep "cpu MHz" /proc/cpuinfo |awk -F: '{print $2}')
    Virt_CPUs=$(grep "processor" /proc/cpuinfo | wc -l)
    CPU_Caches=$(grep "cache size" /proc/cpuinfo| awk -F ':' '{print $2}')
    CPU_Type=$(grep "model name" /proc/cpuinfo | awk -F ': ' '{print $2}' )
    CPU_Arch=$(uname -m)
    echo "CPU主频:$Physical_CPUs"
    echo "CPU个数:$Virt_CPUs"
    echo "CPU缓存:$CPU_Caches"
    echo "CPU型号:$CPU_Type"
    echo "CPU架构:$CPU_Arch"
}


 getMemStatus(){
    echo ""
    echo "############################ Check Memmory Usage ###########################"
    if [[ $OS_Version < 7 ]];then
        free -mo
    else
        free -h
    fi
    # report information
    MemTotal=$(grep MemTotal /proc/meminfo| awk '{print $2}')  #KB
    MemFree=$(grep MemFree /proc/meminfo| awk '{print $2}')    #KB
    let MemUsed=MemTotal-MemFree
    MemPercent=$(awk "BEGIN {if($MemTotal==0){printf 100}else{printf \"%.2f\",$MemUsed*100/$MemTotal}}")
    report_MemTotal="$((MemTotal/1024))""MB"        #内存总容量(MB)
    report_MemFree="$((MemFree/1024))""MB"          #内存剩余(MB)
    report_MemUsedPercent="$(awk "BEGIN {if($MemTotal==0){printf 100}else{printf \"%.2f\",$MemUsed*100/$MemTotal}}")""%"   #内存使用率%
    echo "MemTotal is $report_MemTotal"
    echo "MemFree is $report_MemFree"
    echo "MemUsedPercent is $report_MemUsedPercent"
}

 getDiskStatus(){
    echo ""
    echo "############################ Check Disk Status ############################"
    df -hiP | sed 's/Mounted on/Mounted/' > /tmp/inode
    df -hTP | sed 's/Mounted on/Mounted/' > /tmp/disk 
    join /tmp/disk /tmp/inode | awk '{print $1,$2,"|",$3,$4,$5,$6,"|",$8,$9,$10,$11,"|",$12}'| column -t
    # report information
    diskdata=$(df -TP | sed '1d' | awk '$2!="tmpfs"{print}') #KB
    disktotal=$(echo "$diskdata" | awk '{total+=$3}END{print total}') #KB
    diskused=$(echo "$diskdata" | awk '{total+=$4}END{print total}')  #KB
    diskfree=$((disktotal-diskused)) #KB
    diskusedpercent=$(echo $disktotal $diskused | awk '{if($1==0){printf 100}else{printf "%.2f",$2*100/$1}}') 
    report_DiskTotal=$((disktotal/1024/1024))"GB"   #硬盘总容量(GB)
    report_DiskFree=$((diskfree/1024/1024))"GB"     #硬盘剩余(GB)
    report_DiskUsedPercent="$diskusedpercent""%"    #硬盘使用率%
    echo ""
    echo "硬盘总容量:$report_DiskTotal"
    echo "硬盘剩余:$report_DiskFree"
    echo "硬盘使用率:$report_DiskUsedPercent"
}


 getSystemStatus(){
    echo ""
    echo  "############################ Check System Status ############################"
    if [ -e /etc/sysconfig/i18n ];then
        default_LANG="$(grep "LANG=" /etc/sysconfig/i18n | grep -v "^#" | awk -F '"' '{print $2}')"
    else
        default_LANG=$LANG
    fi
    export LANG="en_US.UTF-8"
    Release=$(cat /etc/redhat-release 2>/dev/null)
    Kernel=$(uname -r)
    OS=$(uname -o)
    Hostname=$(uname -n)
    SELinux=$(/usr/sbin/sestatus | grep "SELinux status: " | awk '{print $3}')
    LastReboot=$(who -b | awk '{print $3,$4}')
    #uptime=$(uptime | sed 's/.*up [,]∗[,]∗, .*/\1/')
    uptime=`uptime | awk -F" " '{print $3 $4}'|sed 's/,//g'`
    echo "     系统：$OS"
    echo " 发行版本：$Release"
    echo "     内核：$Kernel"
    echo "   主机名：$Hostname"
    echo "  SELinux：$SELinux"
    echo "语言/编码：$default_LANG"
    echo " 当前时间：$(date +'%F %T')"
    echo " 最后启动：$LastReboot"
    echo " 运行时间：$uptime"
    export LANG="$default_LANG"
    echo ""
}

 getServiceStatus(){
    echo ""
    echo "############################ Check Service Status ############################"
    if [[ $OS_Version > 7 ]];then
        conf=$(systemctl list-unit-files --type=service --state=enabled --no-pager | grep "enabled")
        process=$(systemctl list-units --type=service --state=running --no-pager | grep ".service")
        # report information
        report_SelfInitiatedService="$(echo "$conf" | wc -l)"       #自启动服务数量
        report_RuningService="$(echo "$process" | wc -l)"           #运行中服务数量
    else
        conf=$(/sbin/chkconfig | grep -E ":on|:启用")
        process=$(/sbin/service --status-all 2>/dev/null | grep -E "is running|正在运行")
        # report information
        report_SelfInitiatedService="$(echo "$conf" | wc -l)"       #自启动服务数量
        report_RuningService="$(echo "$process" | wc -l)"           #运行中服务数量
    fi
    echo "Service Configure"
    echo "--------------------------------"
    echo "$conf" | column -t
    echo ""
    echo "The Running Services"
    echo "--------------------------------"
    echo "$process"
}

 getNetworkStatus(){
    echo ""
    echo "############################ Check Network ############################"
    GATEWAY=$(ip route | grep default | awk '{print $3}')
    DNS=$(grep nameserver /etc/resolv.conf| grep -v "#" | awk '{print $2}' | tr '\n' ',' | sed 's/,$//')
    echo ""
    IP=$(ip -f inet addr | grep -v 127.0.0.1 |  grep inet | awk '{print $NF,$2}' | tr '\n' ',' | sed 's/,$//')
    echo "Gateway: $GATEWAY "
    echo "DNS: $DNS"
    echo "IP: $IP"
}

 getListenStatus(){
    echo ""
    echo "############################ Check Connect Status ############################"
#    TCPListen=$(ss -ntul | column -t)

    TCPListen=$(netstat -ntulp | column -t)
    AllConnect=$(ss -an | awk 'NR>1 {++s[$1]} END {for(k in s) print k,s[k]}' | column -t)
    echo "$TCPListen"
    echo "$AllConnect"
    # report information
    report_Listen="$(echo "$TCPListen"| sed '1d' | awk '/tcp/ {print $5}' | awk -F: '{print $NF}' | sort | uniq | wc -l)"
}

 getCronStatus(){
    echo ""
    echo "############################ Check Crontab ########################"
    Crontab=0
    for shell in $(grep -v "/sbin/nologin" /etc/shells);do
        for user in $(grep "$shell" /etc/passwd | awk -F: '{print $1}');do
            crontab -l -u $user >/dev/null 2>&1
            status=$?
            if [ $status -eq 0 ];then
                echo "$user"
                echo "-------------"
                crontab -l -u $user
                let Crontab=Crontab+$(crontab -l -u $user | wc -l)
                echo ""
            fi
        done
    done
    # scheduled task
    find /etc/cron* -type f | xargs -i ls -l {} | column  -t
    let Crontab=Crontab+$(find /etc/cron* -type f | wc -l)
    # report information
    report_Crontab="$Crontab"    #计划任务数
}

 getUserLastLogin(){
    # 获取用户最近一次登录的时间，含年份
    username=$1
    : ${username:="`whoami`"}
    thisYear=$(date +%Y)
    oldesYear=$(last | tail -n1 | awk '{print $NF}')
    while(( $thisYear >= $oldesYear));do
        loginBeforeToday=$(last $username | grep $username | wc -l)
        loginBeforeNewYearsDayOfThisYear=$(last $username -t $thisYear"0101000000" | grep $username | wc -l)
        if [ $loginBeforeToday -eq 0 ];then
            echo "Never Login"
            break
        elif [ $loginBeforeToday -gt $loginBeforeNewYearsDayOfThisYear ];then
            lastDateTime=$(last -i $username | head -n1 | awk '{for(i=4;i<(NF-2);i++)printf"%s ",$i}')" $thisYear" #格式如: Sat Nov 2 20:33 2015
            lastDateTime=$(date "+%Y-%m-%d %H:%M:%S" -d "$lastDateTime")
            echo "$lastDateTime"
            break
        else
            thisYear=$((thisYear-1))
        fi
    done
}

 getUserStatus(){
    echo ""
    echo "############################ Check User ############################"
    # /etc/passwd the last modification time
    pwdfile="$(cat /etc/passwd)"
    Modify=$(stat /etc/passwd | grep Modify | tr '.' ' ' | awk '{print $2,$3}')
    echo ""
    echo "A privileged user"
    echo "-----------------"
    RootUser=""
    for user in $(echo "$pwdfile" | awk -F: '{print $1}');do
        if [ $(id -u $user) -eq 0 ];then
            echo "$user"
            RootUser="$RootUser,$user"
        fi
    done
    echo ""
    echo "User List"
    echo "--------"
    USERs=0
    echo "$(
    echo "UserName UID GID HOME SHELL LasttimeLogin"
    for shell in $(grep -v "/sbin/nologin" /etc/shells);do
        for username in $(grep "$shell" /etc/passwd| awk -F: '{print $1}');do
            userLastLogin="$(getUserLastLogin $username)"
            echo "$pwdfile" | grep -w "$username" |grep -w "$shell"| awk -F: -v lastlogin="$(echo "$userLastLogin" | tr ' ' '_')" '{print $1,$3,$4,$6,$7,lastlogin}'
        done
        let USERs=USERs+$(echo "$pwdfile" | grep "$shell"| wc -l)
    done
    )" | column -t
    echo ""
    echo "Null Password User"
    echo "------------------"
    USEREmptyPassword=""
    for shell in $(grep -v "/sbin/nologin" /etc/shells);do
            for user in $(echo "$pwdfile" | grep "$shell" | cut -d: -f1);do
            r=$(awk -F: '$2=="!!"{print $1}' /etc/shadow | grep -w $user)
            if [ ! -z $r ];then
                echo $r
                USEREmptyPassword="$USEREmptyPassword,"$r
            fi
        done    
    done
    echo ""
    echo "The Same UID User"
    echo "----------------"
    USERTheSameUID=""
    UIDs=$(cut -d: -f3 /etc/passwd | sort | uniq -c | awk '$1>1{print $2}')
    for uid in $UIDs;do
        echo -n "$uid";
        USERTheSameUID="$uid"
        r=$(awk -F: 'ORS="";$3=='"$uid"'{print ":",$1}' /etc/passwd)
        echo "$r"
        echo ""
        USERTheSameUID="$USERTheSameUID $r,"
    done
    # report information
    report_USERs="$USERs"    #用户
    report_USEREmptyPassword=$(echo $USEREmptyPassword | sed 's/^,//') 
    report_USERTheSameUID=$(echo $USERTheSameUID | sed 's/,$//') 
    report_RootUser=$(echo $RootUser | sed 's/^,//')    #特权用户
}

 getInstalledStatus(){
    echo ""
    echo "############################ Software Check ############################"
    rpm -qa --last | head | column -t 
}

 getProcessStatus(){
    echo ""
    echo "############################ Process Check ############################"
    if [ $(ps -ef | grep defunct | grep -v grep | wc -l) -ge 1 ];then
        echo ""
        echo "zombie process";
        echo "--------"
        ps -ef | head -n1
        ps -ef | grep defunct | grep -v grep
    fi
    echo ""
    echo "Merory Usage TOP10"
    echo "-------------"
    echo -e "PID %MEM RSS COMMAND
    $(ps aux | awk '{print $2, $4, $6, $11}' | sort -k3rn | head -n 10 )"| column -t 
    echo ""
    echo "CPU Usage TOP10"
    echo "------------"
    top b -n1 | head -17 | tail -11
}

 getSyslogStatus(){
    echo ""
    echo "############################ Syslog Check ##########################"
    echo "Service Status：$(getState rsyslog)"
    echo ""
    echo "/etc/rsyslog.conf"
    echo "-----------------"
    cat /etc/rsyslog.conf 2>/dev/null | grep -v "^#" | grep -v "^\\$" | sed '/^$/d'  | column -t
}

 getFirewallStatus(){
    echo ""
    echo "############################ Firewall Check ##########################"
    # Firewall Status/Poilcy
    if [[ $OS_Version < 7 ]];then
        /etc/init.d/iptables status >/dev/null  2>&1
        status=$?
        if [ $status -eq 0 ];then
                s="active"
        elif [ $status -eq 3 ];then
                s="inactive"
        elif [ $status -eq 4 ];then
                s="permission denied"
        else
                s="unknown"
        fi
    else
        s="$(getState iptables)"
    fi
    echo "iptables: $s"
    echo ""
    echo "/etc/sysconfig/iptables"
    echo "-----------------------"
    cat /etc/sysconfig/iptables 2>/dev/null
}

 getState(){
    if [[ $OS_Version < 7 ]];then
        if [ -e "/etc/init.d/$1" ];then
            if [ `/etc/init.d/$1 status 2>/dev/null | grep -E "is running|正在运行" | wc -l` -ge 1 ];then
                r="active"
            else
                r="inactive"
            fi
        else
            r="unknown"
        fi
    else
        #CentOS 7+
        r="$(systemctl is-active $1 2>&1)"
    fi
    echo "$r"
}

 getSSHStatus(){
    #SSHD Service Status,Configure
    echo ""
    echo "############################ SSH Check #############################"
    # Check the trusted host
    pwdfile="$(cat /etc/passwd)"
    echo "Service Status：$(getState sshd)"
    Protocol_Version=$(cat /etc/ssh/sshd_config | grep Protocol | awk '{print $2}')
    echo "SSH Protocol Version：$Protocol_Version"
    echo ""
    echo "Trusted Host"
    echo "------------"
    authorized=0
    for user in $(echo "$pwdfile" | grep /bin/bash | awk -F: '{print $1}');do
        authorize_file=$(echo "$pwdfile" | grep -w $user | awk -F: '{printf $6"/.ssh/authorized_keys"}')
        authorized_host=$(cat $authorize_file 2>/dev/null | awk '{print $3}' | tr '\n' ',' | sed 's/,$//')
        if [ ! -z $authorized_host ];then
            echo "$user authorization \"$authorized_host\" Password-less access"
        fi
        let authorized=authorized+$(cat $authorize_file 2>/dev/null | awk '{print $3}'|wc -l)
    done


    echo ""
    echo "Whether to allow ROOT remote login"
    echo "----------------------------------"
    config=$(cat /etc/ssh/sshd_config | grep PermitRootLogin)
    firstChar=${config:0:1}
    if [ $firstChar == "#" ];then
        PermitRootLogin="yes"  #The default is to allow ROOT remote login
    else
        PermitRootLogin=$(echo $config | awk '{print $2}')
    fi
    echo "PermitRootLogin $PermitRootLogin"


    echo ""
    echo "/etc/ssh/sshd_config"
    echo "--------------------"
    cat /etc/ssh/sshd_config | grep -v "^#" | sed '/^$/d'
}

 check(){
    getSystemStatus
    getCpuStatus
    getMemStatus
    getDiskStatus
    getNetworkStatus
    getListenStatus
    getProcessStatus
    getServiceStatus
    getCronStatus
    getUserStatus
    getFirewallStatus
    getSyslogStatus
    getInstalledStatus
}

check > $RESULTFILE
echo -e "Check the result：\e[31m$RESULTFILE\e[0m"
