VER=6.5
ENABLED_SERVICES=NSO-1 NSO-2 NSO-3
ARCH=x86_64
DESTS=NSO-vol/NSO1 NSO-vol/NSO2 NSO-vol/NSO3

build: certs
	docker load -i ./images/nso-${VER}.container-image-build.linux.${ARCH}.tar.gz
	docker load -i ./images/nso-${VER}.container-image-prod.linux.${ARCH}.tar.gz
	docker build -t mod-nso-prod:${VER}  --no-cache --network=host --build-arg type="prod"  --build-arg ver=${VER}    --file Dockerfile .
	docker build -t mod-nso-build:${VER}  --no-cache --network=host --build-arg type="build"  --build-arg ver=${VER}   --file Dockerfile .
	docker run -d --user root --name nso-prod -e ADMIN_USERNAME=admin -e ADMIN_PASSWORD=admin -e EXTRA_ARGS=--with-package-reload-force -v ./NSO-log-vol/NSO1:/log mod-nso-prod:${VER}
	bash check_nso1_status.sh
	docker exec --user root nso-prod bash -c 'chmod 777 -R /nso/*'
	docker exec --user root nso-prod bash -c 'chmod 777 -R /log/*'
	#docker exec nso-prod chmod 777 -R /nso
	docker exec --user root nso-prod rm -rf /nso/run/cdb
	docker exec --user root nso-prod mkdir /nso/run/cdb
	docker cp nso-prod:/nso/ NSO-vol/
	mv NSO-vol/nso NSO-vol/NSO1
	rm -rf NSO-vol/nso
	$(MAKE) NSO-vol
	$(MAKE) install-certs 
	docker stop nso-prod && docker rm nso-prod
	#cp config/device_conf/nso1.xml NSO-vol/NSO1/run/cdb
	#cp config/device_conf/nso2.xml NSO-vol/NSO2/run/cdb
	#make clean_cdb

certs:
	cp tpl/nso1.in nso1.cnf
	cp tpl/nso2.in nso2.cnf
	cp tpl/nso3.in nso3.cnf
	# creates ca.crt, ca.key, ncsd[1-3].crt and ncsd[1-3].key in raft/
	./gen_tls_certs.sh -d raft nso1 nso2 nso3

install-certs:
	mkdir NSO-vol/NSO1/certs NSO-vol/NSO2/certs NSO-vol/NSO3/certs
	cp -f raft/certs/ca.crt raft/certs/nso1.crt raft/private/nso1.key NSO-vol/NSO1/certs
	cp -f raft/certs/ca.crt raft/certs/nso2.crt raft/private/nso2.key NSO-vol/NSO2/certs
	cp -f raft/certs/ca.crt raft/certs/nso3.crt raft/private/nso3.key NSO-vol/NSO3/certs
	chmod 600 NSO-vol/NSO*/certs/*.key

.PHONY: NSO-vol
NSO-vol:$(DESTS)

.PHONY: NSO-vol/NSO1 NSO-vol/NSO2 NSO-vol/NSO3
$(DESTS):
	echo $@
	-mkdir $@ && cp -R NSO-vol/NSO1/* $@
	cp util/Makefile $@/run/packages/
	cp config/ncs.conf $@/etc/ncs.conf
	cp -R helpers $@
	cp -R tpl $@



deep_clean: clean_log clean_run clean clean_cert

clean: 
	-docker image rm -f cisco-nso-build:${VER}
	-docker image rm -f cisco-nso-prod:${VER}
	-docker image rm -f mod-nso-prod:${VER}  
	-docker image rm -f mod-nso-build:${VER} 
	-docker rm -f  nso-prod

clean_cert:
	rm -f *.cnf
	rm -f raft/certs/*
	rm -f raft/private/*
	rm -f raft/csr/*

clean_run:
	rm -rf ./NSO-vol/* 

clean_log:
	rm -rf ./NSO-log-vol/*/*

clean_cdb:
	rm -f  ./NSO-vol/*/run/cdb/*.cdb


start:
	cp config/ncs.conf NSO-vol/NSO1/etc/ncs.conf
	cp config/ncs.conf NSO-vol/NSO2/etc/ncs.conf
	cp config/ncs.conf NSO-vol/NSO3/etc/ncs.conf
	export VER=${VER} ; docker compose up BUILD-NSO-PKGS -d
	sleep 2
	export VER=${VER} ; docker compose up ${ENABLED_SERVICES} -d
	bash check_status.sh
	docker exec --user root nso1 bash -c 'chmod 777 -R /nso/*'
	docker exec --user root nso1 bash -c 'chmod 777 -R /log/*'
	docker exec --user root nso2 bash -c 'chmod 777 -R /nso/*'
	docker exec --user root nso2 bash -c 'chmod 777 -R /log/*'
	docker exec --user root nso3 bash -c 'chmod 777 -R /nso/*'
	docker exec --user root nso3 bash -c 'chmod 777 -R /log/*'
	cd config/ha_enable; sh nso1.sh
	sleep 5
	cd config/ha_enable; sh nso2.sh
	sleep 5
	cd config/ha_enable; sh nso3.sh

stop:
	export VER=${VER} ;docker compose down BUILD-NSO-PKGS
	export VER=${VER} ;docker compose down  ${ENABLED_SERVICES}
	-docker rm nso-prod -f

compile_packages:
	docker exec -user root -it nso-build make all -C /nso1/run/packages
	docker exec -user root -it nso-build make all -C /nso2/run/packages
	docker exec -user root -it nso-build make all -C /nso3/run/packages



cli-c_nso1:
	docker exec -user root -it nso1 bash -c 'NCS_IPC_PORT=4561 ncs_cli -C -u admin'

cli-c_nso2:
	docker exec -user root -it nso2 bash -c 'NCS_IPC_PORT=4562 ncs_cli -C -u admin'

cli-c_nso3:
	docker exec -user root -it nso3 bash -c 'NCS_IPC_PORT=4563 ncs_cli -C -u admin'

cli-j_nso1:
	docker exec -user root -it nso1 bash -c 'NCS_IPC_PORT=4561 ncs_cli -J -u admin'

cli-j_nso2:
	docker exec -user root -it nso2 bash -c 'NCS_IPC_PORT=4562 ncs_cli -J -u admin'

cli-j_nso3:
	docker exec -user root -it nso3 bash -c 'NCS_IPC_PORT=4563 ncs_cli -J -u admin'
