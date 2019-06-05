#!/bin/bash
# all changes applied to runtime config in case everything is fucked-up so you can rollback
# uncomment --runtime-to-permanent in last lines to really apply generated configuration if you sure everything is generated as expected

zone1=internet #cloudflare application zone
zone2=internet #kg application zone

# stage 1
# Removing all previous ip source configuration
#
# unfortunately there is no mass source purging mechanism so we are looping shit and spawning processes for every deletion, meeh

function source_remover {
 for removing_source in $@
  do
   firewall-cmd --zone=$last_zone --remove-source=$removing_source
  done
}

sources_zone1=($(firewall-cmd --zone=$zone1 --list-sources))
last_zone=$zone1
echo "Zone 1 sources to be removed count: " ${#sources_zone1[*]}
source_remover ${sources_zone1[@]}

sources_zone2=($(firewall-cmd --zone=$zone2 --list-sources))
last_zone=$zone2
echo "Zone 2 sources to be removed count: " ${#sources_zone2[*]}
source_remover ${sources_zone2[@]}

# stage 2
# Getting cloudflare ip blocks
#
echo -e "Trying to download Cloudflare IP blocks from https://www.cloudflare.com/ips-v4 to cloudflare_ip.txt \n \t \t zone=$zone1"
wget https://www.cloudflare.com/ips-v4 -O ./cloudflare_ip.txt

#
# Getting kyrgyzstan ip blocks
#
echo -e "Trying to download Kyrgyzstan IP blocks from ELCAT.KG to kg-nets.txt \n \t \t zone=$zone2"
wget http://ip.elcat.kg/kg-nets.txt -O ./kg-nets.txt

# stage 3
# Counting Cloudflare records in ip-blocks loop
#
cloud_IP_count=`wc -l < cloudflare_ip.txt`
echo "Total Cloudflare IP blocks: $cloud_IP_count"
for (( c=1; c<=cloud_IP_count; c++ ))
do
    curr_pos=`head cloudflare_ip.txt -n $c | tail -n 1`
    echo "Cloudflare NET: $curr_pos";
    echo "Status: ";firewall-cmd --zone=$zone1 --add-source=$curr_pos
done

# Counting Kyrgyzstan records in ip-blocks loop
kyrgyz_IP_count=`wc -l < kg-nets.txt`
echo "Total Kyrgyzstan IP's: $kyrgyz_IP_count"
for (( c=1; c<=kyrgyz_IP_count; c++ ))
do
    curr_pos=`head kg-nets.txt -n $c | tail -n 1`
    echo "Kyrgyz NET: $curr_pos";
    echo "Status: ";firewall-cmd --zone=$zone2 --add-source=$curr_pos
done

echo -e "\nDONE!\t\tFinal changes:"

firewall-cmd --zone=$zone1 --list-all
firewall-cmd --zone=$zone2 --list-all
echo -e "\n uncomment last lines to actually apply changes"
#firewall-cmd --runtime-to-permanent
#firewall-cmd --reload
