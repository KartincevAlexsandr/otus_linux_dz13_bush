#!/bin/bash


function line()
{
    echo "========================================================================"
}

function findinaccess()
{
    unset listdata
    local listdata
    declare -A listdata
    for key in `less /var/log/nginx/access.log | cut -d' ' -f$1 | sort`
    do
        if [ -v listdata[$key] ]
        then
            listdata[$key]=$(( ${listdata[$key]}+1 ))
        else
            listdata[$key]=1
        fi
    done

    echo '('
    for key in  "${!listdata[@]}" ; do
        echo "['$key']='${listdata[$key]}'"
    done
    echo ')'
}

function findurl()
{
    unset listdata
    local listdata
    declare -A listdata
    for key in `less /var/log/nginx/access.log | grep GET | awk -F' ' '{print $7}'| sort`
    do
        if [ -v listdata[$key] ]
        then
            listdata[$key]=$(( ${listdata[$key]}+1 ))
        else
            listdata[$key]=1
        fi
    done

    echo '('
    for key in  "${!listdata[@]}" ; do
        echo "['$key']='${listdata[$key]}'"
    done
    echo ')'
}




echo "Список IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов"
declare -A ipslist="$(findinaccess 1)"
for key in "${!ipslist[@]}"; do
    echo "C ip адреса $key было ${ipslist[$key]} подключений"
done
line

echo "Список запрашиваемых URL (с наибольшим кол-вом запросов) с указанием кол-ва запросов"
myip=`ip addr| grep enp | grep inet | awk -F' ' '{print $2}'`
declare -A urls="$(findurl)"
for key in "${!urls[@]}"; do
    echo "С URL http://$myip$key было ${urls[$key]} запросов"
done
line


#Ошибки веб-сервера/приложения c момента последнего запуска
echo " Ошибки веб-сервера/приложения c момента последнего запуска"
journalctl | grep nginx | grep error
line

#Список всех кодов HTTP ответа с указанием их кол-ва с момента последнего запуска скрипта

echo "Список всех кодов HTTP ответа с указанием их кол-ва с момента последнего запуска скрипта:"
declare -A codelist="$(findinaccess 9)"
for key in "${!codelist[@]}"; do
    echo "C кодом HTTP $key было ${codelist[$key]} ответов"
done
