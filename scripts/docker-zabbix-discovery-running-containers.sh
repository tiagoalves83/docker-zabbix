#!/bin/bash

DATA=""

# Get Running Containers
CONTAINERS=$(docker ps --all --format='{"{#CONTAINERNAME}":"{{.Names}}", "{#CONTAINERID}":"{{.ID}}", "{#CPU_NUM}":"_CPU_NUM_"}' | tr '\n' ',' | sed '$s/,$//'
)

CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)

for (( i=0; i<$CPU_NUM; i++ ))
do
	if [ -n "$DATA"  ];
	then
		DATA="$DATA, "
	fi 
	DATA="$DATA$(echo $CONTAINERS | sed 's/_CPU_NUM_/'"$i"'/g')"
done;

echo '{ "data" : [ '"$DATA"' ] }'
