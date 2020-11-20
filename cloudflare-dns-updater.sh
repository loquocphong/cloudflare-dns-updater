#!/bin/bash

GetConfig () {
    # CONFIG_VALUE=$(awk -F "=" "/$1/ {print \$2}" config.ini)
    CONFIG_VALUE=$(grep -E -o "$1\s*=\s*([^\$]+)\$" config.ini | grep -E -o "[^[:space:]]+\$")
    echo $CONFIG_VALUE
}

#------------------------------------
# Get current ip address by call api
#------------------------------------
GetMyIP () {
    RESAPI=$(curl -s https://dev.phonglo.com/myip/)
    echo $RESAPI
}

#------------------------------------
# Get type of ip address v4 or v6
#------------------------------------
GetIPVersion () {
    DATACHECK=$(grep -E -o "[^[:digit:]\.]+" <<< $1 )
    # echo $DATACHECK
    if [[ $DATACHECK == '' ]]
    then
        echo "v4"
    else 
        echo "v6"
    fi
}

#------------------------------------
# Get DNS record thought Cloudflare API
# Params:
# $1 - AccessToken
# $2 - ZoneID
# $3 - Record Name
#------------------------------------
GetDNSRecord () {
    RESAPI=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$2/dns_records?name=$3" -H "Authorization: Bearer $1" -H "Content-Type:application/json" )
    echo $RESAPI
}


#------------------------------------
# Update DNS record thought Cloudflare API
#------------------------------------
UpdateDNSRecord () {
    local RECORD_TYPE="A"
    if [[ $6 == 'v6' ]]
    then
        RECORD_TYPE="AAAA"
    fi
    local PUTDATA='{"type":"'$RECORD_TYPE'","name":"'$4'","content":"'$5'","ttl":1,"proxied":true}'
    # echo $PUTDATA
    local RESAPI=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$2/dns_records/$3" -H "Authorization: Bearer $1" -H "Content-Type:application/json" --data "$PUTDATA")
    echo $RESAPI
}

#------------------------------------
# Main Function
#------------------------------------
StartUpdateDNS () {
    # get configs
    AccessToken=$(GetConfig AccessToken)
    ZoneID=$(GetConfig ZoneID)
    DNSRecordName=$(GetConfig DNSRecordName)
    DNSRecordID=$(GetConfig DNSRecordID)
    DNSRecordContent=$(GetConfig DNSRecordContent)

    # Check and update DNSRecordID
    if [[ $DNSRecordID == 'YOUR_DNSRecordID' ]]
    then
        DNSRecord=$(GetDNSRecord $AccessToken $ZoneID $DNSRecordName)
        DNSRecordIDNEW=$(echo $DNSRecord | grep -oE "\"id\":\"[^\"]+" | grep -oE "[^\"]+$")
        #update config
        ResUpdateConfig=$(sed -i.backup 's/'$DNSRecordID'/'$DNSRecordIDNEW'/' config.ini)
        DNSRecordID=$DNSRecordIDNEW
        echo "Update Config: DNSRecordID = $DNSRecordIDNEW"
    fi

    # get current public ip address
    MYIP=$(GetMyIP)
	IPV=$(GetIPVersion $MYIP)
    echo "IPADDRESS: "$MYIP
    echo "IPVersion: "$IPV"\n"

    # update DNS Record IF current IP
    ResUpdate=$(UpdateDNSRecord $AccessToken $ZoneID $DNSRecordID $DNSRecordName $MYIP $IPV )

    #Show result Update
    ResUpdateShort=$(echo $ResUpdate | grep -E -o "\"success\":[^,]+")
    echo $ResUpdateShort"\n"
    #Update content of file config.ini
    ResUpdateConfig=$(sed -i.backup 's/'$DNSRecordContent'/'$MYIP'/' config.ini)

    #Show content of file config
    cat config.ini
}

StartUpdateDNS
