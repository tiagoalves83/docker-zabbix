#!/bin/bash

get_system_cpu_usage() {
	FILE="/sys/fs/cgroup/cpu,cpuacct/cpuacct.usage"
        get_container_info $FILE
}

get_system_cpu_usage_per_cpu() {
        CPU_NUM=$(($1 + 1))
	FILE="/sys/fs/cgroup/cpu,cpuacct/cpuacct.usage_percpu"
        RESULT=$(get_container_info $FILE | cut -d" " -f$CPU_NUM)
	
	if [ -n "$RESULT" ];
        then
		echo $RESULT
        else
		echo "0"
	fi
}


get_container_cpu_usage() {
	CID=$1
	FILE="/sys/fs/cgroup/cpu,cpuacct/system.slice/docker-${CID}*.scope/cpuacct.usage"
        get_container_info $FILE	
}

get_container_cpu_usage_per_cpu() {
        CID=$1
	CPU_NUM=$(($2 + 1))
        FILE="/sys/fs/cgroup/cpu,cpuacct/system.slice/docker-${CID}*.scope/cpuacct.usage_percpu"
        RESULT=$(get_container_info $FILE | cut -d" " -f$CPU_NUM)
	
	if [ -n  "$RESULT" ];
        then
                echo $RESULT
        else
                echo "0"
        fi
}

get_container_cpu_percentage() {
	CID=$1

#	NUM_PROC=$(cat /proc/cpuinfo | grep processor | wc -l)

	SYSTEM_PRE=$(get_system_cpu_usage)
	CONTAINER_PRE=$(get_container_cpu_usage $CID)

	sleep 1

	SYSTEM=$(get_system_cpu_usage)
	CONTAINER=$(get_container_cpu_usage $CID)

	CONTAINER_DELTA=$((CONTAINER-CONTAINER_PRE))
	SYSTEM_DELTA=$((SYSTEM-SYSTEM_PRE))

	if [ "$CONTAINER_DELTA" -gt "0" ] && [ "$SYSTEM_DELTA" -gt "0" ];
	then
		#awk "BEGIN {printf \"%.2f\",${CONTAINER_DELTA}/${SYSTEM_DELTA}*100*${NUM_PROC}}"
		awk "BEGIN {printf \"%.2f\",${CONTAINER_DELTA}/${SYSTEM_DELTA}*100}"
	else
		echo "0"
	fi
}

get_container_cpu_percentage_per_cpu() {
        CID=$1
	CPU_NUM=$2
        
	SYSTEM_PRE=$(get_system_cpu_usage_per_cpu $CPU_NUM)
        CONTAINER_PRE=$(get_container_cpu_usage_per_cpu $CID $CPU_NUM)

        sleep 1

        SYSTEM=$(get_system_cpu_usage_per_cpu $CPU_NUM) 
        CONTAINER=$(get_container_cpu_usage_per_cpu $CID $CPU_NUM)

        CONTAINER_DELTA=$((CONTAINER-CONTAINER_PRE))
        SYSTEM_DELTA=$((SYSTEM-SYSTEM_PRE))

        if [ "$CONTAINER_DELTA" -gt "0" ] && [ "$SYSTEM_DELTA" -gt "0" ];
        then
                awk "BEGIN {printf \"%.2f\",${CONTAINER_DELTA}/${SYSTEM_DELTA}*100}"
        else
                echo "0"
        fi
}

get_container_memory_usage() {
	CID=$1
	FILE=/sys/fs/cgroup/memory/system.slice/docker-${CID}*.scope/memory.usage_in_bytes
        get_container_info $FILE
}

get_container_memory_limit() {
        CID=$1
	FILE=/sys/fs/cgroup/memory/system.slice/docker-${CID}*.scope/memory.limit_in_bytes
	get_container_info $FILE
}

get_container_memory_percentage() {
	CID=$1
	MEMORY_USAGE=$(get_container_memory_usage $CID)
	MEMORY_LIMIT=$(get_container_memory_limit $CID)
	if [ "$MEMORY_USAGE" -gt "0" ] && [ "$MEMORY_LIMIT" -gt "0" ];
        then
        	awk "BEGIN {printf \"%.2f\",${MEMORY_USAGE}/${MEMORY_LIMIT}*100}"
	else
		echo "0"
	fi
}

get_container_info() {
	FILE=$1
	if [ -f $FILE ];
        then
                cat $FILE
        else
                echo "0"
        fi
}

testme() {
	CID=$1
	echo "get_system_cpu_usage:" $(get_system_cpu_usage)
	echo "get_container_cpu_usage:" $(get_container_cpu_usage $CID)
	echo "get_container_cpu_percentage:" $(get_container_cpu_percentage $CID)
	echo "get_container_memory_usage:" $(get_container_memory_usage $CID)
	echo "get_container_memory_limit:" $(get_container_memory_limit $CID)
	echo "get_container_memory_percentage:" $(get_container_memory_percentage $CID)
}


FUNCTION=$1
CID=$2
CPU_NUM=$3

case $FUNCTION in
"system_cpu_usage")
	get_system_cpu_usage	
	;;
"system_cpu_usage_per_cpu")
	CPU_NUM=$CID
	get_system_cpu_usage_per_cpu $CPU_NUM
	;;
"container_cpu_usage")
	get_container_cpu_usage $CID	
	;;
"container_cpu_usage_per_cpu")
        get_container_cpu_usage_per_cpu $CID $CPU_NUM
        ;;
"container_cpu_percentage")
	get_container_cpu_percentage $CID	
	;;
"container_cpu_percentage_per_cpu")
	get_container_cpu_percentage_per_cpu $CID $CPU_NUM
	;;
"container_memory_usage")
	get_container_memory_usage $CID	
	;;
"container_memory_limit")
	get_container_memory_limit $CID	
	;;
"container_memory_percentage")
	get_container_memory_percentage $CID	
	;;
"testme")
	testme $CID
	;;
esac
