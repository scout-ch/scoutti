###############################################################################################
# Base
###############################################################################################
FROM node:19 as scoutti-base

RUN mkdir -p /app
WORKDIR /app

RUN mkdir -p /docker

RUN apt-get -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false update
RUN apt-get install dos2unix -y

###############################################################################################
# DEVELOPMENT
###############################################################################################
FROM scoutti-base as scoutti-dev

RUN mkdir -p /docker
COPY ./docker/entrypoint.sh /docker

# required for commits within vscode
RUN apt-get install git gnupg openssh-client -y

RUN chmod +x /docker/entrypoint.sh
RUN dos2unix /docker/entrypoint.sh

# publish app
EXPOSE 3000
ENTRYPOINT [ "/docker/entrypoint.sh" ]

###############################################################################################
# PRODUCTION
###############################################################################################
FROM scoutti-base as scoutti-deploy

# Install app dependencies
COPY . .
RUN npm install
RUN npm run build

COPY ./docker/entrypoint.prod.sh /docker
COPY ./docker/set_env_secrets.sh /docker

RUN chmod +x /docker/entrypoint.prod.sh
RUN chmod +x /docker/set_env_secrets.sh

RUN dos2unix /docker/entrypoint.prod.sh
RUN dos2unix /docker/set_env_secrets.sh

EXPOSE 3000
ENTRYPOINT [ "/docker/entrypoint.prod.sh" ]
