#!/bin/bash

ptokens="/etc/nginx/conf.d/tokens.txt"

path1="/opt/difftokens/token1"

path2="/opt/difftokens/token2"

LOG="/opt/difftokens/log.txt"

mysql_slave="ip_address"

logfunc(){
        message="$(date +"%y-%m-%d %T")"
    echo $message >> $LOG
}

changep(){
        sed 's/^/\"\~/; s/$/\" 1\;/' $path1 1>$ptokens
#       cat $path1 1>/opt/difftokens/tokens.txt
}

mysql -h $mysql_slave -uUSER -pPASSWORD -e 'select api_token from table.users;' | grep -v api_token 1> $path1

cat $ptokens | awk '{print $1}' | sed s/\"~// | sed s/\"// > $path2

if cmp -s $path1 $path2
then
        logfunc
        echo "not different" >> $LOG
else
        logfunc
        echo "different" >> $LOG
        changep
        sudo systemctl reload nginx
fi
