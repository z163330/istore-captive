#!/bin/sh
CODE_DB=/etc/captive/codes.json
RUN=/var/run/cp_daemon.pid
[ -f $RUN ] && exit 0
echo $$ >$RUN
[ -f /tmp/cp_timer.json ] || echo '{}' >/tmp/cp_timer.json
while :; do
  # 1. 新设备加入 guest
  for ip in $(ip -4 neigh | grep 192.168.99 | grep REACHABLE | awk '{print $1}'); do
    nft get element inet cp cp_guest { $ip } >/dev/null 2>&1 && continue
    nft get element inet cp cp_allow { $ip } >/dev/null 2>&1 && continue
    nft add element inet cp cp_guest { $ip }
  done
  # 2. 已 allow 的扣时 & 踢人
  for ip in $(nft list set inet cp cp_allow | grep elements | sed 's/.*{ //;s/ }.*//'); do
    left=$(jq -r --arg ip "$ip" '.[$ip].left // 0' /tmp/cp_timer.json)
    [ "$left" -le 0 ] && {
      nft delete element inet cp cp_allow { $ip }
      nft add element inet cp cp_guest { $ip timeout 30s }
      logger -t cp_daemon "kick $ip (time up)"
      continue
    }
    left=$((left-60))
    jq --arg ip "$ip" '.[$ip].left = '$left /tmp/cp_timer.json > /tmp/cp_timer.json.tmp
    mv /tmp/cp_timer.json.tmp /tmp/cp_timer.json
  done
  sleep 60
done