#!/bin/bash

blue(){
    echo -e "\033[34m\033[01m$1\033[0m"
}
green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}
red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}
#!/bin/bash
if [ `whoami` != "root" ]; then
  red "当前为非root用户,请切换到root用户再运行"
  exit 1
fi

# 笨笨的检测方法
if [[ $(command -v apt-get) ]]; then
  cmd="apt-get"
elif [[ $(command -v yum) ]]; then
  cmd="yum"
else
  green "哈哈……这个辣鸡脚本不支持你的系统。 (-_-)"
  green "备注: 仅支持 Ubuntu 16+ / Debian 8+ / CentOS 7+ 系统" && exit 1
fi


function first(){

$cmd update -y
$cmd install unzip curl -y

checkDocker=$(which docker)
checkDockerCompose=$(which docker-compose)
if [ "$checkDocker" == "" ]; then
  green "docker未安装，开始安装docker"
  curl -sSL https://get.docker.com/ | sh
  systemctl start docker
  systemctl enable docker.service
  green "恭喜docker结束！！"
fi
if [ "$checkDockerCompose" == "" ]; then
  green "docker-compose未安装，开始安装docker-compos"
  curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
  green "恭喜docker-compose结束！！"
fi

rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
cd /root
if [[ -e "v2ray_tls_tcp_trojan_docker.zip" ]]; then
unzip -o v2ray_tls_tcp_trojan_docker.zip
[[ -e "/root/v2ray/config.json" ]] && rm /root/v2ray/config.json
else
wget -N --no-check-certificate https://github.com/hqhyco/v2ray_tls_tcp_trojan_docker/raw/master/v2ray_tls_tcp_trojan_docker.zip
unzip -o v2ray_tls_tcp_trojan_docker.zip
fi


}


function install_vmess(){

read -p "请输入你的域名(eg: abc.com): " domainName
if [ "$domainName" = "" ];then 
  echo "bye~"
        exit
else
  echo "你输入的域名是: "$domainName
  sed -i "s/abc.com/$domainName/g" ./tls-shunt-proxy/config.yaml
fi
  read -p "请输入trojan的密码(eg: 123456): " trojan_password
  sed -i "s/123456/$trojan_password/g" ./trojan/config.json


sys=$(uname)
if [ "$sys" == "Linux" ]; then
  uuid=$(cat /proc/sys/kernel/random/uuid)
elif [ "$sys" == "Darwin" ]; then
  uuid=$(echo $(uuidgen) | tr '[A-Z]' '[a-z]')
else
  uuid=$(od -x /dev/urandom | head -1 | awk '{OFS="-"; print $2$3,$4,$5,$6,$7$8$9}')
fi

sed -i "s/98bc7998-8e06-4193-84e2-38f2e10ee763/$uuid/g" ./v2ray/config-vmess.json
cp ./v2ray/config-vmess.json ./v2ray/config.json
docker-compose up -d
chmod 666 /root/v2ray/sock/v2ray.sock
echo "-----------------------------------------------"
echo "V2ray-vmess Configuration:"
echo "Server:" $domainName
echo "Port: 443"
echo "UUID:" $uuid
echo "AlterId: 0"
echo "level: 0"
echo "security: auto"
echo "network: tcp" 
echo "type: none" 
echo "host: " 
echo "path: " 
echo "TLS: True"
echo "allowInsecure: false"
echo "-----------------------------------------------"
echo "Trojan Configuration:"
echo "Server:" $domainName
echo "Port: 443"
echo "Password:" $trojan_password
echo "-----------------------------------------------"
echo "Enjoy it!"

cat <<-EOF >./info.txt
    -----------------------------------------------
    V2ray-vmess Configuration:
    Server: $domainName
    Port: 443
    UUID: $uuid
    AlterId: 0
    level: 0
    security: auto
    network: tcp
    type: none
    host: 
    path: 
    TLS: True
    allowInsecure: false
    -----------------------------------------------
    Trojan Configuration:
    Server: $domainName
    Port: 443
    Password: $trojan_password
    -----------------------------------------------
EOF
}


function install_vless(){

read -p "请输入你的域名(eg: abc.com): " domainName
if [ "$domainName" = "" ];then 
  echo "bye~"
        exit
else
  echo "你输入的域名是: "$domainName
  sed -i "s/abc.com/$domainName/g" ./tls-shunt-proxy/config.yaml
fi
  read -p "请输入trojan的密码(eg: 123456): " trojan_password
  sed -i "s/123456/$trojan_password/g" ./trojan/config.json


sys=$(uname)
if [ "$sys" == "Linux" ]; then
  uuid=$(cat /proc/sys/kernel/random/uuid)
elif [ "$sys" == "Darwin" ]; then
  uuid=$(echo $(uuidgen) | tr '[A-Z]' '[a-z]')
else
  uuid=$(od -x /dev/urandom | head -1 | awk '{OFS="-"; print $2$3,$4,$5,$6,$7$8$9}')
fi

sed -i "s/98bc7998-8e06-4193-84e2-38f2e10ee763/$uuid/g" ./v2ray/config-vless.json
cp ./v2ray/config-vless.json ./v2ray/config.json
docker-compose up -d
chmod 666 /root/v2ray/sock/v2ray.sock
echo "-----------------------------------------------"
echo "V2ray-vless Configuration:"
echo "Server:" $domainName
echo "Port: 443"
echo "UUID:" $uuid
echo "level: 1"
echo "decryption: none"
echo "network: tcp" 
echo "type: none" 
echo "host: " 
echo "path: " 
echo "TLS: True"
echo "allowInsecure: false"
echo "-----------------------------------------------"
echo "Trojan Configuration:"
echo "Server:" $domainName
echo "Port: 443"
echo "Password:" $trojan_password
echo "-----------------------------------------------"
echo "Enjoy it!"

cat <<-EOF >./info.txt
    -----------------------------------------------
    V2ray-vless Configuration:
    Server: $domainName
    Port: 443
    UUID: $uuid
    level: 1
    decryption: none
    network: tcp
    type: none
    host: 
    path: 
    TLS: True
    allowInsecure: false
    -----------------------------------------------
    Trojan Configuration:
    Server: $domainName
    Port: 443
    Password: $trojan_password
    -----------------------------------------------
EOF
}


start_menu(){
    clear
    green " ===================================="
    green " 介绍：tls分流器+v2ray+trojan+网页伪装docker版 "
    green " 系统：Ubuntu 16+/Debian 8+/CentOS 7+"
    green " centos未测试，应该也可以"
    green " ===================================="
    echo
    green " 1. v2ray+vless+tcp+tls+trojan+网页伪装"
    green " 2. v2ray+vmess+tcp+tls+trojan+网页伪装"
    blue " 0. 退出脚本"
    echo
    read -p "请输入数字:" num
    case "$num" in
    1)
    first
    install_vless
    ;;
    2)
    first
    install_vmess
    ;;
    0)
    exit 1
    ;;
    *)
    clear
    red "请输入正确数字"
    sleep 1s
    start_menu
    ;;
    esac
}


start_menu