[![Coverage Status](https://coveralls.io/repos/github/rapidpro/rapidpro/badge.svg?branch=master)](https://coveralls.io/github/rapidpro/rapidpro?branch=master) 

# RapidPro     

RapidPro is a hosted service for visually building interactive messaging applications.
To learn more, please visit the project site at http://rapidpro.github.io/rapidpro.

### Get Involved

To run RapidPro for development, follow the Quick Start guide at http://rapidpro.github.io/rapidpro/docs/development.

### License

In late 2014, Nyaruka partnered with UNICEF to expand on the capabilities of TextIt and release the source code as RapidPro under the Affero GPL (AGPL) license.

In brief, the Affero license states you can use the RapidPro source for any project free of charge, but that any changes you make to the source code must be available to others. Note that unlike the GPL, the AGPL requires these changes to be made public even if you do not redistribute them. If you host a version of RapidPro, you must make the same source you are hosting available for others.

RapidPro has dual copyright holders of UNICEF and Nyaruka.

The software is provided under AGPL-3.0. Contributions to this project are accepted under the same license.

### Running on Docker

To run current local copy on a docker container

1. Build docker Image Run `docker-compose build`
    In case you experience a timeout error during docker build step `RUN pip install -r /tmp/requirements_docker.txt` or similar `pip` command, you can always add the parameter/switch `--default-timeout=10000` to the `RUN pip install` command in the [Dockerfile](https://docs.docker.com/engine/reference/builder/) file and rerun the `docker-compose` build  command.

    You can concurrently download the needed docker images by running `docker pull` command for the required services
    `docker pull mdillon/postgis` for the rapidpro  postgres database service
    `docker pull rapidproredis` for the rapidpro repis cache service
    `docker pull nginx:alpine` for the rapidpro nginx service
    
    

2. Run needed service, Before starting the rapidpro docker container, Make sure the required services are up, add the `-d` switch to run in background
    `docker-compose up -d nginx` for start the nginx service
    `docker-compose up -d rapidproredis` for start the rapidproredis service
    `docker-compose up -d rapidprodb` for start the rapidprodb service

3. Configure to communicate with local eHA [SET](https://github.com/eHealthAfrica/set) application instance.
    When running local [SET](https://github.com/eHealthAfrica/set) instance, in other to enable to enable the rapidpro docker instance to be able to communicate with the local [SET](https://github.com/eHealthAfrica/set) instance, you have to enable a loopback on your network interface. 

    To acheive this, before starting up the `rapidpro` docker instance run the bash script `sudo ifconfig lo0 alias 192.168.10.10` on your local machine.

    To enable docker reroute requests to your local network interface, you have to configure a host/ip mapping in the docker container box by adding this to your docker configuration file for the docker `rapidpro` and `nginx` services.

    extra_hosts:
        - "set.local:192.168.10.10"

    

    
    


