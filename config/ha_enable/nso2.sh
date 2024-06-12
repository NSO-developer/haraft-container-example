docker exec -i nso2 bash -c 'NCS_IPC_PORT=4562 ncs --reload'

docker exec -i nso2 bash -c 'NCS_IPC_PORT=4562 ncs_cli -C -u admin' << EOF
show ha-raft
exit
EOF   
