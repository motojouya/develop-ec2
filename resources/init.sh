#!/bin/bash
set -x

region=$1
userid=$2
username=$3
# password=$4
ssh_port=$5
volume_id=$6

export AWS_DEFAULT_REGION=$region
cd /home/ec2-user
instance_id=$(curl -s 169.254.169.254/latest/meta-data/instance-id)

# install commands
yum update -y
yum install -y nvme-cli
yum install -y jq
yum install -y tmux
yum install -y tree
yum install -y xauth
yum install -y silversearcher-ag

# mount ebs volume
# aws ec2 attach-volume --volume-id vol-$volume_id --instance-id $instance_id --device /dev/xvdb --region $region
# aws ec2 wait volume-in-use --volume-ids vol-$volume_id
device=$(nvme list | grep $volume_id | awk '{print $1}' | xargs)
while [ -z $device ]; do
    sleep 1
    device=$(nvme list | grep $volume_id | awk '{print $1}' | xargs)
done
# until [ -e $device ]; do
#     sleep 1
# done
mkdir /home/$username
# mkfs -t ext4 $device
mount $device /home/$username

# add user
sudo adduser newuser
# useradd -u $userid -d /home/$username -s /bin/bash $username
# gpasswd -a $username sudo
cp -arpf /home/ec2-user/.ssh/authorized_keys /home/$username/.ssh/authorized_keys
chown $username /home/$username
chgrp $username /home/$username
chown -R $username /home/$username/.ssh
chgrp -R $username /home/$username/.ssh
# echo "$username:$password" | chpasswd

# ssh config
curl https://raw.githubusercontent.com/motojouya/develop-ec2/main/resources/sshd_config.tmpl -O
sed -e s/{%port%}/$ssh_port/g sshd_config.tmpl > sshd_config.init
cp sshd_config.init /etc/ssh/sshd_config
systemctl restart sshd

# install nodejs
yum install https://rpm.nodesource.com/pub_20.x/nodistro/repo/nodesource-release-nodistro-1.noarch.rpm -y
yum install nodejs -y --setopt=nodesource-nodejs.module_hotfixes=1
npm install -g npx
npm install -g typescript typescript-language-server

# install docker
amazon-linux-extras install docker
service docker start
systemctl enable docker
usermod -a -G docker ec2-user
usermod -a -G docker $username
docker info
# gpasswd -a $username docker
# systemctl restart docker

# # others
# /home/$username/.fzf/install --bin