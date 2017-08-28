#bash

user=""
password=""
target=""
title=""

#085569ce-73ed-11df-83c3-002264764cea  empty #daba56c8-73ec-11df-a475-002264764cea  Full and fast #698f691e-7489-11df-9d8c-002264764cea  Full and fast ultimate #708f25c4-7489-11df-8094-002264764cea  Full and very deep
#74db13d6-7489-11df-91b9-002264764cea  Full and very deep ultimate #2d3f051c-55ba-11e3-bf43-406186ea4fc5  Host Discovery #bbca7412-a950-11e3-9109-406186ea4fc5  System Discovery'

target_id=$(omp -u $user -w $password --xml=\
"<create_target>\
<name>$target</name>\
<hosts>$title</hosts>\
</create_target>" | xmlstarlet sel -t -v /create_target_response/@id)
wait

if [ "$target_id" == "" ]; then

ptaskid=$(omp -u $user -w $password -G | grep -m1 $title | tr -s ' ' | cut -d' ' -f 1)
wait

treport_id=$(omp -u $user -w $password -S $ptaskid)
wait

else

task_id=$(omp -u $user -w $password -X '<create_task><name>'$title'</name><preferences><preference><scanner_name>source_iface</scanner_name><value>eth0</value></preference></preferences><config id="74db13d6-7489-11df-91b9-002264764cea"/><target id="'"$target_id"'"/></create_task>' | xmlstarlet sel -t -v /create_task_response/@id)
wait
result=$(omp -u $user -w $password -G | grep -m1 "'$task_id'" | tr -s ' ' | cut -d' ' -f 2)
wait
report_id=$(omp -u $user -w $password -S $task_id)
wait

fi

while read -r line ; do

pStatus=$(omp -u $user -w $password -G | grep -m1 "'$line'" | tr -s ' ' | cut -d' ' -f 2)
wait

preport_id=$(omp -u $user -w $password -S $pid)
wait


if [ "$pStatus" == "Done" ]; then 

omp -u "$user" -w "$password" --get-report "$preport_id" --format XML > /var/www/openvas/reports-"$pid".xml
wait

elif [ "$result" == "Fail" ]; then

report_id=$(omp -u $user -w $password -S $task_id)
wait

fi

done < <(omp -u $user -w $password -G | grep -m1 "'$line'" | tr -s ' ' | cut -d' ' -f 1)
