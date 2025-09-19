#! /bin/bash

echo "Env Installation for Ubuntu 22.04 LTS (jammy)"
echo -e "\\e[34mBash by FpHe\\e[0m"

if [ "$(id -u)" -ne 0 ]
then

echo "请以 root 权限运行！ (sudo $0)"
exit 1

fi

# 配置中文 locale
sudo apt-get install -y locales language-pack-zh-hans
locale-gen zh_CN.UTF-8
update-locale LANG=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8

# 换源
read -p "更改 apt 为清华源?(Y/n)" SELECT
if [ SELECT = "Y" ]
then
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
cat > /etc/apt/sources.list << EOF
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
# 以下安全更新软件源包含了官方源与镜像站配置，如有需要可自行修改注释切换
deb http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse
# deb-src http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse

# 预发布软件源，不建议启用
# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse
# # deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse
EOF

echo -e "\\e[1;32m apt 原始配置已备份至: /etc/apt/sources.list.bak\\e[0m"
fi

# 更新软件包
sudo apt-get update -y && apt-get upgrade -y
echo -e "\\e[1;32m软件包更新成功\\e[0m"

# 软件
echo "安装 git docker py3 pip3 curl"
sudo apt-get install -y git docker.io python3 python3-pip curl openssh-server

# Docker 自启动
sudo systemctl start docker && sudo systemctl enable docker

# ssh 配置
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
echo -e "\\e[1;32m ssh 原始配置已备份至: /etc/ssh/sshd_config.bak\\e[0m"
# 开防火墙
sudo ufw allow ssh
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
# 启用公钥
sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# ssh 超时时间 15 分钟
echo "ClientAliveInterval 900" >> /etc/ssh/sshd_config
echo "ClientAliveCountMax 0" >> /etc/ssh/sshd_config

systemctl restart sshd

echo "所有环境配置已完成！"
echo "建议重启系统以应用所有设置：sudo reboot"