#!/bin/bash
# Access Database
user=""
psw=""
database=""
query="select assets from request where status ='saved'"
timestamp=$(date +%Y-%m-%d)


OIFS="$IFS" ; IFS=$'\n' ; oset="$-" ; set -f
while IFS="$OIFS" read -a line 
do 

if [[ ${line[0]} == *","* ]]; then

for i in $(echo ${line[0]} | tr "," "\n")
do

scantype="select scantype from request WHERE assets="${line[0]}""
wait

OIFS="$IFS" ; IFS=$'\n' ; oset="$-" ; set -f

while IFS="$OIFS" read -a sc 
do

if [[ ${sc[0]} == "port" ]]; then
############################################################################################################
#NMAP
###########################################################################################################

nmapfolder="/var/log/nmap/reports/"

nmap -T5 -Pn -A -oX "$nmapfolder"report-"$i"-"$timestamp".xml $i
wait
mv "$nmapfolder"report-"$i"-"$timestamp".xml "$nmapfolder"report-"$i"-"$timestamp".xml.done
wait

elif [[ ${sc[0]} == "web" ]]; then
############################################################################################################
#WAPITI
###########################################################################################################
wapitifolder="/var/log/wapiti/reports/"
wapiti -s $i -f xml -o "$wapitifolder"report-"$i"-"$timestamp".xml
wait

mv "$wapitifolder"report-"$i"-"$timestamp".xml "$wapitifolder"report-"$i"-"$timestamp".xml.done
wait

############################################################################################################
#ARACHNI
###########################################################################################################
arachnifolder="/var/log/arachni/reports/"

/opt/arachni/bin/./arachni --output-verbose --scope-include-subdomains $i --report-save-path="$arachnifolder"report-"$i"-"$timestamp".afr
wait

/opt/arachni/bin/./arachni_reporter "$arachnifolder"report-"$i"-"$timestamp".afr --reporter=xml:outfile="$arachnifolder"report-"$i"-"$timestamp".xml
wait

mv "$arachnifolder"report-"$i"-"$timestamp".xml "$arachnifolder"report-"$i"-"$timestamp".xml.done
wait

############################################################################################################
#NIKTO
###########################################################################################################
niktofolder="/var/log/nikto/reports/"

cd /opt/nikto/program/

perl nikto.pl -host $i -Format CSV -output "$niktofolder"report-"$i"-"$timestamp".csv
wait

mv "$niktofolder"report-"$i"-"$timestamp".csv "$niktofolder"report-"$i"-"$timestamp".csv.done
wait

############################################################################################################
#OPENVAS
###########################################################################################################
niktofolder="/var/log/openvas/reports/"

fi

done < <(mysql  -sN -u${user} -p${psw} ${database} -e "${scantype}")
done

fi
done < <(mysql -sN -u${user} -p${psw} ${database} -e "${query}")
