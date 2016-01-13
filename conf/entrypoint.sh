#!/bin/bash
set -e


# Define help message
show_help() {
    echo """
    Commands
    manage     : Invoke django manage.py commands
    setupdb  : Create empty database for rapidpro, will still need migrations run
    """
}

setup_local_db() {
    set +e
    psql -U $RDS_USERNAME -h $RDS_HOSTNAME template_postgis -c 'CREATE EXTENSION hstore;'
    psql -U $RDS_USERNAME -h $RDS_HOSTNAME template1 -c 'CREATE EXTENSION hstore;'
    psql -U $RDS_USERNAME -h $RDS_HOSTNAME template_postgis -c 'CREATE EXTENSION postgis;'
    psql -U $RDS_USERNAME -h $RDS_HOSTNAME template1 -c 'CREATE EXTENSION postgis;'
    cd /code
    python manage.py sqlcreate | psql -U $RDS_USERNAME -h $RDS_HOSTNAME
    set -e
    python manage.py migrate
}

setup_prod_db() {
    set +e
    PGPASSWORD=$RDS_PASSWORD psql -U $RDS_USERNAME -h $RDS_HOSTNAME $RDS_DB_NAME -c 'CREATE EXTENSION hstore;'
    PGPASSWORD=$RDS_PASSWORD psql -U $RDS_USERNAME -h $RDS_HOSTNAME $RDS_DB_NAME -c 'CREATE EXTENSION postgis;'
    cd /code
    set -e
    python manage.py migrate
}

case "$1" in
    manage )
        cd /code/
        python manage.py "${@:2}"
    ;;
    setuplocaldb )
        setup_local_db
    ;;
    setupproddb )
        setup_prod_db
    ;;
    start )
        cd /code
        python manage.py collectstatic --noinput
        /usr/local/bin/supervisord -c /etc/supervisor/supervisord.conf
        nginx -g "daemon off;"
    ;;
    bash )
        bash
    ;;
    *)
        show_help
    ;;
esac
