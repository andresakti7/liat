#!/bin/bash
red() { echo -e "\\033[32;1m${*}\\033[0m"; }
clear
echo -n > /var/log/xray/access.log
echo -n > /var/log/nginx/access.log
##----- Auto Remove Vmess
data=($(cat /etc/xray/config.json | grep '^###' | cut -d ' ' -f 2 | sort | uniq))
now=$(date +"%Y-%m-%d")
for user in "${data[@]}"; do
    exp=$(grep -w "^### $user" "/etc/xray/config.json" | cut -d ' ' -f 3 | sort | uniq)
    d1=$(date -d "$exp" +%s)
    d2=$(date -d "$now" +%s)
    exp2=$(((d1 - d2) / 86400))
    exp4=$(cat /etc/vmess/.vmess.db | grep "${user}" | cut -d ' ' -f 3)
    uuid=$(cat /etc/vmess/.vmess.db | grep "${user}" | cut -d ' ' -f 4)
    if [[ "$exp2" -le "0" ]]; then
        echo -e "### $user $exp4 $uuid" >> /etc/vmess/.userexp.db
        sed -i "/^### $user $exp/,/^},{/d" /etc/xray/config.json
        sed -i "/^### $user $exp/,/^},{/d" /etc/xray/config.json
        sed -i "/\b${user}\b/d" /etc/vmess/.vmess.db
        sed -i "/\b${user}\b/d" /etc/vmess/.vmess1.db
        rm -f /etc/vmess/$user
        rm -f /etc/vmess/limit-ip/$user
        rm -f /etc/limit/vmess/$user
    fi
done

#----- Auto Remove Vless
data=($(cat /etc/xray/config.json | grep '^#&' | cut -d ' ' -f 2 | sort | uniq))
now=$(date +"%Y-%m-%d")
for user in "${data[@]}"; do
    exp=$(grep -w "^#& $user" "/etc/xray/config.json" | cut -d ' ' -f 3 | sort | uniq)
    d1=$(date -d "$exp" +%s)
    d2=$(date -d "$now" +%s)
    exp2=$(((d1 - d2) / 86400))
    exp4=$(cat /etc/vless/.vless.db | grep "${user}" | cut -d ' ' -f 3)
    uuid=$(cat /etc/vless/.vless.db | grep "${user}" | cut -d ' ' -f 4)
    if [[ "$exp2" -le "0" ]]; then
        echo -e "### $user $exp4 $uuid" >> /etc/vless/.userexp.db
        sed -i "/^#& $user $exp/,/^},{/d" /etc/xray/config.json
        sed -i "/^#& $user $exp/,/^},{/d" /etc/xray/config.json
        sed -i "/\b${user}\b/d" /etc/vless/.vless.db
        sed -i "/\b${user}\b/d" /etc/vless/.vless1.db
        rm -f /etc/vless/$user
        rm -f /etc/vless/limit-ip/$user
        rm -f /etc/limit/vless/$user
    fi
done

#----- Auto Remove Trojan
data=($(cat /etc/xray/config.json | grep '^#!' | cut -d ' ' -f 2 | sort | uniq))
now=$(date +"%Y-%m-%d")
for user in "${data[@]}"; do
    exp=$(grep -w "^#! $user" "/etc/xray/config.json" | cut -d ' ' -f 3 | sort | uniq)
    d1=$(date -d "$exp" +%s)
    d2=$(date -d "$now" +%s)
    exp2=$(((d1 - d2) / 86400))
    exp4=$(cat /etc/trojan/.trojan.db | grep "${user}" | cut -d ' ' -f 3)
    uuid=$(cat /etc/trojan/.trojan.db | grep "${user}" | cut -d ' ' -f 4)
    if [[ "$exp2" -le "0" ]]; then
        echo -e "### $user $exp4 $uuid" >> /etc/trojan/.userexp.db
        sed -i "/^#! $user $exp/,/^},{/d" /etc/xray/config.json
        sed -i "/^#! $user $exp/,/^},{/d" /etc/xray/config.json
        sed -i "/\b${user}\b/d" /etc/trojan/.trojan.db
        sed -i "/\b${user}\b/d" /etc/trojan/.trojan1.db
        rm -f /etc/trojan/$user
        rm -f /etc/trojan/limit-ip/$user
        rm -f /etc/limit/trojan/$user
    fi
done

#----- Auto Remove SS
data=($(cat /etc/xray/config.json | grep '^#!#' | cut -d ' ' -f 2 | sort | uniq))
now=$(date +"%Y-%m-%d")
for user in "${data[@]}"; do
    exp=$(grep -w "^#!# $user" "/etc/xray/config.json" | cut -d ' ' -f 3 | sort | uniq)
    d1=$(date -d "$exp" +%s)
    d2=$(date -d "$now" +%s)
    exp2=$(((d1 - d2) / 86400))
    if [[ "$exp2" -le "0" ]]; then
        sed -i "/^#!# $user $exp/,/^},{/d" /etc/xray/config.json
        sed -i "/^#!# $user $exp/,/^},{/d" /etc/xray/config.json
        sed -i "/\b${user}\b/d" /etc/shadowsocks/.shadowsocks.db
        rm -f /etc/shadowsocks/$user
        rm -f /etc/limit/shadowsocks
    fi
done
systemctl restart xray

##------ Auto Remove SSH
hariini=$(date +%d-%m-%Y)
cat /etc/shadow | cut -d: -f1,8 | sed /:$/d >/tmp/expirelist.txt
totalaccounts=$(cat /tmp/expirelist.txt | wc -l)
for ((i = 1; i <= $totalaccounts; i++)); do
    tuserval=$(head -n $i /tmp/expirelist.txt | tail -n 1)
    username=$(echo $tuserval | cut -f1 -d:)
    userexp=$(echo $tuserval | cut -f2 -d:)
    userexpireinseconds=$(($userexp * 86400))
    tglexp=$(date -d @$userexpireinseconds)
    tgl=$(echo $tglexp | awk -F" " '{print $3}')
    exp4=$(cat /etc/ssh/.ssh.db | grep "${user}" | cut -d ' ' -f 4)
    pwd=$(cat /etc/ssh/.ssh.db | grep "${user}" | cut -d ' ' -f 3)
    while [ ${#tgl} -lt 2 ]; do
        tgl="0"$tgl
    done
    while [ ${#username} -lt 15 ]; do
        username=$username" "
    done
    bulantahun=$(echo $tglexp | awk -F" " '{print $2,$6}')
    todaystime=$(date +%s)
    if [ $userexpireinseconds -ge $todaystime ]; then
        :
    else
        userdel --force $username
        echo -e ### $username $exp4 $pwd >> /etc/ssh/.userexp.db
        sed -i "/\b${username}\b/d" /etc/ssh/.ssh.db
        sed -i "/\b${username}\b/d" /etc/ssh/.ssh1.db
    fi
done
systemctl reload ssh
