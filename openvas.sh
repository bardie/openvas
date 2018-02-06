while read -r line ; do

id="$(echo $line | cut -d ' ' -f 1)"
status="$(echo $line | cut -d ' ' -f 2)"

#echo "$id"
#echo "$status"

if [ "$status" == "Done" ]; then
if [ ! -f /var/log/openvas/reports/"$id".csv ]; then
omp -u USER -w PASSWORD -f c1645568-627a-11e3-a660-406186ea4fc5 -R "$id" > /var/log/openvas/reports/"$id".csv

else

echo "Scan has not completed"
fi
done < <(omp -u USER -w PASSWORD --get-tasks --details | grep -E '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z')
