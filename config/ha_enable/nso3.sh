docker exec -i nso3 bash -c 'NCS_IPC_PORT=4563 ncs --reload'

docker exec -i nso3 bash -c 'NCS_IPC_PORT=4563 ncs_cli -C -u admin' << EOF
packages reload
show ha-raft
exit
EOF   
