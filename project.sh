#!/bin/bash
clear
      
figlet -c Bad Ip
figlet -f ~/.local/share/fonts/3d.flf "Hello World"

sudo rm ip.txt;

grep -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' projet.log > ip.txt


sudo rm BadIp.txt;
input="ip.txt"
while IFS= read -r line
do
  echo ""
  info=$(curl -Gs https://api.abuseipdb.com/api/v2/check \
  --data-urlencode "ipAddress=$line" \
  -d maxAgeInDays=90 \
  -H "Key: $(cat key.txt)" \
  -H "Accept: application/json"  | jq .) 
  COUNTRY=$(echo $info | jq -r '.data.countryCode')
  DOMAIN=$(echo $info | jq -r '.data.domain')
  ABUSE_SCORE=$(echo $info | jq -r '.data.abuseConfidenceScore')
  LAST_UPDATE=$(echo $info | jq -r '.data.lastReportedAt')
   
  if [ "$ABUSE_SCORE" -gt 25 ]
  then
       echo -e "\e[96mIP Lookup Details:"
       echo "------------------"
      	echo -e "\e[39mBad Ip: \e[91m$line";
  	echo -e "\e[39mABUSE_SCORE: \e[91m$ABUSE_SCORE"%"";
  	echo -e "\e[39mCOUNTRY: $COUNTRY";
  	echo -e "\e[39mDOMAIN: $DOMAIN";
  	echo -e "\e[39mLAST_UPDATE: $LAST_UPDATE";
  	echo $line >> BadIp.txt;
  else
       echo -e "\e[96mIP Lookup Details:"
       echo "------------------"
      	echo -e "\e[39mGood Ip: \e[92m$line";
  	echo -e "\e[39mABUSE_SCORE: \e[32m$ABUSE_SCORE"%"";
  	echo -e "\e[39mCOUNTRY: $COUNTRY";
  	echo -e "\e[39mDOMAIN: $DOMAIN";
  	echo -e "\e[39mLAST_UPDATE: $LAST_UPDATE";	
  fi	
done < "$input"
clear

input="BadIp.txt"
while IFS= read -r line
do
  sudo iptables -A INPUT -s $line -j DROP;
  echo -e "\e[39mIp Blocked: \e[91m$line";
done < "$input"

#send email
echo -e "\e[39mDo you want to send a report to your mail ? [(Y)es/(N)o]"
    read rep

    if [ $rep = "" ] || [ $rep = "Y" ] || [ $rep = "y" ]
      then
        echo "Enter your mail address: "
        read mail
        cat BadIp.txt | sendmail $mail -F "Rapport";    
    fi
   
        
        
