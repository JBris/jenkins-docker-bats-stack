include .env

pull: 
	docker-compose pull

dbuild: 
	docker-compose build

#make up 
#make up s=service
#make up a="-f docker-compose.yml -f docker-compose.override.yml"
up:
	docker-compose $(a) up -d $(s)

down: 
	docker-compose down

start:
	docker-compose $(a) start
	
stop:
	docker-compose $(a) stop

restart:
	docker-compose restart $(s)

ls:
	docker-compose ps 

vol:
	docker volume ls

log:
	docker logs $(PROJECT_NAME)_jenkins
	
#See docker-compose rm
#make rm a="--help"
rm: 
	docker system prune ${a} --all

#Container commands
jenter:
	docker-compose exec jenkins sh $(c)

#make jrun c="echo hello world"
jrun:
	docker-compose run jenkins -c $(c)

init-admin-password:
	docker-compose exec jenkins cat $(JENKINS_HOME)/secrets/initialAdminPassword	

sync-plugins:
	docker-compose exec jenkins sync-plugins.sh

get-plugins:
	docker-compose exec jenkins get-plugins.sh