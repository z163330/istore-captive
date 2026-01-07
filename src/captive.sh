#!/bin/sh
CODE_DB=/etc/captive/codes.json
TIMER=/tmp/cp_timer.json
NFT_TABLE=inet cp
[ -f $TIMER ] || echo '{}' >$TIMER

# 新设备加入 guest set
for ip in $(ip -4 neigh | grep 192.168.99 | grep REACHABLE | awk '{print $1}'); do
  nft get element $NFT_TABLE cp_guest { $ip } &>/dev/null && continue
  nft get element $NFT_TABLE cp_allow { $ip } &>/dev/null && continue
  nft add element $NFT_TABLE cp_guest { $ip }
done

# 对已 allow 的 IP 扣时 & 踢人
for ip in $(nft list set $NFT_TABLE cp_allow | grep elements | sed 's/.*{ //;s/ }.*//'); do
  left=$(jq -r --arg ip "$ip" '.[$ip].left // 0' $TIMER)
  [ "$left" -le 0 ] && {
    nft delete element $NFT_TABLE cp_allow { $ip }
    nft add element $NFT_TABLE cp_guest { $ip timeout 30s }
    logger -t captive "kick $ip (time up)"
    continue
  }
  left=$((left-60))
  jq --arg ip "$ip" '.[$ip].left = '$left $TIMER > $TIMER.tmp && mv $TIMER.tmp $TIMER
done