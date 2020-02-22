ARG JENKINS_TAG

FROM jenkins/jenkins:${JENKINS_TAG}

ARG JENKINS_NUM_OF_EXECUTORS
ARG BATS_TAG
ARG DOCKER_COMPOSE_TAG

USER root
RUN apk --no-cache add bash gettext docker coreutils ncurses perl wget

#Install Bats
RUN wget https://github.com/bats-core/bats-core/archive/$BATS_TAG.tar.gz && tar -zxvf $BATS_TAG.tar.gz \
  && ./bats-core-*/install.sh /usr/local && rm -rf ./bats-core-*

#Install docker-compose
RUN curl -L https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_TAG/run.sh -o /usr/local/bin/docker-compose \ 
  && chmod +x /usr/local/bin/docker-compose
  
#Set Executors  
COPY services/jenkins/templates /var/jenkins/templates
RUN envsubst < /var/jenkins/templates/executors.groovy.template > /usr/share/jenkins/ref/init.groovy.d/executors.groovy

#Add shell scripts
COPY services/jenkins/scripts/sync-plugins.sh /usr/local/bin/sync-plugins.sh
RUN chmod +x /usr/local/bin/sync-plugins.sh && chown jenkins:jenkins /usr/local/bin/sync-plugins.sh \ 
  && dos2unix /usr/local/bin/sync-plugins.sh

COPY services/jenkins/scripts/get-plugins.sh /usr/local/bin/get-plugins.sh
RUN chmod +x /usr/local/bin/get-plugins.sh && chown jenkins:jenkins /usr/local/bin/get-plugins.sh \ 
  && dos2unix /usr/local/bin/get-plugins.sh

#Install Jenkins plugins
RUN echo 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state
COPY services/jenkins/resources/plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
