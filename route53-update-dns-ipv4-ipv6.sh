#!/usr/bin/env bash

readonly LOG_FILE=${HOME}/route53.log
touch $LOG_FILE
exec 1>>$LOG_FILE
exec 2>&1

RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

loginfo() {
   echo -n;
#    echo -e "[$(date '+%F %R')] ${ORANGE}>${NC} $@"
}

logerr() {
   echo -e "[$(date '+%F %R')] ${RED}x${NC} $@"
   exit 1
}

logok() {
    echo -e "[$(date '+%F %R')] ${GREEN}✔${NC} $@"
}

if [[ $EUID -eq 0 ]]; then
   logerr "This script must not be run as root"
fi

AWS_PROFILE=##############CHANGEME

ROUTE53_JSON=route53-resource-record-set.json
HOSTED_ZONE_ID='##############CHANGEME'
RECORDS=(##############CHANGEME)

LAST_IPV4=$(cat ${ROUTE53_JSON} | jq -r '.Changes[0].ResourceRecordSet.ResourceRecords[].Value')
LAST_IPV6=$(cat ${ROUTE53_JSON} | jq -r '.Changes[1].ResourceRecordSet.ResourceRecords[].Value')

IPV6=$(dig +short -6 myip.opendns.com aaaa @resolver1.ipv6-sandbox.opendns.com +timeout=1)
resp=$?
if [ $resp -eq 0 ]; then loginfo "IPv6 ${IPV6}"; fi
if [ $resp -gt 0 ]; then logerr "errcode ${resp} IPv6 lookup"; fi
IPV4=$(wget -qO- https://checkip.amazonaws.com)
resp=$?
if [ $resp -eq 0 ]; then loginfo "IPv4 ${IPV4}"; fi
if [ $resp -gt 0 ]; then logerr "errcode ${resp} IPv4 lookup"; fi

if [[ "${LAST_IPV4}" == "${IPV4}" ]] && [[ "${LAST_IPV6}" == "${IPV6}" ]] ; then
    logok "$LAST_IPV4 $LAST_IPV6"
    exit 0
fi

cat << EOF > ${ROUTE53_JSON}
{
  "Changes": [
EOF

first=''
for dnsrecord in "${RECORDS[@]}";
do
  cat << EOF >> ${ROUTE53_JSON}
    ${first}{
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "${dnsrecord}",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "${IPV4}"
          }
        ]
      }
    }, {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "${dnsrecord}",
        "Type": "AAAA",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "${IPV6}"
          }
        ]
      }
    }
EOF
    first=','
done

cat << EOF >> ${ROUTE53_JSON}
  ]
}
EOF

CHANGE_ID=$(aws --profile ${AWS_PROFILE} route53 change-resource-record-sets --hosted-zone-id ${HOSTED_ZONE_ID} --change-batch file://${ROUTE53_JSON} --output text --query ChangeInfo.Id)
resp=$?
if [ $resp -eq 0 ]; then logok "aws route53 change-resource-record-sets $IPV4 $IPV6"; fi
if [ $resp -gt 0 ]; then logerr "errcode ${resp} aws route53 change-resource-record-sets"; fi

aws --profile ${AWS_PROFILE} route53 wait resource-record-sets-changed --id "${CHANGE_ID}"
resp=$?
if [ $resp -gt 0 ]; then logerr "errcode ${resp} aws route53 resource-record-sets-changed CHANGE_ID ${CHANGE_ID}"; fi
if [ $resp -eq 0 ]; then exit 0; fi
exit 1
