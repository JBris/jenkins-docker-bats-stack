#!/usr/bin/env bats

load jenkins_helper

@test "Docker is running" {
    docker --help
    [ "$?" -eq 0 ]
}

@test "docker-compose installed" {
    docker-compose --help
    [ "$?" -eq 0 ]
}

@test "Jenkins Home set" {
    ls ${JENKINS_HOME}
    [ "$?" -eq 0 ]
}

@test "Docker Images Pulled" {
    docker-compose pull
    [ "$?" -eq 0 ]
}

@test ".env file doesn't exist" {
    [[ ! -f ${WORKSPACE}/.env ]]
    [ "$?" -eq 0 ]
}

@test "docker-compose file exists" {
    [[ -f ${WORKSPACE}/docker-compose.yml ]]
    [ "$?" -eq 0 ]
}

@test "Docker containers are running" {
    count=$(docker ps | wc -l)
    [ "$count" -gt 0 ]
}

@test "Tagged Jenkins container is running" {
    docker ps | grep jenkins/jenkins:${JENKINS_TAG}
    [ "$?" -eq 0 ]
}

@test "Jenkins project container is running" {
    docker ps | grep ${PROJECT_NAME}_jenkins
    [ "$?" -eq 0 ]
}

@test "Jenkins service is reachable" {
    curl "$JENKINS_SERVICE_HOST"
    [ "$?" -eq 0 ]
}