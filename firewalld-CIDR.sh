#!/bin/bash
zone1=internet
echo -e "Trying to download Cloudflare IP blocks from https://www.cloudflare.com/ips-v4 to cloudflare_ip.txt \n \t \t zone=$zone1"
wget https://www.cloudflare.com/ips-v4 -O ./cloudflare_ip.txt

# counting records in cloudflare loop
cloud_IP_count=`wc -l < cloudflare_ip.txt`
echo "Total Cloudflare IP blocks: $cloud_IP_count"
for (( c=1; c<=cloud_IP_count; c++ ))
do
    curr_pos=`head cloudflare_ip.txt -n $c | tail -n 1`
    echo "Cloudflare NET: $curr_pos";
    echo "Status: ";firewall-cmd --zone=$zone1 --add-source=$curr_pos
done

# getting kyrgyzstan ip blocks
zone2=internet
echo -e "Trying to download Kyrgyzstan IP blocks from ELCAT.KG to kg-nets.txt \n \t \t zone=$zone2"
wget http://ip.elcat.kg/kg-nets.txt -O ./kg-nets.txt

#kyrgyzstan loop
kyrgyz_IP_count=`wc -l < kg-nets.txt`
echo "Total Kyrgyzstan IP's: $kyrgyz_IP_count"
for (( c=1; c<=kyrgyz_IP_count; c++ ))
do
    curr_pos=`head kg-nets.txt -n $c | tail -n 1`
    echo "Kyrgyz NET: $curr_pos";
    echo "Status: ";firewall-cmd --zone=$zone2 --add-source=$curr_pos
done
echo -e "\nDONE!\t\tStatus:"
firewall-cmd --zone=$zone --list-all
echo -e "\nfirewalld reloading 'firewall-cmd -reload'"
#firewall-cmd --runtime-to-permanent
firewall-cmd --reload
