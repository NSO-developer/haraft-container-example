# Containerized NSO Example - HA RAFT
Example usecase of running HA RAFT with Containerized NSO. This example is modified from the official example in example.ncs - high-availability/raft-cluster

## Useage
The Makefile have the following target  
build:  
Build the container enviorment  

certs:  
Generate certificate for all nodes  

install-certs:  
Move the certifcate to the right place  

NSO-vol/NSO*:  
Set up specific node  

deep_clean:   
deep_clean will call the following target 
clean_log clean_run clean  

clean:  
clean will remove all the docker images  

clean_cert:  
clean all the relevent certification  

clean_run:  
clean the NSO-vol directory

clean_log:  
clean the NSO-log-vol directory  

clean_CDB:  
clean the *.cdb file in NSO-log/run/cdb directory

stop:  
stop all container with docker-compose

start:  
start all container with docker-compose 

compile_packages:  
compile the packages inside the developer conainter  

cli-c_nso1:  
start Cisco style CLI on Leader NSO1  

cli-c_nso2:  
start Cisco style CLI on Seed NSO2  

cli-c_nso3:  
start Cisco style CLI on Member NSO3  

cli-j_nso1:  
start Juniper style CLI on Leader NSO1  

cli-j_nso2:  
start Juniper style CLI on Seed NSO2  

cli-j_nso3:  
start Juniper style CLI on Member NSO3  

## Use Case
1. Copy the development and production image in the images folder
2. Set Python dependency in requirements.txt
3. Set the dependency that need to be installed via yum and dnf in Dockerfile
4. Modify the "VER" and "ARCH" variable in Makefile. "VER" is the Containerized NSO version and "ARCH" is the CPU Architecture. 
5. "make build" to build the enviorment and import the images
6. Start containers and bring up the HA with "make start" 
7. Build the packages in the development images "make compile_packages"
8. Test the packages inside the production images "make cli-c_nso1/nso2" or Juniper CLI "make 
cli-j_nso1/nso2"
9. Check the HARAFT status via "show ha-raft" with "make cli-c_nso1/nso2"
```
$ make cli-c_nso1 
docker exec -it nso1 bash -c 'NCS_IPC_PORT=4561 ncs_cli -C -u admin'

User admin last logged in 2024-05-23T21:40:38.718736+00:00, to 66b15eaced33, from 127.0.0.1 using cli-console 
admin connected from 127.0.0.1 using console on 66b15eaced33
admin@n1# show ha-raft 
ha-raft status role leader
ha-raft status leader nso1@10.0.0.1
ha-raft status member [ nso1@10.0.0.1 nso2@10.0.0.2 nso3@10.0.0.3 ]
ha-raft status connected-node [ nso2@10.0.0.2 nso3@10.0.0.3 ]
ha-raft status local-node nso1@10.0.0.1
ha-raft status certificates certificate 7FB82CBFE1CBBE50DC4A30986C3421656C44FE01
 expiration-date 2034-05-23T21:39:16+00:00
 file-path       /nso/certs/nso1.crt
ha-raft status certificates certificate-authority 2C20A4E8AB44AAD1D26BDD8EC2C2E9B2F21E8960
 expiration-date 2034-05-23T21:39:16+00:00
 file-path       /nso/certs/ca.crt
ha-raft status log current-index 2
ha-raft status log applied-index 2
ha-raft status log num-entries 2
ha-raft status log replications nso2@10.0.0.2
 state in-sync
 index 2
 lag   0
ha-raft status log replications nso3@10.0.0.3
 state in-sync
 index 2
 lag   0
```

### Copyright and License Notice
``` 
Copyright (c) 2024 Cisco and/or its affiliates.

This software is licensed to you under the terms of the Cisco Sample
Code License, Version 1.1 (the "License"). You may obtain a copy of the
License at

               https://developer.cisco.com/docs/licenses

All use of the material herein must be in accordance with the terms of
the License. All rights not expressly granted by the License are
reserved. Unless required by applicable law or agreed to separately in
writing, software distributed under the License is distributed on an "AS
IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
or implied.
``` 