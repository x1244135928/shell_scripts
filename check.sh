#!/bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
source /etc/profile

# 使用root运行
[ $(id -u) -gt 0 ] && echo "please use root run the script! " && exit 1

# 系统版本
OS_Version=$(awk '{print $(NF-1)}' /etc/redhat-release)

# 定义脚本存放路径
LOGPATH=/var/log/linux_check.log
[ -d $LOGPATH ] || mkdir -p $LOGPATH
RESULTFILE="$LOGPATH/check-`hostname`-`date +%Y%m%d`"


 CpuStatus(){
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


 MemStatus(){
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

 DiskStatus(){
    echo ""
    echo "############################ Check Disk Status ############################"
    join /tmp/disk /tmp/inode | awk '{print $1,$2,"|",$3,$4,$5,$6,"|",$8,$9,$10,$11,"|",$12}'| column -t
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

 check(){

    CpuStatus
    DiskStatus
    MemStatus
}

check > $RESULTFILE
echo -e "Check the result：\e[31m$RESULTFILE\e[0m"

