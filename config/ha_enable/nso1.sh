docker exec -i nso1 bash -c 'NCS_IPC_PORT=4561 ncs --reload'

docker exec -i nso1 bash -c 'NCS_IPC_PORT=4561 ncs_cli -C -u admin' << EOF
packages reload
ha-raft create-cluster member [ nso2@10.0.0.2 nso3@10.0.0.3 ]
show ha-raft
exit
EOF
