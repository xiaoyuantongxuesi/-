#!/bin/bash
#Author : Izo
#Version: 1.0

##进入虚拟机配置IP，主机名
Virtual(){
expect << ETF
spawn virsh console rh7_node$a 
expect "换码符" {send "\r"}
expect "login:" {send "root\r"}
expect "密码：" {send "123456\r"}
expect "#" {send "hostnamectl set-hostname host$a\r"}
expect "#" {send "nmcli connection modify eth0 ipv4.method manual ipv4.addresses 192.168.4.$num/24 connection.autoconnect yes\r"}
expect "#" {send "nmcli connection up eth0\r"}
ETF
}
##部署YUM仓库
YUM(){
expect << EOF
spawn ssh root@192.168.4.$num
expect "yes" {send "yes\r"}
expect "pass" {send "123456\r"}
expect "#" {send "rm  -rf  /etc/yum.repos.d/*.repo\r"}
expect "#" {send "yum-config-manager  --add http://192.168.4.254/rhel7\r"}
expect "#" {send "sleep 2\r"}
expect "#" {send "echo gpgcheck=0 >>/etc/yum.repos.d/192.168.4.254_rhel7.repo\r"}
expect "#" {send "sed -i '3a gpgcheck=0' /etc/yum.repos.d/192.168.4.254_rhel7.repo\r"}
EOF
}
##部署MYSQL数据库服务器
RPM(){
expect << EOF
spawn scp /var/opt/mysql-5.7.17.tar /root/fast.sh root@$ip:/opt/
expect "pass" {send "123456\r"}
EOF
}
Mysql(){
expect << EOF
spawn ssh root@$ip
expect "pass" {send "123456\r"}
expect "#" {send "cd /opt/  \r"}
expect "#" {send "tar -xf /opt/mysql-5.7.17.tar\r"}
expect "#" {send "rpm -e  --nodeps  mariadb-libs\r"}
expect "#" {send "yum -y install perl-JSON\r"}
expect "]#" {send "sleep 2\r"}
expect "]#" {send "rpm -Uvh mysql-community-* \r"}
expect "]#" {send "sleep 2\r"}
EOF
}
##新建虚拟机，开机
cha(){
virsh start rh7_node$a
}

NEW(){
read -p "请输入想要创建虚拟机的编号（1-99）：" num  
echo -n "请再确认编号：" 
clone-vm7   &> /dev/null
[ $num -gt 9 ] && a=$num || a=0$num
#virsh start rh7_node$a  &> /dev/null
cha  &> /dev/null
echo -n "创建完毕，系统启动中"  
for aa in {1..15};do
	echo -n '#' 
	sleep 1
done
echo 
}

echo -e "\t\033[42m   欢迎使用一键部署虚拟机环境系统v1.10！！   \033[0m"
while :
do
	echo -e "请选择您需要的操作（或者按其他键退出系统）："
	echo -e "\t1.创建一台虚拟机环境"
	echo -e "\t2.在一台虚拟机上部署Mysql数据库服务"
	read -n1  option

	case  $option in
	1)
		NEW 
		Virtual &> /dev/null
		YUM &> /dev/null 
		#sed -i 's/ck=1/ck=0/'  /etc/yum.conf
		#echo gpgcheck=0 >>/etc/yum.repos.d/192.168.4.254_rhel7
		echo -e "\t\033[42m Host$num 部署完毕\033[0m "
		;;
	2)
		read -p "请输入需要部署的主机IP：" ip
		RPM
		sleep 3
		#Mysql 
		echo "Mysql服务器部署完毕！" 
		;;
	*)
		exit ;;
	esac
done
