#!/bin/bash


var1=$(docker exec --user root -i nso1 bash -c 'NCS_IPC_PORT=4561 ncs_cli -C -u admin <<< "exit" &> /dev/null ; echo $?')
Data1=$(($var1))
var2=$(docker exec --user root -i nso2 bash -c 'NCS_IPC_PORT=4562 ncs_cli -C -u admin <<< "exit" &> /dev/null ; echo $?')
Data2=$(($var2))
var3=$(docker exec --user root -i nso3 bash -c 'NCS_IPC_PORT=4563 ncs_cli -C -u admin <<< "exit" &> /dev/null ; echo $?')
Data3=$(($var3))
Result=$(($Data1+$Data2+$Data3))

echo "NSO Status: "
echo -ne "NOT READY: NSO1 Status: $var1 / NSO2 Status: $var2 / NSO3 Status: $var3\033[0K\r"


while [ $Result -ne 0 ]
do
var1=$(docker exec --user root -i nso1 bash -c 'NCS_IPC_PORT=4561 ncs_cli -C -u admin <<< "exit" &> /dev/null ; echo $?')
Data1=$(($var1))
var2=$(docker exec --user root -i nso2 bash -c 'NCS_IPC_PORT=4562 ncs_cli -C -u admin <<< "exit" &> /dev/null ; echo $?')
Data2=$(($var2))
var3=$(docker exec --user root -i nso3 bash -c 'NCS_IPC_PORT=4563 ncs_cli -C -u admin <<< "exit" &> /dev/null ; echo $?')
Data3=$(($var3))
Result=$(($Data1+$Data2+$Data3))

echo -ne "NOT READY: NSO1 Status: $var1 / NSO2 Status: $var2 / NSO3 Status: $var3\033[0K\r"
sleep 5
done

#sleep 2
echo -e "READY: NSO1, NSO2 and NSO3 Up\033[0K\r"
