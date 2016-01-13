FROM ubuntu:14.04

ENV HOME /root

ENV TERM screen-256color

RUN locale-gen --no-purge en_US.UTF-8
ENV LC_ALL en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

RUN apt-get update -qq

ADD conf/apt-packages.txt /tmp/apt-packages.txt
RUN cat /tmp/apt-packages.txt | xargs apt-get --yes --force-yes install

ADD conf/npm-packages.txt /tmp/npm-packages.txt
RUN cat /tmp/npm-packages.txt | xargs npm install -g

ADD pip-requires.txt /tmp/requirements_requires.txt
RUN pip install -r /tmp/requirements_requires.txt  

ADD pip-freeze.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt  

WORKDIR /code

COPY ./ /code/
RUN cp /code/temba/settings.py.docker /code/temba/settings.py

RUN mkdir -p /var/log/rapidpro

ADD conf/entrypoint.sh /usr/local/bin/entrypoint.sh 
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN mkdir -p /etc/supervisor/conf.d && mkdir -p /var/log/supervisor
RUN ln -sf /code/conf/supervisor.rapidpro.conf /etc/supervisor/conf.d/rapidpro.conf
RUN ln -sf /code/conf/supervisord.conf /etc/supervisor/supervisord.conf
RUN ln -sf /usr/bin/nodejs /usr/bin/node

ADD conf/nginx.rapidpro.conf /etc/nginx/sites-enabled/default

RUN mkdir -p /var/www/static && chmod -R 777 /var/www/static/ && chown -R www-data:www-data /var/www/static

EXPOSE 5000
EXPOSE 8000

ENTRYPOINT ["entrypoint.sh"]
CMD ["start"]
