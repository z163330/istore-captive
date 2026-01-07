#!/bin/sh
CODE_DB=/etc/captive/codes.json
mkdir -p /etc/captive
[ -f $CODE_DB ] || echo '{}' >$CODE_DB
gen_code(){ tr -dc A-HJKMNP-TV-Z2-9 </dev/urandom | head -c 8; }
[ $# -lt 2 ] && echo "Usage: cp_codegen <数量> <分钟> [备注]" && exit 1
count=$1; mins=$2; note=${3:-""}
for i in $(seq 1 $count); do
  code=$(gen_code)
  jq --arg c "$code" --arg m "$mins" --arg n "$note" \
     '.[$c] = {mins:($m|tonumber),note:$n,used:0}' $CODE_DB >$CODE_DB.tmp
  mv $CODE_DB.tmp $CODE_DB
  echo $code
done