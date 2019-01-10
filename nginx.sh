#!/bin/bash

#想写个全自动安装脚本
#1. Nginx简介
#Nginx (发音为[engine x])专为性能优化而开发，其最知名的优点是它的稳定性和低系统资源消耗，以及对并#发连接的高处理能力(单台物理服务器可支持30000～50000个并发连接)， 是一个高性能的 HTTP 和反向代理服务器，也是一个IMAP/POP3/SMTP 代理服
#2. 安装准备
#2.1 gcc安装   
#安装 nginx 需要先将官网下载的源码进行编译，编译依赖 gcc 环境，如果没有 gcc 环境，则需要安装
yum -y install gcc-c++
#2.2 pcre安装
#PCRE(Perl Compatible Regular Expressions) 是一个Perl库，包括 perl 兼容的正则表达式库。nginx 的 http 模块使用 pcre 来解析正则表达式，所以需要在 linux 上安装 pcre 库，pcre-devel 是使用 pcre 开发的一个二次开发库。nginx也需要此库。
yum -y install  pcre pcre-devel
#2.3 zlib安装
#zlib 库提供了很多种压缩和解压缩的方式， nginx 使用 zlib 对 http 包的内容进行 gzip ，所以需要在 Centos 上安装 zlib 库。
yum -y install zlib zlib-devel
#2.4 OpenSSL安装
#OpenSSL 是一个强大的安全套接字层密码库，囊括主要的密码算法、常用的密钥和证书封装管理功能及 SSL 协议，并提供丰富的应用程序供测试或其它目的使用。nginx 不仅支持 http 协议，还支持 https（即在ssl协议上传输http），所以需要在 Centos 安装 OpenSSL 库
yum -y install openssl openssl-devel

var=`which wget`
if [ $var=="/usr/bin/wget" ];then
    echo "系统中存在wget"
else
    yum -y install wget    
fi

if [ ! -d /usr/local/src ];then
    mkdir -p /usr/local/src
    wget https://nginx.org/download/nginx-1.12.2.tar.gz -P /usr/local/src/
fi

#Nginx版本说明：
#Mainline version：Mainline 是 Nginx 目前主力在做的版本，可以说是开发版
#Stable version：最新稳定版，生产环境上建议使用的版本
#Legacy versions：遗留的老版本的稳定版

cd /usr/local/src
tar -zxvf nginx-1.12.2.tar.gz
#passwd nginx 
#3.4 安装配置
#3.4.1 新建nginx用户和组
groupadd nginx
useradd -g nginx -d /home/nginx nginx
#3.4.2第三方模块安装(此文件请提前放到文件夹中本文放在/usr/local/src/下)
tar -zxvf nginx-goodies-nginx-sticky-module-ng-08a395c66e42..gz 
mv nginx-goodies-nginx-sticky-module-ng-08a395c66e42 nginx-sticky-1.2.5
#3.4.3 安装
cd nginx-1.12.2
./configure --add-module=/root/nginx-sticky-1.2.5
#指定用户、路径和模块配置（可选）：
#./configure \
#--user=nginx --group=nginx \          #安装的用户组
#--prefix=/usr/local/nginx \           #指定安装路径
#--with-http_stub_status_module \         #监控nginx状态，需在nginx.conf配置
#--with-http_ssl_module \             #支持HTTPS
#--with-http_sub_module \             #支持URL重定向
#--with-http_gzip_static_module          #静态压缩
#--add-module=/root/nginx-sticky-1.2.5           #安装sticky模块
#3.5 编译
make && make install

#3.6 nginx命令全局执行设置
cd /usr/local/nginx/sbin/
ln -s /usr/local/nginx/sbin/nginx /usr/local/bin/nginx

#4. Nginx相关命令
#4.1 版本查看
# nginx  -v
#4.2 查看加载的模块
# nginx -V

#4.3.1 启动
 nginx
#4.3.2 停止
# nginx -s stop
# nginx -s quit
#4.3.3 动态加载
# ngins -s reload
#4.3.4 测试配置文件nginx.conf正确性
 nginx  -t
#nginx: the configuration file /usr/local/nginx/conf/nginx.conf syntax is ok
#nginx: configuration file /usr/local/nginx/conf/nginx.conf test is successful
#nginx -s quit:此方式停止步骤是待nginx进程处理任务完毕进行停止。
#nginx -s stop:此方式相当于先查出nginx进程id再使用kill命令强制杀掉进程。
#nginx -s reload:动态加载，当配置文件nginx.conf有变化时执行该命令动态加载。

#4.4 开机自启动
#编辑/etc/rc.d/rc.local文件，新增一行/usr/local/nginx/sbin/nginx

cd /etc/rc.d
sed -i '13a /usr/local/nginx/sbin/nginx' /etc/rc.d/rc.local 
chmod u+x rc.local


#5. 更改默认端口

#编辑配置文件/usr/local/nginx/conf/nginx.conf，将默认端口80修改为81：
 vim /usr/local/nginx/conf/nginx.conf
#加载配置
 nginx -s reload

#6.1 关闭防火墙

iptables -F
#6.2 访问Nginx
