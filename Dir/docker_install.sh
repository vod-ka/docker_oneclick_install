#!/bin/bash
# @Author: Aliao  
# @Repository: https://github.com/vod-ka/docker_oneclick_install   
# @Date: 2021-01-20 21:57:23  
# @Last Modified by:   Aliao  
# @Last Modified time: 2021-01-21 18:08:40

A=$(uname -r | cut -d "." -f1)
SCRIPT="docker_install.sh"

Green(){
    echo -e "\033[32;01m$1\033[0m"
}

Red(){
    echo -e "\033[31;01m$1\033[0m"
}

Blue(){
    echo -e "\033[34;01m$1\033[0m"
}

CheckVersion(){
    if [ "$A" -ge 3 ]
    then
        DockerInstall
    else
        Red "内核版本低于3.10,请升级内核版本"
    fi
}

#检测系统
check_os(){
    osver=$(sed -n '/^ID=/p' /etc/os-release | sed 's/ID=//;s/"//;s/"//')
    if [ "$osver" = centos ]
    then
        Blue "当前系统发行版本为：$osver"
        Action="yum"
    elif [ "$osver" = debian ]
    then
        Blue "当前系统发行版本为：$osver"
        Action="apt-get"
        exit 1
    else
        Red "当前系统发行版本为：$osver,当前脚本不支持"
        exit 1
    fi
}

DockerInstall(){
    if [ "$osver" = centos ]
    then
        yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate  docker-engine > /dev/null
        rm -rf /var/lib/docker > /dev/null
        yum install -y yum-utils
        yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        yum -y install docker-ce docker-ce-cli containerd.io
    elif [ "$osver" = debian ]
    then
        apt-get remove docker docker-engine docker.io containerd runc > /dev/null
        rm -rf /var/lib/docker > /dev/null
        apt-get update && apt-get install apt-transport-https ca-certificates curl gnupg lsb-release
        curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
        $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
        apt-get update && apt-get install docker-ce docker-ce-cli containerd.io
    else
        Red "脚本不支持当前系统！"
    fi    
    systemctl enable docker > /dev/null
    systemctl start docker
    Green "docker 安装成功"
    Green ".....10秒后继续"
    sleep 3
    Green ".........."
    sleep 3
    Green "..............."
    sleep 3
    Green "....................."
    sleep 1
}

STARTDocker(){
    systemctl start docker
}

STOPDocker(){
    systemctl stop docker
}

RELOADDocker(){
    systemctl reload docker
}

TESTDocker(){
    docker run hello-world
    sleep 5
}

REMOVEDocker(){
    $Action remove -y docker-ce docker-ce-cli containerd.io
    rm -rf /var/lib/{docker,containerd}
    find / -name docker -exec rm -rf {} \;
    Green "----------------------------------卸载docker完成"
    find / -name $SCRIPT -exec rm -f {} \;
}

STARTMenu(){
    clear
    Red "#===============================================================================#"
    Red "#                                                                               #"
    Red "#          @Name: docker_oneclick_install_script                                #"
    Red "#          @Author: Aliao                                                       #"
    Red "#          @Repository: https://github.com/vod-ka/docker_oneclick_install       #"
    Red "#                                                                               #"
    Red "#===============================================================================#"
    echo 
    echo 
    Green "1，安装docker"
    Blue "--------------------------"
    Green "2，启动docker"
    Blue "--------------------------"
    Green "3，停止docker"
    Blue "--------------------------"
    Green "4，重启docker"
    Blue "--------------------------"
    Green "5，检测docker"
    Blue "--------------------------"
    Green "6，卸载docker"
    Blue "--------------------------"
    Green "0，exit"
    Blue "--------------------------"
    read -p "输入数字执行: " MUN
    case "$MUN" in
        1)
        CheckVersion
        check_os
        DockerInstall
        STARTMenu
        ;;
        2)
        STARTDocker
        STARTMenu
        ;;
        3)
        STOPDocker
        STARTMenu
        ;;
        4)
        RELOADDocker
        STARTMenu
        ;;
        5)
        TESTDocker
        STARTMenu
        ;;
        6)
        REMOVEDocker
        ;;
        0)
        exit 1
        ;;
    esac
}

STARTMenu